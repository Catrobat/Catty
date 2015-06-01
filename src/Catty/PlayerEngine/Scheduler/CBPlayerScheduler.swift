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

protocol CBPlayerSchedulerProtocol : class {
    // properties
    var schedulingAlgorithm:CBPlayerSchedulingAlgorithmProtocol? { get set }
    var scriptExecContextDict:[Script:CBScriptExecContext] { get }
    var running:Bool { get }

    // main events
    func run()
    func shutdown()

    // script handling
    func addScriptExecContext(scriptExecContext: CBScriptExecContext)
    func startScript(script: Script)
    func startScript(script: Script, withInitialState: CBScriptState)
    func restartScript(script: Script)
    func restartScript(script: Script, withInitialState: CBScriptState)

    // operations
    func isScriptScheduled(script: Script) -> Bool
    func addInstructionsAfterCurrentInstructionOfScript(script: Script, instructionList: [CBExecClosure])
    func addInstructionAfterCurrentInstructionOfScript(script: Script, instruction: CBExecClosure)
    func removeNumberOfInstructions(numberOfInstructions: Int, instructionStartIndex: Int, inScript script: Script)
    func currentInstructionPointerPositionOfScript(script: Script) -> Int?
    func setStateForScript(script: Script, state: CBScriptState)
    func runNextInstructionOfScript(script: Script)
}

final class CBPlayerScheduler : CBPlayerSchedulerProtocol {

    // MARK: - Properties
    var logger: CBLogger
    var schedulingAlgorithm: CBPlayerSchedulingAlgorithmProtocol?
    private(set) var running = false
    private(set) lazy var scriptExecContextDict = [Script:CBScriptExecContext]()

    private let _frontend: CBPlayerFrontendProtocol
    private let _backend: CBPlayerBackendProtocol
    private let _broadcastHandler: CBPlayerBroadcastHandlerProtocol
    private var _currentScriptExecContext: CBScriptExecContext?

    // MARK: - Initializers
    init(logger: CBLogger, frontend: CBPlayerFrontendProtocol, backend: CBPlayerBackendProtocol,
        broadcastHandler: CBPlayerBroadcastHandlerProtocol)
    {
        self.logger = logger
        self.schedulingAlgorithm = nil // default scheduling behavior
        _frontend = frontend
        _backend = backend
        _broadcastHandler = broadcastHandler
    }

    // MARK: - Getters and Setters
    func isScriptScheduled(script: Script) -> Bool {
        if let scriptExecContext = scriptExecContextDict[script] {
            return true
        }
        return false
    }

