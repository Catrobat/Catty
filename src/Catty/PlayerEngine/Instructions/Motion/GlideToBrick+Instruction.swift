/**
 *  Copyright (C) 2010-2016 The Catrobat Team
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

extension GlideToBrick: CBInstructionProtocol {
    
    func instruction() -> CBInstruction {
        
        guard let durationFormula = self.durationInSeconds,
            let object = self.script?.object
            else { fatalError("This should never happen!") }
        
        let cachedDuration = durationFormula.isIdempotent()
            ? CBDuration.FixedTime(duration: durationFormula.interpretDoubleForSprite(object))
            : CBDuration.VarTime(formula: durationFormula)
        
        return .LongDurationAction(duration: cachedDuration, actionCreateClosure: {
            (duration) -> SKAction in
                return self.action(duration)
        })
    }
    
    func action(duration : NSTimeInterval) -> SKAction {
        guard let object = self.script?.object,
            let spriteNode = object.spriteNode
            else { fatalError("This should never happen!") }
        
        let xDestination = self.xDestination.interpretFloatForSprite(object)
        let yDestination = self.yDestination.interpretFloatForSprite(object)
        let duration = self.durationInSeconds.interpretDoubleForSprite(object)
        guard let scene = spriteNode.scene else {
            fatalError("This should never happen!")
        }
        let destPoint = CGPoint(x: scene.size.width / 2 + CGFloat(xDestination), y: scene.size.height / 2 + CGFloat(yDestination))
        
        let action = SKAction.moveTo(destPoint, duration: duration)
        return action
    }
}