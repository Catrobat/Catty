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

import SpriteKit
import ReplayKit

final class CBScene: SKScene {

    // MARK: - Properties
    let logger: CBLogger?

    /// ReplayKit preview view controller used when viewing recorded content.
    private var _previewViewController: AnyObject?
    @available(iOS 9.0, *)
    var previewViewController: RPPreviewViewController? {
        get {
            return _previewViewController as? RPPreviewViewController
        }
        set {
            _previewViewController = newValue
        }
    }
    private(set) var scheduler: CBSchedulerProtocol?
    private(set) var frontend: CBFrontendProtocol?
    private(set) var backend: CBBackendProtocol?
    private(set) var broadcastHandler: CBBroadcastHandlerProtocol?

    // MARK: - Initializers

    // MARK: Convenient initializer
    // ATTENTION: This initializer may only be used for single action testing purposes!!
    convenience override init() {
        self.init(size: CGSizeZero)
    }

    // MARK: initializer
    // Note: This initializer may only be used for single action testing purposes!!
    override init(size: CGSize) {
        logger = nil
        scheduler = nil
        frontend = nil
        backend = nil
        broadcastHandler = nil
        super.init(size: size)
    }

    // MARK: Designated initializer
    init(size: CGSize, logger: CBLogger, scheduler: CBScheduler, frontend: CBFrontend,
        backend: CBBackend, broadcastHandler: CBBroadcastHandlerProtocol)
    {
        self.logger = logger
        self.scheduler = scheduler
        self.frontend = frontend
        self.backend = backend
        self.broadcastHandler = broadcastHandler
        super.init(size: size)
        backgroundColor = UIColor.whiteColor()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Deinitializer
    deinit { logger?.info("Dealloc Scene") }

    // MARK: - Scene events
    override func willMoveFromView(view: SKView) {
        removeAllChildren()
        removeAllActions()
    }

    override func didMoveToView(view: SKView) {
        startProgram()
    }

    func touchedWithTouches(touches: NSSet, withX x:CGFloat, andY y:CGFloat) -> Bool {
        if scheduler?.running == false {
            return false
        }

        logger?.debug("StartTouchOfScene")
        if let touch = touches.anyObject() as? UITouch {
            let location = touch.locationInNode(self)
            logger?.debug("x:\(location.x),y:\(location.y)")
            var foundObject = false
            let nodesAtPoint = self.nodesAtPoint(location)
            if nodesAtPoint.count == 0 {
                return false
            }

            var spriteNode1 = nodesAtPoint[nodesAtPoint.count - 1] as? CBSpriteNode
            var counter = nodesAtPoint.count - 2
            logger?.debug("How many nodes are touched: \(counter)")
            logger?.debug("First Node:\(spriteNode1)")
            if spriteNode1?.name == nil {
                return false
            }

            while foundObject == false {
                let point = touch.locationInNode(spriteNode1!)
                if spriteNode1?.hidden == false {
                    if spriteNode1?.touchedWithTouches(touches as Set<NSObject>, withX:point.x, andY:point.y) == false {
                        if var zPosition = spriteNode1?.zPosition {
                            zPosition -= 1
                            if (zPosition == -1) || (counter < 0) {
                                foundObject = true
                                logger?.debug("Found Object")
                            } else {
                                spriteNode1 = nodesAtPoint[counter] as? CBSpriteNode
                                logger?.debug("NextNode: \(spriteNode1)")
                                --counter
                            }
                        }
                    } else {
                        foundObject = true
                        logger?.debug("Found Object")
                    }
                } else if spriteNode1 != nil {
                    if counter < 0 {
                        foundObject = true
                    } else {
                        spriteNode1 = nodesAtPoint[counter] as? CBSpriteNode
                        logger?.debug("NextNode: \(spriteNode1)")
                        --counter
                    }
                }
            }
            return true
        }
        return false
    }

    func touchedWithTouch(touch: UITouch, atPosition position: CGPoint) -> Bool {
        assert(scheduler?.running == true)
        logger?.debug("StartTouchOfScene (x:\(position.x), y:\(position.y))")
        var nodes = nodesAtPoint(position)
        let numberOfNodes = nodes.count
        if numberOfNodes == 0 { return false } // needed if scene has no background image!

        var nodeIndex = numberOfNodes
        logger?.debug("Number of touched nodes: \(nodeIndex)")

        nodes.forEach { print(">>> \($0.name)") }
        while --nodeIndex >= 0 {
            guard let currentNode = nodes[nodeIndex] as? CBSpriteNode
            else { fatalError("This should not happen!") }

            print("Current node: \(currentNode)")
            logger?.debug("Current node: \(currentNode)")
            if currentNode.hidden { continue }

            let newPosition = touch.locationInNode(currentNode)
            if currentNode.touchedWithTouch(touch, atPosition: newPosition) {
                print("Found sprite node: \(currentNode.name) with logical index: \(nodeIndex)")
                return true
            }
        }
        return true
    }


    // MARK: - Start program
    func startProgram() {
        guard var spriteObjectList = frontend?.program?.objectList as NSArray? as? [SpriteObject]
        else { fatalError("!! Invalid sprite object list given !! This should never happen!") }
        assert(NSThread.currentThread().isMainThread)

        removeAllChildren() // just to ensure

        if #available(iOS 9, *) { // FIXME!!! detect + consider iPhone/iPad version
            spriteObjectList = spriteObjectList.reverse()
        }

        var zPosition = 1
        for spriteObject in spriteObjectList {
            let spriteNode = CBSpriteNode(spriteObject: spriteObject)
            spriteNode.name = spriteObject.name
            spriteNode.hidden = false
            guard let scriptList = spriteObject.scriptList as NSArray? as? [Script]
            else { fatalError("!! No script list given in object: \(spriteObject) !!") }

            for script in scriptList {
                guard let startScript = script as? StartScript,
                                    _ = startScript.brickList.firstObject as? HideBrick
                else { continue }
                spriteNode.hidden = true
                break
            }

            addChild(spriteNode) // now add the brick with correct visability-state to the Scene
            logger?.debug("\(zPosition)")
            spriteNode.start(CGFloat(zPosition))
            spriteNode.setLook()
            spriteNode.userInteractionEnabled = true
            if spriteNode.spriteObject?.isBackground() == false {
                ++zPosition
            }
            scheduler?.registerSpriteNode(spriteNode)

            for script in scriptList {
                guard let scriptSequence = frontend?.computeSequenceListForScript(script),
                      let instructions = backend?.instructionsForSequence(scriptSequence.sequenceList)
                else { fatalError("Unable to create ScriptSequence and Context") }

                logger?.info("Generating Context of \(script)")
                var context: CBScriptContext? = nil

                switch script {
                case let startScript as StartScript:
                    context = CBStartScriptContext(
                        startScript: startScript,
                        spriteNode: spriteNode,
                        state: .Runnable
                    )

                case let whenScript as WhenScript:
                    context = CBWhenScriptContext(
                        whenScript: whenScript,
                        spriteNode: spriteNode,
                        state: .Runnable
                    )

                case let bcScript as BroadcastScript:
                    let broadcastContext = CBBroadcastScriptContext(
                        broadcastScript: bcScript,
                        spriteNode: spriteNode,
                        state: .Runnable
                    )
                    broadcastHandler?.subscribeBroadcastContext(broadcastContext)
                    context = broadcastContext

                default:
                    fatalError("Unknown script! THIS SHOULD NEVER HAPPEN!")
                }
                context! += instructions // generate instructions and add them to script context
                scheduler?.registerContext(context!)
            }
        }

        if #available(iOS 9.0, *) {
            startScreenRecording()
            // TODO: handle microphone error...
        }
        scheduler?.run()
    }

    func stopScreenRecording() {
        if #available(iOS 9.0, *) {
            stopScreenRecordingWithHandler { [weak self] in
                guard let previewViewController = self?.previewViewController,
                      let rootViewController = self?.view?.window?.rootViewController
                else { fatalError("Preview controller or root view controller not available.") }

                // NOTE: RPPreviewViewController only supports full screen modal presentation.
                previewViewController.modalPresentationStyle = .FullScreen
                rootViewController.presentViewController(previewViewController,
                    animated: true, completion: nil)
            }
        }
    }

    // MARK: - Stop program
    func stopProgram() {
        view?.paused = true
        scheduler?.shutdown() // stops all script contexts of all objects and removes all ressources
        removeAllChildren() // remove all CBSpriteNodes from Scene
        frontend?.program?.removeReferences() // remove all references in program hierarchy
        logger?.info("All SpriteObjects and Scripts have been removed from Scene!")
    }

    // MARK: - Operations (Helpers)
    func convertPointToScene(point: CGPoint) -> CGPoint {
        let x = convertXCoordinateToScene(point.x)
        let y = convertYCoordinateToScene(point.y)
        return CGPoint(x: x, y: y)
    }

    func convertXCoordinateToScene(x: CGFloat) -> CGFloat {
        return (size.width/2.0 + x)
    }

    func convertYCoordinateToScene(y: CGFloat) -> CGFloat {
        return (size.height/2.0 + y)
    }

    func convertSceneCoordinateToPoint(point: CGPoint) -> CGPoint {
        let x = point.x - size.width/2.0
        let y = point.y - size.height/2.0
        return CGPointMake(x, y);
    }

    func convertDegreesToScene(degrees: Double) -> Double {
        return 360.0 - degrees
    }

    func convertSceneToDegrees(degrees: CGFloat) -> CGFloat {
        return 360.0 + degrees
    }
}
