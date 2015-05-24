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

@objc class CBPlayerScheduler {

    static let sharedInstance = CBPlayerScheduler() // singleton
    let logger = Swell.getLogger("CBPlayerScheduler")
    final private(set) var running = false
    final private(set) lazy var scriptExecContextDict = [Script:CBScriptExecContext]()
    final var schedulingAlgorithm : CBPlayerSchedulingAlgorithm?
    final private weak var _currentScriptExecContext : CBScriptExecContext?

    private init() {} // private initializer

    final func addScriptExecContext(scriptExecContext: CBScriptExecContext) {
        assert(scriptExecContextDict[scriptExecContext.script] == nil, "Context already in dictionary!")
        scriptExecContextDict[scriptExecContext.script] = scriptExecContext
    }

    final func addInstructionAfterCurrentInstructionOfScript(script: Script, instruction: CBExecClosure) {
        if let scriptExecContext = scriptExecContextDict[script] {
            scriptExecContext.addInstructionAtCurrentPosition(instruction)
        }
    }

    final func addInstructionsAfterCurrentInstructionOfScript(script: Script, instructionList: [CBExecClosure]) {
        for instruction in instructionList {
            addInstructionAfterCurrentInstructionOfScript(script, instruction: instruction)
        }
    }

    final func runNextInstructionOfScript(script: Script) {
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

    final func run() {
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

    final func startScript(script: Script) {
        assert(running) // ensure that player is running!
        let context = self.scriptExecContextDict[script]
        // make sure that context has already been added to Scheduler
        assert(scriptExecContextDict[script] != nil)
        logger.info("    STARTING: \(script)")
        logger.info("-------------------------------------------------------------")

        if script.inParentHierarchy(script.object) == false {
            //            NSLog(@" + Adding this node to object");
            script.object.addChild(script)
        }
        _resetForScript(script)

        if script.hasActions() {
            script.removeAllActions()
        }
        runNextInstructionOfScript(script) // Ready...Steady...Gooooo!! => invoke first instruction!
    }

    final func restartScript(script: Script) {
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

    final func stopScript(script: Script, removeReferences: Bool = true) {
        logger.info("!!! STOPPING: \(script)")
        logger.info("-------------------------------------------------------------")
        if removeReferences {
            if let scriptExecContext = scriptExecContextDict[script] {
                scriptExecContext.removeReferences()
            }
        }
        scriptExecContextDict.removeValueForKey(script)

        script.removeAllActions()
        if script.inParentHierarchy(script.object) {
            script.removeFromParent()
        }
        logger.debug("Script \(script) finished!")
    }

    final func shutdown() {
        logger.info("")
        logger.info("#############################################################")
        logger.info("")
        logger.info("!!! SCHEDULER SHUTDOWN")
        logger.info("")
        logger.info("#############################################################\n\n")
        for (script, scriptExecContext) in scriptExecContextDict {
            logger.info("!!! STOPPING: \(script)")
            logger.info("-------------------------------------------------------------")
            if let scriptExecContext = scriptExecContextDict[script] {
                scriptExecContext.removeReferences()
            }
            if script.inParentHierarchy(script.object) {
                script.removeFromParent()
            }
            logger.debug("Script \(script) finished!")
        }
        scriptExecContextDict.removeAll(keepCapacity: false)
        running = false
        _currentScriptExecContext = nil
    }

    final func isScriptRunning(script: Script) -> Bool {
        if let _ = scriptExecContextDict[script] {
            return true
        }
        return false
    }

    private final func _resetForScript(script: Script) {
        logger.debug("!!! RESETTING: \(script)");
        logger.debug("-------------------------------------------------------------")
        for brick in script.brickList {
            if let loopBeginBrick = brick as? LoopBeginBrick {
                loopBeginBrick.resetCondition()
            }
        }
    }
}
