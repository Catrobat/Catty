/**
 *  Copyright (C) 2010-2015 The Catrobat Team
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

protocol CBScriptContextProtocol: class {
    var id: String { get }
    var spriteNode: CBSpriteNode { get }
    var script: Script { get }
    var state: CBScriptContextState { get set }

    func appendInstructions(instructionList: [CBInstruction])
    func nextInstruction() -> CBInstruction?
    func jump(numberOfInstructions numberOfInstructions: Int)
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
    final var state: CBScriptContextState
    final var count: Int { return _instructionList.count }

    final private var _instructionPointer: Int = 0
    final private lazy var _instructionList = [CBInstruction]()

    // MARK: - Initializers
    convenience init(script: Script, spriteNode: CBSpriteNode) {
        self.init(script: script, spriteNode: spriteNode, state: .Runnable, instructionList: [])
    }

    init(script: Script, spriteNode: CBSpriteNode, state: CBScriptContextState, instructionList: [CBInstruction]) {
        self.spriteNode = spriteNode
        self.script = script
        self.state = state
        assert(spriteNode.name != nil)
        let index = spriteNode.spriteObject?.scriptList.indexOfObject(script)
        assert(index != nil)
        self.id = "[\(spriteNode.name!)][\(index!)]"
        print(self.id)
        _instructionPointer = 0
        _instructionList = instructionList
    }

    // MARK: - Operations
    final func appendInstructions(instructionList: [CBInstruction]) {
        _instructionList += instructionList
    }

    final func nextInstruction() -> CBInstruction? {
        if state == .Dead { return nil } // must be an old deprecated enqueued dispatch closure
        assert(state == .Running)
        if (_instructionPointer == _instructionList.count) || (_instructionList.count == 0) {
            return nil
        }
        return _instructionList[_instructionPointer++]
    }

    final func jump(numberOfInstructions numberOfInstructions: Int) {
        if state == .Dead || state == .Runnable { return } // must be an old deprecated enqueued dispatch closure
        if numberOfInstructions == 0 { return }
        assert(state == .Running)
        let newInstructionPointerPosition = _instructionPointer + numberOfInstructions
        if newInstructionPointerPosition < 0 || newInstructionPointerPosition > _instructionList.count {
            return
        }
        _instructionPointer = newInstructionPointerPosition
    }

    final func reset() {
        _instructionPointer = 0
        for brick in script.brickList {
            if brick is LoopBeginBrick { brick.resetCondition() }
        }
    }
}

//--------------------------------------------------------------------------------------------------
final class CBWhenScriptContext: CBScriptContext {

    convenience init(whenScript: WhenScript, spriteNode: CBSpriteNode, state: CBScriptContextState) {
        self.init(whenScript: whenScript, spriteNode: spriteNode, state: state, instructionList: [])
    }

    init(whenScript: WhenScript, spriteNode: CBSpriteNode, state: CBScriptContextState,
        instructionList: [CBInstruction]
    ) {
        super.init(script: whenScript, spriteNode: spriteNode, state: state,
            instructionList: instructionList)
    }

}

//--------------------------------------------------------------------------------------------------
final class CBBroadcastScriptContext: CBScriptContext, CBBroadcastScriptContextProtocol {

    let broadcastMessage: String
    var waitingContext: CBScriptContextProtocol?

    convenience init(broadcastScript: BroadcastScript, spriteNode: CBSpriteNode, state: CBScriptContextState) {
        self.init(broadcastScript: broadcastScript, spriteNode: spriteNode, state: state, instructionList: [])
    }

    init(broadcastScript: BroadcastScript, spriteNode: CBSpriteNode, state: CBScriptContextState,
        instructionList: [CBInstruction]
    ) {
        broadcastMessage = broadcastScript.receivedMessage
        waitingContext = nil
        super.init(script: broadcastScript, spriteNode: spriteNode, state: state,
            instructionList: instructionList)
    }

}

//--------------------------------------------------------------------------------------------------
final class CBStartScriptContext: CBScriptContext {

    convenience init(startScript: StartScript, spriteNode: CBSpriteNode, state: CBScriptContextState) {
        self.init(startScript: startScript, spriteNode: spriteNode, state: state, instructionList: [])
    }

    init(startScript: StartScript, spriteNode: CBSpriteNode, state: CBScriptContextState,
        instructionList: [CBInstruction]
    ) {
        super.init(script: startScript, spriteNode: spriteNode, state: state,
            instructionList: instructionList)
    }

}
