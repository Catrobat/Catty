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

import Foundation

@objc(SetTempoToBrick) class SetTempoToBrick: Brick, BrickFormulaProtocol {

    @objc public var tempo: Formula!

    override init() {
        super.init()
    }

    override var brickTitle: String! {
        return kLocalizedSetTempoTo + " %@"
    }

    func formula(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> Formula! {
        if lineNumber == 0 && paramNumber == 0 {
            return self.tempo
        }
        return nil
    }

    func setFormula(_ formula: Formula!, forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) {
        if lineNumber == 0 && paramNumber == 0 {
            self.tempo = formula
        }
    }

    func getFormulas() -> [Formula]! {
        return [self.tempo]

    }

    func allowsStringFormula() -> Bool {
        return false
    }

    override func setDefaultValuesFor(_ spriteObject: SpriteObject!) {
        self.tempo = Formula(integer: 60)
    }

    override func mutableCopy(with context: CBMutableCopyContext!) -> Any! {
        return self.mutableCopy(with: context, andErrorReporting: false)
    }

    override func isEqual(to brick: Brick!) -> Bool {
        if !self.tempo.isEqual(to: (brick as! SetTempoToBrick).tempo) {
            return false
        }
        return true
    }

    override func getRequiredResources() -> Int {
        return self.tempo!.getRequiredResources()
    }

    override func description() -> String! {
        return ("SetTempoToBrick")
    }
}
