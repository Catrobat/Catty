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

final class CBScheduler: CBSchedulerProtocol {

    // MARK: - Properties
    var logger: CBLogger
//    var schedulingAlgorithm: CBSchedulingAlgorithmProtocol?
    private(set) var running = false
    private let _broadcastHandler: CBBroadcastHandlerProtocol

    private var _spriteNodes = [String:CBSpriteNode]()
    private var _contexts = [CBScriptContextProtocol]()
    private var _whenContexts = [String:[CBWhenScriptContext]]()
    private var _scheduledContexts = [String:[CBScriptContextProtocol]]()

    private var _availableWaitQueues = [dispatch_queue_t]()
    private var _availableBufferQueues = [dispatch_queue_t]()
    private var _lastQueueIndex = 0

    // MARK: Static properties
    static let vibrateSerialQueue = dispatch_queue_create("org.catrobat.vibrate.queue", DISPATCH_QUEUE_SERIAL)

    // MARK: - Initializers
    init(logger: CBLogger, broadcastHandler: CBBroadcastHandlerProtocol) {
        self.logger = logger
//        self.schedulingAlgorithm = nil // default scheduling behaviour
        _broadcastHandler = broadcastHandler
    }

    // MARK: - Queries
    func isContextScheduled(context: CBScriptContextProtocol) -> Bool {
        guard let spriteName = context.spriteNode.name
        else { fatalError("Sprite node has no name!") }
        return _scheduledContexts[spriteName]?.contains(context) == true
    }

    // MARK: - Model methods
    func registerSpriteNode(spriteNode: CBSpriteNode) {
        precondition(spriteNode.name != nil)
        precondition(_spriteNodes[spriteNode.name!] == nil)
        _spriteNodes[spriteNode.name!] = spriteNode
    }

