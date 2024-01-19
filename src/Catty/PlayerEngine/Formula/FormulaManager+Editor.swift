/**
 *  Copyright (C) 2010-2024 The Catrobat Team
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

extension FormulaManager {

    @nonobjc func formulaEditorItems(spriteObject: SpriteObject) -> [FormulaEditorItem] {
        formulaEditorItems(for: spriteObject, mathSection: true, logicSection: true, objectSection: true, deviceSection: true)
    }

    @nonobjc func formulaEditorItemsForFunctionSection(spriteObject: SpriteObject) -> [FormulaEditorItem] {
        formulaEditorItems(for: spriteObject, mathSection: true, logicSection: false, objectSection: false, deviceSection: false)
    }

    @nonobjc func formulaEditorItemsForLogicSection(spriteObject: SpriteObject) -> [FormulaEditorItem] {
        formulaEditorItems(for: spriteObject, mathSection: false, logicSection: true, objectSection: false, deviceSection: false)
    }

    @nonobjc func formulaEditorItemsForObjectSection(spriteObject: SpriteObject) -> [FormulaEditorItem] {
        formulaEditorItems(for: spriteObject, mathSection: false, logicSection: false, objectSection: true, deviceSection: false)
    }

    @nonobjc func formulaEditorItemsForSensorsSection(spriteObject: SpriteObject) -> [FormulaEditorItem] {
        formulaEditorItems(for: spriteObject, mathSection: false, logicSection: false, objectSection: false, deviceSection: true)
    }

    private func formulaEditorItems(for spriteObject: SpriteObject, mathSection: Bool, logicSection: Bool, objectSection: Bool, deviceSection: Bool) -> [FormulaEditorItem] {
        var items = [(pos: Int, item: FormulaEditorItem)]()
        let allItems = sensorManager.formulaEditorItems(for: spriteObject) + functionManager.formulaEditorItems() + operatorManager.formulaEditorItems()

        for item in allItems {
            for section in item.sections {
                switch section {
                case let .functions(position, _):
                    if mathSection {
                        items += (position, item)
                    }

                case let .logic(position, _):

                    if logicSection {
                        items += (position, item)
                    }

                case let .object(position, _):

                    if objectSection {
                        if item.function?.tag() == CollisionFunction.tag {
                            guard let scene = spriteObject.scene else { continue }

                            var objects = scene.objects()

                            if objects.contains(spriteObject) {
                                objects.removeObject(spriteObject)
                            }

                            if !objects.isEmpty {
                                for i in 0...(objects.count - 1) {
                                    let newItem = FormulaEditorItem.init(function: CollisionFunction.init() as Function)
                                    newItem.title = (kUIFEObjectActorObjectTouch + "(\'" + objects[i].name + "\')")
                                    (newItem.function as! CollisionFunction).addParameter(param: objects[i].name)

                                    items += (position + (i * 10), newItem)
                                }
                            }
                        } else {
                            items += (position, item)
                        }
                    }

                case let .sensors(position, _):

                    if deviceSection {
                        items += (position, item)
                    }

                }
            }
        }

        return items.sorted { $0.0 < $1.0 }.map { $0.1 }
    }

}
