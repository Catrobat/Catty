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
    var running:Bool { get }

    // queries
    func isContextScheduled(context: CBScriptContextAbstract) -> Bool
    func allStartScriptContextsReachedMatureState() -> Bool

    // operations
    func run()
    func shutdown()
    func registerContext(context: CBScriptContextAbstract)
    func registeredContextForScript(script: Script) -> CBScriptContextAbstract?
    func startContext(context: CBScriptContextAbstract)
    func startContext(context: CBScriptContextAbstract, withInitialState: CBScriptState)
    func restartContext(context: CBScriptContextAbstract)
    func restartContext(context: CBScriptContextAbstract, withInitialState: CBScriptState)
    func stopContext(context: CBScriptContextAbstract)
    func runNextInstructionOfContext(context: CBScriptContextAbstract)
}

final class CBPlayerScheduler : CBPlayerSchedulerProtocol {

    // MARK: - Properties
    var logger: CBLogger
    var schedulingAlgorithm: CBPlayerSchedulingAlgorithmProtocol?
    private(set) var running = false

    private lazy var _scheduledScriptContexts = [CBScriptContextAbstract]()
    private lazy var _registeredScriptContexts = [CBScriptContextAbstract]()
    private let _broadcastHandler: CBPlayerBroadcastHandlerProtocol
    private var _currentContext: CBScriptContextAbstract?

    // MARK: - Initializers
    init(logger: CBLogger, broadcastHandler: CBPlayerBroadcastHandlerProtocol) {
        self.logger = logger
        self.schedulingAlgorithm = nil // default scheduling behavior
        _broadcastHandler = broadcastHandler
    }

    // MARK: - Queries
    func isContextScheduled(context: CBScriptContextAbstract) -> Bool {
        return _scheduledScriptContexts.contains(context)
    }

    func allStartScriptContextsReachedMatureState() -> Bool {
        for registeredContext in _scheduledScriptContexts {
            if let startContext = registeredContext as? CBStartScriptContext {
                if startContext.state != .RunningMature
                    && startContext.state != .Waiting
                    && startContext.state != .Dead
                {
                    return false
                }
            }
        }
        return true
    }

    // MARK: - Scheduling
    func runNextInstructionOfContext(context: CBScriptContextAbstract) {
        if context.state == .Waiting { return }
        if _scheduledScriptContexts.count == 0 { return }

        // apply scheduling via StrategyPattern => selects script to be scheduled NOW!
        if schedulingAlgorithm != nil {
            _currentContext = schedulingAlgorithm?.contextForNextInstruction(_currentContext,
                scheduledContexts: _scheduledScriptContexts)
            if _currentContext == nil {
                _currentContext = context
            }
        } else {
            _currentContext = context
        }

        if let scriptContext = _currentContext {
            if scriptContext != context && context.isLocked == false {
                // remember this runNextInstruction call for current context
                // => postpone it via async block!!
                dispatch_async(dispatch_get_main_queue(), { [weak self] in
                    self?.runNextInstructionOfContext(context)
                })
            }
            if scriptContext.isLocked { return }
            if let nextInstruction = scriptContext.nextInstruction() {
                nextInstruction()
            } else {
                precondition(scriptContext.isLocked == false)
                stopContext(scriptContext)
                logger.debug("All actions/instructions have been finished!")
            }
            return
        }
        fatalError("This should NEVER happen!!")
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

        // start all StartScripts
        for context in _registeredScriptContexts {
            if let _ = context as? CBStartScriptContext {
                startContext(context, withInitialState: .Running)
            }
        }
    }

    func registerContext(context: CBScriptContextAbstract) {
        precondition(_registeredScriptContexts.contains(context) == false) // ensure that same context is not added twice
        _registeredScriptContexts += context
    }

    func registeredContextForScript(script: Script) -> CBScriptContextAbstract? {
        for registeredScriptContext in _registeredScriptContexts {
            if registeredScriptContext.script == script {
                return registeredScriptContext
            }
        }
        return nil
    }

    func startContext(context: CBScriptContextAbstract) {
        startContext(context, withInitialState: .Running)
    }

    func startContext(context: CBScriptContextAbstract, withInitialState initialState: CBScriptState) {
        precondition(running) // make sure that player is running!
        precondition(_registeredScriptContexts.contains(context), "Unable to start context! Context not registered.")
        precondition(_scheduledScriptContexts.contains(context) == false, "Unable to start context! Context already scheduled.")
        logger.info("    STARTING: \(context.script)")
        logger.info("-------------------------------------------------------------")

        if context.inParentHierarchy(context.script.object!.spriteNode!) == false {
            //            NSLog(@" + Adding this node to object");
            context.script.object!.spriteNode!.addChild(context)
        }
        _resetContext(context)
        if context.hasActions() {
            context.removeAllActions()
        }
        context.state = initialState
        _scheduledScriptContexts += context
        runNextInstructionOfContext(context) // Ready...Steady...Gooooo!! => invoke first instruction!
    }

    func restartContext(context: CBScriptContextAbstract) {
        restartContext(context, withInitialState: .Running)
    }

    func restartContext(context: CBScriptContextAbstract, withInitialState initialState: CBScriptState) {
        precondition(running) // make sure that player is running!
        precondition(_scheduledScriptContexts.contains(context), "Unable to restart context! Context is not running.")
        stopContext(context)
        startContext(context, withInitialState: initialState)
    }

    func stopContext(context: CBScriptContextAbstract) {
        if context.state == .Dead { return } // already stopped => must be an old deprecated enqueued dispatch closure
        precondition(_registeredScriptContexts.contains(context), "Unable to stop context! Context not registered any more.")
        if _scheduledScriptContexts.contains(context) == false {
            return
        }

        let script = context.script
        logger.info("!!! STOPPING: \(script)")
        logger.info("-------------------------------------------------------------")
        context.state = .Dead

        // if script has been stopped (e.g. WhenScript via restart)
        // => remove it from broadcast waiting list
        _broadcastHandler.removeWaitingContext(context)

        if let broadcastScriptContext = context as? CBBroadcastScriptContext {
            // continue all broadcastWaiting scripts
            _broadcastHandler.continueContextsWaitingForTerminationOfBroadcastScriptContext(broadcastScriptContext)
        }
        if context.inParentHierarchy(context.script.object!.spriteNode!) {
            context.removeFromParent()
        }
        context.removeAllActions()
        _scheduledScriptContexts.removeObject(context)
        logger.debug("\(script) finished!")
    }

    private func _resetContext(context: CBScriptContextAbstract) {
        context.reset()
        logger.debug("!!! RESETTING: \(context.script)");
        logger.debug("-------------------------------------------------------------")
        for brick in context.script.brickList {
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

        // stop all currently (!) scheduled script contexts
        for context in _scheduledScriptContexts {
            precondition(_registeredScriptContexts.contains(context), "Unable to stop context! Context not registered any more.")
            let script = context.script
            logger.info("!!! STOPPING: \(script)")
            logger.info("-------------------------------------------------------------")
            if context.inParentHierarchy(script.object!.spriteNode!) {
                context.removeFromParent()
            }
            logger.debug("\(script) finished!")
            context.removeReferences()
        }
        for context in _registeredScriptContexts {
            context.removeReferences() // IMPORTANT: remove references of other registered scripts as well!
        }
        _scheduledScriptContexts.removeAll(keepCapacity: false)
        _registeredScriptContexts.removeAll(keepCapacity: false)
        _broadcastHandler.tearDownHandler()
        running = false
        _currentContext = nil
    }
}
