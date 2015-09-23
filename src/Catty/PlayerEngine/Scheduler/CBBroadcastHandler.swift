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

final class CBBroadcastHandler : CBBroadcastHandlerProtocol {

    // MARK: - Constants
    // specifies max depth limit for self broadcasts running on the same function stack
    let selfBroadcastRecursionMaxDepthLimit = 30

    // MARK: - Properties
    var logger: CBLogger
    weak var scheduler: CBSchedulerProtocol?
    private lazy var _broadcastWaitingScriptContextsQueue = [CBScriptContextAbstract:[CBBroadcastScriptContext]]()
    private lazy var _registeredBroadcastScriptContexts = [String:[CBBroadcastScriptContext]]()
    private lazy var _broadcastStartQueueBuffer = [CBBroadcastQueueElement]()
    private lazy var _selfBroadcastCounters = [String:Int]()

    // MARK: - Initializers
    init(logger: CBLogger, scheduler: CBSchedulerProtocol?)
    {
        self.logger = logger
        self.scheduler = scheduler
    }

    convenience init(logger: CBLogger) {
        self.init(logger: logger, scheduler: nil)
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
            assert(registeredContexts.contains(context) == false, "FATAL: BroadcastScriptContext already registered!")
            registeredContexts += context
            _registeredBroadcastScriptContexts[message] = registeredContexts

        } else {
            _registeredBroadcastScriptContexts[message] = [context]
        }

        let object = context.broadcastScript.object
        logger.info("Subscribed new CBBroadcastScriptContext of object \(object!.name) for message \(message)")
    }

    func unsubscribeBroadcastScriptContext(context: CBBroadcastScriptContext) {
        let message = context.broadcastMessage
        if var registeredContexts = _registeredBroadcastScriptContexts[message] {
            var index = 0
            for registeredContext in registeredContexts {
                if registeredContext === context {
                    registeredContexts.removeAtIndex(index)
                    let object = context.broadcastScript.object
                    logger.info("Unsubscribed CBBroadcastScriptContext of object \(object!.name) for message \(message)")
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
        senderScriptContext.state = .Waiting
        if scheduler?.allStartScriptContextsReachedMatureState() == false {
            logger.info("Enqueuing \(broadcastType.typeName()): \(message)")
            _broadcastStartQueueBuffer += (message, senderScriptContext, broadcastType)
            return
        }
        senderScriptContext.state = .RunningMature

        logger.info("Performing \(broadcastType.typeName()): \(message)")
        let enqueuedWaitingScripts = _broadcastWaitingScriptContextsQueue[senderScriptContext]
        assert(enqueuedWaitingScripts == nil || enqueuedWaitingScripts?.count == 0) // sanity check

        var isSelfBroadcast = false
        let registeredContexts = _registeredBroadcastScriptContexts[message]

        if registeredContexts == nil || registeredContexts?.count == 0 {
            logger.info("No broadcast scripts subscribed for message: '\(message)'.")
            scheduler?.runNextInstructionOfContext(senderScriptContext) // continue sender script as usual
            return
        }

        // collect all broadcast recipients
        var recipientContexts = [CBBroadcastScriptContext]()
        for registeredContext in registeredContexts! {
            // case broadcastScript == senderScript => restart script
            if registeredContext === senderScriptContext {
                // end of script reached!! Script will be aborted due to self-calling broadcast
                isSelfBroadcast = true
                scheduler?.stopContext(registeredContext) // stop own script (sender script!)
                continue
            }

            // case broadcastScript != senderScript (=> other broadcastscript)
            if scheduler?.isContextScheduled(registeredContext) == true {
                scheduler?.stopContext(registeredContext) // case broadcastScript is running => stop it
            }
            recipientContexts += registeredContext // collect other (!) broadcastScript
        }

        var recipientsInitialState: CBScriptState = .Running
        if isSelfBroadcast == false && broadcastType == .BroadcastWait {
            // do not wait for broadcastscript if self broadcast == senderScript
            // => do not execute further actions of senderScript!
            senderScriptContext.state = .Waiting
            recipientsInitialState = .RunningBlocking
            _broadcastWaitingScriptContextsQueue[senderScriptContext] = recipientContexts
        }

        // launch self (!) listening broadcast script
        if isSelfBroadcast {
            _performSelfBroadcastForContext(senderScriptContext as! CBBroadcastScriptContext)
        }

        // finally launch all other (!) (collected) listening broadcast scripts
        for recipientContext in recipientContexts {
            scheduler?.startContext(recipientContext, withInitialState: recipientsInitialState)
        }

        if isSelfBroadcast == false && broadcastType == .Broadcast {
            // the script must continue here. upcoming actions are executed!!
            scheduler?.runNextInstructionOfContext(senderScriptContext)
        }
    }

    private func _performSelfBroadcastForContext(context: CBBroadcastScriptContext) {
        let message = context.broadcastMessage
        var counter = 0
        if let counterNumber = _selfBroadcastCounters[message] {
            counter = counterNumber
        }
        if ++counter % selfBroadcastRecursionMaxDepthLimit == 0 { // XXX: DIRTY PERFORMANCE HACK!!
            dispatch_async(dispatch_get_main_queue(), { [weak self] in
                self?.scheduler?.startContext(context) // restart this self-listening BroadcastScript
            })
        } else {
            scheduler?.startContext(context)
        }
        _selfBroadcastCounters[message] = counter
        logger.debug("BROADCASTSCRIPT HAS BEEN RESTARTED DUE TO SELF-BROADCAST!!")
    }

    func continueContextsWaitingForTerminationOfBroadcastScriptContext(context: CBBroadcastScriptContext) {
        var waitingContextsToBeContinued = [CBScriptContextAbstract]()
        for (waitingContext, var runningBroadcastScriptContexts) in _broadcastWaitingScriptContextsQueue {
            assert(waitingContext != context)
            runningBroadcastScriptContexts.removeObject(context)
            if runningBroadcastScriptContexts.isEmpty {
                waitingContextsToBeContinued += waitingContext
            }
            _broadcastWaitingScriptContextsQueue[waitingContext] = runningBroadcastScriptContexts
            assert(_broadcastWaitingScriptContextsQueue[waitingContext]!.count == runningBroadcastScriptContexts.count)
        }
        for waitingContext in waitingContextsToBeContinued {
            // finally remove waitingContext from dictionary
            _broadcastWaitingScriptContextsQueue.removeValueForKey(waitingContext)
            // schedule next instruction!
            assert(waitingContext.state == .Waiting) // just to ensure
            dispatch_async(dispatch_get_main_queue(), { [weak self] in
                assert(waitingContext.state == .Waiting) // just to ensure
                waitingContext.state = .Running // running again!
                self?.scheduler?.runNextInstructionOfContext(waitingContext)
            })
        }
    }

    func removeWaitingContext(context: CBScriptContextAbstract) {
        _broadcastWaitingScriptContextsQueue.removeValueForKey(context)
    }
}
