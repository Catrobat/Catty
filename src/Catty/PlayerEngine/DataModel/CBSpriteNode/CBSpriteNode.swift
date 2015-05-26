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

@objc final class CBSpriteNode : SKSpriteNode {

    // MARK: - Properties
    private(set) var spriteObject: SpriteObject?
//    var originalSize: CGSize
    var currentLook: Look?
    var currentUIImageLook: UIImage?
    var currentLookBrightness: CGFloat = 1.0
    var scenePosition : CGPoint {
        set { self.position = (scene as! CBPlayerScene).convertPointToScene(newValue) }
        get { return (scene as! CBPlayerScene).convertSceneCoordinateToPoint(self.position) }
    }
    var xPosition: CGFloat { return self.scenePosition.x }
    var yPosition: CGFloat { return self.scenePosition.y }
    var zIndex: CGFloat { return zPosition }
    var brightness: CGFloat { return (100 * self.currentLookBrightness) }
    var scaleX: CGFloat { return (100 * xScale) }
    var scaleY: CGFloat { return (100 * yScale) }
    var rotation: Double {
        set {
            var rotationInDegrees = newValue%360.0 // swift equivalent for fmodf
            if rotationInDegrees < 0.0 {
                rotationInDegrees += 360.0
            }
            self.zRotation = CGFloat(Util.degreeToRadians(rotationInDegrees))
        }
        get {
            var rotation = Util.radiansToDegree(Double(self.zRotation))%360.0 // swift equivalent for fmodf
            if (rotation < 0.0) { rotation += 360.0 }
            return rotation
        }
    }
    // MARK: Custom getters and setters
    func setPositionForCropping(position: CGPoint) {
        self.position = position
    }

    // MARK: - Initializers
    required init(spriteObject: SpriteObject) {
        let color = UIColor.clearColor()
        self.spriteObject = spriteObject
        if let firstLook = spriteObject.lookList.firstObject as? Look,
           let filePathForLook = spriteObject.pathForLook(firstLook),
           let image = UIImage(contentsOfFile:filePathForLook)
        {
            let texture = SKTexture(image: image)
            let textureSize = texture.size()
            super.init(texture: texture, color: color, size: textureSize)
            self.currentLook = firstLook
            self.currentLook = firstLook
        } else {
            super.init(color: color, size: CGSizeZero)
        }
        self.spriteObject = spriteObject
        setLook()
        self.name = spriteObject.name
        spriteObject.spriteNode = self
    }

    override init(texture: SKTexture, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Operations
    func nextLook() -> Look? {
        if currentLook == nil {
            return nil
        }
        if let spriteObject = self.spriteObject {
            var index = spriteObject.lookList.indexOfObject(currentLook!)
            ++index
            index %= spriteObject.lookList.count
            return spriteObject.lookList[index] as? Look
        }
        return nil
    }

    func changeLook(look: Look?) {
        if look == nil { return }
        let filePathForLook = spriteObject?.pathForLook(look)
        if filePathForLook == nil { return }
        let image = UIImage(contentsOfFile:filePathForLook!)
        if image == nil { return }
        let texture = SKTexture(image: image!)
        if spriteObject?.isBackground() == true {
            self.currentUIImageLook = image
            self.size = texture.size()
        } else {
            // We do not need cropping if touch through transparent pixel is possible!!!!
            
            //        CGRect newRect = [image cropRectForImage:image];
            
            //        if ((newRect.size.height <= image.size.height - 50 && newRect.size.height <= image.size.height - 50)) {
            //            CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, newRect);
            //            UIImage *newImage = [UIImage imageWithCGImage:imageRef];
            ////            NSLog(@"%f,%f,%f,%f",newRect.origin.x,newRect.origin.y,newRect.size.width,newRect.size.height);
            //            [self setPositionForCropping:CGPointMake(newRect.origin.x+newRect.size.width/2,self.scene.size.height-newRect.origin.y-newRect.size.height/2)];
            //            CGImageRelease(imageRef);
            //            texture = [SKTexture textureWithImage:newImage];
            //            self.currentUIImageLook = newImage;
            //        }
            //        else{
            self.currentUIImageLook = image
            //        }
            self.size = texture.size()
        }
        let xScale = self.xScale
        let yScale = self.yScale
        self.xScale = 1.0
        self.yScale = 1.0
        self.texture = texture
        self.currentLook = look
        if xScale != 1.0 {
            self.xScale = xScale;
        }
        if yScale != 1.0 {
            self.yScale = yScale
        }
    }

    func setLook() {
        if spriteObject?.lookList.count > 0 {
            changeLook(spriteObject?.lookList[0] as? Look)
        }
    }

    // MARK: Events
    func start(zPosition: CGFloat) {
        self.scenePosition = CGPointMake(0, 0)
        self.zRotation = 0
        self.currentLookBrightness = 0
        if spriteObject?.isBackground() == true {
            self.zPosition = 0
        } else {
            self.zPosition = zPosition
        }
    }

    func touchedWithTouches(touches: NSSet, withX x: CGFloat, andY y: CGFloat) -> Bool {
        let playerScene = (scene as! CBPlayerScene)
        let scheduler = playerScene.scheduler
        if scheduler?.running == false {
            return false
        }
        let frontend = playerScene.frontend
        let backend = playerScene.backend
        for touchAnyObject in touches {
            let touch = touchAnyObject as! UITouch
            let touchedPoint = touch.locationInNode(self)
//                NSDebug(@"x:%f,y:%f", touchedPoint.x, touchedPoint.y);
            //NSDebug(@"test touch, %@",self.name);
            //        UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, [UIScreen mainScreen].scale);
            //        [self.scene.view drawViewHierarchyInRect:self.frame afterScreenUpdates:NO];
            //        UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
            //        UIGraphicsEndImageContext();
//                NSDebug(@"image : x:%f,y:%f", self.currentUIImageLook.size.width, self.currentUIImageLook.size.height);
            let isTransparent = self.currentUIImageLook?.isTransparentPixel(self.currentUIImageLook, withX:touchedPoint.x, andY:touchedPoint.y)
            if isTransparent == true {
//                    NSDebug(@"I'm transparent at this point");
                return false
            }
            if let spriteObject = self.spriteObject, let scriptList = spriteObject.scriptList as NSArray as? [Script] {
                for script in scriptList {
                    if let whenScript = script as? WhenScript {
                        if scheduler?.isScriptRunning(whenScript) == false {
                            if let sequenceList = frontend?.computeSequenceListForScript(whenScript),
                               let scriptExecContext = backend?.executionContextForScriptSequenceList(sequenceList, spriteNode: self)
                            {
                                scheduler?.addScriptExecContext(scriptExecContext)
                                scheduler?.startScript(whenScript)
                            }
                        } else {
                            scheduler?.restartScript(whenScript)
                        }
                    }
                }
            }
            return true
        }
        return true
    }

    // MARK: Helper
    class func spriteNodeWithName(name: String, inScene scene: SKScene) -> CBSpriteNode? {
        return scene.childNodeWithName(name) as? CBSpriteNode
    }
}
