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

@objc(SetLookByIndexBrick)

@objcMembers class SetLookByIndexBrick: Brick, BrickProtocol, BrickFormulaProtocol {

    var lookIndex: Formula

    override required init() {
        self.lookIndex = Formula(integer: kBackgroundObjects)
        super.init()
    }

    func category() -> kBrickCategoryType {
        kBrickCategoryType.lookBrick
    }

    override class func description() -> String {
        "SetLookByIndexBrick"
    }

    override func getRequiredResources() -> Int {
        ResourceType.noResources.rawValue
    }

    override func brickCell() -> BrickCellProtocol.Type! {
        SetLookByIndexBrickCell.self as BrickCellProtocol.Type
    }

    func formula(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> Formula! {
        self.lookIndex
    }

    func setFormula(_ formula: Formula!, forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) {
        self.lookIndex = formula
    }

    func getFormulas() -> [Formula]! {
        [lookIndex]
    }

    override func setDefaultValuesFor(_ spriteObject: SpriteObject!) {
        self.lookIndex = Formula(integer: kBackgroundObjects)
    }

    func allowsStringFormula() -> Bool {
        false
    }

    override func isDisabledForBackground() -> Bool {
        true
    }

    func pathForLook(look: Look?) -> String? {
        look?.path(for: script.object.scene)
    }

    override func clone(with script: Script!) -> Brick! {
        let clone = SetLookByIndexBrick()
        clone.script = script
        clone.lookIndex = self.lookIndex

        return clone
    }
}
