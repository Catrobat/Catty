/**
 *  Copyright (C) 2010-2017 The Catrobat Team
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
        let program = Program.defaultProgramWithName("a", programID: kNoProgramIDYetPlaceholder)
        let spriteNode = CBSpriteNode(spriteObject: object)
        object.spriteNode = spriteNode
        object.program = program
        let bundle = NSBundle(forClass: self.dynamicType)
        let filePath: String? = bundle.pathForResource("test.png", ofType: nil)
        let imageData: NSData? = UIImagePNGRepresentation(UIImage(contentsOfFile: filePath!)!)
        
        let look = Look(name: "test", andPath: "test.png")
        imageData?.writeToFile("\(object.projectPath())/\("test.png")", atomically: true)
        let look1 = Look(name: "test2", andPath: "test2.png")
        imageData?.writeToFile("\(object.projectPath())/\("test2.png")", atomically: true)
        
        let script = WhenScript()
        script.object = object
        
        object.lookList.addObject(look)
        object.lookList.addObject(look1)
        
        let element = FormulaElement(elementType: .SENSOR, value: SensorManager.stringForSensor(OBJECT_LOOK_NAME), leftChild: nil, rightChild: nil, parent: nil)
        let formula = Formula(formulaElement: element)
        
        spriteNode.currentLook = look
        formula.preCalculateFormulaForSprite(script.object.spriteNode.spriteObject)
        XCTAssertNotNil(formula.bufferedResult)
        XCTAssertEqual(formula.bufferedResult as? String, look.name)
        
        spriteNode.currentLook = look1
        formula.preCalculateFormulaForSprite(script.object.spriteNode.spriteObject)
        XCTAssertNotNil(formula.bufferedResult)
        XCTAssertEqual(formula.bufferedResult as? String, look1.name)
        
        Program.removeProgramFromDiskWithProgramName(program.header.programName, programID: program.header.programID)
    }
    
    func testObjectLookNumber() {
        let object = SpriteObject()
        let program = Program.defaultProgramWithName("a", programID: kNoProgramIDYetPlaceholder)
        let spriteNode = CBSpriteNode(spriteObject: object)
        object.spriteNode = spriteNode
        object.program = program
        let bundle = NSBundle(forClass: self.dynamicType)
        let filePath: String? = bundle.pathForResource("test.png", ofType: nil)
        let imageData: NSData? = UIImagePNGRepresentation(UIImage(contentsOfFile: filePath!)!)
        
        let look = Look(name: "test", andPath: "test.png")
        imageData?.writeToFile("\(object.projectPath())/\("test.png")", atomically: true)
        
        let look1 = Look(name: "test2", andPath: "test2.png")
        imageData?.writeToFile("\(object.projectPath())/\("test2.png")", atomically: true)
        
        let script = WhenScript()
        script.object = object
        
        object.lookList.addObject(look)
        
        object.lookList.addObject(look1)
        
        let element = FormulaElement(elementType: .SENSOR, value: SensorManager.stringForSensor(OBJECT_LOOK_NUMBER), leftChild: nil, rightChild: nil, parent: nil)
        
        let formula = Formula(formulaElement: element)
        
        spriteNode.currentLook = look
        formula.preCalculateFormulaForSprite(script.object.spriteNode.spriteObject)
        XCTAssertNotNil(formula.bufferedResult)
        XCTAssertEqual(formula.bufferedResult as? Int, object.lookList.indexOfObject(look) + 1)
        
        spriteNode.currentLook = look1
        formula.preCalculateFormulaForSprite(script.object.spriteNode.spriteObject)
        XCTAssertNotNil(formula.bufferedResult)
        XCTAssertEqual(formula.bufferedResult as? Int, object.lookList.indexOfObject(look1) + 1)
        
        
        Program.removeProgramFromDiskWithProgramName(program.header.programName, programID: program.header.programID)
    }
    
    func testObjectColor() {
        let object = SpriteObject()
        let program = Program.defaultProgramWithName("a", programID: kNoProgramIDYetPlaceholder)
        let spriteNode = CBSpriteNode(spriteObject: object)
        object.spriteNode = spriteNode
        object.program = program
        let bundle = NSBundle(forClass: self.dynamicType)
        let filePath: String? = bundle.pathForResource("test.png", ofType: nil)
        let imageData: NSData? = UIImagePNGRepresentation(UIImage(contentsOfFile: filePath!)!)
        
        let look = Look(name: "test", andPath: "test.png")
        imageData?.writeToFile("\(object.projectPath())/\("images")/\("test.png")", atomically: true)
        
        let script = WhenScript()
        script.object = object
        
        object.lookList.addObject(look)
        
        let element = FormulaElement(elementType: .SENSOR, value: SensorManager.stringForSensor(OBJECT_COLOR), leftChild: nil, rightChild: nil, parent: nil)
        let formula = Formula(formulaElement: element)
        
        spriteNode.currentLook = look
        formula.preCalculateFormulaForSprite(script.object.spriteNode.spriteObject)
        XCTAssertNotNil(formula.bufferedResult)
        XCTAssertEqual(formula.bufferedResult as? Int, 0)
        
        let changeColorByNBrick = ChangeColorByNBrick()
        changeColorByNBrick.script = script
        changeColorByNBrick.changeColor = Formula(double: 25)
        
        let action = changeColorByNBrick.actionBlock()
        action!()
        
        formula.preCalculateFormulaForSprite(script.object.spriteNode.spriteObject)
        XCTAssertNotNil(formula.bufferedResult)
        XCTAssertEqual(formula.bufferedResult as? Int, 25)
        
        
        Program.removeProgramFromDiskWithProgramName(program.header.programName, programID: program.header.programID)
    }
}
