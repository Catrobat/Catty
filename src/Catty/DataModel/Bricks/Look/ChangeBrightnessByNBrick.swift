/**
 *  Copyright (C) 2010-2021 The Catrobat Team
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
@objc(ChangeBrightnessByNBrick)
@objcMembers class ChangeBrightnessByNBrick: Brick, BrickProtocol, BrickFormulaProtocol {

    var changeBrightness: Formula?

    override required init() {
        super.init()
    }

    func category() -> kBrickCategoryType {
        kBrickCategoryType.lookBrick
    }

    func formula(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> Formula? {
        self.changeBrightness
    }

    func setFormula(_ formula: Formula?, forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) {
        self.changeBrightness = formula
    }

    func getFormulas() -> [Formula]? {
        if let changeBrightness = changeBrightness {
            return [changeBrightness]
        }
        return nil
    }

    func allowsStringFormula() -> Bool {
        false
    }

    override func setDefaultValuesFor(_ spriteObject: SpriteObject?) {
        changeBrightness = Formula(integer: 25)
    }

    func pathForLook(look: Look?) -> String? {
        look?.path(for: script.object.scene)
    }

    override func description() -> String? {
        "ChangeBrightnessByNBrick"
    }

    override func getRequiredResources() -> Int {
        self.changeBrightness?.getRequiredResources() ?? ResourceType.noResources.rawValue
    }

    override func brickCell() -> BrickCellProtocol.Type! {
        ChangeBrightnessByNBrickCell.self as BrickCellProtocol.Type
    }
}
