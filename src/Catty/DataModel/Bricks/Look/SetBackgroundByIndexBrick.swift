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

@objc(SetBackgroundByIndexBrick)

@objcMembers class SetBackgroundByIndexBrick: Brick, BrickProtocol, BrickFormulaProtocol {

    var backgroundIndex: Formula?

    override required init() {
        super.init()
    }

    func category() -> kBrickCategoryType {
        kBrickCategoryType.lookBrick
    }

    override class func description() -> String {
        "SetBackgroundByIndex"
    }

    override func getRequiredResources() -> Int {
        backgroundIndex?.getRequiredResources() ?? ResourceType.noResources.rawValue
    }

    override func brickCell() -> BrickCellProtocol.Type! {
        SetBackgroundByIndexBrickCell.self as BrickCellProtocol.Type
    }

    func formula(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> Formula! {
        self.backgroundIndex
    }

    func setFormula(_ formula: Formula!, forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) {
        self.backgroundIndex = formula
    }

    func getFormulas() -> [Formula]! {
        [backgroundIndex!]
    }

    override func setDefaultValuesFor(_ spriteObject: SpriteObject!) {
        self.backgroundIndex = Formula(integer: 1)
    }

    func allowsStringFormula() -> Bool {
        false
    }

    func path(for look: Look?) -> String? {
        look?.path(for: script.object.scene)
    }
}
