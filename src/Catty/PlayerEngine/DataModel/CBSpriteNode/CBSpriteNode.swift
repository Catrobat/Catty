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

@objc
class CBSpriteNode: SKSpriteNode {

    // MARK: - Properties
    @objc var spriteObject: SpriteObject
    @objc var currentLook: Look?
    @objc var currentUIImageLook: UIImage?
    
    @objc var filterDict = ["brightness": false, "color": false]
    @objc var ciBrightness: CGFloat = CGFloat(BrightnessSensor.defaultRawValue) // CoreImage specific brightness
    @objc var ciHueAdjust: CGFloat = CGFloat(ColorSensor.defaultRawValue) // CoreImage specific hue adjust
    
    private var _lastTimeTouchedSpriteNode = [String:Date]()

    // MARK: Custom getters and setters
    @objc func setPositionForCropping(_ position: CGPoint) {
        self.position = position
    }

    // MARK: - Initializers
    @objc required init(spriteObject: SpriteObject) {
        let color = UIColor.clear
        self.spriteObject = spriteObject
        
        if let firstLook = spriteObject.lookList.firstObject as? Look,
           let filePathForLook = spriteObject.path(for: firstLook),
           let image = UIImage(contentsOfFile:filePathForLook)
        {
            let texture = SKTexture(image: image)
            let textureSize = texture.size()
            super.init(texture: texture, color: color, size: textureSize)
            self.currentLook = firstLook
            self.currentLook = firstLook
        } else {
            super.init(texture: nil, color: color, size: CGSize.zero)
        }
        
        self.spriteObject.spriteNode = self
        self.name = spriteObject.name
        self.isUserInteractionEnabled = false
        setLook()
    }
    
    @objc required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Operations
    func returnFilterInstance(_ filterName: String, image: CIImage) -> CIFilter?{
        var filter: CIFilter? = nil;
        if (filterName == "brightness"){
            filter = CIFilter(name: "CIColorControls", withInputParameters: [kCIInputImageKey:image, "inputBrightness": self.ciBrightness])
        }
        if (filterName == "color"){
            filter = CIFilter(name: "CIHueAdjust", withInputParameters: [kCIInputImageKey:image, "inputAngle": self.ciHueAdjust])
        }
        return filter
    }
    
    @objc func executeFilter(_ inputImage: UIImage?) {
        guard let lookImage = inputImage?.cgImage else { preconditionFailure() }

        var ciImage = CIImage(cgImage: lookImage)
        let context = CIContext(options: nil)
        
        if (Double(self.ciBrightness) != BrightnessSensor.defaultRawValue) {
            self.filterDict["brightness"] = true
        } else {
            self.filterDict["brightness"] = false
        }
        
        if (Double(self.ciHueAdjust) != ColorSensor.defaultRawValue) {
            self.filterDict["color"] = true
        } else {
            self.filterDict["color"] = false
        }
        
        for (filterName, isActive) in filterDict {
            if isActive, let outputImage = returnFilterInstance(filterName, image: ciImage)?.outputImage {
                ciImage = outputImage
            }
        }
        
        let outputImage = ciImage
        // 2
        guard let cgimg = context.createCGImage(outputImage, from: outputImage.extent) else { preconditionFailure() }
        
        // 3
        let newImage = UIImage(cgImage: cgimg)
        self.currentUIImageLook = newImage
        let texture = SKTexture(image: newImage)
        let xScale = self.xScale
        let yScale = self.yScale
        
        let defaultSize = CGFloat(SizeSensor.defaultRawValue)
        self.xScale = defaultSize
        self.yScale = defaultSize
        self.size = texture.size()
        
        self.texture = texture
        if (xScale != defaultSize) {
            self.xScale = xScale
        }
        if (yScale != defaultSize) {
            self.yScale = yScale
        }
    }
    
    @objc func nextLook() -> Look? {
        guard let currentLook = currentLook
            else { return nil }

        let currentIndex = spriteObject.lookList.index(of: currentLook)
        let nextIndex = (currentIndex + 1) % spriteObject.lookList.count
        return spriteObject.lookList[nextIndex] as? Look
    }

    @objc func previousLook() -> Look? {
        if currentLook == nil {
            return nil
        }
        
        var index = spriteObject.lookList.index(of: currentLook!)
        index -= 1
        index = index < 0 ? spriteObject.lookList.count - 1 : index
        return spriteObject.lookList[index] as? Look
    }
    
    @objc func changeLook(_ look: Look?) {
        guard let look = look,
            let filePathForLook = spriteObject.path(for: look),
            let image = UIImage(contentsOfFile:filePathForLook)
            else { return }

        let texture = SKTexture(image: image)
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
        
        self.texture = texture
        self.currentLook = look
    }

    @objc func setLook() {
        if spriteObject.lookList.count > 0, let look = spriteObject.lookList[0] as? Look {
            changeLook(look)
        }
    }

    // MARK: Events
    @objc func start(_ zPosition: CGFloat) {
        self.position = CGPoint(x: PositionXSensor.defaultRawValue, y: PositionYSensor.defaultRawValue)
        self.zRotation = CGFloat(RotationSensor.defaultRawValue)
        self.xScale = CGFloat(SizeSensor.defaultRawValue)
        self.yScale = CGFloat(SizeSensor.defaultRawValue)
        
        self.ciBrightness = CGFloat(BrightnessSensor.defaultRawValue)
        
        if self.spriteObject.isBackground() == true {
            self.zPosition = 0
        } else {
            self.zPosition = zPosition
        }
    }
    
    @objc func touchedWithTouch(_ touch: UITouch, atPosition position: CGPoint) -> Bool {
        guard let playerScene = (scene as? CBScene),
              let scheduler = playerScene.scheduler,
              let imageLook = currentUIImageLook, scheduler.running
        else { return false }

        guard let spriteName = spriteObject.name
        else { preconditionFailure("Invalid SpriteObject!") }
        let touchedPoint = touch.location(in: self)
        
        if imageLook.isTransparentPixel(atScenePoint: touchedPoint) {
            print("\(spriteName): \"I'm transparent at this point\"")
            return false
        }

        if let lastTime = _lastTimeTouchedSpriteNode[spriteName] {
            let duration = Date().timeIntervalSince(lastTime)
            // ignore multiple touches on same sprite node within a certain amount of time...
            if duration < PlayerConfig.MinIntervalBetweenTwoAcceptedTouches {
                return true
            }
        }
        _lastTimeTouchedSpriteNode[spriteName] = Date()

        scheduler.startWhenContextsOfSpriteNodeWithName(spriteName)

        return true
    }

}
