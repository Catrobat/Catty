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

import XCTest

@testable import Pocket_Code

final class FormulaManagerTests: XCTestCase {

    var spriteObject: SpriteObject!

    override func setUp() {
        spriteObject = SpriteObjectMock()
    }

    func testFormulaEditorItemsEmpty() {
        let manager = FormulaManager(sensorManager: SensorManager(sensors: [], landscapeMode: false),
                                     functionManager: FunctionManager(functions: []),
                                     operatorManager: OperatorManager(operators: []))

        XCTAssertEqual(0, manager.formulaEditorItems(spriteObject: spriteObject).count)
        XCTAssertEqual(0, manager.formulaEditorItemsForLogicSection(spriteObject: spriteObject).count)
        XCTAssertEqual(0, manager.formulaEditorItemsForFunctionSection(spriteObject: spriteObject).count)
        XCTAssertEqual(0, manager.formulaEditorItemsForSensorsSection(spriteObject: spriteObject).count)
        XCTAssertEqual(0, manager.formulaEditorItemsForObjectSection(spriteObject: spriteObject).count)
    }

    func testFormulaEditorItems() {
        let functionA = ZeroParameterDoubleFunctionMock(tag: "functionTagA",
                                                        value: 1.0,
                                                        formulaEditorSection: .object(position: 1, subsection: .general))
        let functionB = ZeroParameterDoubleFunctionMock(tag: "functionTagB",
                                                        value: 1.0,
                                                        formulaEditorSection: .sensors(position: 2, subsection: .device))
        let functionC = DoubleParameterDoubleFunctionMock(tag: "functionTagC",
                                                          value: 3.0,
                                                          firstParameter: .number(defaultValue: 1),
                                                          secondParameter: .number(defaultValue: 1))

        let sensorA = SensorMock(tag: "sensorTagA", formulaEditorSection: .object(position: 3, subsection: .general))
        let sensorB = SensorMock(tag: "sensorTagB")

        let operatorA = UnaryOperatorMock(value: 0, formulaEditorSection: .object(position: 4, subsection: .general))
        let operatorB = BinaryOperatorMock(value: 0)

        let manager = FormulaManager(sensorManager: SensorManager(sensors: [sensorA, sensorB], landscapeMode: false),
                                     functionManager: FunctionManager(functions: [functionA, functionB, functionC]),
                                     operatorManager: OperatorManager(operators: [operatorA, operatorB]))

        let items = manager.formulaEditorItems(spriteObject: spriteObject)
        XCTAssertEqual(4, items.count)
        XCTAssertTrue(functionA.formulaEditorSections().elementsEqual(items[0].function!.formulaEditorSections()))
        XCTAssertTrue(functionB.formulaEditorSections().elementsEqual(items[1].function!.formulaEditorSections()))
        XCTAssertTrue(sensorA.formulaEditorSections(for: spriteObject).elementsEqual(items[2].sensor!.formulaEditorSections(for: spriteObject)))
        XCTAssertTrue(operatorA.formulaEditorSections().elementsEqual(items[3].op!.formulaEditorSections()))
    }

    func testFormulaEditorItemsSamePosition() {
        let functionA = ZeroParameterDoubleFunctionMock(tag: "functionTagA",
                                                        value: 1.0,
                                                        formulaEditorSection: .object(position: 1, subsection: .general))
        let functionB = SingleParameterDoubleFunctionMock(tag: "functionTagB",
                                                          value: 2.0,
                                                          parameter: .number(defaultValue: 1),
                                                          formulaEditorSection: .object(position: 1, subsection: .general))

        let sensorA = SensorMock(tag: "sensorTagA", formulaEditorSection: .object(position: 1, subsection: .general))

        let operatorA = UnaryOperatorMock(value: 0, formulaEditorSection: .object(position: 1, subsection: .general))

        let manager = FormulaManager(sensorManager: SensorManager(sensors: [sensorA], landscapeMode: false),
                                     functionManager: FunctionManager(functions: [functionA, functionB]),
                                     operatorManager: OperatorManager(operators: [operatorA]))

        XCTAssertEqual(4, manager.formulaEditorItems(spriteObject: spriteObject).count)
    }

