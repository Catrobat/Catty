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

extension IfOnEdgeBounceBrick: CBInstructionProtocol {

    func instruction() -> CBInstruction {
        return .Action(action: SKAction.runBlock(actionBlock()))
    }

    func actionBlock() -> dispatch_block_t {
        guard let object = self.script?.object,
              let spriteNode = object.spriteNode,
              let scene = spriteNode.scene
        else { fatalError("This should never happen!") }
        /* newVersion
        return {
        
            let width = spriteNode.size.width
            let height = spriteNode.size.height
            
            let virtualScreenWidth = scene.size.width/2.0
            let virtualScreenHeight = scene.size.height/2.0
            
            var xPosition = spriteNode.scenePosition.x
            var yPosition = spriteNode.scenePosition.y
            var rotation = spriteNode.rotation
            
            //Check upper/lowerEdge
            let upperEdge = -virtualScreenWidth + (width/2.0)
            let lowerEdge = virtualScreenWidth - (width/2.0)
            if xPosition < upperEdge {
                xPosition = upperEdge
                if (self.isLookingDown(rotation)){
                    rotation = 180 - rotation
                }
            } else if xPosition > lowerEdge {
                xPosition = lowerEdge
                if (self.isLookingUp(rotation)) {
                    rotation = 180 - rotation
                }
            }
            
            //Check left/right edge
            let leftEdge = virtualScreenHeight - (height/2.0)
            let rightEdge = -virtualScreenHeight + (height/2.0)
            if yPosition > leftEdge {
                yPosition = leftEdge
                if (self.isLookingRight(rotation)) {
                    rotation = -rotation
                }
            } else if yPosition < rightEdge {
                 yPosition = rightEdge
                if (self.isLookingLeft(rotation)) {
                    rotation = 360 - rotation
                }
            }
            if rotation < 0 { rotation += 360 }
            spriteNode.rotation = rotation
            spriteNode.scenePosition = CGPointMake(xPosition, yPosition)
        }*/
            
        return {
                let width = spriteNode.size.width
                let height = spriteNode.size.height
                
                let virtualScreenWidth = scene.size.width/2.0
                let virtualScreenHeight = scene.size.height/2.0
                
                var xPosition = spriteNode.scenePosition.x
                var rotation = spriteNode.rotation
                let xLeftPosition = -virtualScreenWidth + (width/2.0)
                let xRightPosition = virtualScreenWidth - (width/2.0)
                if xPosition < xLeftPosition {
                    if (rotation >= 0 && rotation < 90) || (rotation > 270 && rotation <= 360) || (rotation <= 0 && rotation > -90) || (rotation < -270 && rotation >= -360){
                        rotation = 180 - rotation
                    }
                    xPosition = xLeftPosition
                } else if xPosition > xRightPosition {
                    if (rotation > 90) && (rotation < 270) || (rotation < -90) && (rotation > -270){
                        rotation = 180 - rotation
                    }
                    xPosition = xRightPosition
                }
                //if rotation < 0 { rotation += 360 }
                
                var yPosition = spriteNode.scenePosition.y
                let yUpPosition = virtualScreenHeight - (height/2.0)
                let yDownPosition = -virtualScreenHeight + (height/2.0)
                if yPosition > yUpPosition {
                    if (rotation > 180) && (rotation < 360) || (rotation < -180) && (rotation > -360) {
                        rotation = -rotation
                    }
                    yPosition = yUpPosition
                } else if yPosition < yDownPosition {
                    if (rotation > 0) && (rotation < 180) || (rotation < 0) && (rotation > -180) {
                        rotation = 360 - rotation
                    }
                    yPosition = yDownPosition
                }
                spriteNode.rotation = rotation
                spriteNode.scenePosition = CGPointMake(xPosition, yPosition)
            }
            
    }
    
    func isLookingDown(rotation:Double) -> Bool {
        if (rotation > 90) && (rotation < 270) {
            return true
        }
        return false
    }
    
    func isLookingUp(rotation:Double) -> Bool {
        if (rotation >= 0 && rotation < 90) || (rotation > 270 && rotation <= 360) {
            return true
        }
        return false
    }
    
    func isLookingLeft(rotation:Double) -> Bool {
        if (rotation > 180) && (rotation < 360) {
            return true
        }
        return false
    }
    
    func isLookingRight(rotation:Double) -> Bool {
        if (rotation > 0) && (rotation < 180) {
            return true
        }
        return false
    }

}
