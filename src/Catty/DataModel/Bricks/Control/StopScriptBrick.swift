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

@objc(StopScriptBrick) class StopScriptBrick: Brick, BrickProtocol, BrickStaticChoiceProtocol {
    static let defaultSelection = StopStyle.thisScript
    var question: Formula?
    var selection: StopStyle

    override required init() {
        self.selection = type(of: self).defaultSelection
        super.init()
    }

    func category() -> kBrickCategoryType {
        kBrickCategoryType.controlBrick
    }

    override func description() -> String {
        "StopScriptBrick"
    }

    override func getRequiredResources() -> Int {
        ResourceType.noResources.rawValue
    }

    override func brickCell() -> BrickCellProtocol.Type! {
        StopScriptBrickCell.self as BrickCellProtocol.Type
    }

    func choice(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> String {
        selection.localizedString()
    }

    func setChoice(_ message: String, forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) {
        self.selection = StopStyle.from(localizedString: message) ?? type(of: self).defaultSelection
    }

    func possibleChoices(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> [String] {
        StopStyle.allCases.map { $0.localizedString() }
    }
}
