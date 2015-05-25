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

protocol CBPlayerSchedulingAlgorithm {
    // param: lastScript (nilable)
    // param: scriptExecContextDict is a non empty list!
    func scriptExecContextForNextInstruction(lastScript: Script?,
        scriptExecContextDict: [Script:CBScriptExecContext]) -> CBScriptExecContext
}

@objc final class CBPlayerScheduler {

    // MARK: - Constants
    // specifies max depth limit for self broadcasts running on the same function stack
    let selfBroadcastRecursionMaxDepthLimit = 20

    // MARK: - Properties
    static let sharedInstance = CBPlayerScheduler() // singleton
    let logger = Swell.getLogger("CBPlayerScheduler")
    private(set) var running = false
    private(set) lazy var scriptExecContextDict = [Script:CBScriptExecContext]()
    var schedulingAlgorithm : CBPlayerSchedulingAlgorithm?
    private weak var _currentScriptExecContext : CBScriptExecContext?
    private lazy var _registeredBroadcastScripts = [BroadcastScript]()
    private lazy var _selfBroadcastCounters = [String:Int]()

    // MARK: - Initializers
    private init() {} // private initializer

    // MARK: - Getters and Setters
    func isScriptRunning(script: Script) -> Bool {
        if let _ = scriptExecContextDict[script] {
            return true
        }
        return false
    }

    // MARK: - Operations
    private func _resetScript(script: Script) {
        logger.debug("!!! RESETTING: \(script)");
        logger.debug("-------------------------------------------------------------")
        for brick in script.brickList {
            if let loopBeginBrick = brick as? LoopBeginBrick {
                loopBeginBrick.resetCondition()
            }
        }
    }

    func addScriptExecContext(scriptExecContext: CBScriptExecContext) {
        assert(scriptExecContextDict[scriptExecContext.script] == nil, "Context already in dictionary!")
        scriptExecContextDict[scriptExecContext.script] = scriptExecContext
    }

    func addInstructionAfterCurrentInstructionOfScript(script: Script, instruction: CBExecClosure) {
        if let scriptExecContext = scriptExecContextDict[script] {
            scriptExecContext.addInstructionAtCurrentPosition(instruction)
        }
    }

    func addInstructionsAfterCurrentInstructionOfScript(script: Script, instructionList: [CBExecClosure]) {
        for instruction in instructionList {
            addInstructionAfterCurrentInstructionOfScript(script, instruction: instruction)
        }
    }

    func removeInstructionsBeforeCurrentInstruction(#numberOfInstructions: Int, inScript script: Script) {
        if let scriptExecContext = scriptExecContextDict[script] {
            scriptExecContext.removeNumberOfInstructionsBeforeCurrentInstruction(numberOfInstructions)
        }
    }

    func registerBroadcastScript(broadcastScript: BroadcastScript) {
        assert(contains(_registeredBroadcastScripts, broadcastScript) == false, "FATAL: BroadcastScript already registered!")
        _registeredBroadcastScripts += broadcastScript
    }

    func unregisterBroadcastScript(broadcastScript: BroadcastScript) {
        var index = 0
        for script in _registeredBroadcastScripts {
            if script === broadcastScript {
                _registeredBroadcastScripts.removeAtIndex(index)
                return
            }
            ++index
        }
        fatalError("FATAL: Given BroadcastScript is NOT registered!")
    }

    func runNextInstructionOfScript(script: Script) {
        if scriptExecContextDict.count == 0 { return }
        if schedulingAlgorithm != nil {
            let newScriptExecContext = schedulingAlgorithm?.scriptExecContextForNextInstruction(
                _currentScriptExecContext?.script,
                scriptExecContextDict: scriptExecContextDict
            )
            _currentScriptExecContext = newScriptExecContext
        } else {
            _currentScriptExecContext = scriptExecContextDict[script]
        }

        if let scriptExecContext = _currentScriptExecContext {
            if let nextInstruction = scriptExecContext.nextInstruction() {
                nextInstruction()
            } else {
                logger.debug("All actions/instructions have been finished!")
                stopScript(script)
            }
        } else {
            // TODO: review!!
            logger.debug("Script already removed from scheduler!")
            logger.debug("Force stopping script now!")
            stopScript(script)
        }
    }

    func run() {
        logger.info("")
        logger.info("#############################################################")
        logger.info("")
        logger.info(" => SCHEDULER STARTED")
        logger.info("")
        logger.info("#############################################################\n\n")
        running = true

        for (script, _) in scriptExecContextDict {
            startScript(script)
        }
    }

