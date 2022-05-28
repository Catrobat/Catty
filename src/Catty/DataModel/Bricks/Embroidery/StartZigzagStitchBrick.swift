/**
 *  Copyright (C) 2010-2022 The Catrobat Team
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

@objc(StartZigzagStitchBrick)
@objcMembers class StartZigzagStitchBrick: Brick, BrickProtocol, BrickFormulaProtocol {

    var length: Formula?
    var width: Formula?

    override required init() {
        self.length = Formula(integer: Int32(EmbroideryDefines.defaultZigzagStitchLength))
        self.width = Formula(integer: Int32(EmbroideryDefines.defaultZigzagStitchWidth))
        super.init()
    }

    func category() -> kBrickCategoryType {
        kBrickCategoryType.embroideryBrick
    }

    override class func description() -> String {
        "StartZigzagStitchBrick"
    }

    override func getRequiredResources() -> Int {
        ResourceType.embroidery.rawValue
    }

    override func brickCell() -> BrickCellProtocol.Type! {
        StartZigzagStitchBrickCell.self as BrickCellProtocol.Type
    }

    func formula(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> Formula! {
        (lineNumber == 0) ? self.length : self.width
    }

    func setFormula(_ formula: Formula!, forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) {
        (lineNumber == 0) ? (self.length = formula) : (self.width = formula)
    }

    func getFormulas() -> [Formula]? {
        if let length = length, let width = width {
            return [length, width]
        }
        return nil
    }

    override func setDefaultValuesFor(_ spriteObject: SpriteObject!) {
        self.length = Formula(integer: Int32(EmbroideryDefines.defaultZigzagStitchLength))
        self.width = Formula(integer: Int32(EmbroideryDefines.defaultZigzagStitchWidth))
    }

    func allowsStringFormula() -> Bool {
        false
    }
}
