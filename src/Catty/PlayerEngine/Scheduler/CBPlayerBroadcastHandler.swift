/**
 *  Copyright (C) 2010-2015 The Catrobat Team
 *  (http://developer.catrobat.org/credits)
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *
 *  An additional term exception under section 7 of the GNU Affero
 *  General Public License, version 3, is available at
 *  (http://developer.catrobat.org/license_additional_term)
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU Affero General Public License for more details.
 *
 *  You should have received a copy of the GNU Affero General Public License
 *  along with this program.  If not, see http://www.gnu.org/licenses/.
 */

protocol CBPlayerBroadcastHandlerProtocol : class {
    func setupHandler()
    func tearDownHandler()
    func subscribeBroadcastScriptContext(context: CBBroadcastScriptContext)
    func unsubscribeBroadcastScriptContext(context: CBBroadcastScriptContext)
    func performBroadcastWithMessage(message: String, senderScriptContext: CBScriptContextAbstract, broadcastType: CBBroadcastType)
    func continueContextsWaitingForTerminationOfBroadcastScriptContext(context: CBBroadcastScriptContext)
    func removeWaitingContextDueToRestart(context: CBScriptContextAbstract)
}

final class CBPlayerBroadcastHandler : CBPlayerBroadcastHandlerProtocol {

    // MARK: - Constants
    // specifies max depth limit for self broadcasts running on the same function stack
    let selfBroadcastRecursionMaxDepthLimit = 20

    // MARK: - Properties
    var logger: CBLogger
    let frontend: CBPlayerFrontendProtocol
    let backend: CBPlayerBackendProtocol
    weak var scheduler: CBPlayerSchedulerProtocol?
    private lazy var _broadcastWaitingScriptContextsQueue = [CBScriptContextAbstract:[CBBroadcastScriptContext]]()
    private lazy var _registeredBroadcastScriptContexts = [String:[CBBroadcastScriptContext]]()
    private lazy var _broadcastStartQueueBuffer = [CBBroadcastQueueElement]()
    private lazy var _selfBroadcastCounters = [String:Int]()

    // MARK: - Initializers
    init(logger: CBLogger, frontend: CBPlayerFrontendProtocol, backend: CBPlayerBackendProtocol,
        scheduler: CBPlayerSchedulerProtocol?)
    {
        self.logger = logger
        self.scheduler = scheduler
        self.frontend = frontend
        self.backend = backend
    }

    convenience init(logger: CBLogger, frontend: CBPlayerFrontendProtocol, backend: CBPlayerBackendProtocol) {
        self.init(logger: logger, frontend: frontend, backend: backend, scheduler: nil)
    }

    // MARK: - Operations
    func setupHandler() {
        // setup broadcast start queue handler
        let broadcastQueue = dispatch_queue_create("org.catrobat.broadcastStart.queue", DISPATCH_QUEUE_CONCURRENT)
        dispatch_async(broadcastQueue, { [weak self] in
            while self?.scheduler?.allStartScriptContextsReachedMatureState() == false {
                NSThread.sleepForTimeInterval(0.1)
            }

            // if mature state reached => perform all already enqueued broadcasts
            dispatch_async(dispatch_get_main_queue(), { [weak self] in
                if self?._broadcastStartQueueBuffer.count > 0 {
                    if self?.scheduler?.allStartScriptContextsReachedMatureState() == true {
                        if let broadcastStartQueueBuffer = self?._broadcastStartQueueBuffer {
                            for (message, senderScriptContext, broadcastType) in broadcastStartQueueBuffer {
                                self?.performBroadcastWithMessage(message, senderScriptContext: senderScriptContext, broadcastType: broadcastType)
                            }
                            self?._broadcastStartQueueBuffer.removeAll(keepCapacity: false)
                        }
                    }
                }
            })
        })
        // start all StartScripts
        _broadcastStartQueueBuffer.removeAll()
    }

    func tearDownHandler() {
        _broadcastWaitingScriptContextsQueue.removeAll(keepCapacity: false)
        _registeredBroadcastScriptContexts.removeAll(keepCapacity: false)
        _broadcastStartQueueBuffer.removeAll(keepCapacity: false)
        _selfBroadcastCounters.removeAll(keepCapacity: false)
    }

    func subscribeBroadcastScriptContext(context: CBBroadcastScriptContext) {
        let message = context.broadcastMessage
        if var registeredContexts = _registeredBroadcastScriptContexts[message] {
            assert(contains(registeredContexts, context) == false,
                "FATAL: BroadcastScriptContext already registered!")
            registeredContexts += context
            _registeredBroadcastScriptContexts[message] = registeredContexts

        } else {
            _registeredBroadcastScriptContexts[message] = [context]
        }

        let object = context.broadcastScript.object
        logger.info("Subscribed new CBBroadcastScriptContext of object \(object.name) for message \(message)")
    }

    func unsubscribeBroadcastScriptContext(context: CBBroadcastScriptContext) {
        let message = context.broadcastMessage
        if var registeredContexts = _registeredBroadcastScriptContexts[message] {
            var index = 0
            for registeredContext in registeredContexts {
                if registeredContext === context {
                    registeredContexts.removeAtIndex(index)
                    let object = context.broadcastScript.object
                    logger.info("Unsubscribed CBBroadcastScriptContext of object \(object.name) for message \(message)")
                    return
                }
                ++index
            }
        }
        fatalError("FATAL: Given BroadcastScript is NOT registered!")
    }

