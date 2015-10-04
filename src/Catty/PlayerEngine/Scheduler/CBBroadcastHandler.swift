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

final class CBBroadcastHandler: CBBroadcastHandlerProtocol {

    // MARK: - Properties
    var logger: CBLogger
    weak var scheduler: CBSchedulerProtocol?
    private lazy var _broadcastWaitingContexts = [String:CBScriptContextProtocol]()
    private lazy var _broadcastWaitingContextsQueue = [String:[CBBroadcastScriptContextProtocol]]()
    private lazy var _registeredBroadcastContexts = [String:[CBBroadcastScriptContextProtocol]]()
    private lazy var _selfBroadcastCounters = [String:Int]()

    // MARK: - Initializers
    init(logger: CBLogger, scheduler: CBSchedulerProtocol?) {
        self.logger = logger
        self.scheduler = scheduler
    }

    convenience init(logger: CBLogger) {
        self.init(logger: logger, scheduler: nil)
    }

    // MARK: - Operations
    func setup() {}

    func tearDown() {
        _broadcastWaitingContexts.removeAll()
        _broadcastWaitingContextsQueue.removeAll()
        _registeredBroadcastContexts.removeAll()
        _selfBroadcastCounters.removeAll()
    }

    func subscribeBroadcastContext(context: CBBroadcastScriptContextProtocol) {
        let message = context.broadcastMessage
        if var registeredContexts = _registeredBroadcastContexts[message] {
            assert(!registeredContexts.contains(context), "FATAL: BroadcastContext already registered!")
            registeredContexts += context
            _registeredBroadcastContexts[message] = registeredContexts

        } else {
            _registeredBroadcastContexts[message] = [context]
        }
        logger.info("Subscribed new CBBroadcastContext of object "
            + "\(context.script.object!.name) for message \(message)")
    }

    func unsubscribeBroadcastContext(context: CBBroadcastScriptContextProtocol) {
        let message = context.broadcastMessage
        if var registeredContexts = _registeredBroadcastContexts[message] {
            var index = 0
            for registeredContext in registeredContexts {
                if registeredContext === context {
                    registeredContexts.removeAtIndex(index)
                    let object = context.script.object
                    logger.info("Unsubscribed CBBroadcastContext of object \(object!.name) for message \(message)")
                    return
                }
                ++index
            }
        }
        fatalError("FATAL: Given BroadcastScript is NOT registered!")
    }

    // MARK: - Broadcast Handling
    func performBroadcastWithMessage(message: String, senderContext: CBScriptContextProtocol,
        broadcastType: CBBroadcastType)
    {
        logger.info("Performing \(broadcastType.rawValue) with message '\(message)'")
        let enqueuedWaitingScripts = _broadcastWaitingContextsQueue[senderContext.id]
        assert(enqueuedWaitingScripts == nil || enqueuedWaitingScripts?.count == 0)

        var isSelfBroadcast = false
        let registeredContexts = _registeredBroadcastContexts[message]
        if registeredContexts == nil || registeredContexts?.count == 0 {
            logger.info("No listeners for message '\(message)' found")
            scheduler?.runNextInstructionOfContext(senderContext)
            return
        }

        // collect all broadcast recipients
        var recipientContexts = [CBBroadcastScriptContextProtocol]()
        for registeredContext in registeredContexts! {
            // case broadcastScript == senderScript => restart script
            if registeredContext === senderContext {
                // end of script reached!! Script will be aborted due to self-calling broadcast
                isSelfBroadcast = true
                // stop own script (sender script!)
                scheduler?.stopContext(registeredContext, continueWaitingBroadcastSenders: true)
                continue
            }

            // case broadcastScript != senderScript (=> other broadcastscript)
            if scheduler?.isContextScheduled(registeredContext) == true {
                // case broadcastScript is running => stop it
                scheduler?.stopContext(registeredContext, continueWaitingBroadcastSenders: true)
            }
            recipientContexts += registeredContext // collect other (!) broadcastScript
        }

        if !isSelfBroadcast && broadcastType == .BroadcastWait {
            // do not wait for broadcast script if self broadcast == senderScript
            // => do not execute further actions of senderScript!
            senderContext.state = .Waiting
            _broadcastWaitingContextsQueue[senderContext.id] = recipientContexts
            _broadcastWaitingContexts[senderContext.id] = senderContext
        }

        // finally schedule all other (!) (collected) listening broadcast scripts
        for recipientContext in recipientContexts {
            scheduler?.scheduleContext(recipientContext)
        }

        if isSelfBroadcast {
            // launch self (!) listening broadcast script
            _performSelfBroadcastForContext(senderContext as! CBBroadcastScriptContext)
        } else if broadcastType == .Broadcast {
            scheduler?.runNextInstructionOfContext(senderContext)
        } else if broadcastType == .BroadcastWait {
            scheduler?.runNextInstructionsGroup()
        }
    }

