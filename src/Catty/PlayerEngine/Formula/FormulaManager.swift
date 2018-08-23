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

@objc class FormulaManager: NSObject, FormulaManagerProtocol {
    
    let sensorManager: SensorManagerProtocol
    let functionManager: FunctionManagerProtocol
    
    override init() {
        // TODO remove Singleton
        self.sensorManager = CBSensorManager.shared
        self.functionManager = FunctionManager.shared
    }
    
    @objc(setupForProgram: andScene:)
    func setup(for program: Program, and scene: CBScene) {
        sensorManager.setup(for: program, and: scene)
        functionManager.setup(for: program, and: scene)
    }
    
    @objc(setupForFormula:)
    func setup(for formula: Formula) {
        sensorManager.setup(for: formula)
        functionManager.setup(for: formula)
    }
        
    @objc func stop() {
        sensorManager.stop()
        functionManager.stop()
    }
    
    func unavailableResources(for requiredResources: NSInteger) -> NSInteger {
        let unavailableResourcesSensors = sensorManager.unavailableResources(for: requiredResources)
        return unavailableResourcesSensors
    }
    
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
        var items = [Int: FormulaEditorItem]()
        let allItems = sensorManager.formulaEditorItems(for: spriteObject) + functionManager.formulaEditorItems()
        
        for item in allItems {
            switch (item.section) {
            case let .math(position):
                if (mathSection) {
                    items[position] = item
                }
                
            case let .object(position):
                if (objectSection) {
                    items[position] = item
                }
                
            case let .device(position):
                if (deviceSection) {
                    items[position] = item
                }
                
            default:
                break;
            }
        }
        return items.sorted(by: { $0.0 < $1.0 }).map{ $1}
    }
}
