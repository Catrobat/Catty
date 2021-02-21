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

protocol FormulaManagerProtocol: FormulaInterpreterProtocol {

    var touchManager: TouchManagerProtocol { get }

    func setup(for project: Project, and stage: Stage)

    func setup(for formula: Formula)

    func stop()

    func pause()

    func resume()

    func unavailableResources(for requiredResources: NSInteger) -> NSInteger

    func functionExists(tag: String) -> Bool

    func sensorExists(tag: String) -> Bool

    func operatorExists(tag: String) -> Bool

    func getFunction(tag: String) -> Function?

    func getSensor(tag: String) -> Sensor?

    func getOperator(tag: String) -> Operator?

    func formulaEditorItems(spriteObject: SpriteObject) -> [FormulaEditorItem]

    func formulaEditorItemsForFunctionSection(spriteObject: SpriteObject) -> [FormulaEditorItem]

    func formulaEditorItemsForLogicSection(spriteObject: SpriteObject) -> [FormulaEditorItem]

    func formulaEditorItemsForObjectSection(spriteObject: SpriteObject) -> [FormulaEditorItem]

    func formulaEditorItemsForDeviceSection(spriteObject: SpriteObject) -> [FormulaEditorItem]
}
