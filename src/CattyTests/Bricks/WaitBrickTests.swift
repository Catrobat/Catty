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

final class WaitBrickTests: XCTestCase {
    
    var spriteObject : SpriteObject!
    var spriteNode : CBSpriteNode!
    var script : Script!
    var logger : CBLogger!
    
    override func setUp() {
        super.setUp()
        
        logger = CBLogger(name: "Logger");
        
        spriteObject = SpriteObject();
        spriteNode = CBSpriteNode();
        spriteNode.name = "SpriteNode";
        spriteNode.spriteObject = spriteObject;
        spriteObject.spriteNode = spriteNode;
        
        script = Script();
        script.object = spriteObject;
    }
    
    func testWaitDuration() {
        let duration = 2.0 // 2 seconds
        let waitBrick = WaitBrick()
        waitBrick.timeToWaitInSeconds = Formula(double: duration)
        waitBrick.script = script;
        
        let executionTime = measureExecutionTime(instruction: waitBrick.instruction())
        XCTAssertEqual(executionTime, duration, accuracy: 0.1, "Wrong execution time")
    }
    
    /*func testSpeakAndWaitDuration() {
        let speakAndWaitBrick = SpeakAndWaitBrick()
        speakAndWaitBrick.formula = Formula(double: 1010101.0)
        speakAndWaitBrick.script = self.script;
        
        let executionTime = self.measureExecutionTime(speakAndWaitBrick.instruction())
        XCTAssertEqualWithAccuracy(executionTime, 5.0, accuracy: 1.0, "Wrong execution time")
    }*/

    func testTitleSingular() {
        let waitBrick = WaitBrick()
        waitBrick.timeToWaitInSeconds = Formula(double: 1)
        XCTAssertEqual(kLocalizedWait + "%@ " + kLocalizedSecond, waitBrick.brickTitle, "Wrong brick title")
    }
    
    func testTitlePlural() {
        let waitBrick = WaitBrick()
        waitBrick.timeToWaitInSeconds = Formula(double: 2)
        XCTAssertEqual(kLocalizedWait + "%@ " + kLocalizedSeconds, waitBrick.brickTitle, "Wrong brick title")
    }
    
    func measureExecutionTime(instruction: CBInstruction) -> Double {
        let start = NSDate()
       
        switch instruction {
            case let .waitExecClosure(closure):
                closure(CBScriptContext(script: self.script, spriteNode: self.spriteNode), CBScheduler(logger: self.logger, broadcastHandler: CBBroadcastHandler(logger: self.logger)))
            default: break
        }
        
        let end = NSDate()
        let timeIntervalInSeconds: Double = end.timeIntervalSince(start as Date)
        return timeIntervalInSeconds
    }
}
