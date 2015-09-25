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
        guard let spriteName = context.spriteNode.name else { fatalError("Sprite node has no name!") }
        if let spriteScheduledContexts = _scheduledContexts[spriteName] {
            return spriteScheduledContexts.contains(context)
        }
        return false
    }

    func allStartScriptContextsReachedMatureState() -> Bool {
        for contexts in _scheduledContexts.values {
            for context in contexts {
                if context is CBStartScriptContext
                && context.state != .RunningMature
                && context.state != .Waiting
                && context.state != .Dead
                {
                    return false
                }
            }
        }
        return true
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
        if context.state == .Waiting { return }
        if _scheduledContexts.count == 0 { return }

        // TODO: apply scheduling via StrategyPattern => selects script to be scheduled NOW!
        if let nextInstruction = context.nextInstruction() {
            nextInstruction()
        } else {
            stopContext(context)
            logger.debug("All actions/instructions have been finished!")
        }
        return
    }

    // MARK: - Events
    func run() {
        logger.info("\n\n#############################################################\n"
            + " => SCHEDULER STARTED\n"
            + "#############################################################\n\n")

        // set running flag
        running = true
        _broadcastHandler.setup()

        // start all StartScripts
        _contexts.forEach { if $0 is CBStartScriptContext { startContext($0, withInitialState: .Running) } }
    }

    func startContext(context: CBScriptContext, withInitialState initialState: CBScriptState) {
        guard let spriteName = context.spriteNode.name else { fatalError("Sprite node has no name!") }
        assert(running)
        assert(!isContextScheduled(context))
        assert(_contexts.contains(context))
        logger.info("[STARTING: \(context.script)]")

        logger.debug("  >>> !!! RESETTING: \(context.script) <<<")
        context.reset()

//        if context.hasActions() {
//            context.removeAllActions()
//        }
        context.state = initialState

        // enqueue
        if _scheduledContexts[spriteName] == nil {
            _scheduledContexts[spriteName] = [CBScriptContext]()
        }
        _scheduledContexts[spriteName]! += context
        runNextInstructionOfContext(context) // Ready...Steady...Gooooo!! => invoke first instruction!
    }

    func stopContext(context: CBScriptContext) {
        stopContext(context, continueWaitingBroadcastSenders: true)
    }

    func stopContext(context: CBScriptContext, continueWaitingBroadcastSenders: Bool) {
        guard let spriteName = context.spriteNode.name else { fatalError("Sprite node has no name!") }
        if context.state == .Dead { return } // already stopped => must be an old deprecated enqueued dispatch closure
        assert(isContextScheduled(context))
        assert(_contexts.contains(context))
        let script = context.script
        logger.info("!!! STOPPING: \(script)")

        context.state = .Dead

        // if script has been stopped (e.g. WhenScript via restart)
        // => remove it from broadcast waiting list
        _broadcastHandler.removeWaitingContextAndTerminateAllCalledBroadcastScripts(context)

        //-----------------------
        //
        // FIXME: stop all called running broadcast scripts!!??
        //
        //-----------------------

        if let broadcastScriptContext = context as? CBBroadcastScriptContext
        where continueWaitingBroadcastSenders
        {
            // continue all broadcastWaiting scripts
            _broadcastHandler.continueContextsWaitingForTerminationOfBroadcastScriptContext(broadcastScriptContext)
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
