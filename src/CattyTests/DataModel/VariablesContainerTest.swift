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

final class VariablesContainerTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    func testAddObjectVariable() {
        let objectA = SpriteObject()
        objectA.name = "testObjectA"
        
        let objectB = SpriteObject()
        objectB.name = "testObjectB"
        
        let userVariable = UserVariable()
        userVariable.name = "testName"
        
        let container = VariablesContainer()
        XCTAssertEqual(0, container.allVariables()?.count)
        XCTAssertEqual(0, container.allVariables(for: objectA)?.count)
        XCTAssertEqual(0, container.allVariables(for: objectB)?.count)
        
        var result = container.addObjectVariable(userVariable, for: objectA)
        XCTAssertTrue(result)
        
        XCTAssertEqual(1, container.allVariables()?.count)
        XCTAssertEqual(1, container.allVariables(for: objectA)?.count)
        XCTAssertEqual(0, container.allVariables(for: objectB)?.count)
        
        result = container.addObjectVariable(userVariable, for: objectA)
        XCTAssertFalse(result)
        
        result = container.addObjectVariable(userVariable, for: objectB)
        XCTAssertTrue(result)
        
        XCTAssertEqual(2, container.allVariables()?.count)
        XCTAssertEqual(1, container.allVariables(for: objectA)?.count)
        XCTAssertEqual(1, container.allVariables(for: objectB)?.count)
    }
    
    func testAddObjectList() {
        let objectA = SpriteObject()
        objectA.name = "testObjectA"
        
        let objectB = SpriteObject()
        objectB.name = "testObjectB"
        
        let list = UserVariable()
        list.name = "testName"
        list.isList = true
        
        let container = VariablesContainer()
        XCTAssertEqual(0, container.allLists().count)
        XCTAssertEqual(0, container.allLists(for: objectA)?.count)
        XCTAssertEqual(0, container.allLists(for: objectB)?.count)
        
        var result = container.addObjectList(list, for: objectA)
        XCTAssertTrue(result)
        
        XCTAssertEqual(1, container.allLists()?.count)
        XCTAssertEqual(1, container.allLists(for: objectA)?.count)
        XCTAssertEqual(0, container.allLists(for: objectB)?.count)
        
        result = container.addObjectList(list, for: objectA)
        XCTAssertFalse(result)
        
        result = container.addObjectList(list, for: objectB)
        XCTAssertTrue(result)
        
        XCTAssertEqual(2, container.allLists()?.count)
        XCTAssertEqual(1, container.allLists(for: objectA)?.count)
        XCTAssertEqual(1, container.allLists(for: objectB)?.count)
    }
}
