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

import Foundation

extension PhiroMotorMoveForwardBrick :CBInstructionProtocol,CBFormulaBufferProtocol {
    
    func instruction() -> CBInstruction {
        guard let object = self.script?.object
            else { fatalError("This should never happen!") }
        return CBInstruction.ExecClosure { (context, _) in
            let speedValue:Int = Int(self.formula.interpretIntegerForSprite(object))
            //TODO
            //            if (speedValue < MIN_SPEED) {
            //                speedValue = MIN_SPEED;
            //            } else if (speedValue > MAX_SPEED) {
            //                speedValue = MAX_SPEED;
            //            }
            
            guard let phiro:Phiro = BluetoothService.swiftSharedInstance.phiro else {
                return
            }
            
            switch (self.phiroMotor()) {
            case .Left:
                    phiro.moveLeftMotorForward(speedValue);
                break;
            case .Right:
                    phiro.moveRightMotorForward(speedValue);
                break;
            case .Both:
                    phiro.moveRightMotorForward(speedValue);
                    phiro.moveLeftMotorForward(speedValue);
                break;
            }
            context.state = .Runnable
        }
    }
    
    func preCalculate() {
        guard let object = self.script?.object
            else { fatalError("This should never happen!") }
        self.formula.interpretIntegerForSprite(object)
    }
    
}