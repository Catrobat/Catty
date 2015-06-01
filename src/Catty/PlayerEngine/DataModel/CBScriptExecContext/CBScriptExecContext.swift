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

final class CBScriptExecContext : SKNode {

    // MARK: - Properties
    let script : Script
    let scriptType : CBScriptType
    private var _stateStorage : CBScriptState
    var state : CBScriptState {
        get { return _stateStorage }
        // if script is RunningBlocking (BroadcastScript called by BroadcastWait) then do not change state!
        set { if _stateStorage != .RunningBlocking || newValue != .RunningMature { _stateStorage = newValue } }
    }
    private(set) var reverseInstructionPointer = 0
    var count : Int { return _instructionList.count }

    private lazy var _instructionList = [CBExecClosure]()
    private var _scriptSequenceList: CBScriptSequenceList?

    // MARK: - Initializers
    convenience init(script: Script, scriptSequenceList: CBScriptSequenceList) {
        self.init(script: script, state: .Runnable, scriptSequenceList: scriptSequenceList, instructionList: [])
    }

    init(script: Script, state: CBScriptState, scriptSequenceList: CBScriptSequenceList, instructionList: [CBExecClosure]) {
        self.script = script
        self.scriptType = CBScriptType.scriptTypeOfScript(script)
        _stateStorage = state
        self._scriptSequenceList = scriptSequenceList
        super.init()
        for instruction in instructionList {
            self.appendInstruction(instruction)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("This initializer must NOT be called")
    }

    // MARK: - Operations
    func appendInstruction(instruction: CBExecClosure) {
        _instructionList.append(instruction)
        ++reverseInstructionPointer
    }

    func addInstructionAtCurrentPosition(instruction: CBExecClosure) {
        assert((state == .Running) || (state == .RunningMature) || (state == .RunningBlocking))
        _instructionList.insert(instruction, atIndex: reverseInstructionPointer)
        ++reverseInstructionPointer
    }

    func removeNumberOfInstructions(numberOfInstructions: Int, instructionStartIndex startIndex: Int) {
        assert((state == .Running) || (state == .RunningMature) || (state == .RunningBlocking))
        let range = Range<Int>(startIndex ..< (startIndex + numberOfInstructions))
        _instructionList.removeRange(range)
        reverseInstructionPointer = startIndex
    }

    func nextInstruction() -> CBExecClosure? {
        assert((state == .Running) || (state == .RunningMature) || (state == .RunningBlocking))
        if (reverseInstructionPointer == 0) || (_instructionList.count == 0) {
            return nil
        }
        // after first instruction executed => set state to RunningMature
        if state == .Running {
            state = .RunningMature
        }
        return _instructionList[--reverseInstructionPointer]
    }

    func reset() {
        reverseInstructionPointer = _instructionList.count
    }

    func removeReferences() {
        self._instructionList.removeAll(keepCapacity: false)
        self._scriptSequenceList?.sequenceList.rootSequenceList = nil
        if self._scriptSequenceList != nil {
            for sequence in self._scriptSequenceList!.sequenceList {
                sequence.rootSequenceList = nil
            }
        }
        self._scriptSequenceList = nil
    }
}

// MARK: - Custom operators
func +=(inout left: CBScriptExecContext, right: CBExecClosure) {
    left.appendInstruction(right)
}

func +=<T>(inout left: [T], right: T) {
    left.append(right)
}
