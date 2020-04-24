/**
 *  Copyright (C) 2010-2020 The Catrobat Team
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
    private lazy var _broadcastWaitingContexts = [String: CBScriptContextProtocol]()
    private lazy var _broadcastWaitingContextsQueue = [String: [CBBroadcastScriptContextProtocol]]()
    private lazy var _registeredBroadcastContexts = [String: [CBBroadcastScriptContextProtocol]]()
    private lazy var _selfBroadcastCounters = [String: Int]()

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

    func subscribeBroadcastContext(_ context: CBBroadcastScriptContextProtocol) {
        let message = context.broadcastMessage
        if var registeredContexts = _registeredBroadcastContexts[message] {
            assert(!registeredContexts.contains(context), "FATAL: BroadcastContext already registered!")
            registeredContexts += context
            _registeredBroadcastContexts[message] = registeredContexts

        } else {
            _registeredBroadcastContexts[message] = [context]
        }
        logger.info("Subscribed new CBBroadcastContext of object "
            + "\(context.script.object?.name ?? "<no name>") for message \(message)")
    }

    func unsubscribeBroadcastContext(_ context: CBBroadcastScriptContextProtocol) {
        let message = context.broadcastMessage
        if var registeredContexts = _registeredBroadcastContexts[message] {
            var index = 0
            for registeredContext in registeredContexts {
                if registeredContext === context {
                    registeredContexts.remove(at: index)
                    let object = context.script.object
                    logger.info("Unsubscribed CBBroadcastContext of object \(object?.name ?? "<no name>") for message \(message)")
                    return
                }
                index += 1
            }
        }
        fatalError("FATAL: Given BroadcastScript is NOT registered!")
    }

    // MARK: - Broadcast Handling
    func performBroadcastWithMessage(_ message: String, senderContext: CBScriptContextProtocol,
                                     broadcastType: CBBroadcastType) {
        logger.info("Performing \(broadcastType.rawValue) with message '\(message)'")
        let enqueuedWaitingScripts = _broadcastWaitingContextsQueue[senderContext.id]
        assert(enqueuedWaitingScripts == nil || enqueuedWaitingScripts!.isEmpty)

        var isSelfBroadcast = false
        guard let registeredContexts = _registeredBroadcastContexts[message], !registeredContexts.isEmpty else {
            logger.info("No listeners for message '\(message)' found")
            scheduler?.runNextInstructionOfContext(senderContext)
            return
        }

        // collect all broadcast recipients
        var recipientContexts = [CBBroadcastScriptContextProtocol]()
        for registeredContext in registeredContexts {
            // case broadcastScript == senderScript => restart script
            if registeredContext === senderContext {
                // end of script reached!! Script will be aborted due to self-calling broadcast
                isSelfBroadcast = true
                // stop own script (sender script!)
                scheduler?.stopContext(registeredContext, continueWaitingBroadcastSenders: true)
                continue
            }

            // case broadcastScript != senderScript (=> other broadcastscript)
            recipientContexts += registeredContext // collect other (!) broadcastScript
        }

        if !isSelfBroadcast && broadcastType == .BroadcastWait {
            // do not wait for broadcast script if self broadcast == senderScript
            // => do not execute further actions of senderScript!
            senderContext.state = .waiting
            _broadcastWaitingContextsQueue[senderContext.id] = recipientContexts
            _broadcastWaitingContexts[senderContext.id] = senderContext
        }

        // finally schedule all other (!) (collected) listening broadcast scripts
        scheduler?.startBroadcastContexts(recipientContexts)

        if isSelfBroadcast, let broadcastScriptContext = senderContext as? CBBroadcastScriptContext {
            // launch self (!) listening broadcast script
            _performSelfBroadcastForContext(broadcastScriptContext)
        } else if broadcastType == .Broadcast {
            scheduler?.runNextInstructionOfContext(senderContext)
        } else if broadcastType == .BroadcastWait {
            scheduler?.runNextInstructionsGroup()
        }
    }

    private func _performSelfBroadcastForContext(_ context: CBBroadcastScriptContextProtocol) {
        let message = context.broadcastMessage
        var counter = 0
        if let counterNumber = _selfBroadcastCounters[message] {
            counter = counterNumber
        }
        counter += 1
        DispatchQueue.main.async(execute: { [weak self] in
            // restart this self-listening BroadcastScript
            self?.scheduler?.scheduleContext(context)
            self?.scheduler?.runNextInstructionsGroup()
        })
        _selfBroadcastCounters[message] = counter
        logger.debug("BROADCASTSCRIPT HAS BEEN RESTARTED DUE TO SELF-BROADCAST!!")
    }

    func wakeUpContextsWaitingForTerminationOfBroadcastContext(_ context: CBBroadcastScriptContextProtocol) {
        var waitingContextToBeContinued: CBScriptContextProtocol?
        for (waitingContextID, var runningBroadcastContexts) in _broadcastWaitingContextsQueue {
            assert(waitingContextID != context.id)
            if let waitingContext = _broadcastWaitingContexts[waitingContextID], let index = runningBroadcastContexts.indexOfElement(context) {
                runningBroadcastContexts.remove(at: index)
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

        _broadcastWaitingContextsQueue.removeValue(forKey: waitingContext.id)
        _broadcastWaitingContexts.removeValue(forKey: waitingContext.id)
        assert(waitingContext.state == .waiting) // just to ensure
        DispatchQueue.main.async { [weak self] in
            assert(waitingContext.state == .waiting) // just to ensure
            waitingContext.state = .runnable // running again!
            self?.scheduler?.runNextInstructionOfContext(waitingContext)
        }
    }

    func isWaitingForCalledBroadcastContexts(_ context: CBScriptContextProtocol) -> Bool {
        (_broadcastWaitingContextsQueue[context.id]?.count ?? 0) > 0
    }

    func terminateAllCalledBroadcastContextsAndRemoveWaitingContext(_ context: CBScriptContextProtocol) {
        if let broadcastContexts = _broadcastWaitingContextsQueue[context.id] {
            _broadcastWaitingContexts.removeValue(forKey: context.id)
            _broadcastWaitingContextsQueue.removeValue(forKey: context.id)
            for broadcastContext in broadcastContexts {
                scheduler?.stopContext(broadcastContext, continueWaitingBroadcastSenders: false)
            }
        }
    }

}
