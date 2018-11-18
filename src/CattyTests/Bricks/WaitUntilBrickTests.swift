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

final class WaitUntilBrickTests : XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    func testWaitUntilBrick_conditionTrue_proceedsToNextBrick() {
        let program = self.getProgramForXML(xmlFile: "WaitUntilBrick0991")
        var testVar = program?.variables.getUserVariableNamed("testVar", for: program?.objectList[0] as! SpriteObject)
        var hasFinishedWaiting = program?.variables.getUserVariableNamed("hasFinishedWaiting", for: program?.objectList[0] as! SpriteObject)

        let sceneBuilder = SceneBuilder(program: program!).withFormulaManager(formulaManager: FormulaManager())
        let scene = sceneBuilder.build()
        scene.startProgram()
        program!.variables.setUserVariable(testVar, toValue: NSNumber(integerLiteral: 1))

        let conditionMetPredicate = NSPredicate(block: { variable , _ in
            let hasFinishedWaiting = (variable as? UserVariable)!.value as! NSNumber
            return NSNumber.init(integerLiteral: 1).isEqual(to: hasFinishedWaiting)
        })

        expectation(for: conditionMetPredicate, evaluatedWith: hasFinishedWaiting, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)


//        expectation(for: predicate(variable: hasFinishedWaiting!, shouldNotBe: NSNumber(integerLiteral: 1), forSeconds: 10), evaluatedWith: self, handler: nil)
        //waitForExpectations(timeout:20, handler: nil)
    }

    func testWaitUntilBrick_conditionFalse_getsStuckInWaitUntilBrick() {
        let program = self.getProgramForXML(xmlFile: "WaitUntilBrick0991")
        var testVar = program?.variables.getUserVariableNamed("testVar", for: program?.objectList[0] as! SpriteObject)
        var hasFinishedWaiting = program?.variables.getUserVariableNamed("hasFinishedWaiting", for: program?.objectList[0] as! SpriteObject)

        let sceneBuilder = SceneBuilder(program: program!).withFormulaManager(formulaManager: FormulaManager())
        let scene = sceneBuilder.build()
        scene.startProgram()
        var testPredicate = createPredicate(variable: hasFinishedWaiting!, shouldNotBeEqual: NSNumber(integerLiteral: 1), forSeconds: 2)

        expectation(for: testPredicate, evaluatedWith: self, handler: nil)
        waitForExpectations(timeout: 4, handler: nil)


        //        expectation(for: predicate(variable: hasFinishedWaiting!, shouldNotBe: NSNumber(integerLiteral: 1), forSeconds: 10), evaluatedWith: self, handler: nil)
        //waitForExpectations(timeout:20, handler: nil)
    }

    func testWaitUntilBrickCondition_returnsTrue() {
        var brick = WaitUntilBrick()
        var script = Script()
        var object = SpriteObjectMock()
        script.object = object
        brick.script = script
        brick.waitCondition = Formula(float: 0)
        let conditionResult = brick.checkCondition(formulaInterpreter: FormulaManager())
        XCTAssertTrue(conditionResult, "Condition should have returned true.")
    }

    func testWaitUntilBrickCondition_returnsFalse() {
        var brick = WaitUntilBrick()
        var script = Script()
        var object = SpriteObjectMock()
        script.object = object
        brick.script = script
        brick.waitCondition = Formula(float: 1)
        let conditionResult = brick.checkCondition(formulaInterpreter: FormulaManager())
        XCTAssertFalse(conditionResult, "Condition should have returned false.")
    }

    private func createPredicate(variable: UserVariable, shouldNotBeEqual: NSNumber, forSeconds:Double) -> NSPredicate {
        let stopTime = Date().addingTimeInterval(TimeInterval(forSeconds))
        return NSPredicate(block: { _ , _ in
            let variableNumber = variable.value as! NSNumber

            if (shouldNotBeEqual.isEqual(to: variableNumber)) {
                XCTFail("Script has continued although condition should not have been met.")
                return true
            }

            return Date().timeIntervalSince1970 > stopTime.timeIntervalSince1970
        })
    }


    
}
