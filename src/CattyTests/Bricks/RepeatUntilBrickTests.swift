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

final class RepeatUntilBrickTests: XCTestCase {
    
    func testRepeatUntil() {
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
        
        let varContainer = VariablesContainer();
        object.program.variables = varContainer;
        
        let script = WhenScript()
        script.object = object
        
        object.lookList.addObject(look)
        
        spriteNode.currentLook = look

        let repeatUntilBrick = RepeatUntilBrick()
        
        
        let variableC = UserVariable()
        variableC.name = "c"
        variableC.value = 0
        
        object.program.variables.programVariableList.addObject(variableC)

        repeatUntilBrick.repeatCondition = Formula(formulaElement: FormulaElement(elementType: .OPERATOR, value: "GREATER_THAN", leftChild: nil , rightChild: nil, parent: nil))
        let timesToRepeat = FormulaElement(elementType: .NUMBER, value: "5", leftChild: nil, rightChild: nil, parent: repeatUntilBrick.repeatCondition.formulaTree)
        let variableElement = FormulaElement(elementType: .USER_VARIABLE, value: variableC.name, leftChild: nil, rightChild: nil, parent: repeatUntilBrick.repeatCondition.formulaTree)
        
        repeatUntilBrick.repeatCondition.formulaTree.leftChild = variableElement
        repeatUntilBrick.repeatCondition.formulaTree.rightChild = timesToRepeat
        
        let setVarBrick = SetVariableBrick()
        setVarBrick.variableFormula = Formula(formulaElement: variableElement)
        
        script.addBrick(repeatUntilBrick, atIndex: 1)
        script.addBrick(setVarBrick, atIndex: 2)
        
        Program.removeProgramFromDiskWithProgramName(program.header.programName, programID: program.header.programID)
    }
}
