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

//    func allStartScriptContextsReachedMatureState() -> Bool {
//        let startScriptContexts = _scriptContexts.filter{ return $0 is CBStartScriptContext }
//        for context in startScriptContexts {
//            if context.state != .RunningMature && context.state != .Waiting && context.state != .Dead {
//                return false
//            }
//        }
//        return true
//    }

final class CBScheduler : CBSchedulerProtocol {

    // MARK: - Properties
    var logger: CBLogger
    private(set) var running = false

    private lazy var _scriptContexts = [CBScriptContextAbstract]()
    private let _broadcastHandler: CBBroadcastHandlerProtocol

    // MARK: - Initializers
    init(logger: CBLogger, broadcastHandler: CBBroadcastHandlerProtocol) {
        self.logger = logger
        _broadcastHandler = broadcastHandler
    }

    // MARK: - Queries
    func isContextScheduled(context: CBScriptContextAbstract) -> Bool {
        return context.state == .Running && _scriptContexts.contains(context)
    }

    // MARK: - Scheduling
    func schedule() {

        let kMaxNumOfParallelRunningScripts = 4
        let kMaxNumOfInstructionsInSequence = 6

        while running {

            var parallelInstructionList = [[CBExecClosure]]()
            let runnableContexts = _scriptContexts.filter{ return $0.state == .Runnable }

            for context in runnableContexts {

                var nextNInstructions = context.nextNInstructions(kMaxNumOfInstructionsInSequence)
                if nextNInstructions.isEmpty {
                    continue
                }

                SKAction()
                SKAction.sequence([SKAction]())
                nextNInstructions.prepend({ context.state = .Running }) // Tells the scheduler script is running
                nextNInstructions.append({ context.state = .Runnable }) // Tell scheduler to continue
                parallelInstructionList += nextNInstructions
            }
            if parallelInstructionList.count > kMaxNumOfParallelRunningScripts {
                parallelInstructionList = Array(parallelInstructionList[0..<kMaxNumOfParallelRunningScripts])
            }
            SKAction.group([repeatAnimation, repeatMove])

            // enqueue instructions...
            dispatch_async(dispatch_get_main_queue(), { [weak self] in
                context.runAction(brick.action(), completion:{
                }
            })
            NSThread.sleepForTimeInterval(0.01)
        }
    }

    // MARK: - Events
    func run() {
        logger.info("\n\n#############################################################\n"
                  + " => SCHEDULER STARTED\n"
                  + "#############################################################\n\n")

        // set running flag
        running = true
        _broadcastHandler.setupHandler()

        // start all StartScripts
        _scriptContexts.filter{ $0 is CBStartScriptContext }.forEach{ startContext($0) }

        let schedulerQueue = dispatch_queue_create("org.catrobat.scheduler.queue", DISPATCH_QUEUE_SERIAL)
        dispatch_async(schedulerQueue, { [weak self] in self?.schedule() })
    }

    func registerContext(context: CBScriptContextAbstract) {
        precondition(_scriptContexts.contains(context) == false) // ensure that same context is not added twice
        _scriptContexts += context
    }

    func registeredContextForScript(script: Script) -> CBScriptContextAbstract? {
        return _scriptContexts.filter{ $0.script == script }.first
    }

    func startContext(context: CBScriptContextAbstract) {
        startContext(context, withInitialState: .Running)
    }

    func startContext(context: CBScriptContextAbstract, withInitialState initialState: CBScriptState) {
        precondition(running)
        precondition(_scriptContexts.contains(context), "Unable to start context! Context not registered.")
        precondition(context.state == .Running, "Unable to start context! Context already scheduled.")
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
    }

    func restartContext(context: CBScriptContextAbstract) {
        restartContext(context, withInitialState: .Running)
    }

    func restartContext(context: CBScriptContextAbstract, withInitialState initialState: CBScriptState) {
        precondition(running)
        precondition(_scriptContexts.contains(context), "Unable to restart context! Context is not running.")
        stopContext(context)
        startContext(context, withInitialState: initialState)
    }

    func stopContext(context: CBScriptContextAbstract) {
        if context.state == .Dead { return } // already stopped => must be an old deprecated enqueued dispatch closure
        precondition(_scriptContexts.contains(context), "Unable to stop context! Context not registered any more.")
        if _scriptContexts.contains(context) == false {
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
        _scriptContexts.removeObject(context)
        logger.debug("\(script) finished!")
    }

    private func _resetContext(context: CBScriptContextAbstract) {
        context.reset()
        logger.debug("  >>> !!! RESETTING: \(context.script) <<<");
        context.script.brickList.filter{ $0 is LoopBeginBrick }.forEach{ $0.resetCondition() }
    }

    func shutdown() {
        logger.info("\n#############################################################\n\n"
                  + "!!! SCHEDULER SHUTDOWN\n\n"
                  + "#############################################################\n\n")

        // stop all currently (!) scheduled script contexts
        for context in _scriptContexts {
            precondition(_scriptContexts.contains(context), "Unable to stop context! Context not registered any more.")
            let script = context.script
            logger.info("!!! STOPPING: \(script)")
            logger.info("-------------------------------------------------------------")
            if context.inParentHierarchy(script.object!.spriteNode!) {
                context.removeFromParent()
            }
            logger.debug("\(script) finished!")
            context.removeReferences()
        }
        // IMPORTANT: remove references of other registered scripts as well!
        _scriptContexts.forEach{ $0.removeReferences() }
        _scriptContexts.removeAll(keepCapacity: false)
        _scriptContexts.removeAll(keepCapacity: false)
        _broadcastHandler.tearDownHandler()
        running = false
    }
}
