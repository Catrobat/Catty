/**
 *  Copyright (C) 2010-2019 The Catrobat Team
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

@objc(SetInstrumentToBrick) class SetInstrumentToBrick: Brick, BrickStaticChoiceProtocol {

    @objc public var instrumentChoice: Int

    required override init() {
        instrumentChoice = 0
        super.init()
    }

    init(choice: Int) {
        self.instrumentChoice = choice
        super.init()
    }

    override var brickTitle: String! {
        return kLocalizedSetInstrumentTo + "\n%@"
    }

    override func getRequiredResources() -> Int {
        return ResourceType.noResources.rawValue
    }

    override func description() -> String! {
        return ("instrument choice \(self.instrumentChoice)")
    }

    func setDefaultValues(for spriteObject: SpriteObject!) {
        self.instrumentChoice = 0
    }

    func choice(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> String! {
        let choices = possibleChoices(forLineNumber: 1, andParameterNumber: 0)
        return choices![self.instrumentChoice]
    }

    func setChoice(_ choice: String!, forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) {
        let choices = possibleChoices(forLineNumber: 1, andParameterNumber: 0)
        let index = choices!.firstIndex(of: choice)
        if (index! < choices!.count) && (index! >= 0) {
            self.instrumentChoice = index!
        } else {
            self.instrumentChoice = 0
        }
    }

    func possibleChoices(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> [String]! {
        return AudioEngineConfig.localizedInstrumentNames
    }
}
