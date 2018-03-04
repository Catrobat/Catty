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

final class SensorHandlerTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    func testObjectLookName() {
        let object = SpriteObject()
        let program = Program.defaultProgram(withName: "a", programID: kNoProgramIDYetPlaceholder)
        let spriteNode = CBSpriteNode(spriteObject: object)
        object.spriteNode = spriteNode
        object.program = program
        let bundle = Bundle(for: type(of: self))
        let filePath: String? = bundle.path(forResource: "test.png", ofType: nil)
        let imageData: NSData? = UIImagePNGRepresentation(UIImage(contentsOfFile: filePath!)!)! as NSData
        
        let look = Look(name: "test", andPath: "test.png")
        imageData?.write(toFile: "\(object.projectPath())/\("test.png")", atomically: true)
        let look1 = Look(name: "test2", andPath: "test2.png")
        imageData?.write(toFile: "\(object.projectPath())/\("test2.png")", atomically: true)
        
        let script = WhenScript()
        script.object = object
        
        object.lookList.add(look!)
        object.lookList.add(look1!)
        
        let element = FormulaElement(elementType: .SENSOR, value: SensorManager.string(for: OBJECT_LOOK_NAME), leftChild: nil, rightChild: nil, parent: nil)
        let formula = Formula(formulaElement: element)
        
        spriteNode.currentLook = look
        formula?.preCalculate(forSprite: script.object.spriteNode.spriteObject)
        XCTAssertNotNil(formula?.bufferedResult)
        XCTAssertEqual(formula?.bufferedResult as? String, look?.name)
        
        spriteNode.currentLook = look1
        formula?.preCalculate(forSprite: script.object.spriteNode.spriteObject)
        XCTAssertNotNil(formula?.bufferedResult)
        XCTAssertEqual(formula?.bufferedResult as? String, look1?.name)
        
