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

class SetBackgroundByIndexBrickCell: BrickCell, BrickCellProtocol {

    var textLabel: UILabel?
    var backgroundIndexField: UITextField?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    static func cellHeight() -> CGFloat {
        CGFloat(kBrickHeight1h)
    }

    func brickTitle(forBackground isBackground: Bool, andInsertionScreen isInsertion: Bool) -> String! {
        kLocalizedSetBackgroundByIndex + " %@"
    }

    override func hookUpSubViews(_ inlineViewSubViews: [Any]!) {
        self.textLabel = inlineViewSubViews[0] as? UILabel
        self.backgroundIndexField = inlineViewSubViews[1] as? UITextField
    }

    override func parameters() -> [String]! {
        NSArray.init(objects: "{FLOAT;range=(-inf,inf)}") as? [String]
    }
}
