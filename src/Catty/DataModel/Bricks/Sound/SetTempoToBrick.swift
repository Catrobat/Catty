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

@objc(SetTempoToBrick)
@objcMembers class SetTempoToBrick: Brick, BrickFormulaProtocol {

    var tempo: Formula

    override required init() {
        self.tempo = Formula(integer: Int32(AudioEngineDefines.defaultTempo))
        super.init()
    }

    func category() -> kBrickCategoryType {
        kBrickCategoryType.soundBrick
    }

    override class func description() -> String {
        "SetTempoToBrick"
    }

    override func getRequiredResources() -> Int {
        tempo.getRequiredResources()

    }

    override func brickCell() -> BrickCellProtocol.Type! {
        SetTempoToBrickCell.self as BrickCellProtocol.Type
    }

    func formula(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> Formula! {
        self.tempo
    }

    func setFormula(_ formula: Formula!, forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) {
        self.tempo = formula
    }

    func getFormulas() -> [Formula] {
     [tempo]

    }

    override func setDefaultValuesFor(_ spriteObject: SpriteObject!) {
        self.tempo = Formula(integer: Int32(AudioEngineDefines.defaultTempo))
    }

    func allowsStringFormula() -> Bool {
        false
    }

    @objc(isEqualToBrick:)
    override func isEqual(to brick: Brick) -> Bool {
        guard let setTempoToBrick = brick as? SetTempoToBrick else {
            return false
        }

        return self.tempo.isEqual(to: setTempoToBrick.tempo)
    }

    @objc(mutableCopyWithContext:)
    override func mutableCopy(with context: CBMutableCopyContext) -> Any {
        let brick = SetTempoToBrick()
        brick.tempo = self.tempo
        return brick
    }

    override func clone(with script: Script!) -> Brick! {
        let clone = SetTempoToBrick()
        clone.script = script
        clone.tempo = self.tempo

        return clone
    }
}
