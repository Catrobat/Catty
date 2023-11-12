/**
 *  Copyright (C) 2010-2023 The Catrobat Team
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

final class WaitUntilBrickTests: XMLAbstractTest {

    func testWaitUntilBrick_conditionTrue_proceedsToNextBrick() {
        let project = getProjectForXML(xmlFile: "WaitUntilBrick0991")
        project.activeScene = project.scenes.firstObject as! Scene
        let testVar = project.userData.getUserVariable(identifiedBy: "testVar")
        let hasFinishedWaiting = project.userData.getUserVariable(identifiedBy: "hasFinishedWaiting")

        let stage = createStage(project: project)
        let started = stage.startProject()
        XCTAssertTrue(started)
        testVar?.value = NSNumber(value: 1)

        let conditionMetPredicate = NSPredicate(block: { variable, _ in
            let hasFinishedWaiting = (variable as? UserVariable)!.value as! NSNumber
            return NSNumber(value: 1).isEqual(to: hasFinishedWaiting)
        })

        expectation(for: conditionMetPredicate, evaluatedWith: hasFinishedWaiting!, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
    }

    func testWaitUntilBrick_conditionFalse_getsStuckInWaitUntilBrick() {
        let project = getProjectForXML(xmlFile: "WaitUntilBrick0991")
        project.activeScene = project.scenes.firstObject as! Scene
        let hasFinishedWaiting = project.userData.getUserVariable(identifiedBy: "hasFinishedWaiting")

        let stage = createStage(project: project)
        let started = stage.startProject()
        XCTAssertTrue(started)
        let testPredicate = createPredicate(variable: hasFinishedWaiting!, shouldNotBeEqual: NSNumber(value: 1), forSeconds: 2)

        expectation(for: testPredicate, evaluatedWith: self, handler: nil)
        waitForExpectations(timeout: 4, handler: nil)
    }

    func testWaitUntilBrickCondition_returnsTrue() {
        let brick = WaitUntilBrick()
        let script = Script()
        let object = SpriteObjectMock()
        script.object = object
        brick.script = script
        brick.waitCondition = Formula(float: 0)
        let conditionResult = brick.checkCondition(formulaInterpreter: FormulaManager(stageSize: Util.screenSize(true), landscapeMode: false))
        XCTAssertTrue(conditionResult, "Condition should have returned true.")
    }

    func testWaitUntilBrickCondition_returnsFalse() {
        let brick = WaitUntilBrick()
        let script = Script()
        let object = SpriteObjectMock()
        script.object = object
        brick.script = script
        brick.waitCondition = Formula(float: 1)
        let conditionResult = brick.checkCondition(formulaInterpreter: FormulaManager(stageSize: Util.screenSize(true), landscapeMode: false))
        XCTAssertFalse(conditionResult, "Condition should have returned false.")
    }

    func testMutableCopy() {
        var brick = WaitUntilBrick()
        brick.waitCondition = Formula(float: 0)

        var copiedBrick: WaitUntilBrick = brick.mutableCopy(with: CBMutableCopyContext(), andErrorReporting: true) as! WaitUntilBrick

        XCTAssertTrue(brick.isEqual(to: copiedBrick))
        XCTAssertFalse(brick === copiedBrick)
        XCTAssertTrue(brick.waitCondition.isEqual(to: copiedBrick.waitCondition))
        XCTAssertFalse(brick.waitCondition === copiedBrick.waitCondition)

        brick = WaitUntilBrick()
        brick.waitCondition = Formula(float: 1)

        copiedBrick = brick.mutableCopy(with: CBMutableCopyContext(), andErrorReporting: true) as! WaitUntilBrick

        XCTAssertTrue(brick.waitCondition.isEqual(to: copiedBrick.waitCondition))
        XCTAssertFalse(brick.waitCondition === copiedBrick.waitCondition)

    }

    private func createPredicate(variable: UserVariable, shouldNotBeEqual: NSNumber, forSeconds: Double) -> NSPredicate {
        let stopTime = Date().addingTimeInterval(TimeInterval(forSeconds))
        return NSPredicate(block: { _, _ in
            let variableNumber = variable.value as! NSNumber

            if shouldNotBeEqual.isEqual(to: variableNumber) {
                XCTFail("Script has continued although condition should not have been met.")
                return true
            }

            return Date().timeIntervalSince1970 > stopTime.timeIntervalSince1970
        })
    }

    private func createStage(project: Project) -> Stage {
        let stageBuilder = StageBuilder(project: project)
            .withFormulaManager(formulaManager: FormulaManager(stageSize: Util.screenSize(true), landscapeMode: false))
            .withAudioEngine(audioEngine: AudioEngineMock())
        return stageBuilder.build()
    }

    func testGetFormulas() {
        let brick = WaitUntilBrick()
        let script = Script()
        let object = SpriteObjectMock()
        script.object = object
        brick.script = script
        brick.waitCondition = Formula(float: 1)
        var formulas = brick.getFormulas()

        XCTAssertTrue(brick.waitCondition.isEqual(to: formulas?[0]))
        XCTAssertTrue(brick.waitCondition.isEqual(to: Formula(float: 1)))
        XCTAssertFalse(brick.waitCondition.isEqual(to: Formula(float: 22)))

        brick.waitCondition = Formula(float: 22)
        formulas = brick.getFormulas()

        XCTAssertTrue(brick.waitCondition.isEqual(to: formulas?[0]))
        XCTAssertTrue(brick.waitCondition.isEqual(to: Formula(float: 22)))
        XCTAssertFalse(brick.waitCondition.isEqual(to: Formula(float: 1)))
    }
}