    func testFormulaEditorItemsForFunctionSection() {
        let functionA = ZeroParameterDoubleFunctionMock(tag: "functionTagA",
                                                        value: 1.0,
                                                        formulaEditorSection: .functions(position: 10, subsection: .maths))
        let functionB = SingleParameterDoubleFunctionMock(tag: "functionTagB",
                                                          value: 2.0,
                                                          parameter: .number(defaultValue: 1.0),
                                                          formulaEditorSection: .object(position: 1, subsection: .general))

        let sensorA = SensorMock(tag: "sensorTagA", formulaEditorSection: .functions(position: 20, subsection: .maths))
        let sensorB = SensorMock(tag: "sensorTagB")

        let operatorA = UnaryOperatorMock(value: 0, formulaEditorSections: [.functions(position: 30, subsection: .maths), .logic(position: 40, subsection: .logical)])
        let operatorB = BinaryOperatorMock(value: 0)

        let manager = FormulaManager(sensorManager: SensorManager(sensors: [sensorA, sensorB], landscapeMode: false),
                                     functionManager: FunctionManager(functions: [functionA, functionB]),
                                     operatorManager: OperatorManager(operators: [operatorA, operatorB]))

        let items = manager.formulaEditorItemsForFunctionSection(spriteObject: spriteObject)
        XCTAssertEqual(3, items.count)
        XCTAssertTrue(functionA.formulaEditorSections().elementsEqual(items[0].function!.formulaEditorSections()))
        XCTAssertTrue(sensorA.formulaEditorSections(for: spriteObject).elementsEqual(items[1].sensor!.formulaEditorSections(for: spriteObject)))
        XCTAssertTrue(operatorA.formulaEditorSections().elementsEqual(items[2].op!.formulaEditorSections()))
    }

    func testFormulaEditorItemsForLogicSection() {
        let functionA = ZeroParameterDoubleFunctionMock(tag: "functionTagA",
                                                        value: 1.0,
                                                        formulaEditorSections: [.logic(position: 10, subsection: .logical), .functions(position: 50, subsection: .maths)])
        let functionB = SingleParameterDoubleFunctionMock(tag: "functionTagB",
                                                          value: 2.0,
                                                          parameter: .number(defaultValue: 1.0),
                                                          formulaEditorSection: .object(position: 1, subsection: .general))

        let sensorA = SensorMock(tag: "sensorTagA", formulaEditorSection: .logic(position: 20, subsection: .logical))
        let sensorB = SensorMock(tag: "sensorTagB")

        let operatorA = UnaryOperatorMock(value: 0, formulaEditorSection: .logic(position: 30, subsection: .logical))
        let operatorB = BinaryOperatorMock(value: 0)

        let manager = FormulaManager(sensorManager: SensorManager(sensors: [sensorA, sensorB], landscapeMode: false),
                                     functionManager: FunctionManager(functions: [functionA, functionB]),
                                     operatorManager: OperatorManager(operators: [operatorA, operatorB]))

        let items = manager.formulaEditorItemsForLogicSection(spriteObject: spriteObject)
        XCTAssertEqual(3, items.count)
        XCTAssertTrue(functionA.formulaEditorSections().elementsEqual(items[0].function!.formulaEditorSections()))
        XCTAssertTrue(sensorA.formulaEditorSections(for: spriteObject).elementsEqual(items[1].sensor!.formulaEditorSections(for: spriteObject)))
        XCTAssertTrue(operatorA.formulaEditorSections().elementsEqual(items[2].op!.formulaEditorSections()))
    }