    // MARK: - Broadcast Handling
    func performBroadcastWithMessage(message: String, senderScriptContext: CBScriptContextAbstract,
        broadcastType: CBBroadcastType)
    {
        senderScriptContext.state = .RunningMature
        if scheduler?.allStartScriptContextsReachedMatureState() == false {
            logger.info("Enqueuing \(broadcastType.typeName()): \(message)")
            _broadcastStartQueueBuffer += (message, senderScriptContext, broadcastType)
            return
        }

        logger.info("Performing \(broadcastType.typeName()): \(message)")
        var runNextInstructionOfSenderScript = true
        var receivingScriptInitialState : CBScriptState = .Running
        if broadcastType == .BroadcastWait {
            runNextInstructionOfSenderScript = false
            receivingScriptInitialState = .RunningBlocking
            senderScriptContext.state = .Waiting

            // sanity check
            if let _ = _broadcastWaitingScriptContextsQueue[senderScriptContext] {
                logger.warn("Sender script is still running but waiting for BroadcastScripts to finish." +
                            "THIS SHOULD NOT HAPPEN!!")
                _broadcastWaitingScriptContextsQueue[senderScriptContext] = [CBBroadcastScriptContext]()
            }
        }

        var isSelfBroadcast = false
        if let registeredContexts = _registeredBroadcastScriptContexts[message] {
            var waitingForBroadcastScriptContexts = [CBBroadcastScriptContext]()
            for registeredContext in registeredContexts {
                // case broadcastScript == senderScript => restart script
                if registeredContext === senderScriptContext {
                    // end of script reached!! Scripts will be aborted due to self-calling broadcast
                    _performSelfBroadcastForContext(registeredContext)
                    isSelfBroadcast = true
                    receivingScriptInitialState = .Running
                    runNextInstructionOfSenderScript = false // still enqueued next actions are ignored due to restart!
                    continue
                }
                waitingForBroadcastScriptContexts += registeredContext

                // case broadcastScript != senderScript
                if scheduler?.isContextScheduled(registeredContext) == false {
                    // case broadcastScript is not running
                    scheduler?.registerContext(registeredContext)
                    scheduler?.startContext(registeredContext, withInitialState: receivingScriptInitialState)
                } else {
                    // case broadcastScript is running
                    // trigger script to restart
                    scheduler?.restartContext(registeredContext, withInitialState: receivingScriptInitialState)
                }
            }
            // do not wait for broadcastscript if self broadcast == senderScript (never execute further actions of senderScript!)
            if isSelfBroadcast == false {
                _broadcastWaitingScriptContextsQueue[senderScriptContext] = waitingForBroadcastScriptContexts
            }
        } else {
            logger.info("The program does not contain broadcast scripts listening for message: '\(message)'.")
        }
        if (runNextInstructionOfSenderScript) {
            // the script must continue here. upcoming actions are executed!!
            scheduler?.runNextInstructionOfContext(senderScriptContext)
        }
    }

    private func _performSelfBroadcastForContext(context: CBBroadcastScriptContext) {
        // if sender script stopped in the mean while => do NOT restart and abort this broadcast!
        if scheduler?.isContextScheduled(context) == false {
            return;
        }
        let message = context.broadcastMessage
        var counter = 0
        if let counterNumber = _selfBroadcastCounters[message] {
            counter = counterNumber
        }
        if ++counter % selfBroadcastRecursionMaxDepthLimit == 0 { // XXX: DIRTY PERFORMANCE HACK!!
            dispatch_async(dispatch_get_main_queue(), { [weak self] in
                self?.scheduler?.restartContext(context) // restart this self-listening BroadcastScript
            })
        } else {
            scheduler?.restartContext(context)
        }
        _selfBroadcastCounters[message] = counter
        logger.debug("BROADCASTSCRIPT HAS BEEN RESTARTED DUE TO SELF-BROADCAST!!")
    }

    func continueContextsWaitingForTerminationOfBroadcastScriptContext(context: CBBroadcastScriptContext) {
        var waitingContextsToRemove = [CBScriptContextAbstract]()
        for (waitingContext, var runningBroadcastScriptContexts) in _broadcastWaitingScriptContextsQueue {
            var index = 0
            var found = false
            for runningBroadcastScriptContext in runningBroadcastScriptContexts {
                if runningBroadcastScriptContext == context {
                    runningBroadcastScriptContexts.removeAtIndex(index)
                    found = true
                    break
                }
                ++index
            }
            if found && runningBroadcastScriptContexts.count == 0 {
                // schedule next instruction!
                dispatch_async(dispatch_get_main_queue(), { [weak self] in
//                    assert(waitingContext.state == .Waiting) // just to ensure
                    waitingContext.state = .Running // running again!
                    self?.scheduler?.runNextInstructionOfContext(waitingContext)
                })
                waitingContextsToRemove += waitingContext
            }
            _broadcastWaitingScriptContextsQueue[waitingContext] = runningBroadcastScriptContexts
            assert(_broadcastWaitingScriptContextsQueue[waitingContext]!.count == runningBroadcastScriptContexts.count)
        }
        for waitingContext in waitingContextsToRemove {
            _broadcastWaitingScriptContextsQueue.removeValueForKey(waitingContext)
        }
    }

    func removeWaitingContextDueToRestart(context: CBScriptContextAbstract) {
        _broadcastWaitingScriptContextsQueue.removeValueForKey(context)
    }
}
