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

@objc protocol CBPlayerBroadcastHandlerProtocol {
    func setupHandler()
    func subscribeBroadcastScript(broadcastScript: BroadcastScript, forMessage message: String)
    func unsubscribeBroadcastScript(broadcastScript: BroadcastScript, forMessage message: String)
    func performBroadcastWithMessage(message: String, senderScript:Script, broadcastType: CBBroadcastType)
    func continueForBroadcastScriptTerminationWaitingScripts(#broadcastScript: BroadcastScript)
    func removeWaitingScriptDueToRestart(script: Script)
}

final class CBPlayerBroadcastHandler : NSObject, CBPlayerBroadcastHandlerProtocol {

    // MARK: - Constants
    // specifies max depth limit for self broadcasts running on the same function stack
    let selfBroadcastRecursionMaxDepthLimit = 20

    // MARK: - Properties
    var logger : CBLogger
    let frontend : CBPlayerFrontendProtocol
    let backend : CBPlayerBackendProtocol
    weak var scheduler : CBPlayerSchedulerProtocol?
    private(set) lazy var broadcastWaitingScriptsQueue = [Script:[BroadcastScript]]()
    private lazy var _registeredBroadcastScripts = [String:[BroadcastScript]]()
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
            while self?._allStartScriptsReachedMatureState() == false {
                NSThread.sleepForTimeInterval(0.1)
            }

