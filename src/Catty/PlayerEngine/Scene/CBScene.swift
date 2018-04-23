/**
 *  Copyright (C) 2010-2018 The Catrobat Team
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

@objc
final class CBScene: SKScene {

    // MARK: - Properties
    let logger: CBLogger?

    /// ReplayKit preview view controller used when viewing recorded content.
    private var _previewViewController: AnyObject?
    @available(iOS 9.0, *)
    @objc var previewViewController: RPPreviewViewController? {
        get { return _previewViewController as? RPPreviewViewController }
        set { _previewViewController = newValue }
    }
    private(set) var scheduler: CBSchedulerProtocol?
    private(set) var frontend: CBFrontendProtocol?
    private(set) var backend: CBBackendProtocol?
    private(set) var broadcastHandler: CBBroadcastHandlerProtocol?
    @objc var isScreenRecorderAvailable: Bool {
    return RPScreenRecorder.shared().isAvailable
    
    }
    @objc var isScreenRecording: Bool {
        return RPScreenRecorder.shared().isRecording
    }
    @objc weak var screenRecordingDelegate: CBScreenRecordingDelegate?

    // MARK: - Initializers

    // MARK: Convenient initializer
    // ATTENTION: This initializer may only be used for single action testing purposes!!
    @objc convenience override init() {
        self.init(size: CGSize.zero)
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
        backgroundColor = UIColor.white
    }

    @objc required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Deinitializer
    @objc deinit { logger?.info("Dealloc Scene") }

    // MARK: - Scene events
    @objc override func willMove(from view: SKView) {
        removeAllChildren()
        removeAllActions()
    }

    override func didMove(to view: SKView) {
        view.isMultipleTouchEnabled = true
        startProgram()
    }

    @objc
    @discardableResult
    func touchedWithTouch(_ touch: UITouch) -> Bool {
        assert(scheduler?.running == true)
        logger?.debug("StartTouchOfScene (x:\(position.x), y:\(position.y))")
        
        let location = touch.location(in: self)
        
        // Get sprite nodes only (ShowTextBrick creates a SKLabelNode)
        let nodes = self.nodes(at: location).filter({$0 is CBSpriteNode})
        if nodes.count == 0 { return false } // needed if scene has no background image!
        
        logger?.debug("Number of touched nodes: \(nodes.count)")
        
        nodes.forEach { print(">>> \(String(describing: $0.name))") }
        for node in nodes {
            guard let currentNode = node as? CBSpriteNode
                else { fatalError("This should not happen!") }
            if currentNode.name == nil {
                return false
            }
            print("Current node: \(currentNode)")
            logger?.debug("Current node: \(currentNode)")
            if currentNode.isHidden { continue }
            
            let newPosition = touch.location(in: currentNode)
            if currentNode.touchedWithTouch(touch, atPosition: newPosition) {
                print("Found sprite node: \(String(describing: currentNode.name)) with zPosition: \(currentNode.zPosition)")
                return true
            } else {
                var zPosition = currentNode.zPosition
                zPosition -= 1
                if (zPosition == -1) {
                    logger?.debug("Found Object")
                    return true
                }
            }
        }
        return true
    }


    // MARK: - Start program
    @objc func startProgram() {
        guard let spriteObjectList = frontend?.program?.objectList as NSArray? as? [SpriteObject], let variableList = frontend?.program?.variables.allVariables() as NSArray? as? [UserVariable]
        else { fatalError("!! Invalid sprite object list given !! This should never happen!") }
        assert(Thread.current.isMainThread)

        removeAllChildren() // just to ensure


        var zPosition = 1
        for spriteObject in spriteObjectList {
            let spriteNode = CBSpriteNode(spriteObject: spriteObject)
            spriteNode.name = spriteObject.name
            spriteNode.isHidden = false
            guard let scriptList = spriteObject.scriptList as NSArray? as? [Script]
            else { fatalError("!! No script list given in object: \(spriteObject) !!") }

            for script in scriptList {
                guard let startScript = script as? StartScript,
                                    let _ = startScript.brickList.firstObject as? HideBrick
                else { continue }
                spriteNode.isHidden = true
                break
            }

            addChild(spriteNode) // now add the brick with correct visability-state to the Scene
            logger?.debug("\(zPosition)")
            spriteNode.start(CGFloat(zPosition))
            spriteNode.setLook()
            spriteNode.isUserInteractionEnabled = true
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
                    context = CBStartScriptContext(startScript: startScript, spriteNode: spriteNode, state: .runnable)

                case let whenScript as WhenScript:
                    context = CBWhenScriptContext(whenScript: whenScript, spriteNode: spriteNode, state: .runnable)

                case let bcScript as BroadcastScript:
                    context = CBBroadcastScriptContext(broadcastScript: bcScript, spriteNode: spriteNode, state: .runnable)
                    if let broadcastContext = context as? CBBroadcastScriptContext {
                        broadcastHandler?.subscribeBroadcastContext(broadcastContext)
                    }
                default:
                    break
                }
                guard var scriptContext = context else {
                    fatalError("Unknown script! THIS SHOULD NEVER HAPPEN!")
                }
                scriptContext += instructions // generate instructions and add them to script context
                scheduler?.registerContext(scriptContext)
            }
        }
        for variable:UserVariable in variableList {
            variable.textLabel = SKLabelNode()
            variable.textLabel.text = ""
            variable.textLabel.zPosition = CGFloat(zPosition + 1)
            variable.textLabel.fontColor = UIColor.black
            variable.textLabel.fontSize = 16
            variable.textLabel.isHidden = true
            addChild(variable.textLabel)
        }

        scheduler?.run()
    }

    @objc func initializeScreenRecording() {
        RPScreenRecorder.shared().delegate = self
    }

    @objc func startScreenRecording() {
        _startScreenRecording()
    }

    @objc func stopScreenRecording() {
        
        _stopScreenRecordingWithHandler { [weak self] in
            guard let rootVC = self?.view?.window?.rootViewController,
                    let previewVC = self?.previewViewController
                    else { fatalError("Preview controller or root view controller not available.") }

            // NOTE: RPPreviewViewController only supports full screen modal presentation.
            previewVC.modalPresentationStyle = .fullScreen
            rootVC.present(previewVC, animated: true, completion: nil)
        }
    }

    @objc func pauseScheduler() {
        scheduler?.pause()
    }
    
    @objc func resumeScheduler() {
        scheduler?.resume()
    }
    
    // MARK: - Stop program
    @objc func stopProgram() {
        view?.isPaused = true
        scheduler?.shutdown() // stops all script contexts of all objects and removes all ressources
        removeAllChildren() // remove all CBSpriteNodes from Scene
        frontend?.program?.removeReferences() // remove all references in program hierarchy
        logger?.info("All SpriteObjects and Scripts have been removed from Scene!")
    }

}
