/**
 *  Copyright (C) 2010-2024 The Catrobat Team
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

@objc(SavePlotSVGBrick)

@objcMembers class SavePlotSVGBrick: Brick, BrickProtocol, BrickFormulaProtocol {

    var filename: Formula?

    override required init() {
        super.init()
    }

    func category() -> kBrickCategoryType {
        kBrickCategoryType.plotBrick
    }

    override class func description() -> String {
        "PlotBrick"
    }

    override func getRequiredResources() -> Int {
        ResourceType.noResources.rawValue
    }

    override func brickCell() -> BrickCellProtocol.Type! {
        SavePlotSVGBrickCell.self as BrickCellProtocol.Type
    }

    func formula(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> Formula! {
        self.filename
    }

    func setFormula(_ formula: Formula!, forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) {
        self.filename = formula
    }

    func getFormulas() -> [Formula]! {
        [filename!]
    }

    override func setDefaultValuesFor(_ spriteObject: SpriteObject!) {
        self.filename = Formula(string: spriteObject.name! + ".svg") ?? Formula(string: kLocalizedSavePlotDefaultFile)
    }

    func allowsStringFormula() -> Bool {
        true
    }

    override func isDisabledForBackground() -> Bool {
        false
    }
}
