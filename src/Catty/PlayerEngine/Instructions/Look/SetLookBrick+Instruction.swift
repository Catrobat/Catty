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

extension SetLookBrick: CBInstructionProtocol {

    func instruction() -> CBInstruction {
        if let actionClosure = actionBlock() {
            return .Action(action: SKAction.runBlock(actionClosure))
        }
        return .InvalidInstruction()
    }

    func actionBlock() -> dispatch_block_t? {
        guard let object = self.script?.object,
              let spriteNode = object.spriteNode
        else { fatalError("This should never happen!") }

        guard let image = UIImage(contentsOfFile: self.pathForLook()) else { return nil }

        let texture = SKTexture(image: image)
        if object.isBackground() {
            spriteNode.currentUIImageLook = image
        } else {
            //        CGRect newRect = [image cropRectForImage:image];
            //        CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, newRect);
            //        UIImage *newImage = [UIImage imageWithCGImage:imageRef];
            //        CGImageRelease(imageRef);
            spriteNode.currentUIImageLook = image
        }
        spriteNode.currentLookBrightness = 0

        return {
            let xScale = spriteNode.xScale
            let yScale = spriteNode.yScale
            spriteNode.xScale = 1.0
            spriteNode.yScale = 1.0
            spriteNode.size = texture.size()
            spriteNode.texture = texture
            spriteNode.currentLook = self.look
            if xScale != 1.0 {
                spriteNode.xScale = CGFloat(xScale)
            }
            if yScale != 1.0 {
                spriteNode.yScale = CGFloat(yScale)
            }
        }
    }
    
    func preCalculate() {
        
    }

}
