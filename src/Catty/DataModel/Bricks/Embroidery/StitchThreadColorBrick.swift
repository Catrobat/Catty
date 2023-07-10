/**
 *  Copyright (C) 2010-2023 The Catrobat Team
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

@objc(StitchThreadColorBrick)
@objcMembers class StitchThreadColorBrick: Brick, BrickProtocol, BrickFormulaProtocol, BrickVariableProtocol {
    var userVariable: UserVariable!
    var stitchColor: Formula?

    func variable(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> UserVariable! {
        self.userVariable
    }

    func setVariable(_ variable: UserVariable!, forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) {
        self.userVariable = variable
    }

    override required init() {
        self.stitchColor = Formula(string: EmbroideryDefines.defaultThreadColor)
        super.init()
    }

    func category() -> [NSNumber]! {
        [NSNumber(value: kBrickCategoryType.embroideryBrick.rawValue)]
    }

    override class func description() -> String {
        "StitchThreadColor"
    }

    override func getRequiredResources() -> Int {
        ResourceType.embroidery.rawValue

    }

    override func brickCell() -> BrickCellProtocol.Type! {
        StitchThreadColorCell.self as BrickCellProtocol.Type
    }

    func formula(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> Formula! {
        self.stitchColor
    }

    func setFormula(_ formula: Formula!, forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) {
        self.stitchColor = formula
    }

    func getFormulas() -> [Formula]! {
        [stitchColor!]
    }

    override func setDefaultValuesFor(_ spriteObject: SpriteObject!) {
        self.stitchColor = Formula(string: EmbroideryDefines.defaultThreadColor)
    }

    func allowsStringFormula() -> Bool {
        true
    }
}
