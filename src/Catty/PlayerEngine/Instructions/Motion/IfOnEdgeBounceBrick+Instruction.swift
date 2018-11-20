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

@objc extension IfOnEdgeBounceBrick: CBInstructionProtocol {

    @nonobjc func instruction() -> CBInstruction {
        return .action { _ in SKAction.run(self.actionBlock()) }
    }

    @objc func actionBlock() -> () -> Void {
        guard let object = self.script?.object,
            let spriteNode = object.spriteNode,
            let scene = spriteNode.scene
            else {
                fatalError("This should never happen!")
            }

        return {
            let width = spriteNode.size.width
            let height = spriteNode.size.height

            let virtualScreenWidth = scene.size.width / 2.0
            let virtualScreenHeight = scene.size.height / 2.0

            var xPosition = CGFloat(spriteNode.catrobatPositionX)
            var yPosition = CGFloat(spriteNode.catrobatPositionY)
            var rotation = spriteNode.catrobatRotation

            //Check left/right edge
            let leftEdge = -virtualScreenWidth + (width / 2.0)
            let rightEdge = virtualScreenWidth - (width / 2.0)

            if xPosition < leftEdge {
                xPosition = leftEdge
                if self.isLookingLeft(rotation) {
                    rotation = -rotation
                }
            } else if xPosition > rightEdge {
                xPosition = rightEdge
                if self.isLookingRight(rotation) {
                    rotation = -rotation
                }
            }

            //Check upper/lowerEdge
            let upperEdge = virtualScreenHeight - (height / 2.0)
            let lowerEdge = -virtualScreenHeight + (height / 2.0)

            if yPosition > upperEdge {
                yPosition = upperEdge
                if self.isLookingUp(rotation) {
                    rotation = 180 - rotation
                }
            } else if yPosition < lowerEdge {
                yPosition = lowerEdge
                if self.isLookingDown(rotation) {
                    rotation = 180 - rotation
                }
            }

            spriteNode.catrobatRotation = rotation
            spriteNode.catrobatPositionX = Double(xPosition)
            spriteNode.catrobatPositionY = Double(yPosition)
        }
    }

    func isLookingDown(_ rotation: Double) -> Bool {
        let normalizedRotation = self.normalizeRotation(rotation)
        if self.isGreater(normalizedRotation, second: 90.0) && self.isLess(normalizedRotation, second: 270.0) {
            return true
        }
        return false
    }

    func isLookingUp(_ rotation: Double) -> Bool {
        let normalizedRotation = self.normalizeRotation(rotation)
        if (self.isGreaterOrEqual(normalizedRotation, second: 0.0) &&
            self.isLess(normalizedRotation, second: 90.0)) ||
            (self.isGreater(normalizedRotation, second: 270.0) &&
                self.isLessOrEqual(normalizedRotation, second: 360.0)) {
            return true
        }
        return false
    }

    func isLookingLeft(_ rotation: Double) -> Bool {
        let normalizedRotation = self.normalizeRotation(rotation)
        if (self.isGreater(normalizedRotation, second: 180.0)) && (self.isLess(normalizedRotation, second: 360.0)) {
            return true
        }
        return false
    }

    func isLookingRight(_ rotation: Double) -> Bool {
        let normalizedRotation = self.normalizeRotation(rotation)
        if (self.isGreater(normalizedRotation, second: 0.0)) && (self.isLess(normalizedRotation, second: 180.0)) {
            return true
        }
        return false
    }

    private func normalizeRotation(_ rotation: Double) -> Double {
        var normalizedRotation = rotation

        if self.isLess(normalizedRotation, second: 0.0) {
            normalizedRotation = 360.0 + (normalizedRotation.truncatingRemainder(dividingBy: -360.0))
        }
        return normalizedRotation.truncatingRemainder(dividingBy: 360)
    }

    private func isGreater(_ first: Double, second: Double) -> Bool {
        return first - second > Double.epsilon
    }

    private func isGreaterOrEqual(_ first: Double, second: Double) -> Bool {
        return first - second > Double.epsilon || self.isEqual(first, second: second)
    }

    private func isLess(_ first: Double, second: Double) -> Bool {
        return first - second < Double.epsilon && !self.isEqual(first, second: second)
    }

    private func isLessOrEqual(_ first: Double, second: Double) -> Bool {
        return first - second < Double.epsilon || self.isEqual(first, second: second)
    }

    private func isEqual(_ first: Double, second: Double) -> Bool {
        return abs(first - second) <= Double.epsilon
    }
}
