/**
 *  Copyright (C) 2010-2020 The Catrobat Team
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

extension GoToBrick: CBInstructionProtocol {

    func instruction() -> CBInstruction {
        .action { context in SKAction.run(self.actionBlock(context.touchManager)) }
    }

    func actionBlock(_ touchManager: TouchManagerProtocol) -> () -> Void {
        let spinnerSelection = self.spinnerSelection

        guard let object = self.script?.object,
            let spriteNode = object.spriteNode,
            let scene = spriteNode.scene
            else {
                fatalError("This should never happen!")
        }

        return {
            var destination = CBPosition(x: 0.0, y: 0.0)

            if spinnerSelection == kGoToTouchPosition {
                let lastTouch = touchManager.lastPositionInScene()

                guard let position = lastTouch else {
                    return
                }

                destination = CBPosition(
                    x: PositionXSensor.convertToStandardized(rawValue: Double(position.x), for: object),
                    y: PositionYSensor.convertToStandardized(rawValue: Double(position.y), for: object))
            } else if spinnerSelection == kGoToRandomPosition {
                let virtualScreenWidth = Double(scene.size.width / 2.0)
                let virtualScreenHeight = Double(scene.size.height / 2.0)

                destination = CBPosition(x: Double.random(in: (virtualScreenWidth * (-1))...virtualScreenWidth),
                                         y: Double.random(in: (virtualScreenHeight * (-1))...virtualScreenHeight))
            } else {
                guard let goToObject = self.goToObject
                else { fatalError("This should never happen!") }
                destination = goToObject.spriteNode.catrobatPosition
            }

            spriteNode.catrobatPosition = destination
        }
    }
}
