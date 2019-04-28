/**
 *  Copyright (C) 2010-2019 The Catrobat Team
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

@objc extension PointToBrick: CBInstructionProtocol {

    @nonobjc func instruction() -> CBInstruction {
        return .action { _ in SKAction.run(self.actionBlock()) }
    }

    @objc func actionBlock() -> () -> Void {
        guard let object = self.script?.object,
            let spriteNode = object.spriteNode,
            let pointedObjectPosition = self.pointedObject?.spriteNode?.position
            else { fatalError("This should never happen!") }

        return {
            let objectPosition = spriteNode.position

            var rotationDegrees = 0.0
            if (objectPosition.x == pointedObjectPosition.x) && (objectPosition.y == pointedObjectPosition.y) {
                rotationDegrees = 0.0
            } else if objectPosition.x == pointedObjectPosition.x {
                if objectPosition.y > pointedObjectPosition.y {
                    rotationDegrees = 180.0
                } else {
                    rotationDegrees = 0.0
                }
            } else if objectPosition.y == pointedObjectPosition.y {
                if objectPosition.x > pointedObjectPosition.x {
                    rotationDegrees = 270.0
                } else {
                    rotationDegrees = 90.0
                }
            } else {
                let base = abs(objectPosition.y - pointedObjectPosition.y)
                let height = abs(objectPosition.x - pointedObjectPosition.x)
                let value = Double(atan(base / height)) * 180.0 / Double.pi

                if objectPosition.x < pointedObjectPosition.x {
                    if objectPosition.y > pointedObjectPosition.y {
                        rotationDegrees = 90.0 + value
                    } else {
                        rotationDegrees = 90.0 - value
                    }
                } else {
                    if objectPosition.y > pointedObjectPosition.y {
                        rotationDegrees = 270.0 - value
                    } else {
                        rotationDegrees = 270.0 + value
                    }
                }
            }

            spriteNode.catrobatRotation = rotationDegrees
        }
    }
}
