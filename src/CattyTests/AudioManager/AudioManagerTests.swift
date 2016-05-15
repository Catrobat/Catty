/**
 *  Copyright (C) 2010-2016 The Catrobat Team
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

class AudioManagerTests: XCTestCase {
    
    var audioManager = AudioManager.sharedAudioManager()
    
    override func setUp( ) {
        super.setUp()
        audioManager = AudioManager.sharedAudioManager()
    }
    
    override func tearDown() {
        super.tearDown()
        audioManager.stopAllSounds()
    }
    
    func testPlaySound() {
        let testBundle = NSBundle(forClass: self.dynamicType)
        let fileURL = testBundle.URLForResource("silence", withExtension: "mp3")
        XCTAssertNotNil(fileURL)
        
        let result = audioManager.playSoundWithFileName(fileURL!.lastPathComponent, andKey: "key", atFilePath: fileURL!.URLByDeletingLastPathComponent!.path)
        XCTAssertTrue(result)
    }
    
    func testPlaySoundAndFail() {
        let result = audioManager.playSoundWithFileName("invalidFile", andKey: "key", atFilePath: "invalidPath")
        XCTAssertFalse(result)
    }
}
