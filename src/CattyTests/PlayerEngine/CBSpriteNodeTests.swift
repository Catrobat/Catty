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
        
        self.spriteNode.zRotation = 20.0
        XCTAssertEqual(20.0, Double(self.spriteNode.zRotation), accuracy: epsilon, "SpriteNode rotation not correct")
        
        /*self.spriteNode.rRotation = 180.0
        XCTAssertEqual(180.0, self.spriteNode.zRotation, accuracy: epsilon, "SpriteNode rotation not correct")
        
        self.spriteNode.zRotation = 181.0
        XCTAssertEqual(-179.0, self.spriteNode.zRotation, accuracy: epsilon, "SpriteNode rotation not correct")
        
        self.spriteNode.zRotation = 220.0
        XCTAssertEqual(-140.0, self.spriteNode.zRotation, accuracy: epsilon, "SpriteNode rotation not correct")
        
        self.spriteNode.zRotation = 359.0
        XCTAssertEqual(-1.0, self.spriteNode.zRotation, accuracy: epsilon, "SpriteNode rotation not correct")
        
        self.spriteNode.zRotation = 360.0
        XCTAssertEqual(0.0, self.spriteNode.zRotation, accuracy: epsilon, "SpriteNode rotation not correct")
        
        self.spriteNode.zRotation = 361.0
        XCTAssertEqual(CGFloat(1.0), self.spriteNode.zRotation, accuracy: epsilon, "SpriteNode rotation not correct")
        
        self.spriteNode.zRotation = -361.0
        XCTAssertEqual(CGFloat(-1.0), self.spriteNode.zRotation, accuracy: epsilon, "SpriteNode rotation not correct")
        
        self.spriteNode.zRotation = -90.0
        XCTAssertEqual(CGFloat(-90.0), self.spriteNode.zRotation, accuracy: epsilon, "SpriteNode rotation not correct")
        
        self.spriteNode.zRotation = -185.0
        XCTAssertEqual(CGFloat(175.0), self.spriteNode.zRotation, accuracy: epsilon, "SpriteNode rotation not correct")*/
    }
}
