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

@objc extension ChangeSizeByNBrick: CBInstructionProtocol{

    @nonobjc func instruction() -> CBInstruction {
        return .action(action: SKAction.run(actionBlock()))
    }

    @objc func actionBlock() -> ()->() {
        guard let object = self.script?.object,
            let spriteNode = object.spriteNode,
            let size = self.size
        else { fatalError("This should never happen!") }

        return {
            let sizeInPercent = size.interpretDouble(forSprite: object)
            spriteNode.xScale = CGFloat(spriteNode.xScale + CGFloat(sizeInPercent/100.0))
            spriteNode.yScale = CGFloat(spriteNode.yScale + CGFloat(sizeInPercent/100.0))
            if let textBubble = spriteNode.childNodeWithName("textBubble")
            {
                textBubble.position = CGPoint(x: spriteNode.size.width/4, y: spriteNode.size.height/2)
            }
        }
    }
}
