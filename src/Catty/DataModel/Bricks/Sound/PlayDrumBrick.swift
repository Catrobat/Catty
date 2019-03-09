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

@objc(PlayDrumBrick) class PlayDrumBrick: Brick, BrickStaticChoiceProtocol, BrickFormulaProtocol {

    @objc public var drumChoice: Int
    @objc public var duration: Formula!

    override required init() {
        drumChoice = 0
        duration = Formula(integer: 1)
        super.init()
    }

    override var brickTitle: String! {
        return kLocalizedPlayDrum + "\n%@\n" + kLocalizedFor + " %@" + kLocalizedBeats
    }

    func formula(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> Formula! {
        if lineNumber == 2 && paramNumber == 0 {
            return self.duration
        }
        return nil
    }

    func setFormula(_ formula: Formula!, forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) {
        if lineNumber == 2 && paramNumber == 0 {
            self.duration = formula
        }
    }

    func getFormulas() -> [Formula]! {
        return [self.duration]

    }

    func allowsStringFormula() -> Bool {
        return false
    }

    override func getRequiredResources() -> Int {
        return self.duration.getRequiredResources()
    }

    override func description() -> String! {
        return ("instrument choice \(self.drumChoice)")
    }

    func setDefaultValues(for spriteObject: SpriteObject!) {
        self.drumChoice = 0
        self.duration = Formula(integer: 1)
    }

    override func mutableCopy(with context: CBMutableCopyContext!) -> Any! {
        return self.mutableCopy(with: context, andErrorReporting: false)
    }

    override func isEqual(to brick: Brick!) -> Bool {
        if !self.duration.isEqual(to: (brick as! PlayDrumBrick).duration) {
            return false
        }
        if self.drumChoice != (brick as! PlayDrumBrick).drumChoice {
            return false
        }
        return true
    }

    init(choice: Int) {
        self.drumChoice = choice
        super.init()
    }

    func choice(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> String! {
        let choices = possibleChoices(forLineNumber: 1, andParameterNumber: 0)
        return choices![self.drumChoice]
    }

    func setChoice(_ choice: String!, forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) {
        let choices = possibleChoices(forLineNumber: 1, andParameterNumber: 0)
        let index = choices!.firstIndex(of: choice)
        if (index! < choices!.count) && (index! >= 0) {
            self.drumChoice = index!
        } else {
            self.drumChoice = 0
        }
    }

    func possibleChoices(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> [String]! {
        return AudioEngineConfig.localizedDrumNames
    }
}
