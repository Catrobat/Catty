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

final class ChooseCameraBrickTests: XCTestCase {
    
    func testDefaultCameraPosition() {
        // front camera should be default
        CameraPreviewHandler.resetSharedInstance()
        XCTAssertEqual(AVCaptureDevice.Position.front, CameraPreviewHandler.shared().cameraPosition)
    }
    
    func testChooseCameraBrick() {
        
        let program = Program();
        let object = SpriteObject();
        let spriteNode = CBSpriteNode();
        spriteNode.name = "SpriteNode";
        spriteNode.spriteObject = object;
        object.spriteNode = spriteNode;
        object.program = program;
        
        let brick = ChooseCameraBrick();
        
        let script = Script();
        script.object = object;
        brick.script = script;
        
        let instruction = brick.instruction();
        
        let logger = CBLogger(name: "Logger");
        let broadcastHandler = CBBroadcastHandler(logger: logger);
        let scheduler = CBScheduler(logger: logger, broadcastHandler: broadcastHandler);
        
        switch instruction {
        case let .execClosure(closure):
            closure(CBScriptContext(script: script, spriteNode: spriteNode)!, scheduler)
        default: break;
        }
        
        XCTAssertEqual(AVCaptureDevice.Position.back, CameraPreviewHandler.shared().cameraPosition)
    }
    
    func testChooseCameraBrickInitWithZero() {
        
        let program = Program();
        let object = SpriteObject();
        let spriteNode = CBSpriteNode();
        spriteNode.name = "SpriteNode";
        spriteNode.spriteObject = object;
        object.spriteNode = spriteNode;
        object.program = program;
        
        let brick = ChooseCameraBrick(choice: 0);
        
        let script = Script();
        script.object = object;
        brick?.script = script;
        
        let instruction = brick?.instruction();
        
        let logger = CBLogger(name: "Logger");
        let broadcastHandler = CBBroadcastHandler(logger: logger);
        let scheduler = CBScheduler(logger: logger, broadcastHandler: broadcastHandler);
        
        switch instruction! {
        case let .execClosure(closure):
            closure(CBScriptContext(script: script, spriteNode: spriteNode)!, scheduler)
        default: break;
        }
        
        XCTAssertEqual(AVCaptureDevice.Position.back, CameraPreviewHandler.shared().cameraPosition)
    }
    
    func testChooseCameraBrickInitWithOne() {
        
        let program = Program();
        let object = SpriteObject();
        let spriteNode = CBSpriteNode();
        spriteNode.name = "SpriteNode";
        spriteNode.spriteObject = object;
        object.spriteNode = spriteNode;
        object.program = program;
        
        let brick = ChooseCameraBrick(choice: 1);
        
        let script = Script();
        script.object = object;
        brick?.script = script;
        
        let instruction = brick?.instruction();
        
        let logger = CBLogger(name: "Logger");
        let broadcastHandler = CBBroadcastHandler(logger: logger);
        let scheduler = CBScheduler(logger: logger, broadcastHandler: broadcastHandler);
        
        switch instruction! {
        case let .execClosure(closure):
            closure(CBScriptContext(script: script, spriteNode: spriteNode)!, scheduler)
        default: break;
        }
        
        XCTAssertEqual(AVCaptureDevice.Position.front, CameraPreviewHandler.shared().cameraPosition)
    }
}
