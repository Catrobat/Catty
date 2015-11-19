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

extension SetTransparencyBrick: CBInstructionProtocol,CBFormulaBufferProtocol {

    func instruction() -> CBInstruction {
        if let actionClosure = actionBlock() {
            return .Action(action: SKAction.runBlock(actionClosure))
        }
        return .InvalidInstruction()
    }

    func actionBlock() -> dispatch_block_t? {
        guard let object = self.script?.object,
              let spriteNode = object.spriteNode,
              let transparency = self.transparency
        else { fatalError("This should never happen!") }

        return {
            let trans = transparency.interpretDoubleForSprite(object)
            let alpha = 1.0 - (trans / 100.0)
            if (alpha < 0) {
                spriteNode.alpha = 0;
            }
            else if (alpha > 1){
                spriteNode.alpha = 1;
            }
            else{
               spriteNode.alpha = CGFloat(alpha);
            }

        }
    }
    
    func preCalculate() {
        guard let object = self.script?.object
            else { fatalError("This should never happen!") }
        self.transparency.interpretIntegerForSprite(object)
    }

}
