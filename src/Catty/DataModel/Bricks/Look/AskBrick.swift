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

@objc(AskBrick)

@objcMembers class AskBrick: Brick, BrickProtocol, BrickFormulaProtocol, BrickVariableProtocol {

    var question: Formula?
    var userVariable: UserVariable?

    override required init() {
        super.init()
    }

    func category() -> kBrickCategoryType {
        kBrickCategoryType.lookBrick
    }

    override class func description() -> String {
        "AskBrick"
    }

    override func getRequiredResources() -> Int {
        ResourceType.noResources.rawValue
    }

    override func brickCell() -> BrickCellProtocol.Type! {
        AskBrickCell.self as BrickCellProtocol.Type
    }

    func variable(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> UserVariable! {
        self.userVariable
    }

    func setVariable(_ variable: UserVariable!, forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) {
        self.userVariable = variable
    }

    func formula(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> Formula! {
        self.question
    }

    func setFormula(_ formula: Formula!, forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) {
        self.question = formula
    }

    func getFormulas() -> [Formula]! {
        [question!]
    }

    override func setDefaultValuesFor(_ spriteObject: SpriteObject!) {
        self.question = Formula(string: kLocalizedDefaultAskBrickQuestion)
    }

    func allowsStringFormula() -> Bool {
        true
    }

    override func isDisabledForBackground() -> Bool {
        false
    }
}
