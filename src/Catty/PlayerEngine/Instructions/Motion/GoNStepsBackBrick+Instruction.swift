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

@objc extension GoNStepsBackBrick: CBInstructionProtocol {

    @nonobjc func instruction() -> CBInstruction {
        return .action(action: SKAction.run(actionBlock()))
    }

    @objc func actionBlock() -> ()->() {
        guard let object = self.script?.object,
            let spriteNode = object.spriteNode,
            let stepsFormula = self.steps,
            let objectList = self.script?.object?.program?.objectList
        else { fatalError("This should never happen!") }

        return {
            let zValue = spriteNode.zPosition
            let steps = stepsFormula.interpretDouble(forSprite: object)
            spriteNode.zPosition = max(1, zValue - CGFloat(steps))
            for obj in objectList {
                guard let objSpriteNode = (obj as AnyObject).spriteNode! else {
                    continue
                }
                if(objSpriteNode.zPosition < zValue) && (objSpriteNode.zPosition >= (object.spriteNode?.zPosition)!) && (obj as! SpriteObject != object){
                    objSpriteNode.zPosition += 1
                }
            }
        }

    }
}
