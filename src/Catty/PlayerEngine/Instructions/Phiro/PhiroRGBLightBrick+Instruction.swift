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

@objc extension PhiroRGBLightBrick: CBInstructionProtocol {

    @nonobjc func instruction() -> CBInstruction {

        return CBInstruction.execClosure { context, _ in
            let redValue = self.getFormulaValue(self.redFormula, formulaInterpreter: context.formulaInterpreter)
            let greenValue = self.getFormulaValue(self.greenFormula, formulaInterpreter: context.formulaInterpreter)
            let blueValue = self.getFormulaValue(self.blueFormula, formulaInterpreter: context.formulaInterpreter)

            guard let phiro = BluetoothService.swiftSharedInstance.phiro else {
                return
            }

            switch self.phiroLight() {
            case .LLeft:
                phiro.setLeftRGBLightColor(redValue, green: greenValue, blue: blueValue)
            case .LRight:
                phiro.setRightRGBLightColor(redValue, green: greenValue, blue: blueValue)
            case .LBoth:
                phiro.setLeftRGBLightColor(redValue, green: greenValue, blue: blueValue)
                phiro.setRightRGBLightColor(redValue, green: greenValue, blue: blueValue)
            @unknown default:
                print("ERROR: case not handled by switch statement")
            }
            context.state = .runnable
        }

    }

    @objc func getFormulaValue(_ formula: Formula, formulaInterpreter: FormulaInterpreterProtocol) -> Int {
        var rgbValue = formulaInterpreter.interpretInteger(formula, for: (self.script?.object)!)
        if rgbValue < 0 {
            rgbValue = 0
        } else if rgbValue > 255 {
            rgbValue = 255
        }

        return rgbValue
    }

}
