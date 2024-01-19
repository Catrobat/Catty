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

import Foundation

@objc(StartTripleStitchBrick)
@objcMembers class StartTripleStitchBrick: Brick, BrickProtocol, BrickFormulaProtocol {

    var stitchLength: Formula?

    override required init() {
        self.stitchLength = Formula(integer: Int32(EmbroideryDefines.defaultTripleStitchLength))
        super.init()
    }

    func category() -> kBrickCategoryType {
        kBrickCategoryType.embroideryBrick
    }

    override class func description() -> String {
        "StartTripleStitchBrick"
    }

    override func getRequiredResources() -> Int {
        ResourceType.embroidery.rawValue
    }

    override func brickCell() -> BrickCellProtocol.Type! {
        StartTripleStitchBrickCell.self as BrickCellProtocol.Type
    }

    func formula(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> Formula! {
        self.stitchLength
    }

    func setFormula(_ formula: Formula!, forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) {
        self.stitchLength = formula
    }

    func getFormulas() -> [Formula]? {
        if let stitchLength = stitchLength {
            return [stitchLength]
        }
        return nil
    }

    override func setDefaultValuesFor(_ spriteObject: SpriteObject!) {
        self.stitchLength = Formula(integer: Int32(EmbroideryDefines.defaultTripleStitchLength))
    }

    func allowsStringFormula() -> Bool {
        false
    }
}