    func testFormulaEditorItemsForDeviceSection() {
        let functionA = ZeroParameterDoubleFunctionMock(tag: "functionTagA",
                                                        value: 1.0,
                                                        formulaEditorSections: [.functions(position: 10, subsection: .maths), .logic(position: 10, subsection: .logical)])
        let functionB = SingleParameterDoubleFunctionMock(tag: "functionTagB",
                                                          value: 2.0,
                                                          parameter: .number(defaultValue: 20),
                                                          formulaEditorSections: [.sensors(position: 20, subsection: .device), .functions(position: 100, subsection: .maths)])

        let sensorA = SensorMock(tag: "sensorTagA", formulaEditorSection: .sensors(position: 1, subsection: .device))
        let sensorB = SensorMock(tag: "sensorTagB")

        let manager = FormulaManager(sensorManager: SensorManager(sensors: [sensorA, sensorB], landscapeMode: false),
                                     functionManager: FunctionManager(functions: [functionA, functionB]),
                                     operatorManager: OperatorManager(operators: []))

        let items = manager.formulaEditorItemsForSensorsSection(spriteObject: spriteObject)
        XCTAssertEqual(2, items.count)
        XCTAssertTrue(sensorA.formulaEditorSections(for: spriteObject).elementsEqual(items[0].sensor!.formulaEditorSections(for: spriteObject)))
        XCTAssertTrue(functionB.formulaEditorSections().elementsEqual(items[1].function!.formulaEditorSections()))
    }

    func testFormulaEditorItemsForObjectSection() {
        let functionA = ZeroParameterDoubleFunctionMock(tag: "functionTagA",
                                                        value: 1.0,
                                                        formulaEditorSection: .functions(position: 10, subsection: .maths))
        let functionB = ZeroParameterDoubleFunctionMock(tag: "functionTagB",
                                                        value: 2.0,
                                                        formulaEditorSection: .sensors(position: 20, subsection: .device))

        let sensorA = SensorMock(tag: "sensorTagA", formulaEditorSection: .object(position: 30, subsection: .general))
        let sensorB = SensorMock(tag: "sensorTagB")

        let operatorA = UnaryOperatorMock(value: 0, formulaEditorSection: .object(position: 40, subsection: .general))
        let operatorB = BinaryOperatorMock(value: 0)

        let manager = FormulaManager(sensorManager: SensorManager(sensors: [sensorA, sensorB], landscapeMode: false),
                                     functionManager: FunctionManager(functions: [functionA, functionB]),
                                     operatorManager: OperatorManager(operators: [operatorA, operatorB]))

        let items = manager.formulaEditorItemsForObjectSection(spriteObject: spriteObject)
        XCTAssertEqual(2, items.count)
        XCTAssertTrue(sensorA.formulaEditorSections(for: spriteObject).elementsEqual(items[0].sensor!.formulaEditorSections(for: spriteObject)))
        XCTAssertTrue(operatorA.formulaEditorSections().elementsEqual(items[1].op!.formulaEditorSections()))
    }

    func testFormulaEditorItemsForFunctionAndLogicSection() {
        let function = ZeroParameterDoubleFunctionMock(tag: "functionTagA", value: 1.0, formulaEditorSection: .functions(position: 10, subsection: .maths))

        let sensorA = SensorMock(tag: "sensorTagA", formulaEditorSections: [.functions(position: 20, subsection: .maths), .sensors(position: 30, subsection: .device)])
        let sensorB = SensorMock(tag: "sensorTagB", formulaEditorSections: [.logic(position: 50, subsection: .logical)])

        let op = UnaryOperatorMock(value: 0, formulaEditorSections: [.functions(position: 60, subsection: .maths), .logic(position: 70, subsection: .logical)])

        let manager = FormulaManager(sensorManager: SensorManager(sensors: [sensorA, sensorB], landscapeMode: false),
                                     functionManager: FunctionManager(functions: [function]),
                                     operatorManager: OperatorManager(operators: [op]))

        let mathItems = manager.formulaEditorItemsForFunctionSection(spriteObject: spriteObject)
        XCTAssertEqual(3, mathItems.count)
        XCTAssertTrue(mathItems.contains { $0.function?.tag() == function.tag() })
        XCTAssertTrue(mathItems.contains { $0.sensor?.tag() == sensorA.tag() })
        XCTAssertTrue(mathItems.contains { $0.title == type(of: op).name })

        let logicItems = manager.formulaEditorItemsForLogicSection(spriteObject: spriteObject)
        XCTAssertEqual(2, logicItems.count)
        XCTAssertTrue(logicItems.contains { $0.sensor?.tag() == sensorB.tag() })
        XCTAssertTrue(logicItems.contains { $0.title == type(of: op).name })
    }

