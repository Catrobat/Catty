/**
 *  Copyright (C) 2010-2016 The Catrobat Team
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

@objc protocol CBScreenRecordingDelegate {
    func showMenuRecordButton()
    func hideMenuRecordButton()
}

final class CBScene: SKScene {

    // MARK: - Properties
    let logger: CBLogger?

    /// ReplayKit preview view controller used when viewing recorded content.
    private var _previewViewController: AnyObject?
    @available(iOS 9.0, *)
    var previewViewController: RPPreviewViewController? {
        get { return _previewViewController as? RPPreviewViewController }
        set { _previewViewController = newValue }
    }
    private(set) var scheduler: CBSchedulerProtocol?
    private(set) var frontend: CBFrontendProtocol?
    private(set) var backend: CBBackendProtocol?
    private(set) var broadcastHandler: CBBroadcastHandlerProtocol?
    var isScreenRecorderAvailable: Bool {
        if #available(iOS 9.0, *) {
            return RPScreenRecorder.sharedRecorder().available
        }
        return false
    }
    var isScreenRecording: Bool {
        if #available(iOS 9.0, *) {
            return RPScreenRecorder.sharedRecorder().recording
        }
        return false
    }
    weak var screenRecordingDelegate: CBScreenRecordingDelegate?

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
        view.multipleTouchEnabled = true
        startProgram()
    }

    func touchedWithTouch(touch: UITouch) -> Bool {
        assert(scheduler?.running == true)
        logger?.debug("StartTouchOfScene (x:\(position.x), y:\(position.y))")
        
        let location = touch.locationInNode(self)
        var nodes = nodesAtPoint(location)
        if #available(iOS 9.0, *) {
            nodes = nodes.reverse()
        }
        let numberOfNodes = nodes.count
        if numberOfNodes == 0 { return false } // needed if scene has no background image!
        
        logger?.debug("Number of touched nodes: \(numberOfNodes)")
        var nodeIndex = numberOfNodes - 1
        
        nodes.forEach { print(">>> \($0.name)") }
        while nodeIndex >= 0 {
            guard let currentNode = nodes[nodeIndex] as? CBSpriteNode
                else { fatalError("This should not happen!") }
            if currentNode.name == nil {
                return false
            }
            print("Current node: \(currentNode)")
            logger?.debug("Current node: \(currentNode)")
            if currentNode.hidden { continue }
            
            let newPosition = touch.locationInNode(currentNode)
            if currentNode.touchedWithTouch(touch, atPosition: newPosition) {
                print("Found sprite node: \(currentNode.name) with logical index: \(nodeIndex)")
                return true
            } else {
                var zPosition = currentNode.zPosition
                zPosition -= 1
                if (zPosition == -1) {
                    return true;
                    logger?.debug("Found Object")
                }
                
            }
            nodeIndex -= 1
        }
        return true
    }


    // MARK: - Start program
    func startProgram() {
        guard let spriteObjectList = frontend?.program?.objectList as NSArray? as? [SpriteObject], let variableList = frontend?.program?.variables.allVariables() as NSArray? as? [UserVariable]
        else { fatalError("!! Invalid sprite object list given !! This should never happen!") }
        assert(NSThread.currentThread().isMainThread)

        removeAllChildren() // just to ensure

        if #available(iOS 9, *) { // FIXME!!! detect + consider iPhone/iPad version
//            spriteObjectList = spriteObjectList.reverse()
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
                zPosition += 1
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
        for variable:UserVariable in variableList {
            variable.textLabel = SKLabelNode()
            variable.textLabel.text = ""
            variable.textLabel.zPosition = CGFloat(zPosition + 1)
            variable.textLabel.fontColor = UIColor.blackColor()
            variable.textLabel.fontSize = 16
            variable.textLabel.hidden = true
            addChild(variable.textLabel)
        }

        scheduler?.run()
    }

    func initializeScreenRecording() {
        if #available(iOS 9.0, *) {
            RPScreenRecorder.sharedRecorder().delegate = self
        }
    }

    func startScreenRecording() {
        if #available(iOS 9.0, *) {
            _startScreenRecording()
        }
    }

    func stopScreenRecording() {
        if #available(iOS 9.0, *) {
            _stopScreenRecordingWithHandler { [weak self] in
                guard let rootVC = self?.view?.window?.rootViewController,
                      let previewVC = self?.previewViewController
                else { fatalError("Preview controller or root view controller not available.") }

                // NOTE: RPPreviewViewController only supports full screen modal presentation.
                previewVC.modalPresentationStyle = .FullScreen
                rootVC.presentViewController(previewVC, animated: true, completion: nil)
            }
        }
    }

    func pauseScheduler() {
        scheduler?.pause()
    }
    
    func resumeScheduler() {
        scheduler?.resume()
    }
    
    // MARK: - Stop program
    func stopProgram() {
        view?.paused = true
        scheduler?.shutdown() // stops all script contexts of all objects and removes all ressources
        removeAllChildren() // remove all CBSpriteNodes from Scene
        frontend?.program?.removeReferences() // remove all references in program hierarchy
        logger?.info("All SpriteObjects and Scripts have been removed from Scene!")
    }

}
