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

protocol CBScriptContextProtocol : class, Hashable, Equatable {
    var spriteNode: CBSpriteNode { get }
    var script: Script { get }
    var state: CBScriptState { get set }
    func appendInstructions(instructionList: [CBExecClosure])
    func nextInstruction() -> CBExecClosure?
    func jump(numberOfInstructions numberOfInstructions: Int)
    func reset()
}

// TODO: refactor abstract class, maybe protocol extension??
class CBScriptContext : CBScriptContextProtocol {

    // MARK: - Properties
    final let spriteNode: CBSpriteNode
    final var script: Script
    final var state: CBScriptState
    final var count: Int { return _instructionList.count }

    final private var _instructionPointer: Int = 0
    final private lazy var _instructionList = [CBExecClosure]()
    var hashValue: Int { return spriteNode.name!.hashValue }

    // MARK: - Initializers
    convenience init(script: Script, spriteNode: CBSpriteNode) {
        self.init(script: script, spriteNode: spriteNode, state: .Runnable, instructionList: [])
    }

    init(script: Script, spriteNode: CBSpriteNode, state: CBScriptState,
        instructionList: [CBExecClosure]
    ) {
        self.spriteNode = spriteNode
        self.script = script
        self.state = state
        _instructionPointer = 0
        _instructionList = instructionList
    }

    // MARK: - Operations
    final func appendInstructions(instructionList: [CBExecClosure]) {
        _instructionList += instructionList
    }

    final func nextInstruction() -> CBExecClosure? {
        if state == .Dead { return nil } // must be an old deprecated enqueued dispatch closure
        assert(state == .Running || state == .RunningMature || state == .RunningBlocking)
        if (_instructionPointer == _instructionList.count) || (_instructionList.count == 0) {
            return nil
        }

        // after first instruction executed => set state to RunningMature
        if state == .Running { state = .RunningMature }
        return _instructionList[_instructionPointer++]
    }

    final func jump(numberOfInstructions numberOfInstructions: Int) {
        if state == .Dead { return } // must be an old deprecated enqueued dispatch closure
        if numberOfInstructions == 0 { return }
        assert(state == .Running || state == .RunningMature || state == .RunningBlocking)
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
final class CBWhenScriptContext : CBScriptContext {
    
    convenience init(whenScript: WhenScript, spriteNode: CBSpriteNode, state: CBScriptState) {
        self.init(whenScript: whenScript, spriteNode: spriteNode, state: state, instructionList: [])
    }
    
    init(whenScript: WhenScript, spriteNode: CBSpriteNode, state: CBScriptState, instructionList: [CBExecClosure]) {
        super.init(script: whenScript, spriteNode: spriteNode, state: state, instructionList: instructionList)
    }

}

//--------------------------------------------------------------------------------------------------
final class CBBroadcastScriptContext : CBScriptContext {

    final var broadcastMessage: String

    convenience init(broadcastScript: BroadcastScript, spriteNode: CBSpriteNode, state: CBScriptState) {
        self.init(broadcastScript: broadcastScript, spriteNode: spriteNode, state: state, instructionList: [])
    }

    init(broadcastScript: BroadcastScript, spriteNode: CBSpriteNode, state: CBScriptState, instructionList: [CBExecClosure]) {
        broadcastMessage = broadcastScript.receivedMessage
        super.init(script: broadcastScript, spriteNode: spriteNode, state: state, instructionList: instructionList)
    }

}

//--------------------------------------------------------------------------------------------------
final class CBStartScriptContext : CBScriptContext {

    convenience init(startScript: StartScript, spriteNode: CBSpriteNode, state: CBScriptState) {
        self.init(startScript: startScript, spriteNode: spriteNode, state: state, instructionList: [])
    }
    
    init(startScript: StartScript, spriteNode: CBSpriteNode, state: CBScriptState, instructionList: [CBExecClosure]) {
        super.init(script: startScript, spriteNode: spriteNode, state: state, instructionList: instructionList)
    }

}

// MARK: - Custom operators
func ==(lhs: CBScriptContext, rhs: CBScriptContext) -> Bool {
    return lhs.spriteNode === rhs.spriteNode && lhs.script === rhs.script
}

func +=(inout left: CBScriptContext, right: CBExecClosure) {
    left.appendInstructions([right])
}

func +=(inout left: CBScriptContext, right: [CBExecClosure]) {
    left.appendInstructions(right)
}