    func testFunctionExists() {
        let functionA = ZeroParameterDoubleFunctionMock(tag: "functionTagA",
                                                        value: 1.0,
                                                        formulaEditorSection: .functions(position: 10, subsection: .maths))
        let functionB = SingleParameterDoubleFunctionMock(tag: "functionTagB",
                                                          value: 2.0,
                                                          parameter: .number(defaultValue: 20),
                                                          formulaEditorSection: .sensors(position: 20, subsection: .device))

        let manager = FormulaManager(sensorManager: SensorManager(sensors: [], landscapeMode: false),
                                     functionManager: FunctionManager(functions: [functionA, functionB]),
                                     operatorManager: OperatorManager(operators: []))

        XCTAssertFalse(manager.functionExists(tag: "unavailableFunctionTag"))
        XCTAssertTrue(manager.functionExists(tag: functionA.tag()))
        XCTAssertTrue(manager.functionExists(tag: functionB.tag()))

        XCTAssertNil(manager.getFunction(tag: "unavailableFunctionTag"))
        XCTAssertNotNil(manager.getFunction(tag: functionA.tag()))
        XCTAssertNotNil(manager.getFunction(tag: functionB.tag()))
    }

    func testSensorExists() {
        let sensorA = AccelerationXSensor(motionManagerGetter: { nil })
        let sensorB = AccelerationYSensor(motionManagerGetter: { nil })

        let manager = FormulaManager(sensorManager: SensorManager(sensors: [sensorA, sensorB], landscapeMode: false),
                                     functionManager: FunctionManager(functions: []),
                                     operatorManager: OperatorManager(operators: []))

        XCTAssertFalse(manager.sensorExists(tag: "unavailableSensorTag"))
        XCTAssertTrue(manager.sensorExists(tag: sensorA.tag()))
        XCTAssertTrue(manager.sensorExists(tag: sensorB.tag()))

        XCTAssertNil(manager.getSensor(tag: "unavailableSensorTag"))
        XCTAssertNotNil(manager.getSensor(tag: sensorA.tag()))
        XCTAssertNotNil(manager.getSensor(tag: sensorB.tag()))
    }

    func testOperatorExists() {
        let operatorA = UnaryOperatorMock(value: 0, formulaEditorSection: .object(position: 40, subsection: .general))
        let operatorB = BinaryOperatorMock(value: 0)

        let manager = FormulaManager(sensorManager: SensorManager(sensors: [], landscapeMode: false),
                                     functionManager: FunctionManager(functions: []),
                                     operatorManager: OperatorManager(operators: [operatorA, operatorB]))

        XCTAssertFalse(manager.operatorExists(tag: "unavailableOperatorTag"))
        XCTAssertTrue(manager.operatorExists(tag: type(of: operatorA).tag))
        XCTAssertTrue(manager.operatorExists(tag: type(of: operatorB).tag))

        XCTAssertNil(manager.getOperator(tag: "unavailableOperatorTag"))
        XCTAssertNotNil(manager.getOperator(tag: type(of: operatorA).tag))
        XCTAssertNotNil(manager.getOperator(tag: type(of: operatorB).tag))
    }
}
