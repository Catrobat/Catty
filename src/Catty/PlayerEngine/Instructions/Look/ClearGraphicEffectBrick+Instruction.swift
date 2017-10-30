/**
 *  Copyright (C) 2010-2017 The Catrobat Team
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

@objc extension ClearGraphicEffectBrick: CBInstructionProtocol {

    @nonobjc func instruction() -> CBInstruction {
        if let actionClosure = actionBlock() {
            return .action(action: SKAction.run(actionClosure))
        }
        return .invalidInstruction()
    }

    @objc func actionBlock() -> (()->())? {
        guard let object = self.script?.object,
              let spriteNode = object.spriteNode
        else { fatalError("This should never happen!") }

        return {
            guard let look = spriteNode.currentLook,
                  let image = UIImage(contentsOfFile: self.path(for: look)) else {return}
            
            let texture = SKTexture(image: image)
            spriteNode.currentUIImageLook = image
            spriteNode.currentLookBrightness = 0
            spriteNode.currentLookColor = 0
            for (paramName, _) in spriteNode.filterDict {
                spriteNode.filterDict[paramName] = false
            }
            let xScale = spriteNode.xScale
            let yScale = spriteNode.yScale
            spriteNode.xScale = 1.0
            spriteNode.yScale = 1.0
            spriteNode.alpha = 1.0
            spriteNode.size = texture.size()
            spriteNode.texture = texture
            spriteNode.currentLook = look
            if xScale != 1.0 {
                spriteNode.xScale = CGFloat(xScale)
            }
            if yScale != 1.0 {
                spriteNode.yScale = CGFloat(yScale)
            }

        }

    }

}