    func startScript(script: Script) {
        assert(running) // ensure that player is running!
        if let scriptExecContext = scriptExecContextDict[script] {
            logger.info("    STARTING: \(script)")
            logger.info("-------------------------------------------------------------")

            if scriptExecContext.inParentHierarchy(scriptExecContext.script.object) == false {
                //            NSLog(@" + Adding this node to object");
                scriptExecContext.script.object.addChild(scriptExecContext)
            }
            _resetScript(script)

            if scriptExecContext.hasActions() {
                scriptExecContext.removeAllActions()
            }
            runNextInstructionOfScript(script) // Ready...Steady...Gooooo!! => invoke first instruction!
            return
        }
        // make sure that context has already been added to Scheduler
        fatalError("Unable to start script! ScriptExecContext not added to scheduler. This should NEVER happen!!")
    }

    func restartScript(script: Script) {
        assert(running) // make sure that player is running!
        if let scriptExecContext = scriptExecContextDict[script] {
            stopScript(script, removeReferences:false)
            scriptExecContext.reset()
            addScriptExecContext(scriptExecContext)
            startScript(script)
        } else {
//            let sequenceList = CBPlayerFrontend().computeSequenceListForScript(script)
//            let scriptExecContext = CBPlayerBackend().executionContextForScriptSequenceList(sequenceList)
//            addScriptExecContext(scriptExecContext)
//            startScript(script)
            fatalError("Script is not running!")
        }
    }

    func stopScript(script: Script, removeReferences: Bool = true) {
        logger.info("!!! STOPPING: \(script)")
        logger.info("-------------------------------------------------------------")
        if let scriptExecContext = scriptExecContextDict[script] {
            if removeReferences {
                scriptExecContext.removeReferences()
            }
            if scriptExecContext.inParentHierarchy(script.object) {
                scriptExecContext.removeFromParent()
            }
            scriptExecContext.removeAllActions()
            scriptExecContextDict.removeValueForKey(script)
            logger.debug("\(script) finished!")
            return
        }
        logger.debug("\(script) already stopped!!")
    }

    func shutdown() {
        logger.info("")
        logger.info("#############################################################")
        logger.info("")
        logger.info("!!! SCHEDULER SHUTDOWN")
        logger.info("")
        logger.info("#############################################################\n\n")
        for (script, scriptExecContext) in scriptExecContextDict {
            logger.info("!!! STOPPING: \(script)")
            logger.info("-------------------------------------------------------------")
            if scriptExecContext.inParentHierarchy(script.object) {
                scriptExecContext.removeFromParent()
            }
            scriptExecContext.removeReferences()
            logger.debug("\(script) finished!")
        }
        scriptExecContextDict.removeAll(keepCapacity: false)
        running = false
        _currentScriptExecContext = nil
    }

    // MARK: - Broadcast handling
    func broadcastWithMessage(message: String, senderScript:Script) {
        logger.info("Broadcast: \(message)")
        var runNextInstructionOfSenderScript = true
        let frontend = CBPlayerFrontend()
        let backend = CBPlayerBackend()
        for broadcastScript in _registeredBroadcastScripts {
            if broadcastScript.receivedMessage != message {
                continue
            }

            // case broadcastScript == senderScript => restart script
            if broadcastScript === senderScript {
                if isScriptRunning(broadcastScript) == false {
                    return;
                }
                broadcastScript.calledByOtherScriptBroadcastWait = false // no synchronization needed here
                var counter = 0
                if let counterNumber = _selfBroadcastCounters[message] {
                    counter = counterNumber
                }
                if ++counter % selfBroadcastRecursionMaxDepthLimit == 0 { // XXX: DIRTY PERFORMANCE HACK!!
                    dispatch_async(dispatch_get_main_queue(), { [weak self] in
                        self?.restartScript(broadcastScript) // restart this self-listening BroadcastScript
                    })
                } else {
                    restartScript(broadcastScript)
                }
                _selfBroadcastCounters[message] = counter

                // end of script reached!! Scripts will be aborted due to self-calling broadcast
                // the final closure will never be called (except when script is canceled!) due
                // to self-broadcast
                runNextInstructionOfSenderScript = false // still enqueued next actions are ignored due to restart!
                logger.debug("BROADCASTSCRIPT HAS BEEN RESTARTED DUE TO SELF-BROADCAST!!")
                continue
            }

            // case broadcastScript != senderScript
            broadcastScript.calledByOtherScriptBroadcastWait = false
            if isScriptRunning(broadcastScript) == false {
                // case broadcastScript is not running
                let sequenceList = frontend.computeSequenceListForScript(broadcastScript)
                addScriptExecContext(backend.executionContextForScriptSequenceList(sequenceList))
                startScript(broadcastScript)
            } else {
                // case broadcastScript is running
                if broadcastScript.calledByOtherScriptBroadcastWait {
                    broadcastScript.signalForWaitingBroadcasts() // signal finished broadcast!
                }
                restartScript(broadcastScript) // trigger script to restart
            }
        }
        if (runNextInstructionOfSenderScript) {
            // the script must continue here. upcoming actions are executed!!
            runNextInstructionOfScript(senderScript)
        }
    }

}