            // if mature state reached => perform all already enqueued broadcasts
            dispatch_async(dispatch_get_main_queue(), { [weak self] in
                if self?._broadcastStartQueueBuffer.count > 0 {
                    if self?._allStartScriptsReachedMatureState() == true {
                        if let broadcastStartQueueBuffer = self?._broadcastStartQueueBuffer {
                            for (message, senderScript, broadcastType) in broadcastStartQueueBuffer {
                                self?.performBroadcastWithMessage(message, senderScript: senderScript, broadcastType: broadcastType)
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

    func subscribeBroadcastScript(broadcastScript: BroadcastScript, forMessage message: String) {
        if var broadcastScripts = _registeredBroadcastScripts[message] {
            assert(contains(broadcastScripts, broadcastScript) == false, "FATAL: BroadcastScript already registered!")
            broadcastScripts += broadcastScript
            _registeredBroadcastScripts[message] = broadcastScripts
        } else {
            _registeredBroadcastScripts[message] = [broadcastScript]
        }
        logger.info("Subscribed new BroadcastScript of object \(broadcastScript.object.name) " +
                    "for message \(message)")
    }

    func unsubscribeBroadcastScript(broadcastScript: BroadcastScript, forMessage message: String) {
        if var broadcastScripts = _registeredBroadcastScripts[message] {
            var index = 0
            for script in broadcastScripts {
                if script === broadcastScript {
                    broadcastScripts.removeAtIndex(index)
                    logger.info("Unsubscribed BroadcastScript of object \(broadcastScript.object.name) " +
                                "for message \(message)")
                    return
                }
                ++index
            }
        }
        fatalError("FATAL: Given BroadcastScript is NOT registered!")
    }

    // MARK: - Broadcast Handling
    private func _allStartScriptsReachedMatureState() -> Bool {
        if let scriptExecContextDict = scheduler?.scriptExecContextDict {
            for (script, scriptExecContext) in scriptExecContextDict {
                if CBScriptType.scriptTypeOfScript(script) == .Start {
                    if (scriptExecContext.state != .RunningMature) && (scriptExecContext.state != .Dead) {
                        logger.debug("StartScript (of object:\(script.object.name), #bricks:" +
                                     "\(script.brickList.count)) NOT MATURE!!")
                        return false
                    }
                }
            }
            return true
        }
        return false
    }

    func performBroadcastWithMessage(message: String, senderScript:Script, broadcastType: CBBroadcastType) {
        if let senderScriptExecContext = scheduler?.scriptExecContextDict[senderScript] {
            senderScriptExecContext.state = .RunningMature
        }
        if _allStartScriptsReachedMatureState() == false {
            logger.info("Enqueuing \(broadcastType.rawValue): \(message)")
            _broadcastStartQueueBuffer += (message, senderScript, broadcastType)
            return
        }

        logger.info("Performing \(broadcastType.rawValue): \(message)")
        var runNextInstructionOfSenderScript = true
        var receivingScriptInitialState : CBScriptState = .Running
        if broadcastType == .BroadcastWait {
            runNextInstructionOfSenderScript = false
            receivingScriptInitialState = .RunningBlocking
            scheduler?.setStateForScript(senderScript, state: .Waiting)

            // sanity check
            if let _ = broadcastWaitingScriptsQueue[senderScript] {
                logger.warn("Sender script is still running but waiting for BroadcastScripts to finish." +
                            "THIS SHOULD NOT HAPPEN!!")
                broadcastWaitingScriptsQueue[senderScript] = [BroadcastScript]()
            }
        }

        var isSelfBroadcast = false
        if let broadcastScripts = _registeredBroadcastScripts[message] {
            var waitingForBroadcastScripts = [BroadcastScript]()
            for broadcastScript in broadcastScripts {
                // case broadcastScript == senderScript => restart script
                if broadcastScript === senderScript {
                    // end of script reached!! Scripts will be aborted due to self-calling broadcast
                    _performSelfBroadcastWithMessage(message, broadcastScript: broadcastScript)
                    isSelfBroadcast = true
                    receivingScriptInitialState = .Running
                    runNextInstructionOfSenderScript = false // still enqueued next actions are ignored due to restart!
                    continue
                }
                waitingForBroadcastScripts += broadcastScript

                // case broadcastScript != senderScript
                if scheduler?.isScriptScheduled(broadcastScript) == false {
                    // case broadcastScript is not running
                    let sequenceList = frontend.computeSequenceListForScript(broadcastScript)
                    if let senderScriptExecContext = scheduler?.scriptExecContextDict[senderScript],
                       let scene = senderScriptExecContext.scene,
                       let spriteNode = CBSpriteNode.spriteNodeWithName(broadcastScript.object.name, inScene: scene)
                    {
                        scheduler?.addScriptExecContext(backend.executionContextForScriptSequenceList(sequenceList, spriteNode: spriteNode))
                        scheduler?.startScript(broadcastScript, withInitialState: receivingScriptInitialState)
                    }
                } else {
                    // case broadcastScript is running
                    // trigger script to restart
                    scheduler?.restartScript(broadcastScript, withInitialState: receivingScriptInitialState)
                }
            }
            // do not wait for broadcastscript if self broadcast == senderScript (never execute further actions of senderScript!)
            if isSelfBroadcast == false {
                broadcastWaitingScriptsQueue[senderScript] = waitingForBroadcastScripts
            }
        } else {
            logger.info("The program does not contain broadcast scripts listening for message: '\(message)'.")
        }
        if (runNextInstructionOfSenderScript) {
            // the script must continue here. upcoming actions are executed!!
            scheduler?.runNextInstructionOfScript(senderScript)
        }
    }

    private func _performSelfBroadcastWithMessage(message: String, broadcastScript: BroadcastScript) {
        // if sender script stopped in the mean while => do NOT restart and abort this broadcast!
        if scheduler?.isScriptScheduled(broadcastScript) == false {
            return;
        }
        var counter = 0
        if let counterNumber = _selfBroadcastCounters[message] {
            counter = counterNumber
        }
        if ++counter % selfBroadcastRecursionMaxDepthLimit == 0 { // XXX: DIRTY PERFORMANCE HACK!!
            dispatch_async(dispatch_get_main_queue(), { [weak self] in
                self?.scheduler?.restartScript(broadcastScript) // restart this self-listening BroadcastScript
            })
        } else {
            scheduler?.restartScript(broadcastScript)
        }
        _selfBroadcastCounters[message] = counter
        logger.debug("BROADCASTSCRIPT HAS BEEN RESTARTED DUE TO SELF-BROADCAST!!")
    }

    func continueForBroadcastScriptTerminationWaitingScripts(#broadcastScript: BroadcastScript) {
        var waitingScriptsToRemove = [Script]()
        for (waitingScript, var runningBroadcastScripts) in broadcastWaitingScriptsQueue {
            var index = 0
            var found = false
            for runningBroadcastScript in runningBroadcastScripts {
                if runningBroadcastScript == broadcastScript {
                    runningBroadcastScripts.removeAtIndex(index)
                    found = true
                    break
                }
                ++index
            }
            if found && runningBroadcastScripts.count == 0 {
                // schedule next instruction!
                dispatch_async(dispatch_get_main_queue(), { [weak self] in
                    self?.scheduler?.setStateForScript(waitingScript, state: .Running) // running again!
                    self?.scheduler?.runNextInstructionOfScript(waitingScript)
                })
                waitingScriptsToRemove += waitingScript
            }
            broadcastWaitingScriptsQueue[waitingScript] = runningBroadcastScripts
            assert(broadcastWaitingScriptsQueue[waitingScript]!.count == runningBroadcastScripts.count)
        }
        for waitingScript in waitingScriptsToRemove {
            broadcastWaitingScriptsQueue.removeValueForKey(waitingScript)
        }
    }

    func removeWaitingScriptDueToRestart(script: Script) {
        broadcastWaitingScriptsQueue.removeValueForKey(script)
    }
}
