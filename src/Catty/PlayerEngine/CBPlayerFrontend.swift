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

@objc final class CBScriptSequenceList {

    final let script : Script
    final let sequenceList : CBSequenceList
    final var abortScriptExecutionCompletionClosure : dispatch_block_t?
    final var scriptExecutionClosure : dispatch_block_t?
    final lazy var whileSequences = [String:dispatch_block_t]()
    final var running : Bool
    final var count : Int { return sequenceList.count }

    init(script : Script, sequenceList : CBSequenceList) {
        self.script = script
        self.abortScriptExecutionCompletionClosure = nil
        self.running = false
        self.sequenceList = sequenceList
        sequenceList.rootSequenceList = self
    }

    final func reverseSequenceList() -> CBScriptSequenceList {
        return CBScriptSequenceList(script: script, sequenceList: sequenceList.reverseSequenceList())
    }

    final func reset() {
//        NSDebug(@"Reset");
        for brick in self.script.brickList {
            if let loopBeginBrick = brick as? LoopBeginBrick {
                loopBeginBrick.resetCondition()
            }
        }
    }

    final func runFullScriptSequence() {
        self.running = true
        assert(CBPlayerBackend.sharedInstance.running); // ensure that player is running!
//        NSLog(@"Starting: %@ of object %@", [self class], [self.object class]);
        
        if self.script.inParentHierarchy(self.script.object) == false {
//            NSLog(@" + Adding this node to object");
            self.script.object.addChild(self.script)
        }
        self.reset()
        if self.script.hasActions() {
            self.script.removeAllActions()
        }
        scriptExecutionClosure?()
    }
}

@objc final class CBSequenceList : SequenceType {

    final var rootSequenceList : CBScriptSequenceList?
    final /*private */lazy var sequenceList = [CBSequence]()
    final var count : Int { return sequenceList.count }

    init(rootSequenceList : CBScriptSequenceList?) {
        self.rootSequenceList = rootSequenceList
    }

    final func append(let sequence : CBSequence) {
        sequenceList.append(sequence)
    }

    final func generate() -> GeneratorOf<CBSequence> {
        var i = 0
        return GeneratorOf<CBSequence> {
            return i >= self.sequenceList.count ? .None : self.sequenceList[i++]
        }
    }

    // FIXME: implement reverse generator!
    final func reverseSequenceList() -> CBSequenceList {
        var reverseScriptSequenceList = CBSequenceList(rootSequenceList: rootSequenceList)
        for sequence in sequenceList.reverse() {
            reverseScriptSequenceList += sequence
        }
        return reverseScriptSequenceList
    }

}

// operator overloading for append method in CBSequenceList
func +=(left: CBSequenceList, right: CBSequence) {
    left.append(right)
}

final class CBPlayerFrontend : NSObject {

    static let sharedInstance = CBPlayerFrontend() // singleton

    override private init() {} // private constructor

    final func computeSequenceListForScript(script : Script) -> CBScriptSequenceList {
        var currentSequenceList = CBSequenceList(rootSequenceList: nil)
        let scriptSequenceList = CBScriptSequenceList(script: script, sequenceList: currentSequenceList)
        var currentOperationSequence = CBOperationSequence(rootSequenceList: scriptSequenceList)
        var sequenceStack = CBStack<CBSequenceList>()

        for brick in (script.brickList as NSArray as! [Brick]) {
            if let _ = brick as? IfLogicBeginBrick {
                if currentOperationSequence.isEmpty() == false {
                    currentSequenceList += currentOperationSequence
                }
                // preserve currentSequenceList and push it to stack
                sequenceStack.push(currentSequenceList)
                currentSequenceList = CBSequenceList(rootSequenceList: scriptSequenceList) // new sequence list for If
                currentOperationSequence = CBOperationSequence(rootSequenceList: scriptSequenceList)

            } else if let _ = brick as? IfLogicElseBrick {
                if currentOperationSequence.isEmpty() == false {
                    currentSequenceList += currentOperationSequence
                }
                // preserve currentSequenceList and push it to stack
                sequenceStack.push(currentSequenceList)
                currentSequenceList = CBSequenceList(rootSequenceList: scriptSequenceList) // new sequence list for Else
                currentOperationSequence = CBOperationSequence(rootSequenceList: scriptSequenceList)

            } else if let ifLogicEndBrick = brick as? IfLogicEndBrick {
                if currentOperationSequence.isEmpty() == false {
                    currentSequenceList += currentOperationSequence
                }

                let ifBrick = ifLogicEndBrick.ifBeginBrick
                let elseBrick = ifLogicEndBrick.ifElseBrick
                var ifSequence = CBIfConditionalSequence(rootSequenceList: scriptSequenceList, conditionBrick: ifBrick, sequenceList: currentSequenceList)

                if elseBrick != nil {
                    // currentSequenceList is ElseSequenceList
                    let elseSequenceList = currentSequenceList
                    let topMostSequenceList = sequenceStack.pop() // pop IfSequenceList from stack
                    assert(topMostSequenceList != nil, "topMostSequenceList must NOT be nil!")
                    currentSequenceList = topMostSequenceList!
                    ifSequence = CBIfConditionalSequence(rootSequenceList: scriptSequenceList, conditionBrick: ifBrick,
                        ifSequenceList:currentSequenceList, elseSequenceList: elseSequenceList)
                }
                let topMostSequenceList = sequenceStack.pop() // pop currentSequenceList from stack
                assert(topMostSequenceList != nil, "topMostSequenceList must NOT be nil!")
                currentSequenceList = topMostSequenceList!
                currentSequenceList += ifSequence
                currentOperationSequence = CBOperationSequence(rootSequenceList: scriptSequenceList)

            } else if let _ = brick as? LoopBeginBrick {
                if currentOperationSequence.isEmpty() == false {
                    currentSequenceList += currentOperationSequence
                }
                // preserve currentSequenceList and push it to stack
                sequenceStack.push(currentSequenceList)
                currentSequenceList = CBSequenceList(rootSequenceList: scriptSequenceList) // new sequence list for Loop
                currentOperationSequence = CBOperationSequence(rootSequenceList: scriptSequenceList)

            } else if let loopEndBrick = brick as? LoopEndBrick {
                if currentOperationSequence.isEmpty() == false {
                    currentSequenceList += currentOperationSequence
                }
                // loop end -> fetch currentSequenceList from stack
                let conditionalSequence = CBConditionalSequence(rootSequenceList: scriptSequenceList, conditionBrick: loopEndBrick.loopBeginBrick!, sequenceList: currentSequenceList)
                let topMostSequenceList = sequenceStack.pop() // pop currentSequenceList from stack
                assert(topMostSequenceList != nil, "topMostSequenceList must NOT be nil!")
                currentSequenceList = topMostSequenceList!
                currentSequenceList += conditionalSequence
                currentOperationSequence = CBOperationSequence(rootSequenceList: scriptSequenceList)

            } else if let _ = brick as? NoteBrick {
                // ignore NoteBricks!
            } else {
                currentOperationSequence.addOperation(CBOperation(brick: brick))
            }
        }

        assert(scriptSequenceList.sequenceList === currentSequenceList, "scriptSequenceList.sequenceList !== currentSequenceList")
        if currentOperationSequence.isEmpty() == false {
            currentSequenceList += currentOperationSequence
        }
        return scriptSequenceList
    }

    // TODO: sequence optimization code goes here...

}
