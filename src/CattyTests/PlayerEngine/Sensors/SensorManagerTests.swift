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

import CoreLocation
import CoreMotion
import XCTest

@testable import Pocket_Code

final class SensorManagerTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func testDefaultValueForUndefinedSensor() {
        let defaultValue = 12.3
        let manager = SensorManager(sensors: [], landscapeMode: false)
        type(of: manager).defaultValueForUndefinedSensor = defaultValue

        XCTAssertNil(manager.sensor(tag: "noSensorForThisTag"))
        XCTAssertEqual(defaultValue, manager.value(tag: "noSensorForThisTag", spriteObject: nil) as! Double)
    }

    func testExists() {
        let sensorA = SensorMock(tag: "tagA")
        let sensorB = SensorMock(tag: "tagB")
        let manager = SensorManager(sensors: [sensorA, sensorB], landscapeMode: false)

        XCTAssertFalse(manager.exists(tag: "unavailableSensorTag"))
        XCTAssertTrue(manager.exists(tag: sensorA.tag()))
        XCTAssertTrue(manager.exists(tag: sensorB.tag()))
    }

    func testSensor() {
        let sensorA = SensorMock(tag: "tagA")
        let sensorB = SensorMock(tag: "tagB")
        let manager = SensorManager(sensors: [sensorA, sensorB], landscapeMode: false)

        XCTAssertNil(manager.sensor(tag: "unavailableSensorTag"))

        var sensor = manager.sensor(tag: sensorA.tag())
        XCTAssertNotNil(sensor)
        XCTAssertEqual(sensorA.tag(), sensor?.tag())

        sensor = manager.sensor(tag: sensorB.tag())
        XCTAssertNotNil(sensor)
        XCTAssertEqual(sensorB.tag(), sensor?.tag())
    }

    func testRequiredResource() {
        let sensorA = AccelerationXSensor(motionManagerGetter: { nil })
        let sensorB = SensorMock(tag: "tagB")
        type(of: sensorB).requiredResource = ResourceType.accelerometer

        let manager = SensorManager(sensors: [sensorA, sensorB], landscapeMode: false)

        XCTAssertEqual(ResourceType.noResources, type(of: manager).requiredResource(tag: "invalidTag"))
        XCTAssertEqual(type(of: sensorA).requiredResource, type(of: manager).requiredResource(tag: sensorA.tag()))
        XCTAssertEqual(type(of: sensorB).requiredResource, type(of: manager).requiredResource(tag: sensorB.tag()))
        XCTAssertNotEqual(type(of: sensorA).requiredResource, type(of: sensorB).requiredResource)
    }

    func testName() {
        let sensorA = AccelerationXSensor(motionManagerGetter: { nil })
        let sensorB = SensorMock(tag: "tagB")
        type(of: sensorB).name = "testName"

        let manager = SensorManager(sensors: [sensorA, sensorB], landscapeMode: false)

        XCTAssertNil(type(of: manager).name(tag: "invalidTag"))
        XCTAssertEqual(type(of: sensorA).name, type(of: manager).name(tag: sensorA.tag()))
        XCTAssertEqual(type(of: sensorB).name, type(of: manager).name(tag: sensorB.tag()))
        XCTAssertNotEqual(type(of: sensorA).name, type(of: sensorB).name)
    }

    func testFormulaEditorItems() {
        let sensorA = SensorMock(tag: "tagA", formulaEditorSections: [])
        let sensorB = SensorMock(tag: "tagB", formulaEditorSections: [.sensors(position: 1, subsection: .device), .functions(position: 10, subsection: .maths)])
        let sensorC = SensorMock(tag: "tagC", formulaEditorSections: [.object(position: 2, subsection: .general), .functions(position: 10, subsection: .maths)])

        let manager = SensorManager(sensors: [sensorA, sensorB, sensorC], landscapeMode: false)
        let items = manager.formulaEditorItems(for: SpriteObject())

        XCTAssertEqual(3, items.count)
        XCTAssertNotNil(items.filter { $0.sensor?.tag() == sensorA.tag() }.first)
        XCTAssertNotNil(items.filter { $0.sensor?.tag() == sensorB.tag() }.first)
        XCTAssertNotNil(items.filter { $0.sensor?.tag() == sensorC.tag() }.first)
    }

    func testValue() {
        let object = SpriteObject()
        let sensorA = DeviceDoubleSensorMock(tag: "tagA", value: 1.0)
        let sensorB = ObjectDoubleSensorMock(tag: "tagB", value: 2.0)
        let sensorC = ObjectStringSensorMock(tag: "tagC", value: "test")

        let manager = SensorManager(sensors: [sensorA, sensorB, sensorC], landscapeMode: false)
        type(of: manager).defaultValueForUndefinedSensor = 12.3

        XCTAssertEqual(type(of: manager).defaultValueForUndefinedSensor, manager.value(tag: "undefinedTag", spriteObject: object) as! Double)
        XCTAssertEqual(sensorA.rawValue(landscapeMode: false), manager.value(tag: sensorA.tag(), spriteObject: object) as! Double)
        XCTAssertEqual(sensorA.rawValue(landscapeMode: true), manager.value(tag: sensorA.tag(), spriteObject: object) as! Double)
        XCTAssertEqual(sensorA.rawValue(landscapeMode: false), manager.value(tag: sensorA.tag(), spriteObject: nil) as! Double)
        XCTAssertEqual(sensorA.rawValue(landscapeMode: true), manager.value(tag: sensorA.tag(), spriteObject: nil) as! Double)
        XCTAssertEqual(type(of: sensorB).rawValue(for: SpriteObject()), manager.value(tag: sensorB.tag(), spriteObject: object) as! Double)
        XCTAssertEqual(type(of: sensorC).rawValue(for: object), manager.value(tag: sensorC.tag(), spriteObject: object) as! String)
        XCTAssertEqual(type(of: sensorC).defaultRawValue, manager.value(tag: sensorC.tag()) as! Double)
    }
}
