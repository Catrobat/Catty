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

class StartZigzagStitchBrickCell: BrickCell, BrickCellProtocol {
    var textLabel1: UILabel?
    var textLabel2: UILabel?
    var lenghtField: UITextField?
    var widthField: UITextField?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    static func cellHeight() -> CGFloat {
        UIDefines.brickHeight2h
    }

    override func hookUpSubViews(_ inlineViewSubViews: [Any]!) {
        self.textLabel1 = inlineViewSubViews[0] as? UILabel
        self.lenghtField = inlineViewSubViews[1] as? UITextField
        self.textLabel2 = inlineViewSubViews[2] as? UILabel
        self.widthField = inlineViewSubViews[3] as? UITextField
    }

    func brickTitle(forBackground isBackground: Bool, andInsertionScreen isInsertion: Bool) -> String! {
        kLocalizedStartZigzagStitch + " %@\n" + kLocalizedAndWidth + " %@"
    }

    override func parameters() -> [String]! {
        ["{FLOAT;range=(0,inf)}", "{FLOAT;range=(0,inf)}"]
    }
}
