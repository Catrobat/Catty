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

import Foundation

@objc extension PhiroRGBLightBrick :CBInstructionProtocol {
    
    @nonobjc func instruction() -> CBInstruction {
        
        return CBInstruction.execClosure { (context, _) in
            let redValue = self.getFormulaValue(self.redFormula)
            let greenValue = self.getFormulaValue(self.greenFormula)
            let blueValue = self.getFormulaValue(self.blueFormula)
            
            
            guard let phiro:Phiro = BluetoothService.swiftSharedInstance.phiro else {
                //ERROR
                return;
            }
            
            switch (self.phiroLight()) {
            case .LLeft:
                phiro.setLeftRGBLightColor(redValue, green: greenValue, blue: blueValue);
                break;
            case .LRight:
                phiro.setRightRGBLightColor(redValue, green: greenValue, blue: blueValue);
                break;
            case .LBoth:
                phiro.setLeftRGBLightColor(redValue, green: greenValue, blue: blueValue);
                phiro.setRightRGBLightColor(redValue, green: greenValue, blue: blueValue);
                break;
            }
            context.state = .runnable
        }
        
    }
    
    
    @objc func getFormulaValue(_ formula:Formula) -> Int {
        var rgbValue = Int(formula.interpretInteger(forSprite: self.script?.object))
        if (rgbValue < 0) {
            rgbValue = 0;
        } else if (rgbValue > 255) {
            rgbValue = 255;
        }
    
        return rgbValue;
    }
    
}
