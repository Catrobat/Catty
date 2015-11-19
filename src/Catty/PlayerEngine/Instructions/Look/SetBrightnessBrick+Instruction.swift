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

extension SetBrightnessBrick: CBInstructionProtocol{

    func instruction() -> CBInstruction {
        if let actionClosure = actionBlock() {
            return .Action(action: SKAction.runBlock(actionClosure))
        }
        return .InvalidInstruction()
    }

    func actionBlock() -> dispatch_block_t? {
        guard let object = self.script?.object,
            let spriteNode = object.spriteNode,
            let bright = self.brightness
            else { fatalError("This should never happen!") }
        
        return {
            guard let look = object.spriteNode!.currentLook else { return }

            var brightnessValue = bright.interpretDoubleForSprite(object) / 100
            if (brightnessValue > 2) {
                brightnessValue = 1.0;
            }
            else if (brightnessValue < 0){
                brightnessValue = -1.0;
            }
            else{
                brightnessValue -= 1.0;
            }

            let lookImage = UIImage(contentsOfFile:self.pathForLook(look))
            
            let image = lookImage!.CGImage
            let ciImage = CIImage(CGImage: image!)
            /////
            let context = CIContext(options: nil)
            
            let dict:[String:AnyObject] = [kCIInputImageKey:ciImage,"inputBrightness":brightnessValue]
            
            let filter = CIFilter(name: "CIColorControls", withInputParameters: dict)
            
            if let outputImage = filter?.outputImage {
                // 2
                let cgimg = context.createCGImage(outputImage, fromRect: outputImage.extent)
                
                // 3
                let newImage = UIImage(CGImage: cgimg)
                spriteNode.currentUIImageLook = newImage
                spriteNode.texture = SKTexture(image: newImage)
                spriteNode.currentLookBrightness = CGFloat(brightnessValue)
                let xScale = spriteNode.xScale
                let yScale = spriteNode.yScale
                spriteNode.xScale = 1.0
                spriteNode.yScale = 1.0
                spriteNode.size = spriteNode.texture!.size()
                spriteNode.texture = spriteNode.texture
                if(xScale != 1.0) {
                    spriteNode.xScale = xScale;
                }
                if(yScale != 1.0) {
                    spriteNode.yScale = yScale;
                }
            }
            
        }
    }
}
