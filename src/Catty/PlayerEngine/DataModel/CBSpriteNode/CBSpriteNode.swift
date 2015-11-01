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

final class CBSpriteNode: SKSpriteNode {

    // MARK: - Properties
    private(set) var spriteObject: SpriteObject?
    var currentLook: Look?
    var currentUIImageLook: UIImage?
    var currentLookBrightness: CGFloat = 1.0
    var scenePosition: CGPoint {
        set { self.position = (scene as! CBScene).convertPointToScene(newValue) }
        get { return (scene as! CBScene).convertSceneCoordinateToPoint(self.position) }
    }
    var zIndex: CGFloat { return zPosition }
    var brightness: CGFloat { return (100 * self.currentLookBrightness) }
    var scaleX: CGFloat { return (100 * xScale) }
    var scaleY: CGFloat { return (100 * yScale) }
    var rotation: Double {
        set {
            var rotationInDegrees = newValue%360.0 // swift equivalent for fmodf
            if rotationInDegrees < 0.0 { rotationInDegrees += 360.0 }
            self.zRotation = CGFloat(Util.degreeToRadians(rotationInDegrees))
        }
        get {
            var rotation = Util.radiansToDegree(Double(self.zRotation))%360.0 // swift equivalent for fmodf
            if (rotation < 0.0) { rotation += 360.0 }
            return rotation
        }
    }
    private var _lastTimeTouchedSpriteNode = [String:NSDate]()

    // MARK: Custom getters and setters
    func setPositionForCropping(position: CGPoint) {
        self.position = position
    }

    // MARK: - Initializers
    required init(spriteObject: SpriteObject) {
        let color = UIColor.clearColor()
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
        spriteObject.spriteNode = self
        self.name = spriteObject.name
        setLook()
    }

