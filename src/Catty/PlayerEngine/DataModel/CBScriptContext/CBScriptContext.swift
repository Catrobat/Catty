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

protocol CBScriptContextProtocol: AnyObject {
    var id: String { get }
    var spriteNode: CBSpriteNode { get }
    var script: Script { get }
    var formulaInterpreter: FormulaInterpreterProtocol { get }
    var state: CBScriptContextState { get set }
    var index: Int { get set }

    func appendInstructions(_ instructionList: [CBInstruction])
    func nextInstruction() -> CBInstruction?
    func jump(numberOfInstructions: Int)
    func reset()
}

protocol CBBroadcastScriptContextProtocol: CBScriptContextProtocol {
    var broadcastMessage: String { get }
    var waitingContext: CBScriptContextProtocol? { get set }
}

// TODO: refactor abstract class, maybe protocol extension??
class CBScriptContext: CBScriptContextProtocol {

    // MARK: - Properties
    final let id: String
    final let spriteNode: CBSpriteNode
    final let script: Script
    final let formulaInterpreter: FormulaInterpreterProtocol
    final var state: CBScriptContextState
    final var count: Int { return _instructionList.count }
    final var index: Int = 0

    private final var _instructionPointer: Int = 0
    private lazy final var _instructionList = [CBInstruction]()

    // MARK: - Initializers
    convenience init?(script: Script, spriteNode: CBSpriteNode, formulaInterpreter: FormulaInterpreterProtocol) {
        self.init(script: script, spriteNode: spriteNode, formulaInterpreter: formulaInterpreter, state: .runnable, instructionList: [])
    }

    init?(script: Script, spriteNode: CBSpriteNode, formulaInterpreter: FormulaInterpreterProtocol, state: CBScriptContextState, instructionList: [CBInstruction]) {
        guard let spriteNodeName = spriteNode.name else { return nil }
        let nodeIndex = spriteNode.spriteObject.scriptList.index(of: script)

        self.spriteNode = spriteNode
        self.script = script
        self.formulaInterpreter = formulaInterpreter
        self.state = state
        self.id = "[\(spriteNodeName)][\(nodeIndex)]"
        print(self.id)
        _instructionPointer = 0
        index = 0
        _instructionList = instructionList
    }

    // MARK: - Operations
    final func appendInstructions(_ instructionList: [CBInstruction]) {
        _instructionList += instructionList
    }

    final func nextInstruction() -> CBInstruction? {
        if state == .dead { return nil } // must be an old deprecated enqueued dispatch closure
        assert(state == .running)
        if _instructionPointer == _instructionList.count || _instructionList.isEmpty {
            return nil
        }
        let instruction = _instructionList[_instructionPointer]
        _instructionPointer += 1
        return instruction
    }

    final func jump(numberOfInstructions: Int) {
        if state == .dead || state == .runnable {
            return // must be an old deprecated enqueued dispatch closure
        }
        if numberOfInstructions == 0 {
            return
        }
        assert(state == .running)
        let newInstructionPointerPosition = _instructionPointer + numberOfInstructions
        if newInstructionPointerPosition < 0 || newInstructionPointerPosition > _instructionList.count {
            return
        }
        _instructionPointer = newInstructionPointerPosition
    }

    final func reset() {
        _instructionPointer = 0
        index += 1 // FIXME: ThreadSanitizer detects Swift access race here
        for brick in script.brickList {
            if let condition = brick as? CBConditionProtocol {
                condition.resetCondition()
            }
        }
    }
}

//--------------------------------------------------------------------------------------------------
final class CBWhenScriptContext: CBScriptContext {

    convenience init?(whenScript: WhenScript, spriteNode: CBSpriteNode, formulaInterpreter: FormulaInterpreterProtocol, state: CBScriptContextState) {
        self.init(whenScript: whenScript, spriteNode: spriteNode, formulaInterpreter: formulaInterpreter, state: state, instructionList: [])
    }

    init?(whenScript: WhenScript, spriteNode: CBSpriteNode, formulaInterpreter: FormulaInterpreterProtocol, state: CBScriptContextState, instructionList: [CBInstruction]
        ) {
        super.init(script: whenScript,
                   spriteNode: spriteNode,
                   formulaInterpreter: formulaInterpreter,
                   state: state,
                   instructionList: instructionList)
    }

}

//--------------------------------------------------------------------------------------------------
final class CBWhenTouchDownScriptContext: CBScriptContext {

    convenience init?(whenTouchDownScript: WhenTouchDownScript, spriteNode: CBSpriteNode, formulaInterpreter: FormulaInterpreterProtocol, state: CBScriptContextState) {
        self.init(whenTouchDownScript: whenTouchDownScript, spriteNode: spriteNode, formulaInterpreter: formulaInterpreter, state: state, instructionList: [])
    }

    init?(whenTouchDownScript: WhenTouchDownScript, spriteNode: CBSpriteNode, formulaInterpreter: FormulaInterpreterProtocol, state: CBScriptContextState, instructionList: [CBInstruction]
        ) {
        super.init(script: whenTouchDownScript,
                   spriteNode: spriteNode,
                   formulaInterpreter: formulaInterpreter,
                   state: state,
                   instructionList: instructionList)
    }

}

//--------------------------------------------------------------------------------------------------
final class CBBroadcastScriptContext: CBScriptContext, CBBroadcastScriptContextProtocol {

    let broadcastMessage: String
    var waitingContext: CBScriptContextProtocol?

    convenience init?(broadcastScript: BroadcastScript, spriteNode: CBSpriteNode, formulaInterpreter: FormulaInterpreterProtocol, state: CBScriptContextState) {
        self.init(broadcastScript: broadcastScript, spriteNode: spriteNode, formulaInterpreter: formulaInterpreter, state: state, instructionList: [])
    }

    init?(broadcastScript: BroadcastScript, spriteNode: CBSpriteNode, formulaInterpreter: FormulaInterpreterProtocol, state: CBScriptContextState, instructionList: [CBInstruction]
        ) {
        broadcastMessage = broadcastScript.receivedMessage
        waitingContext = nil
        super.init(script: broadcastScript,
                   spriteNode: spriteNode,
                   formulaInterpreter: formulaInterpreter,
                   state: state,
                   instructionList: instructionList)
    }

}

//--------------------------------------------------------------------------------------------------
final class CBStartScriptContext: CBScriptContext {

    convenience init?(startScript: StartScript, spriteNode: CBSpriteNode, formulaInterpreter: FormulaInterpreterProtocol, state: CBScriptContextState) {
        self.init(startScript: startScript, spriteNode: spriteNode, formulaInterpreter: formulaInterpreter, state: state, instructionList: [])
    }

    init?(startScript: StartScript, spriteNode: CBSpriteNode, formulaInterpreter: FormulaInterpreterProtocol, state: CBScriptContextState, instructionList: [CBInstruction]
        ) {
        super.init(script: startScript,
                   spriteNode: spriteNode,
                   formulaInterpreter: formulaInterpreter,
                   state: state,
                   instructionList: instructionList)
    }

}
