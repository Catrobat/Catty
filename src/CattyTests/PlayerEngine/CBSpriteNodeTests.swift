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

final class CBSpriteNodeTests: XCTestCase {

    var spriteNode = CBSpriteNode()
    
    override func setUp() {
        self.spriteNode = CBSpriteNode()
        
        let spriteObject = SpriteObject()
        spriteNode.spriteObject = spriteObject
        spriteObject.name = "SpriteObjectName"
        spriteObject.spriteNode = spriteNode
    }
    
    func testRotation() {
        let epsilon = 0.001
        
        self.spriteNode.rotation = 20
        XCTAssertEqual(20, self.spriteNode.rotation, accuracy: epsilon, "SpriteNode rotation not correct")
        
        self.spriteNode.rotation = 180
        XCTAssertEqual(180, self.spriteNode.rotation, accuracy: epsilon, "SpriteNode rotation not correct")
        
        self.spriteNode.rotation = 181
        XCTAssertEqual(-179, self.spriteNode.rotation, accuracy: epsilon, "SpriteNode rotation not correct")
        
        self.spriteNode.rotation = 220
        XCTAssertEqual(-140, self.spriteNode.rotation, accuracy: epsilon, "SpriteNode rotation not correct")
        
        self.spriteNode.rotation = 359
        XCTAssertEqual(-1, self.spriteNode.rotation, accuracy: epsilon, "SpriteNode rotation not correct")
        
        self.spriteNode.rotation = 360
        XCTAssertEqual(0, self.spriteNode.rotation, accuracy: epsilon, "SpriteNode rotation not correct")
        
        self.spriteNode.rotation = 361
        XCTAssertEqual(1, self.spriteNode.rotation, accuracy: epsilon, "SpriteNode rotation not correct")
        
        self.spriteNode.rotation = -361
        XCTAssertEqual(-1, self.spriteNode.rotation, accuracy: epsilon, "SpriteNode rotation not correct")
        
        self.spriteNode.rotation = -90
        XCTAssertEqual(-90, self.spriteNode.rotation, accuracy: epsilon, "SpriteNode rotation not correct")
        
        self.spriteNode.rotation = -185
        XCTAssertEqual(175, self.spriteNode.rotation, accuracy: epsilon, "SpriteNode rotation not correct")
    }
}