    private func _performSelfBroadcastForContext(context: CBBroadcastScriptContextProtocol) {
        let message = context.broadcastMessage
        var counter = 0
        if let counterNumber = _selfBroadcastCounters[message] {
            counter = counterNumber
        }
        if ++counter % PlayerConfig.MaxRecursionLimitOfSelfBroadcasts == 0 { // XXX: DIRTY PERFORMANCE HACK!!
            dispatch_async(dispatch_get_main_queue(), { [weak self] in
                // restart this self-listening BroadcastScript
                self?.scheduler?.forceStopContext(context)
                self?.scheduler?.scheduleContext(context)
                self?.scheduler?.runNextInstructionsGroup()
            })
        } else {
            scheduler?.forceStopContext(context)
            scheduler?.scheduleContext(context)
            scheduler?.runNextInstructionsGroup()
        }
        _selfBroadcastCounters[message] = counter
        logger.debug("BROADCASTSCRIPT HAS BEEN RESTARTED DUE TO SELF-BROADCAST!!")
    }

    func wakeUpContextsWaitingForTerminationOfBroadcastContext(context: CBBroadcastScriptContextProtocol) {
        var waitingContextToBeContinued: CBScriptContextProtocol? = nil
        for (waitingContextID, var runningBroadcastContexts) in _broadcastWaitingContextsQueue {
            assert(waitingContextID != context.id)
            let waitingContext = _broadcastWaitingContexts[waitingContextID]!
            if let index = runningBroadcastContexts.indexOfElement(context) {
                runningBroadcastContexts.removeAtIndex(index)
                _broadcastWaitingContextsQueue[waitingContextID] = runningBroadcastContexts
                assert(_broadcastWaitingContextsQueue[waitingContextID]!.count == runningBroadcastContexts.count)

                // check if current broadcast script context is the last!
                if runningBroadcastContexts.isEmpty {
                    waitingContextToBeContinued = waitingContext
                }
                break
            }
        }

        guard let waitingContext = waitingContextToBeContinued else { return }

        _broadcastWaitingContextsQueue.removeValueForKey(waitingContext.id)
        _broadcastWaitingContexts.removeValueForKey(waitingContext.id)
        assert(waitingContext.state == .Waiting) // just to ensure
        dispatch_async(dispatch_get_main_queue(), { [weak self] in
            assert(waitingContext.state == .Waiting) // just to ensure
            waitingContext.state = .Runnable // running again!
            self?.scheduler?.runNextInstructionOfContext(waitingContext)
        })
    }

    func isWaitingForCalledBroadcastContexts(context: CBScriptContextProtocol) -> Bool {
        return _broadcastWaitingContextsQueue[context.id]?.count > 0
    }

    func terminateAllCalledBroadcastContextsAndRemoveWaitingContext(context: CBScriptContextProtocol) {
        if let broadcastContexts = _broadcastWaitingContextsQueue[context.id] {
            for broadcastContext in broadcastContexts {
                scheduler?.forceStopContext(broadcastContext)
            }
            _broadcastWaitingContexts.removeValueForKey(context.id)
            _broadcastWaitingContextsQueue.removeValueForKey(context.id)
        }
    }

}
