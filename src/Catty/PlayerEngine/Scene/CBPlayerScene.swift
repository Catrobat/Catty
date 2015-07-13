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

//#if os(iOS9)
    import ReplayKit
//#endif

final class CBPlayerScene : SKScene {

    // MARK: - Properties
    let logger : CBLogger?

//    #if os(iOS9)
    /// ReplayKit preview view controller used when viewing recorded content.
    var previewViewController: RPPreviewViewController?
//    #endif

    private(set) var scheduler : CBPlayerSchedulerProtocol?
    private(set) var frontend : CBPlayerFrontendProtocol?
    private(set) var backend : CBPlayerBackendProtocol?
    private(set) var broadcastHandler : CBPlayerBroadcastHandlerProtocol?

    // MARK: - Initializers

    // MARK: Convenient initializer
    // ATTENTION: This initializer may only be used for single action testing purposes!!
    convenience override init() {
        self.init(size: CGSizeZero)
    }

    // MARK: initializer
    // ATTENTION: This initializer may only be used for single action testing purposes!!
    override init(size: CGSize) {
        logger = nil
        scheduler = nil
        frontend = nil
        backend = nil
        broadcastHandler = nil
        super.init(size: size)
    }

    // MARK: Designated initializer
    init(size: CGSize, logger: CBLogger, scheduler: CBPlayerScheduler, frontend: CBPlayerFrontend,
        backend: CBPlayerBackend, broadcastHandler: CBPlayerBroadcastHandlerProtocol)
    {
        self.logger = logger
        self.scheduler = scheduler
        self.frontend = frontend
        self.backend = backend
        self.broadcastHandler = broadcastHandler
        super.init(size: size)
        self.backgroundColor = UIColor.whiteColor()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Deinitializer
    deinit {
        logger?.info("Dealloc Scene")
    }

    // MARK: - Scene events
    override func willMoveFromView(view: SKView) {
        self.removeAllChildren()
        self.removeAllActions()
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

    // MARK: - Start program
    func startProgram() {

        // sanity check
        if NSThread.currentThread().isMainThread == false {
            logger?.error(" ")
            logger?.error("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
            logger?.error("!!                                                                                       !!")
            logger?.error("!! FATAL: THIS METHOD SHOULD NEVER EVER BE CALLED FROM ANOTHER THREAD EXCEPT MAIN-THREAD !!")
            logger?.error("!!                                                                                       !!")
            logger?.error("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
            logger?.error(" ")
            abort()
        }

        // init and prepare Scene
        self.removeAllChildren() // just to ensure

        var zPosition = 1.0
        var spriteNodes = [String:CBSpriteNode]()
        guard let spriteObjectList = frontend?.program?.objectList as NSArray? as? [SpriteObject] else {
            logger?.error("!! Invalid sprite object list given !! This should never happen!")
            return
        }
        for spriteObject in spriteObjectList {
            let spriteNode = CBSpriteNode(spriteObject: spriteObject)
            spriteNode.hidden = false
            guard let scriptList = spriteObject.scriptList as NSArray? as? [Script] else {
                logger?.error("!! No script list given in object: \(spriteObject) !! This should never happen!")
                return
            }
            for script in scriptList {
                guard let startScript = script as? StartScript,
                      let _ = startScript.brickList.firstObject as? HideBrick else {
                    continue
                }
                spriteNode.hidden = true
                break
            }

            // now add the brick with correct visability-state to the Scene
            addChild(spriteNode)
            spriteNodes[spriteObject.name] = spriteNode
            logger?.debug("\(zPosition)")
            spriteNode.start(CGFloat(zPosition))
            spriteNode.setLook()
            spriteNode.userInteractionEnabled = true
            if spriteNode.spriteObject?.isBackground() == false {
                ++zPosition;
            }
        }

        // compute all sequence lists
        for spriteObject in spriteObjectList {
            guard let scriptList = spriteObject.scriptList as NSArray as? [Script] else { return }
            for script in scriptList {
                guard let scriptSequence = frontend?.computeSequenceListForScript(script),
                      let scriptContext = backend?.scriptContextForSequenceList(scriptSequence) else {
                    fatalError("Unable to create ScriptSequence and ScriptContext")
                }

                // register script
                scheduler?.registerContext(scriptContext)

                // IMPORTANT: BroadcastHandler registration for broadcast scripts required
                guard let bcsContext = scriptContext as? CBBroadcastScriptContext else { continue }
                broadcastHandler?.subscribeBroadcastScriptContext(bcsContext)
            }
        }
        if #available(iOS 9.0, *) {
            startScreenRecording()
        }
        scheduler?.run()
    }

    func stopScreenRecording() {
        if #available(iOS 9.0, *) {
            stopScreenRecordingWithHandler {
                //        if #available(iOS 9, *) {
                guard let previewViewController = self.previewViewController else {
                    fatalError("The user requested playback, but a valid preview controller does not exist.")
                }
                guard let rootViewController = self.view?.window?.rootViewController else {
                    fatalError("The scene must be contained in a window with e root view controller.")
                }
                // RPPreviewViewController only supports full screen modal presentation.
                previewViewController.modalPresentationStyle = UIModalPresentationStyle.FullScreen
                rootViewController.presentViewController(previewViewController, animated:true, completion:nil)
                //        }
            }
        }
    }

    // MARK: - Stop program
    func stopProgram() {

        view?.paused = true // pause scene!
        scheduler?.shutdown() // stops scheduler and removes all ressources

        // now all (!) scripts of all (!) objects have been finished!
        // we can safely remove all CBSpriteNodes from Scene
        removeAllChildren()
        // finally remove all references in program hierarchy
        frontend?.program?.removeReferences()
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

    func convertDegreesToScene(degrees: CGFloat) -> CGFloat {
        return 360.0 - degrees
    }

    func convertSceneToDegrees(degrees: CGFloat) -> CGFloat {
        return 360.0 + degrees
    }
}
