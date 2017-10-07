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

@objc extension ChangeColorByNBrick: CBInstructionProtocol {

    @nonobjc func instruction() -> CBInstruction {
        if let actionClosure = actionBlock() {
            return .action(action: SKAction.run(actionClosure))
        }
        return .invalidInstruction()
    }
    
    @objc func actionBlock() -> (()->())? {
        guard let object = self.script?.object,
            let spriteNode = object.spriteNode,
            let colorFormula = self.changeColor
            else { fatalError("This should never happen!") }
        
        return {
            guard let look = object.spriteNode!.currentLook else { return }
            
            let colorValue = colorFormula.interpretDouble(forSprite: object)
            
            let lookImage = UIImage(contentsOfFile:self.path(for: look))
            let colorDefaultValue:CGFloat = 0.0
            let colorValueRadian = (spriteNode.currentLookColor + CGFloat(colorValue)*CGFloat(Double.pi)/100).truncatingRemainder(dividingBy: (2*CGFloat(Double.pi)))
            spriteNode.currentLookColor = colorValueRadian
            
            if (colorValueRadian != colorDefaultValue){
                spriteNode.filterDict["color"] = true
            }else{
                spriteNode.filterDict["color"] = false
            }
            
            spriteNode.executeFilter(lookImage)
            
        }
    }
}
