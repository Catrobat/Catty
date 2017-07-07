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

final class ChangeVariableBrickTests: XCTestCase {
    
    func testChangeVariableBrickUserVariablesNil() {
        
        let program = Program();
        let object = SpriteObject();
        let spriteNode = CBSpriteNode();
        spriteNode.name = "SpriteNode";
        spriteNode.spriteObject = object;
        object.spriteNode = spriteNode;
        spriteNode.position = CGPoint(x: 0, y: 0);
        object.program = program;
        
        let formula = Formula();
        let formulaTree = FormulaElement();
        formulaTree.type = ElementType.NUMBER;
        formulaTree.value = "0";
        formula.formulaTree = formulaTree;
        
        object.program.programVariableList = NSMutableArray()
        
        let brick = ChangeVariableBrick();
        brick.variableFormula = formula;
        
        let script = Script();
        script.object = object;
        brick.script = script;
        
        let instruction = brick.instruction();
        
        let logger = CBLogger(name: "Logger");
        let broadcastHandler = CBBroadcastHandler(logger: logger);
        let scheduler = CBScheduler(logger: logger, broadcastHandler: broadcastHandler);
        
        switch instruction {
        case let .ExecClosure(closure):
            closure(context: CBScriptContext(script: script, spriteNode: spriteNode), scheduler: scheduler)
        default: break;
        }
        
        XCTAssertTrue(true); // The purpose of this test is to show that the program does not crash
                             // when no UserVariable is selected in the IDE and the brick is executed
    }
}
