/**
 *  Copyright (C) 2010-2018 The Catrobat Team
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

class FormulaEditorItem {

    var sensor: Sensor?
    var function: Function?
    var op: CBOperator?
    var title: String
    var section: FormulaEditorSection

    public init(sensor: Sensor, spriteObject: SpriteObject) {
        self.title = type(of: sensor).name
        self.sensor = sensor
        self.section = sensor.formulaEditorSection(for: spriteObject)
    }

    public init(function: Function) {
        self.title = function.nameWithParameters()
        self.function = function
        self.section = function.formulaEditorSection()
    }

    public init(op: CBOperator) {
        self.title = type(of: op).name
        self.op = op
        self.section = op.formulaEditorSection()
    }
}
