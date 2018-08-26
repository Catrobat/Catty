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

import XCTest

@testable import Pocket_Code

final class FormulaManagerTest: XCTestCase {
    
    var manager: FormulaManagerProtocol!
    var sensorManager: SensorManagerMock!
    var functionManager: FunctionManagerMock!
    var spriteObject: SpriteObject!
    
    override func setUp() {
        self.sensorManager = SensorManagerMock(sensors: [])
        self.functionManager = FunctionManagerMock(functions: [])
        self.manager = FormulaManager(sensorManager: sensorManager, functionManager: functionManager)
        
        self.spriteObject = SpriteObjectMock()
    }
    
    func testFormulaEditorItems() {
        XCTAssertEqual(0, manager.formulaEditorItems(spriteObject: spriteObject).count)
        
        functionManager.functions = [FunctionMock(formulaEditorSection: .object(position: 1)), FunctionMock(formulaEditorSection: .device(position: 1)), FunctionMock(formulaEditorSection: .hidden)]
        XCTAssertEqual(2, manager.formulaEditorItems(spriteObject: spriteObject).count)
        
        sensorManager.sensors = [SensorMock(formulaEditorSection: .object(position: 1)), SensorMock(formulaEditorSection: .hidden)]
        XCTAssertEqual(3, manager.formulaEditorItems(spriteObject: spriteObject).count)
    }
}
