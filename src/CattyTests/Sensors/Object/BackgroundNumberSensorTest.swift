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

final class BackgroundNumberSensorTest: XCTestCase {
    
    var spriteObject: SpriteObjectMock!
    var spriteNode: CBSpriteNodeMock!
    var sensor: BackgroundNumberSensor!
    
    override func setUp() {
        self.spriteObject = SpriteObjectMock()
        self.spriteNode = CBSpriteNodeMock(spriteObject: spriteObject)
        
        self.sensor = BackgroundNumberSensor()
    }
    
    override func tearDown() {
        self.spriteObject = nil
        self.sensor = nil
    }
    
    func testReturnDefaultValue() {
        // TODO
        // hint: what happens if object does not have a background?
    }
    
    func testRawValue() {
        // TODO
        // hint: internally index starts at 0
        
        // hint: this code might be useful
        // let lookA = Look(name: "name", andPath: "test.png")
        // spriteObject.lookList = [lookA!]
        // spriteNode.currentLook = lookA
    }
    
    func testStandardizeValue() {
        // TODO
        // hint: where does standarized index start?
    }
    
    func testTag() {
        // TODO
    }
    
    func testRequiredResources() {
        // TODO
    }
    
    func testShowInFormulaEditor() {
        // TODO
        // hint: use self.spriteObject.background to set object as "background object"
    }
}
