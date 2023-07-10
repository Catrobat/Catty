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

@objc(SetPenColorBrick)
@objcMembers class SetPenColorBrick: Brick, BrickFormulaProtocol {

    var red: Formula?
    var green: Formula?
    var blue: Formula?

    override required init() {
        super.init()
    }

    func category() -> [NSNumber]! {
        [NSNumber(value: kBrickCategoryType.penBrick.rawValue)]
    }

    override class func description() -> String {
        "PenBrick"
    }

    override func getRequiredResources() -> Int {
        ResourceType.noResources.rawValue
    }

    override func brickCell() -> BrickCellProtocol.Type! {
        SetPenColorBrickCell.self as BrickCellProtocol.Type
    }

    func formula(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> Formula! {
        switch paramNumber {

        case 0:
            return red

        case 1:
            return green

        case 2:
            return blue

        default:
            return nil

        }

    }

    func setFormula(_ formula: Formula!, forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) {
        switch paramNumber {

        case 0:
            self.red = formula

        case 1:
            self.green = formula

        case 2:
            self.blue = formula

        default:
            fatalError("This should never happen")

        }
    }

    override func setDefaultValuesFor(_ spriteObject: SpriteObject!) {

        if let red = SpriteKitDefines.defaultPenColor.redComponent, let green = SpriteKitDefines.defaultPenColor.greenComponent, let blue = SpriteKitDefines.defaultPenColor.blueComponent {

            self.red = Formula(integer: Int32(red))
            self.green = Formula(integer: Int32(green))
            self.blue = Formula(integer: Int32(blue))

        } else {

            self.red = Formula(integer: 0)
            self.green = Formula(integer: 0)
            self.blue = Formula(integer: 0)

        }

    }

    func getFormulas() -> [Formula]! {
        [red!, green!, blue!]
    }

    func allowsStringFormula() -> Bool {
        false
    }

    override func isDisabledForBackground() -> Bool {
        true
    }

}