    required override init(texture: SKTexture?, color: UIColor, size: CGSize) {
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
        self.currentUIImageLook = image
        self.size = texture.size()
        //if spriteObject?.isBackground() == true {
        //    self.currentUIImageLook = image
        //    self.size = texture.size()
        //} else {
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
            //          self.currentUIImageLook = image
            //        }
            //        self.size = texture.size()
        //}
        let xScale = self.xScale
        let yScale = self.yScale
        self.xScale = 1.0
        self.yScale = 1.0
        self.texture = texture
        self.currentLook = look
        if xScale != 1.0 {
            self.xScale = xScale
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
        if self.spriteObject?.isBackground() == true {
            self.zPosition = 0
        } else {
            self.zPosition = zPosition
        }
        
    }

//    func touchedWithTouches(touches: NSSet, withX x: CGFloat, andY y: CGFloat) -> Bool {
//        guard let playerScene = (scene as? CBScene),
//              let scheduler = playerScene.scheduler
//        else { return false }
//
//        //  this check does not work any more since Swift 2.0! seems to be a compiler problem!
//        //        if scheduler.running == false {
//        //            return false
//        //        }
//
//        guard let spriteObject = spriteObject,
//              let spriteName = spriteObject.name
//        else { fatalError("Invalid SpriteObject!") }
//
//        for touchAnyObject in touches {
//            let touch = touchAnyObject as! UITouch
//            let touchedPoint = touch.locationInNode(self)
//            //                println("x:%f,y:%f", touchedPoint.x, touchedPoint.y)
//            //println("test touch, %@",self.name)
//            //        UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, [UIScreen mainScreen].scale);
//            //        [self.scene.view drawViewHierarchyInRect:self.frame afterScreenUpdates:NO];
//            //        UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
//            //        UIGraphicsEndImageContext();
//            //                println("image : x:%f,y:%f", self.currentUIImageLook.size.width, self.currentUIImageLook.size.height)
//            //            let isTransparent = self.currentUIImageLook?.isTransparentPixel(self.currentUIImageLook, withX:touchedPoint.x, andY:touchedPoint.y)
//            if self.currentUIImageLook?.isTransparentPixelOLDMETHOD(self.currentUIImageLook, withX:touchedPoint.x, andY:touchedPoint.y) == true {
//                return false
//            }
//
//            if let lastTime = _lastTimeTouchedSpriteNode[spriteName] {
//                let duration = NSDate().timeIntervalSinceDate(lastTime)
//                // ignore multiple touches on same sprite node within a certain amount of time...
//                if duration < PlayerConfig.MinIntervalBetweenTwoAcceptedTouches {
//                    return true
//                }
//            }
//            _lastTimeTouchedSpriteNode[spriteName] = NSDate()
//
//            scheduler.startWhenContextsOfSpriteNodeWithName(spriteName)
////            if let whenContexts = scheduler.whenContextsForSpriteNodeWithName(spriteName) {
////                for whenContext in whenContexts {
////                    if scheduler.isContextScheduled(whenContext) {
////                        scheduler.forceStopContext(whenContext)
////                    }
////                    scheduler.scheduleContext(whenContext)
////                }
////                scheduler.runNextInstructionsGroup()
////            }
//            return true
//        }
//        return true
//    }

    func touchedWithTouch(touch: UITouch, atPosition position: CGPoint) -> Bool {
        guard let playerScene = (scene as? CBScene),
              let scheduler = playerScene.scheduler,
              let imageLook = currentUIImageLook
        where scheduler.running
        else { return false }

        guard let spriteObject = spriteObject,
              let spriteName = spriteObject.name
        else { fatalError("Invalid SpriteObject!") }
        let touchedPoint = touch.locationInNode(self)
        if imageLook.isTransparentPixel(imageLook, withX:touchedPoint.x, andY:touchedPoint.y) {
            print("\(spriteName): \"I'm transparent at this point\"")
            return false
        }

        if let lastTime = _lastTimeTouchedSpriteNode[spriteName] {
            let duration = NSDate().timeIntervalSinceDate(lastTime)
            // ignore multiple touches on same sprite node within a certain amount of time...
            if duration < PlayerConfig.MinIntervalBetweenTwoAcceptedTouches {
                return true
            }
        }
        _lastTimeTouchedSpriteNode[spriteName] = NSDate()

        scheduler.startWhenContextsOfSpriteNodeWithName(spriteName)
//        if let whenContexts = scheduler.whenContextsForSpriteNodeWithName(spriteName) {
//            for whenContext in whenContexts {
//                if scheduler.isContextScheduled(whenContext) {
//                    scheduler.forceStopContext(whenContext)
//                }
//                scheduler.scheduleContext(whenContext)
//            }
//            scheduler.runNextInstructionsGroup()
//        }
        return true
    }
    
//    func pixelFromTexture(texture: SKTexture, position: CGPoint) -> SKColor {
//        let view = SKView(frame: CGRectMake(0, 0, 1, 1))
//        let scene = SKScene(size: CGSize(width: 1, height: 1))
//        let sprite  = SKSpriteNode(texture: texture)
//        sprite.anchorPoint = CGPointZero
//        sprite.position = CGPoint(x: -floor(position.x), y: -floor(position.y))
//        scene.anchorPoint = CGPointZero
//        scene.addChild(sprite)
//        view.presentScene(scene)
//        var pixel: [UInt8] = [0, 0, 0, 0]
//        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue)
//        let context = CGBitmapContextCreate(&pixel, 1, 1, 8, 4, CGColorSpaceCreateDeviceRGB(), bitmapInfo);
//        UIGraphicsPushContext(context);
//        view.drawViewHierarchyInRect(view.bounds, afterScreenUpdates: true)
//        UIGraphicsPopContext()
//        return SKColor(red: CGFloat(pixel[0]) / 255.0, green: CGFloat(pixel[1]) / 255.0, blue: CGFloat(pixel[2]) / 255.0, alpha: CGFloat(pixel[3]) / 255.0)
//    }

}
