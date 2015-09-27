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
    func scheduleContext(context: CBScriptContext, withInitialState initialState: CBContextState) {
        guard let spriteName = context.spriteNode.name else { fatalError("Sprite node has no name!") }
        assert(_contexts.contains(context))
        assert(!isContextScheduled(context))
        logger.info("[STARTING: \(context.script)]")
        logger.debug("  >>> !!! RESETTING: \(context.script) <<<")
        context.state = initialState
        context.reset()
        //        if context.hasActions() { context.removeAllActions() }

        // enqueue
        if _scheduledContexts[spriteName] == nil {
            _scheduledContexts[spriteName] = [CBScriptContext]()
        }
        _scheduledContexts[spriteName]! += context
    }

    // TODO: RENAME!!!
    func runNextInstructionOfContext(context: CBScriptContext) {
        context.state = .Runnable
        runNextInstructionsGroup()
    }

    // <<<<<<<<<<<<<<<<<<|>>>>>>>>>>>>>>>>>>
    // <<<   SCHEDULER   |   CONTROLLER  >>>
    // <<<<<<<<<<<<<<<<<<|>>>>>>>>>>>>>>>>>>
    func runNextInstructionsGroup() {
        // TODO: apply scheduling via StrategyPattern => selects scripts to be scheduled NOW!
        assert(NSThread.currentThread().isMainThread)

        var nextClosures = [CBExecClosure]()
        var nextWaitClosures = [CBScheduleClosureElement]()
        for (spriteName, contexts) in _scheduledContexts {
            guard let spriteNode = _spriteNodes[spriteName]
            else { fatalError("WTH?? Sprite node not available (any more)...") }

            var nextLongActionElements = [CBScheduleActionElement]()
            var nextActionElements = [CBScheduleActionElement]()
            for context in contexts {
                if context.state != .Runnable { continue }
                context.state = .Running
                // collect...
                if let nextInstruction = context.nextInstruction() {
                    switch nextInstruction {
                    case let .ExecClosure(closure):
                        nextClosures += closure
                    case let .LongDurationAction(action):
                        nextLongActionElements += (context, action)
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

            if nextActionElements.count > 0 {
                let groupAction = nextActionElements.count > 1
                                ? SKAction.group(nextActionElements.map { $0.action })
                                : nextActionElements.first!.1
                let startTime = NSDate()
                spriteNode.runAction(groupAction) { [weak self] in
                    let duration = NSDate().timeIntervalSinceDate(startTime)
                    //                self?.logger.info("  Duration for Group: \(duration*1000)ms")
//                    print("  Duration for Group: \(duration*1000)ms")
                    nextActionElements.forEach { $0.context.state = .Runnable }
                    self?.runNextInstructionsGroup()
                }
            }

            for nextLongActionElement in nextLongActionElements {
                spriteNode.runAction(nextLongActionElement.action) { [weak self] in
//                    let duration = NSDate().timeIntervalSinceDate(startTime)
//                    print("  Duration for Group: \(duration*1000)ms")
                    nextLongActionElement.context.state = .Runnable
                    self?.runNextInstructionsGroup()
                }
            }
        }

        for (context, closure) in nextWaitClosures {
            var queue = availableWaitQueues.first
            if queue == nil {
                queue = dispatch_queue_create("org.catrobat.wait.queue[\(++lastQueueIndex)]", DISPATCH_QUEUE_SERIAL)
            } else {
                availableWaitQueues.removeFirst()
            }
            dispatch_async(queue!, { [weak self] in
                closure()
                self?.availableWaitQueues += queue!
                dispatch_async(dispatch_get_main_queue()) {
                    self?.runNextInstructionOfContext(context)
                }
            })
        }
        for closure in nextClosures {
            closure()
            // TODO: continue here...
        }
    }

    // MARK: - Events
    var availableWaitQueues = [dispatch_queue_t]()
    var lastQueueIndex = 3
    func run() {
        assert(!running)
        logger.info("\n\n#############################################################\n"
            + " => SCHEDULER STARTED\n"
            + "#############################################################\n\n")
        running = true
        _broadcastHandler.setup()

        for var idx = 1; idx <= lastQueueIndex; ++idx {
            availableWaitQueues += dispatch_queue_create("org.catrobat.wait.queue[\(idx)]", DISPATCH_QUEUE_SERIAL)
        }

        // schedule all start scripts
        _contexts.forEach { if $0 is CBStartScriptContext { scheduleContext($0, withInitialState: .Runnable) } }
        // ... Ready...Steady...Gooooo!! => invoke first instruction!
        runNextInstructionsGroup()
    }

    func startContext(context: CBScriptContext, withInitialState initialState: CBContextState) {
        assert(running)
        scheduleContext(context, withInitialState: initialState)
        runNextInstructionsGroup()
        // TODO...
    }

    func stopContext(context: CBScriptContext) {
        stopContext(context, continueWaitingBroadcastSenders: true)
    }

    func stopContext(context: CBScriptContext, continueWaitingBroadcastSenders: Bool) {
        guard let spriteName = context.spriteNode.name else { fatalError("Sprite node has no name!") }
        if context.state == .Dead { return } // already stopped => must be an old deprecated dispatch closure
//        assert(isContextScheduled(context))
//        assert(_contexts.contains(context))
        let script = context.script
        logger.info("!!! STOPPING: \(script)")

        context.state = .Dead

        // if script has been stopped (e.g. WhenScript via restart)
        // => remove it from broadcast waiting list
        _broadcastHandler.removeWaitingContextAndTerminateAllCalledBroadcastContexts(context)

        //-----------------------
        //
        // FIXME: stop all called running broadcast scripts!!??
        //
        //-----------------------

        if let broadcastScriptContext = context as? CBBroadcastScriptContext
        where continueWaitingBroadcastSenders {
            // continue all broadcastWaiting scripts
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
        logger.info("\n#############################################################\n\n"
            + "!!! SCHEDULER SHUTDOWN\n\n"
            + "#############################################################\n\n")

        // stop all currently (!) scheduled script contexts
        for contexts in _scheduledContexts.values {
            for context in contexts {
                stopContext(context, continueWaitingBroadcastSenders: false)
            }
        }
        _scheduledContexts.removeAll(keepCapacity: false)
        _contexts.removeAll(keepCapacity: false)
        _broadcastHandler.tearDown()
        running = false
    }

}
