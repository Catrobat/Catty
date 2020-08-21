/**
 *  Copyright (C) 2010-2020 The Catrobat Team
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

import SpriteKit

@objc
final class Stage: SKScene, StageProtocol {

    // MARK: - Properties
    final let scheduler: CBSchedulerProtocol
    private final let frontend: CBFrontendProtocol
    private final let backend: CBBackendProtocol
    private final let broadcastHandler: CBBroadcastHandlerProtocol
    private final let formulaManager: FormulaManagerProtocol
    private final let soundEngine: AudioEngineProtocol
    private final let logger: CBLogger
    private var frameCounter: Int

    init(size: CGSize,
         logger: CBLogger,
         scheduler: CBSchedulerProtocol,
         frontend: CBFrontendProtocol,
         backend: CBBackendProtocol,
         broadcastHandler: CBBroadcastHandlerProtocol,
         formulaManager: FormulaManagerProtocol,
         soundEngine: AudioEngineProtocol) {
        self.logger = logger
        self.scheduler = scheduler
        self.frontend = frontend
        self.backend = backend
        self.broadcastHandler = broadcastHandler
        self.formulaManager = formulaManager
        self.soundEngine = soundEngine
        self.frameCounter = 0
        super.init(size: size)
        backgroundColor = UIColor.white
    }

    @objc required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Deinitializer
    @objc deinit { logger.info("Dealloc Scene") }

    override func update(_ currentTime: TimeInterval) {

        if frameCounter >= PlayerConfig.NumberOfFramesPerSpriteNodeUpdate {
            frameCounter = 0
            let spriteNodes = scheduler.spriteNodes()
            spriteNodes.forEach { $0.update(currentTime) }
        }

        frameCounter += 1

    }

    // MARK: - Scene events
    @objc override func willMove(from view: SKView) {
        removeAllChildren()
        removeAllActions()
    }

    override func didMove(to view: SKView) {
        view.isMultipleTouchEnabled = true
    }

    func notifyBackgroundChange() {
        logger.debug("StartWhenBackgroundChanges")
        scheduler.startWhenBackgroundChangesContexts()
    }

    func notifyWhenCondition() {
        logger.debug("StartWhenConditionScript")
        scheduler.startWhenConditionContexts()
    }

    @objc
    @discardableResult
    func touchedWithTouch(_ touch: UITouch) -> Bool {
        if !scheduler.running {
            return false
        }

        logger.debug("StartTouchOfScene (x:\(position.x), y:\(position.y))")

        let location = touch.location(in: self)

        //Start all "When screen touched"-scripts
        scheduler.startWhenTouchDownContexts()

        // Get sprite nodes only (ShowTextBrick creates a SKLabelNode)
        let nodes = self.nodes(at: location).filter({ $0 is CBSpriteNode })
        if nodes.isEmpty {
            return false // needed if scene has no background image!
        }

        logger.debug("Number of touched nodes: \(nodes.count)")

        nodes.forEach { print(">>> \(String(describing: $0.name))") }
        for node in nodes {
            guard let currentNode = node as? CBSpriteNode
                else { fatalError("This should not happen!") }
            if currentNode.name == nil {
                return false
            }
            print("Current node: \(currentNode)")
            logger.debug("Current node: \(currentNode)")
            if currentNode.isHidden { continue }

            let newPosition = touch.location(in: currentNode)
            if currentNode.touchedWithTouch(touch, atPosition: newPosition) {
                print("Found sprite node: \(String(describing: currentNode.name)) with zPosition: \(currentNode.zPosition)")
                return true
            } else {
                var zPosition = currentNode.zPosition
                zPosition -= 1
                if zPosition == -1 {
                    logger.debug("Found Object")
                    return true
                }
            }
        }
        return true
    }

    // MARK: - Start project

    @objc func startProject() -> Bool {
        guard let project = frontend.project else {
            //fatalError
            debugPrint("Invalid project. This should never happen!")
            return false
        }

        guard let spriteObjectList = project.scene.objects() as NSArray? as? [SpriteObject],
            let variableList = UserDataContainer.allVariables(for: project) as NSArray? as? [UserVariable] else {
                //fatalError
                debugPrint("!! Invalid sprite object list given !! This should never happen!")
                return false
        }
        assert(Thread.current.isMainThread)

        removeAllChildren() // just to ensure

        var zPosition = LayerSensor.defaultRawValue
        for spriteObject in spriteObjectList {
            let spriteNode = CBSpriteNode(spriteObject: spriteObject)
            spriteNode.name = spriteObject.name
            spriteNode.isHidden = false
            guard let scriptList = spriteObject.scriptList as NSArray? as? [Script] else {
                //fatalError
                debugPrint("!! No script list given in object: \(spriteObject) !!")
                return false
            }

            for script in scriptList {
                guard let startScript = script as? StartScript,
                    let _ = startScript.brickList.firstObject as? HideBrick
                    else { continue }
                spriteNode.isHidden = true
                break
            }

            addChild(spriteNode) // now add the brick with correct visability-state to the Scene

            zPosition = LayerSensor.defaultRawValue(for: spriteObject)
            spriteNode.start(CGFloat(zPosition))
            spriteNode.setLook()
            spriteNode.isUserInteractionEnabled = true
            scheduler.registerSpriteNode(spriteNode)

            for script in scriptList {
                let scriptSequence = frontend.computeSequenceListForScript(script)
                let instructions = backend.instructionsForSequence(scriptSequence.sequenceList)

                logger.info("Generating Context of \(script)")
                var context: CBScriptContext?
                switch script {
                case let startScript as StartScript:
                    context = CBStartScriptContext(
                        startScript: startScript,
                        spriteNode: spriteNode,
                        formulaInterpreter: formulaManager,
                        touchManager: formulaManager.touchManager,
                        state: .runnable)

                case let whenScript as WhenScript:
                    context = CBWhenScriptContext(
                        whenScript: whenScript,
                        spriteNode: spriteNode,
                        formulaInterpreter: formulaManager,
                        touchManager: formulaManager.touchManager,
                        state: .runnable)

                case let whenTouchDownScript as WhenTouchDownScript:
                    context = CBWhenTouchDownScriptContext(
                        whenTouchDownScript: whenTouchDownScript,
                        spriteNode: spriteNode,
                        formulaInterpreter: formulaManager,
                        touchManager: formulaManager.touchManager,
                        state: .runnable)

                case let whenBackgroundChangesScript as WhenBackgroundChangesScript:
                    context = CBWhenBackgroundChangesScriptContext(
                        whenBackgroundChangesScript: whenBackgroundChangesScript,
                        spriteNode: spriteNode,
                        formulaInterpreter: formulaManager,
                        touchManager: formulaManager.touchManager,
                        state: .runnable)

                case let bcScript as BroadcastScript:
                    context = CBBroadcastScriptContext(
                        broadcastScript: bcScript,
                        spriteNode: spriteNode,
                        formulaInterpreter: formulaManager,
                        touchManager: formulaManager.touchManager,
                        state: .runnable)
                    if let broadcastContext = context as? CBBroadcastScriptContext {
                        broadcastHandler.subscribeBroadcastContext(broadcastContext)
                    }

                case let whenConditionScript as WhenConditionScript:
                    context = CBWhenConditionScriptContext(
                        whenConditionScript: whenConditionScript,
                        spriteNode: spriteNode,
                        formulaInterpreter: formulaManager,
                        touchManager: formulaManager.touchManager,
                        state: .runnable)

                default:
                    break
                }
                guard var scriptContext = context else {
                    //fatalError
                    debugPrint("Unknown script! THIS SHOULD NEVER HAPPEN!")
                    return false
                }
                scriptContext += instructions // generate instructions and add them to script context
                scheduler.registerContext(scriptContext)
            }
        }
        for variable: UserVariable in variableList {
            let label = SKLabelNode(fontNamed: SpriteKitDefines.defaultFont)
            variable.textLabel = label
            variable.textLabel?.text = ""
            variable.textLabel?.zPosition = CGFloat(zPosition + 1)
            variable.textLabel?.fontColor = UIColor.black
            variable.textLabel?.fontSize = CGFloat(SpriteKitDefines.defaultLabelFontSize)
            variable.textLabel?.isHidden = true
            variable.textLabel?.horizontalAlignmentMode = .center
            addChild(label)
        }

        formulaManager.setup(for: project, and: self)
        soundEngine.start()
        scheduler.run()
        return true
    }

    @objc func pauseScheduler() {
        scheduler.pause()
        formulaManager.pause()
    }

    @objc func resumeScheduler() {
        scheduler.resume()
        formulaManager.resume()
    }

    @objc func getSoundEngine() -> AudioEngineProtocol {
        self.soundEngine
    }

    // MARK: - Stop project
    @objc func stopProject() {
        view?.isPaused = true
        scheduler.shutdown() // stops all script contexts of all objects and removes all ressources
        removeAllChildren() // remove all CBSpriteNodes from Scene
        frontend.project?.removeReferences() // remove all references in project hierarchy
        formulaManager.stop()
        logger.info("All SpriteObjects and Scripts have been removed from Scene!")
        soundEngine.stop()
    }

    func clearPenLines() {

        self.enumerateChildNodes(withName: SpriteKitDefines.penShapeNodeName) { node, _ in
            guard let line = node as? LineShapeNode else {
                fatalError("Could not cast SKNode named SpriteKitDefines.penShapeNodeName to LineShapeNode")
            }
            line.removeFromParent()
        }

    }

    func clearStampedSpriteNodes() {

        self.enumerateChildNodes(withName: SpriteKitDefines.stampedSpriteNodeName) { node, _ in
            node.removeFromParent()
        }

    }
}
