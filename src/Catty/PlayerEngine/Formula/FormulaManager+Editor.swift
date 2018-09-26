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

extension FormulaManager {
    
    @nonobjc func formulaEditorItems(spriteObject: SpriteObject) -> [FormulaEditorItem] {
        return formulaEditorItems(for: spriteObject, mathSection: true, objectSection: true, deviceSection: true)
    }
    
    @nonobjc func formulaEditorItemsForMathSection(spriteObject: SpriteObject) -> [FormulaEditorItem] {
        return formulaEditorItems(for: spriteObject, mathSection: true, objectSection: false, deviceSection: false)
    }
    
    @nonobjc func formulaEditorItemsForObjectSection(spriteObject: SpriteObject) -> [FormulaEditorItem] {
        return formulaEditorItems(for: spriteObject, mathSection: false, objectSection: true, deviceSection: false)
    }
    
    @nonobjc func formulaEditorItemsForDeviceSection(spriteObject: SpriteObject) -> [FormulaEditorItem] {
        return formulaEditorItems(for: spriteObject, mathSection: false, objectSection: false, deviceSection: true)
    }
    
    private func formulaEditorItems(for spriteObject: SpriteObject, mathSection: Bool, objectSection: Bool, deviceSection: Bool) -> [FormulaEditorItem] {
        var items = [FormulaEditorItem]()
        let allItems = sensorManager.formulaEditorItems(for: spriteObject) + functionManager.formulaEditorItems()
        
        for item in allItems {
            switch (item.section) {
            case .math(_):
                if (mathSection) {
                    items += item
                }
                
            case .object(_):
                if (objectSection) {
                    items += item
                }
                
            case .device(_):
                if (deviceSection) {
                    items += item
                }
                
            default:
                break;
            }
        }
        return items.sorted(by: { $0.section.position() < $1.section.position() }).map{ $0 }
    }
}