        Program.removeProgramFromDisk(withProgramName: program.header.programName, programID: program.header.programID)
    }
    
    func testObjectLookNumber() {
        let object = SpriteObject()
        let program = Program.defaultProgram(withName: "a", programID: kNoProgramIDYetPlaceholder)
        let spriteNode = CBSpriteNode(spriteObject: object)
        object.spriteNode = spriteNode
        object.program = program
        let bundle = Bundle(for: type(of: self))
        let filePath: String? = bundle.path(forResource: "test.png", ofType: nil)
        let imageData: NSData? = UIImagePNGRepresentation(UIImage(contentsOfFile: filePath!)!)! as NSData
        
        let look = Look(name: "test", andPath: "test.png")
        imageData?.write(toFile: "\(object.projectPath())/\("test.png")", atomically: true)
        
        let look1 = Look(name: "test2", andPath: "test2.png")
        imageData?.write(toFile: "\(object.projectPath())/\("test2.png")", atomically: true)
        
        let script = WhenScript()
        script.object = object
        
        object.lookList.add(look!)
        
        object.lookList.add(look1!)
        
        let element = FormulaElement(elementType: .SENSOR, value: SensorManager.string(for: OBJECT_LOOK_NUMBER), leftChild: nil, rightChild: nil, parent: nil)
        
        let formula = Formula(formulaElement: element)
        
        spriteNode.currentLook = look
        formula?.preCalculate(forSprite: script.object.spriteNode.spriteObject)
        XCTAssertNotNil(formula?.bufferedResult)
        XCTAssertEqual(formula?.bufferedResult as? Int, object.lookList.index(of: look!) + 1)
        
        spriteNode.currentLook = look1
        formula?.preCalculate(forSprite: script.object.spriteNode.spriteObject)
        XCTAssertNotNil(formula?.bufferedResult)
        XCTAssertEqual(formula?.bufferedResult as? Int, object.lookList.index(of: look1!) + 1)
        
        
        Program.removeProgramFromDisk(withProgramName: program.header.programName, programID: program.header.programID)
    }
    
    func testObjectLookNumberDefaultValue() {
        let program = Program()
        let object = SpriteObject()
        let spriteNode = CBSpriteNode(spriteObject: object)
        object.spriteNode = spriteNode
        object.program = program
        
        let script = WhenScript()
        script.object = object
        
        let element = FormulaElement(elementType: .SENSOR, value: SensorManager.string(for: OBJECT_LOOK_NUMBER), leftChild: nil, rightChild: nil, parent: nil)
        let formula = Formula(formulaElement: element)
        
        formula?.preCalculate(forSprite: script.object.spriteNode.spriteObject)
        XCTAssertNotNil(formula?.bufferedResult)
        XCTAssertEqual(1, formula?.bufferedResult as? Int, "Invalid default value for OBJECT_LOOK_NUMBER")
    }
    
    func testObjectLookNameDefaultValue() {
        let program = Program()
        let object = SpriteObject()
        let spriteNode = CBSpriteNode(spriteObject: object)
        object.spriteNode = spriteNode
        object.program = program
        
        let script = WhenScript()
        script.object = object
        
        let element = FormulaElement(elementType: .SENSOR, value: SensorManager.string(for: OBJECT_LOOK_NAME), leftChild: nil, rightChild: nil, parent: nil)
        let formula = Formula(formulaElement: element)
        
        formula?.preCalculate(forSprite: script.object.spriteNode.spriteObject)
        XCTAssertNotNil(formula?.bufferedResult)
        XCTAssertEqual("", formula?.bufferedResult as? String, "Invalid default value for OBJECT_LOOK_NAME")
    }
    
    func testObjectColor() {
        let object = SpriteObject()
        let program = Program.defaultProgram(withName: "a", programID: kNoProgramIDYetPlaceholder)
        let spriteNode = CBSpriteNode(spriteObject: object)
        object.spriteNode = spriteNode
        object.program = program
        let bundle = Bundle(for: type(of: self))
        let filePath: String? = bundle.path(forResource: "test.png", ofType: nil)
        let imageData: NSData? = UIImagePNGRepresentation(UIImage(contentsOfFile: filePath!)!)! as NSData
        
        do {
            try imageData?.write(to: URL(fileURLWithPath: object.projectPath() + "images/test.png"), options: .atomic)
        } catch {
            XCTFail("Image not written to disk")
        }
        
        let look = Look(name: "test", andPath: "test.png")
        let script = WhenScript()
        script.object = object
        
        object.lookList.add(look!)
        
        let element = FormulaElement(elementType: .SENSOR, value: SensorManager.string(for: OBJECT_COLOR), leftChild: nil, rightChild: nil, parent: nil)
        let formula = Formula(formulaElement: element)
        
        spriteNode.currentLook = look
        formula?.preCalculate(forSprite: script.object.spriteNode.spriteObject)
        XCTAssertNotNil(formula?.bufferedResult)
        XCTAssertEqual(formula?.bufferedResult as? Int, 0)
        
        let changeColorByNBrick = ChangeColorByNBrick()
        changeColorByNBrick.script = script
        changeColorByNBrick.changeColor = Formula(double: 25)
        
        let action = changeColorByNBrick.actionBlock()
        action!()
        
        formula?.preCalculate(forSprite: script.object.spriteNode.spriteObject)
        XCTAssertNotNil(formula?.bufferedResult)
        XCTAssertEqual(formula?.bufferedResult as? Int, 25)
        
        
        Program.removeProgramFromDisk(withProgramName: program.header.programName, programID: program.header.programID)
    }
    
    func testDateSensors() {
        let object = SpriteObject()
        let program = Program.defaultProgram(withName: "a", programID: kNoProgramIDYetPlaceholder)
        let spriteNode = CBSpriteNode(spriteObject: object)
        object.spriteNode = spriteNode
        object.program = program
        let bundle = Bundle(for: type(of: self))
        let filePath: String? = bundle.path(forResource: "test.png", ofType: nil)
        let imageData: NSData? = UIImagePNGRepresentation(UIImage(contentsOfFile: filePath!)!)! as NSData
        
        let look = Look(name: "test", andPath: "test.png")
        imageData?.write(toFile: "\(object.projectPath())/\("images")/\("test.png")", atomically: true)
        
        let script = WhenScript()
        script.object = object
        
        object.lookList.add(look!)
        spriteNode.currentLook = look
        
        let element = FormulaElement(elementType: .SENSOR, value: SensorManager.string(for: DATE_YEAR), leftChild: nil, rightChild: nil, parent: nil)
        let formula = Formula(formulaElement: element)
        
        formula?.preCalculate(forSprite: script.object.spriteNode.spriteObject)
        XCTAssertNotNil(formula?.bufferedResult)
        
        let units: Set<Calendar.Component> = [.year, .month, .day, .weekday, .hour, .minute, .second]
        let components = Calendar.current.dateComponents(units, from: Date())
        
        XCTAssertEqual(formula?.bufferedResult as? Int, components.year)
        
        element?.value = SensorManager.string(for: DATE_MONTH)
        formula?.preCalculate(forSprite: script.object.spriteNode.spriteObject)
        XCTAssertEqual(formula?.bufferedResult as? Int, components.month)
        
        element?.value = SensorManager.string(for: DATE_DAY)
        formula?.preCalculate(forSprite: script.object.spriteNode.spriteObject)
        XCTAssertEqual(formula?.bufferedResult as? Int, components.day)
        
        element?.value = SensorManager.string(for: DATE_WEEKDAY)
        formula?.preCalculate(forSprite: script.object.spriteNode.spriteObject)
        XCTAssertEqual(formula?.bufferedResult as? Int, components.weekday)
        
        element?.value = SensorManager.string(for: TIME_HOUR)
        formula?.preCalculate(forSprite: script.object.spriteNode.spriteObject)
        XCTAssertEqual(formula?.bufferedResult as? Int, components.hour)
        
        element?.value = SensorManager.string(for: TIME_MINUTE)
        formula?.preCalculate(forSprite: script.object.spriteNode.spriteObject)
        XCTAssertEqual(formula?.bufferedResult as? Int, components.minute)
        
        element?.value = SensorManager.string(for: TIME_SECOND)
        formula?.preCalculate(forSprite: script.object.spriteNode.spriteObject)
        XCTAssertEqual(formula?.bufferedResult as? Int, components.second)
        
        Program.removeProgramFromDisk(withProgramName: program.header.programName, programID: program.header.programID)
    }
}