    // MARK: - Operations
    func addScriptExecContext(scriptExecContext: CBScriptExecContext) {
        assert(scriptExecContextDict[scriptExecContext.script] == nil, "Context already in dictionary!")
        logger.info("Added new CBScriptExecContext for \(scriptExecContext.script)")
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

    func removeNumberOfInstructions(numberOfInstructions: Int, instructionStartIndex startIndex: Int, inScript script: Script) {
        if let scriptExecContext = scriptExecContextDict[script] {
            scriptExecContext.removeNumberOfInstructions(numberOfInstructions, instructionStartIndex: startIndex)
        }
    }

    func currentInstructionPointerPositionOfScript(script: Script) -> Int? {
        if let scriptExecContext = scriptExecContextDict[script] {
            return scriptExecContext.reverseInstructionPointer
        }
        return nil
    }

    // MARK: - Scheduling
    func runNextInstructionOfScript(script: Script) {
        if scriptExecContextDict.count == 0 { return }

        // apply scheduling via StrategyPattern => selects script to be scheduled NOW!
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

    func setStateForScript(script: Script, state: CBScriptState) {
        if let scriptExecContext = scriptExecContextDict[script] {
            scriptExecContext.state = state
        }
    }

    // MARK: - Events
    func run() {
        logger.info("")
        logger.info("#############################################################")
        logger.info("")
        logger.info(" => SCHEDULER STARTED")
        logger.info("")
        logger.info("#############################################################\n\n")

        // set running flag
        running = true
        _broadcastHandler.setupHandler()

        for (script, _) in scriptExecContextDict {
            startScript(script)
        }
    }

    func startScript(script: Script) {
        startScript(script, withInitialState: .Running)
    }

    func startScript(script: Script, withInitialState initialState: CBScriptState) {
        assert(running) // ensure that player is running!
        if let scriptExecContext = scriptExecContextDict[script] {
            logger.info("    STARTING: \(script)")
            logger.info("-------------------------------------------------------------")

            if scriptExecContext.inParentHierarchy(scriptExecContext.script.object.spriteNode) == false {
                //            NSLog(@" + Adding this node to object");
                scriptExecContext.script.object.spriteNode.addChild(scriptExecContext)
            }
            _resetScript(script)
            if scriptExecContext.hasActions() {
                scriptExecContext.removeAllActions()
            }
            scriptExecContext.state = initialState
            runNextInstructionOfScript(script) // Ready...Steady...Gooooo!! => invoke first instruction!
            return
        }
        // make sure that context has already been added to Scheduler
        fatalError("Unable to start script! ScriptExecContext not added to scheduler. This should NEVER happen!!")
    }

    func restartScript(script: Script) {
        restartScript(script, withInitialState: .Running)
    }

    func restartScript(script: Script, withInitialState initialState: CBScriptState = .Running) {
        assert(running) // make sure that player is running!
        if let scriptExecContext = scriptExecContextDict[script] {
            // remove it from waiting list
            _broadcastHandler.removeWaitingScriptDueToRestart(script)
            stopScript(script, removeReferences:false)
            scriptExecContext.reset()
//            let sequenceList = _frontend.computeSequenceListForScript(script)
//            let newScriptExecContext = _backend.executionContextForScriptSequenceList(sequenceList, spriteNode: script.object.spriteNode)
            addScriptExecContext(scriptExecContext)
            startScript(script, withInitialState: initialState)
        } else {
//            let sequenceList = _frontend.computeSequenceListForScript(script)
//            let scriptExecContext = _backend.executionContextForScriptSequenceList(sequenceList)
//            addScriptExecContext(scriptExecContext)
//            startScript(script)
            fatalError("Script is not running!")
        }
    }

    func stopScript(script: Script, removeReferences: Bool = true) {
        logger.info("!!! STOPPING: \(script)")
        logger.info("-------------------------------------------------------------")
        if let scriptExecContext = scriptExecContextDict[script] {
            scriptExecContext.state = .Dead
            if scriptExecContext.scriptType == .Broadcast {
                // continue all broadcastWaiting scripts
                if let broadcastScript = script as? BroadcastScript { // sanity check
                    _broadcastHandler.continueForBroadcastScriptTerminationWaitingScripts(broadcastScript: broadcastScript)
                } else {
                    fatalError("This should never happen!")
                }
            }
            if removeReferences {
                scriptExecContext.removeReferences()
            }
            if scriptExecContext.inParentHierarchy(scriptExecContext.script.object.spriteNode) {
                scriptExecContext.removeFromParent()
            }
            scriptExecContext.removeAllActions()
            scriptExecContextDict.removeValueForKey(script)
            logger.debug("\(script) finished!")
            return
        }
        logger.debug("\(script) already stopped!!")
    }

    private func _resetScript(script: Script) {
        logger.debug("!!! RESETTING: \(script)");
        logger.debug("-------------------------------------------------------------")
        for brick in script.brickList {
            if let loopBeginBrick = brick as? LoopBeginBrick {
                loopBeginBrick.resetCondition()
            }
        }
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
            if scriptExecContext.inParentHierarchy(scriptExecContext.script.object.spriteNode) {
                scriptExecContext.removeFromParent()
            }
            scriptExecContext.removeReferences()
            logger.debug("\(script) finished!")
        }
        scriptExecContextDict.removeAll(keepCapacity: false)
        running = false
        _currentScriptExecContext = nil
    }
}
