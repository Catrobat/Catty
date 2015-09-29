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

final class CBScheduler : CBSchedulerProtocol {

    // MARK: - Properties
    var logger: CBLogger
//    var schedulingAlgorithm: CBSchedulingAlgorithmProtocol?
    private(set) var running = false
    private let _broadcastHandler: CBBroadcastHandlerProtocol

    private var _spriteNodes = [String:CBSpriteNode]()
    private var _contexts = [CBScriptContext]()
    private var _whenContexts = [String:[CBWhenScriptContext]]()
    private var _scheduledContexts = [String:[CBScriptContext]]()

    private var _availableWaitQueues = [dispatch_queue_t]()
    private var _lastQueueIndex = 3

    // MARK: - Initializers
    init(logger: CBLogger, broadcastHandler: CBBroadcastHandlerProtocol) {
        self.logger = logger
//        self.schedulingAlgorithm = nil // default scheduling behaviour
        _broadcastHandler = broadcastHandler
    }

    // MARK: - Queries
    func isContextScheduled(context: CBScriptContext) -> Bool {
        guard let spriteName = context.spriteNode.name
        else { fatalError("Sprite node has no name!") }
        return _scheduledContexts[spriteName]?.contains(context) == true
    }

    func whenContextsForSpriteNodeWithName(spriteName: String) -> [CBWhenScriptContext]? {
        return _whenContexts[spriteName]
    }

    // MARK: - Model methods
    func registerSpriteNode(spriteNode: CBSpriteNode) {
        precondition(spriteNode.name != nil)
        precondition(_spriteNodes[spriteNode.name!] == nil)
        _spriteNodes[spriteNode.name!] = spriteNode
    }

    func registerContext(context: CBScriptContext) {
        guard let spriteName = context.spriteNode.name else { fatalError("Sprite node has no name!") }
        precondition(!_contexts.contains(context))
        precondition(_spriteNodes[spriteName] == context.spriteNode)

        _contexts += context
        if let whenContext = context as? CBWhenScriptContext {
            if _whenContexts[spriteName] == nil {
                _whenContexts[spriteName] = [CBWhenScriptContext]()
            }
            _whenContexts[spriteName]! += whenContext
        }
    }

    // MARK: - Scheduling
    func runNextInstructionOfContext(context: CBScriptContext) {
        assert(NSThread.currentThread().isMainThread)
        context.state = .Runnable
        runNextInstructionsGroup()
    }

    // <<<<<<<<<<<<<<<<<<|>>>>>>>>>>>>>>>>>>
    // <<<   SCHEDULER   |   CONTROLLER  >>>
    // <<<<<<<<<<<<<<<<<<|>>>>>>>>>>>>>>>>>>
    func runNextInstructionsGroup() {
        // TODO: apply scheduling via StrategyPattern => selects scripts to be scheduled NOW!
        assert(NSThread.currentThread().isMainThread)
        //        let scheduleStartTime = NSDate()

        var nextHighPriorityClosures = [CBScheduleClosureElement]()
        var nextClosures = [CBScheduleClosureElement]()
        var nextWaitClosures = [CBScheduleClosureElement]()
        for (spriteName, contexts) in _scheduledContexts {
            guard let spriteNode = _spriteNodes[spriteName]
            else { fatalError("WTH?? Sprite node not available (any more)...") }

            // collect
            var nextLongActionElements = [CBScheduleLongActionElement]()
            var nextActionElements = [CBScheduleActionElement]()
            for context in contexts {
                if context.state != .Runnable { continue }
                context.state = .Running
                if let nextInstruction = context.nextInstruction() {
                    switch nextInstruction {
                    case let .HighPriorityExecClosure(closure):
                        nextHighPriorityClosures += (context, closure)
                    case let .ExecClosure(closure):
                        nextClosures += (context, closure)
                    case let .LongDurationAction(durationFormula, actionCreateClosure):
                        nextLongActionElements += (context, durationFormula, actionCreateClosure)
                    case let .WaitExecClosure(closure):
                        nextWaitClosures += (context, closure)
                    case let .Action(action):
                        nextActionElements += (context, action)
                    case .InvalidInstruction:
                        continue // skip invalid instruction
                    }
                } else {
                    stopContext(context, continueWaitingBroadcastSenders: true)
                    logger.debug("All actions/instructions have been finished!")
                }
            }

            // execute actions (node dependend!)
            if nextActionElements.count > 0 {
                let groupAction = nextActionElements.count > 1
                                ? SKAction.group(nextActionElements.map { $0.action })
                                : nextActionElements.first!.1
//                let startTime = NSDate()
                spriteNode.runAction(groupAction) { [weak self] in
//                    let duration = NSDate().timeIntervalSinceDate(startTime)
                    //                self?.logger.info("  Duration for Group: \(duration*1000)ms")
//                    print("  Duration for Group: \(duration*1000)ms")
                    nextActionElements.forEach { $0.context.state = .Runnable }
                    self?.runNextInstructionsGroup()
                }
            }

            for (context, durationFormula, actionCreateClosure) in nextLongActionElements {
                let durationInSeconds = durationFormula.interpretDoubleForSprite(context.spriteNode.spriteObject)
                let actionClosure = actionCreateClosure(duration: durationInSeconds)
                let action = SKAction.customActionWithDuration(durationInSeconds, actionBlock: actionClosure)
                spriteNode.runAction(action) { [weak self] in
//                    let duration = NSDate().timeIntervalSinceDate(startTime)
//                    print("  Duration for Group: \(duration*1000)ms")
                    context.state = .Runnable
                    self?.runNextInstructionsGroup()
                }
            }
        }

        // execute closures (not node dependend!)
        for (context, closure) in nextWaitClosures {
            var queue = _availableWaitQueues.first
            if queue == nil {
                queue = dispatch_queue_create("org.catrobat.wait.queue[\(++_lastQueueIndex)]", DISPATCH_QUEUE_SERIAL)
            } else {
                _availableWaitQueues.removeFirst()
            }
            dispatch_async(queue!, { [weak self] in
                closure()
                self?._availableWaitQueues += queue!
                dispatch_async(dispatch_get_main_queue()) {
                    self?.runNextInstructionOfContext(context)
                }
            })
        }

        for (_, closure) in nextClosures {
            closure()
        }
//        let duration = NSDate().timeIntervalSinceDate(scheduleStartTime)
//        print("  Duration of last Schedule Cycle: \(duration*1000)ms")
        if nextClosures.count > 0 && nextHighPriorityClosures.count == 0 {
            runNextInstructionsGroup()
            return
        }

        for (_, closure) in nextHighPriorityClosures {
            closure()
        }
    }

