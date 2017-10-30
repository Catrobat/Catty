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

final class BrickTests: XCTestCase {
    
    func testRemoveWaitBrick() {
        
        let script = Script()
        let brick = WaitBrick()
        
        script.add(brick, at: 0)
        
        XCTAssertEqual(1, script.brickList.count, "Invalid number of Bricks")
        
        brick.removeFromScript()
        
        XCTAssertEqual(0, script.brickList.count, "Invalid number of Bricks")
    }
    
    func testRemoveSetVariableBrick() {
        
        let script = Script()
        let brickA = SetVariableBrick()
        brickA.variableFormula = Formula.init(float: 1.0)
        
        let brickB = SetVariableBrick()
        brickB.variableFormula = Formula.init(float: 2.0)
        
        script.add(brickA, at: 0)
        script.add(brickB, at: 1)
        
        XCTAssertEqual(2, script.brickList.count, "Invalid number of Bricks")
        
        brickB.removeFromScript()
        
        XCTAssertEqual(1, script.brickList.count, "Invalid number of Bricks")
        
        let brick = script.brickList[0] as! SetVariableBrick
        
        XCTAssertEqual(1.0, brick.variableFormula.interpretDouble(forSprite: nil), "Invalid formula");
    }
}
