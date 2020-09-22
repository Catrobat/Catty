/**
 *  Copyright (C) 2010-2020 The Catrobat Team
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

final class WaitBrickTests: XCTestCase {

    var spriteObject: SpriteObject!
    var spriteNode: CBSpriteNode!
    var script: Script!
    var logger: CBLogger!
    var formulaInterpreter: FormulaManager!
    var scheduler: CBScheduler!

    override func setUp() {
        super.setUp()

        logger = CBLogger(name: "Logger")

        spriteObject = SpriteObject()
        let scene = Scene()
        spriteObject.scene = scene

        spriteNode = CBSpriteNode(spriteObject: spriteObject)
        spriteNode.name = "SpriteNode"
        spriteNode.spriteObject = spriteObject
        spriteObject.spriteNode = spriteNode

        script = Script()
        script.object = spriteObject
        formulaInterpreter = FormulaManager(stageSize: Util.screenSize(true), landscapeMode: false)

        scheduler = CBScheduler(logger: self.logger,
                                broadcastHandler: CBBroadcastHandler(logger: self.logger),
                                formulaInterpreter: formulaInterpreter,
                                audioEngine: AudioEngineMock())
    }

    func testWaitDuration() {
        let duration = 3.0 // 3 seconds
        let waitBrick = WaitBrick()
        waitBrick.timeToWaitInSeconds = Formula(double: duration)
        waitBrick.script = script
        let executionTime = self.measureExecutionTime(instruction: waitBrick.instruction(), expectation: nil)
        XCTAssertEqual(executionTime, duration, accuracy: 0.5, "Wrong execution time")
        XCTAssertEqual(scheduler._activeTimers.count, 0)
    }

    func testSchedulerSetTimer_activeTimersCountIsOne() {
        let extendedTimer = ExtendedTimer.init(timeInterval: 2,
                                               repeats: false,
                                               execOnMainRunLoop: true,
                                               startTimerImmediately: true) { _ in }
        self.scheduler.registerTimer(extendedTimer)
        XCTAssertEqual(scheduler._activeTimers.count, 1)
    }

    func testSchedulerRemoveTimer_activeTimersCountIsZero() {
        let extendedTimer = ExtendedTimer.init(timeInterval: 2,
                                               repeats: false,
                                               execOnMainRunLoop: true,
                                               startTimerImmediately: true) { _ in }
        self.scheduler.registerTimer(extendedTimer)
        self.scheduler.removeTimer(extendedTimer)

        XCTAssertEqual(scheduler._activeTimers.count, 0)
    }

    func measureExecutionTime(instruction: CBInstruction, expectation: XCTestExpectation?) -> Double {
        var timeIntervalInSeconds = Double(-10)

        switch instruction {
        case let .waitExecClosure(closure):

            let expectation = self.expectation(description: "Wait expectation")
            DispatchQueue.global(qos: .background).async {
                let start = NSDate()
                closure(CBScriptContext(script: self.script,
                                        spriteNode: self.spriteNode,
                                        formulaInterpreter: self.formulaInterpreter,
                                        touchManager: self.formulaInterpreter.touchManager)!,
                        self.scheduler)
                let end = NSDate()
                timeIntervalInSeconds = end.timeIntervalSince(start as Date)
                expectation.fulfill()
            }
            waitForExpectations(timeout: 10)

        default:
            break
        }

        return timeIntervalInSeconds
    }
}