    // MARK: - Events
    func run() {
        assert(!running)
        logger.info(">>> [SCHEDULER STARTED] <<<")
        running = true
        _broadcastHandler.setup()

        for var idx = 1; idx <= _lastQueueIndex; ++idx {
            _availableWaitQueues += dispatch_queue_create("org.catrobat.wait.queue[\(idx)]", DISPATCH_QUEUE_SERIAL)
        }

        // schedule all start scripts
        _contexts.forEach { if $0 is CBStartScriptContext { scheduleContext($0) } }
        // ... Ready...Steady...Gooooo!! => invoke first instruction!
        runNextInstructionsGroup()
    }

    func scheduleContext(context: CBScriptContext) {
        guard let spriteName = context.spriteNode.name else { fatalError("Sprite node has no name!") }
        assert(_contexts.contains(context))
        assert(!isContextScheduled(context))
        logger.info("[STARTING: \(context.script)]")
        logger.debug("  >>> !!! RESETTING: \(context.script) <<<")
        context.state = .Runnable
        context.reset()
        // if context.hasActions() { context.removeAllActions() }

        // enqueue
        if _scheduledContexts[spriteName] == nil {
            _scheduledContexts[spriteName] = [CBScriptContext]()
        }
        _scheduledContexts[spriteName]! += context
    }

    func forceStopContext(context: CBScriptContext) {
        logger.debug("!!! FORCE STOPPING SCRIPT CONTEXT !!!")
        //_broadcastHandler.terminateAllCalledBroadcastContextsAndRemoveWaitingContext(context)
        stopContext(context, continueWaitingBroadcastSenders: false)
    }

    func stopContext(context: CBScriptContext, continueWaitingBroadcastSenders: Bool) {
        guard let spriteName = context.spriteNode.name else { fatalError("Sprite node has no name!") }
        assert(!_broadcastHandler.isWaitingForCalledBroadcastContexts(context))
        if context.state == .Dead { return } // already stopped => must be an old deprecated dispatch closure
        let script = context.script
        logger.info("!!! STOPPING: \(script)")

        context.state = .Dead

        if let broadcastScriptContext = context as? CBBroadcastScriptContext
        where continueWaitingBroadcastSenders {
            _broadcastHandler.continueContextsWaitingForTerminationOfBroadcastContext(broadcastScriptContext)
        }

        // dequeue
        var spriteScheduledContexts = _scheduledContexts[spriteName]!
        spriteScheduledContexts.removeObject(context)
        if spriteScheduledContexts.count > 0 {
            _scheduledContexts[spriteName] = spriteScheduledContexts
        } else {
            _scheduledContexts.removeValueForKey(spriteName)
        }
        logger.debug("\(script) finished!")
    }

    func shutdown() {
        logger.info("!!! SCHEDULER SHUTDOWN !!!")
        _scheduledContexts.values.forEach { $0.forEach { forceStopContext($0) } }
        _scheduledContexts.removeAll()
        _whenContexts.removeAll()
        _contexts.removeAll()
        _broadcastHandler.tearDown()
        running = false
    }

}
