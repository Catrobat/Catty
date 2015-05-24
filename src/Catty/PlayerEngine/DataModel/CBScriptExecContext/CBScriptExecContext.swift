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

typealias CBExecClosure = dispatch_block_t

@objc class CBScriptExecContext {

    final let script : Script
    final private lazy var _instructionList = [CBExecClosure]()
    final private var _scriptSequenceList : CBScriptSequenceList?
    final private(set) var reverseInstructionPointer = 0
    final var count : Int { return _instructionList.count }

    // MARK: Initializers
    init(script: Script, scriptSequenceList: CBScriptSequenceList, instructionList: [CBExecClosure]) {
        self.script = script
        self._scriptSequenceList = scriptSequenceList
        for instruction in instructionList {
            appendInstruction(instruction)
        }
    }

    // MARK: Operations
    final func appendInstruction(instruction: CBExecClosure) {
        _instructionList.append(instruction)
        ++reverseInstructionPointer
    }

    final func addInstructionAtCurrentPosition(instruction: CBExecClosure) {
        _instructionList.insert(instruction, atIndex: reverseInstructionPointer)
        ++reverseInstructionPointer
    }

    final func nextInstruction() -> CBExecClosure? {
        if (reverseInstructionPointer == 0) || (_instructionList.count == 0) {
            return nil
        }
        return _instructionList[--reverseInstructionPointer]
    }

    final func reset() {
        reverseInstructionPointer = _instructionList.count
    }

    final func removeReferences() {
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

// operator overloading for appendInstruction method in CBExecContext
func +=(inout left: CBScriptExecContext, right: CBExecClosure) {
    left.appendInstruction(right)
}

func +=<T>(inout left: [T], right: T) {
    left.append(right)
}
