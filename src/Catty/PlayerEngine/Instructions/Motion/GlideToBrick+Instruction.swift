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

extension GlideToBrick: CBInstructionProtocol {

    func instruction() -> CBInstruction {

        guard let durationFormula = self.durationInSeconds,
              let object = self.script?.object,
              let spriteNode = object.spriteNode
        else { fatalError("This should never happen!") }

        let cachedDuration = durationFormula.isIdempotent()
                           ? CBDuration.FixedTime(duration: durationFormula.interpretDoubleForSprite(object))
                           : CBDuration.VarTime(formula: durationFormula)

        return .LongDurationAction(duration: cachedDuration, actionCreateClosure: {
            (duration) -> CBLongActionClosure in

            self.isInitialized = false
            return { (node, elapsedTime) in
//                self?.logger.debug("Performing: \(self.description())")
                let xDestination = self.xDestination.interpretFloatForSprite(object)
                let yDestination = self.yDestination.interpretFloatForSprite(object)
                if !self.isInitialized {
                    self.isInitialized = true
                    let startingPoint = spriteNode.scenePosition
                    self.startingPoint = startingPoint
                    let startingX = Float(startingPoint.x)
                    let startingY = Float(startingPoint.y)
                    self.deltaX = xDestination - startingX
                    self.deltaY = yDestination - startingY
                }
                
                let percent = Float(elapsedTime) / Float(duration)
                let startingPoint = self.startingPoint
                let startingX = Float(startingPoint.x)
                let startingY = Float(startingPoint.y)
                spriteNode.scenePosition = CGPointMake(
                    CGFloat(startingX + self.deltaX * percent),
                    CGFloat(startingY + self.deltaY * percent)
                )
            }
        })
    }
    
    func preCalculate() {
        guard let object = self.script?.object
            else { fatalError("This should never happen!") }
        self.xDestination.interpretIntegerForSprite(object)
        self.yDestination.interpretIntegerForSprite(object)
        self.durationInSeconds.interpretIntegerForSprite(object)
    }

}
