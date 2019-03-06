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

@objc(ChangeEffectByBrick) class ChangeEffectByBrick: Brick, BrickStaticChoiceProtocol, BrickFormulaProtocol {

    @objc public var effectChoice: Int
    @objc public var effectChange: Formula!

    required override init() {
        effectChoice = 0
        effectChange = Formula(integer: 10)
        super.init()
    }


    init(choice: Int) {
        self.effectChoice = choice
        super.init()
    }

    override var brickTitle: String! {
        return kLocalizedChange + "\n%@\n" + kLocalizedEffectBy + " %@"
    }

    func formula(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> Formula! {
        if lineNumber == 2 && paramNumber == 0 {
            return self.effectChange
        }
        return nil
    }

    func setFormula(_ formula: Formula!, forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) {
        if lineNumber == 2 && paramNumber == 0 {
            self.effectChange = formula
        }
    }

    func getFormulas() -> [Formula]! {
        return [self.effectChange]

    }

    func allowsStringFormula() -> Bool {
        return false
    }

    override func getRequiredResources() -> Int {
        return self.effectChange.getRequiredResources()
    }

    override func description() -> String! {
        return ("effect choice \(self.effectChoice)")
    }

    func setDefaultValues(for spriteObject: SpriteObject!) {
        self.effectChoice = 0
        self.effectChange = Formula(integer: 10)
    }

    override func mutableCopy(with context: CBMutableCopyContext!) -> Any! {
        return self.mutableCopy(with: context, andErrorReporting: false)
    }

    override func isEqual(to brick: Brick!) -> Bool {
        if !self.effectChange.isEqual(to: (brick as! ChangeEffectByBrick).effectChange) {
            return false
        }
        if self.effectChoice != (brick as! ChangeEffectByBrick).effectChoice {
            return false
        }
        return true
    }

    func choice(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> String! {
        let choices = possibleChoices(forLineNumber: 1, andParameterNumber: 0)
        return choices![self.effectChoice]
    }

    func setChoice(_ choice: String!, forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) {
        let choices = possibleChoices(forLineNumber: 1, andParameterNumber: 0)
        let index = choices!.firstIndex(of: choice)
        if (index! < choices!.count) && (index! >= 0) {
            self.effectChoice = index!
        } else {
            self.effectChoice = 0
        }
    }

    func possibleChoices(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> [String]! {
        return AudioEngineConfig.localizedEffectNames
    }
}
