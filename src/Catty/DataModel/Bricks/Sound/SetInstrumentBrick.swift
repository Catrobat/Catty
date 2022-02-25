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

@objc(SetInstrumentBrick) class SetInstrumentBrick: Brick, BrickStaticChoiceProtocol {

    public var instrument: Instrument

    override required init() {
        self.instrument = AudioEngineDefines.defaultInstrument
        super.init()
    }

    func category() -> kBrickCategoryType { kBrickCategoryType.soundBrick }

    override func getRequiredResources() -> Int { ResourceType.noResources.rawValue }

    override func description() -> String! { ("SetInstrumentBrick: \(self.instrument.tag)") }

    func setDefaultValues(for spriteObject: SpriteObject!) {
        self.instrument = AudioEngineDefines.defaultInstrument
    }

    func choice(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> String! {
        self.instrument.localizedName
    }

    func setChoice(_ localizedName: String!, forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) {
        self.instrument = Instrument.from(localizedName: localizedName) ?? AudioEngineDefines.defaultInstrument
    }

    func possibleChoices(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> [String] {
        Instrument.allCases.map { $0.localizedName }
    }

    @objc(isEqualToBrick:)
    override func isEqual(to brick: Brick) -> Bool {
        guard let setInstrumentBrick = brick as? SetInstrumentBrick else {
            return false
        }

        return self.instrument == setInstrumentBrick.instrument
    }

    @objc(mutableCopyWithContext:)
    override func mutableCopy(with context: CBMutableCopyContext) -> Any {
        let brick = SetInstrumentBrick()
        brick.instrument = self.instrument
        return brick
    }
}
