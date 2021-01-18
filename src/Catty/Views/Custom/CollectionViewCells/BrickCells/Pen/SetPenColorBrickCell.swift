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

class SetPenColorBrickCell: BrickCell, BrickCellProtocol {

    var titleLabel: UILabel?
    var redLabel: UILabel?
    var redTextField: UITextField?
    var greenLabel: UILabel?
    var greenTextField: UITextField?
    var blueLabel: UILabel?
    var blueTextField: UITextField?

    static func cellHeight() -> CGFloat {
        CGFloat(kBrickHeight2h)
    }

    func brickTitle(forBackground isBackground: Bool, andInsertionScreen isInsertion: Bool) -> String! {
        kLocalizedSetPenColor + "\n" + kLocalizedRed + " %@ " + kLocalizedGreen + " %@ " + kLocalizedBlue + " %@"
    }

    override func hookUpSubViews(_ inlineViewSubViews: [Any]!) {
        self.titleLabel = inlineViewSubViews[0] as? UILabel
        self.redLabel = inlineViewSubViews[1] as? UILabel
        self.redTextField = inlineViewSubViews[2] as? UITextField
        self.greenLabel = inlineViewSubViews[3] as? UILabel
        self.greenTextField = inlineViewSubViews[4] as? UITextField
        self.blueLabel = inlineViewSubViews[5] as? UILabel
        self.blueTextField = inlineViewSubViews[6] as? UITextField
    }

    override func parameters() -> [String]! {
        let params = NSArray.init(objects: "{FLOAT;range=(0,255)}", "{FLOAT;range=(0,255)}", "{FLOAT;range=(0,255)}") as? [String]
        return params
    }
}