    func registerContext(context: CBScriptContextProtocol) {
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
    func runNextInstructionOfContext(context: CBScriptContextProtocol) {
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

        var nextHighPriorityClosures = [CBHighPriorityScheduleElement]()
        var nextClosures = [CBScheduleElement]()
        var nextWaitClosures = [CBScheduleElement]()
        var nextBufferElements = [CBBufferElement]()
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
                    case let .Buffer(brick):
                        nextBufferElements += (context, brick)
                    case .InvalidInstruction:
                        context.state = .Runnable
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
                spriteNode.runAction(groupAction) { [weak self] in
                    nextActionElements.forEach { $0.context.state = .Runnable }
                    self?.runNextInstructionsGroup()
                }
            }

            for (context, duration, actionCreateClosure) in nextLongActionElements {
                var durationTime = 0.0
                switch duration {
                case let .VarTime(formula):
                    durationTime = formula.interpretDoubleForSprite(context.spriteNode.spriteObject)
                case let .FixedTime(time):
                    durationTime = time
                }
                let actionClosure = actionCreateClosure(duration: durationTime)
                let action = SKAction.customActionWithDuration(durationTime, actionBlock: actionClosure)
                spriteNode.runAction(action) { [weak self] in
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
            dispatch_async(queue!, {
                closure(context: context, scheduler: self)
                self._availableWaitQueues += queue!
                dispatch_async(dispatch_get_main_queue()) {
                    self.runNextInstructionOfContext(context)
                }
            })
        }


        for (context, closure) in nextClosures {
            closure(context: context, scheduler: self)
        }
        
        for (context, brick) in nextBufferElements {
            var queue = _availableBufferQueues.first
            if queue == nil {
                queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
            } else {
                _availableBufferQueues.removeFirst()
            }
            dispatch_async(queue!, {
                brick.preCalculate()
                self._availableBufferQueues += queue!
                dispatch_async(dispatch_get_main_queue()) {
                    self.runNextInstructionOfContext(context)
                }
            })
        }

        if nextClosures.count > 0 && nextHighPriorityClosures.count == 0 {
            runNextInstructionsGroup()
            return
        }

        for (context, closure) in nextHighPriorityClosures {
            closure(context: context, scheduler: self, broadcastHandler: _broadcastHandler)
        }
    }

    // MARK: - Events
    func run() {
        assert(!running)
        logger.info(">>> [SCHEDULER STARTED] <<<")
        running = true
        _broadcastHandler.setup()

        for var idx = 1; idx <= PlayerConfig.NumberOfWaitQueuesInitialValue; ++idx {
            _availableWaitQueues += dispatch_queue_create("org.catrobat.wait.queue[\(idx)]", DISPATCH_QUEUE_SERIAL)
        }
        _lastQueueIndex = PlayerConfig.NumberOfWaitQueuesInitialValue

        // schedule all start scripts
        _contexts.forEach { if $0 is CBStartScriptContext { scheduleContext($0) } }
        // ... Ready...Steady...Gooooo!! => invoke first instruction!
        runNextInstructionsGroup()
    }

    func scheduleContext(context: CBScriptContextProtocol) {
        guard let spriteName = context.spriteNode.name else { fatalError("Sprite node has no name!") }
        assert(_contexts.contains(context))
        logger.info("[STARTING: \(context.script)]")
        logger.debug("  >>> !!! RESETTING: \(context.script) <<<")
        context.state = .Runnable
        context.reset()
        // if context.hasActions() { context.removeAllActions() }

        // enqueue
        if _scheduledContexts[spriteName] == nil {
            _scheduledContexts[spriteName] = [CBScriptContext]()
        }
        // TODO: use Set-datastructure instead...
        if !_scheduledContexts[spriteName]!.contains(context) {
            _scheduledContexts[spriteName]! += context
        }
    }

    func startWhenContextsOfSpriteNodeWithName(spriteName: String) {
        guard let contexts = _whenContexts[spriteName] else { return }

        let scheduledContextsOfSprite = _scheduledContexts[spriteName]
        let areAnyContextsRunning = !_scheduledContexts.isEmpty

        for context in contexts {
//            if context.state == .Running || context.state == .Waiting {
//                _broadcastHandler.terminateAllCalledBroadcastContextsAndRemoveWaitingContext(context)
//            }
            context.reset()
            context.state = .Runnable

            if scheduledContextsOfSprite == nil || !scheduledContextsOfSprite!.contains(context) {
                scheduleContext(context)
            }
        }

        if !areAnyContextsRunning { runNextInstructionsGroup() }
    }

    func startBroadcastContexts(broadcastContexts: [CBBroadcastScriptContextProtocol]) {
        let areAnyContextsRunning = !_scheduledContexts.isEmpty
        
        for context in broadcastContexts {
            if context.state == .Running || context.state == .Waiting {
                _broadcastHandler.terminateAllCalledBroadcastContextsAndRemoveWaitingContext(context)
            }
            context.reset()
            context.state = .Runnable

            let scheduledContextsOfSprite = _scheduledContexts[context.spriteNode.name!]
            if scheduledContextsOfSprite == nil || !scheduledContextsOfSprite!.contains(context) {
                scheduleContext(context)
            }
        }
        
        if !areAnyContextsRunning { runNextInstructionsGroup() }

    }

    func stopContext(context: CBScriptContextProtocol, continueWaitingBroadcastSenders: Bool) {
        guard let spriteName = context.spriteNode.name else { fatalError("Sprite node has no name!") }
//        assert(!_broadcastHandler.isWaitingForCalledBroadcastContexts(context))
        if context.state == .Dead { return } // already stopped => must be an old deprecated dispatch closure
        let script = context.script
        logger.info("!!! STOPPING: \(script)")

        context.state = .Dead

        if let broadcastContext = context as? CBBroadcastScriptContext
        where continueWaitingBroadcastSenders {
            _broadcastHandler.wakeUpContextsWaitingForTerminationOfBroadcastContext(broadcastContext)
        }

        // dequeue
        var spriteScheduledContexts = _scheduledContexts[spriteName]!
        if let index = spriteScheduledContexts.indexOfElement(context) {
            spriteScheduledContexts.removeAtIndex(index)
        }

        if spriteScheduledContexts.count > 0 {
            _scheduledContexts[spriteName] = spriteScheduledContexts
        } else {
            _scheduledContexts.removeValueForKey(spriteName)
        }
        logger.debug("\(script) finished!")
    }

    func shutdown() {
        logger.info("!!! SCHEDULER SHUTDOWN !!!")
        _scheduledContexts.values.forEach { $0.forEach {
            stopContext($0, continueWaitingBroadcastSenders: false)
        } }
        _scheduledContexts.removeAll()
        _whenContexts.removeAll()
        _contexts.removeAll()
        _broadcastHandler.tearDown()
        running = false
    }

}
