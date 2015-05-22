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

@objc class CBScriptSequenceList {

    let script : Script

    let sequenceList : CBSequenceList

    init(script : Script, sequenceList : CBSequenceList) {
        self.script = script
        self.sequenceList = sequenceList
    }

    var count : Int { return sequenceList.count }

    func reverseSequenceList() -> CBScriptSequenceList {
        return CBScriptSequenceList(script: script, sequenceList: sequenceList.reverseSequenceList())
    }

}

@objc class CBSequenceList {

    /*private */lazy var sequenceList = [CBSequence]()

    var count : Int { return sequenceList.count }

    func append(let sequence : CBSequence) {
        sequenceList.append(sequence)
    }

    func generate() -> GeneratorOf<CBSequence> {
        var i = 0
        return GeneratorOf<CBSequence> {
            return i >= self.sequenceList.count ? .None : self.sequenceList[i++]
        }
    }

    // FIXME: implement reverse generator!
    func reverseSequenceList() -> CBSequenceList {
        var reverseScriptSequenceList = CBSequenceList()
        for sequence in sequenceList.reverse() {
            reverseScriptSequenceList.append(sequence)
        }
        return reverseScriptSequenceList
    }

    //    func +=(left: , right: CBSequence) {
    //    var sum = [Int]() // 2
    //    assert(left.count == right.count, "vector of same length only")  // 3
    //    for (key, v) in enumerate(left) {
    //    sum.append(left[key] + right[key]) // 4
    //    }
    //    return sum
    //    }

}

class CBPlayerFrontend : NSObject {

    static let sharedInstance = CBPlayerFrontend() // singleton

    override private init() {} // private constructor

    func computeSequenceListForScript(script : Script) -> CBScriptSequenceList {
        var scriptSequenceList = CBSequenceList()
        var currentOperationSequence = CBOperationSequence()

        var sequenceStack = CBStack<CBSequenceList>()
        var currentSequenceList = scriptSequenceList
        var brickList = script.brickList as NSArray as! [Brick]

        for brick in brickList {
            if let _ = brick as? IfLogicBeginBrick {
                if currentOperationSequence.isEmpty() == false {
                    currentSequenceList.append(currentOperationSequence)
                }
                // preserve currentSequenceList and push it to stack
                sequenceStack.push(currentSequenceList)
                currentSequenceList = CBSequenceList() // new sequence list for If
                currentOperationSequence = CBOperationSequence()

            } else if let _ = brick as? IfLogicElseBrick {
                if currentOperationSequence.isEmpty() == false {
                    currentSequenceList.append(currentOperationSequence)
                }
                // preserve currentSequenceList and push it to stack
                sequenceStack.push(currentSequenceList)
                currentSequenceList = CBSequenceList() // new sequence list for Else
                currentOperationSequence = CBOperationSequence()

            } else if let ifLogicEndBrick = brick as? IfLogicEndBrick {
                if currentOperationSequence.isEmpty() == false {
                    currentSequenceList.append(currentOperationSequence)
                }

                let ifBrick = ifLogicEndBrick.ifBeginBrick
                let elseBrick = ifLogicEndBrick.ifElseBrick
                let ifSequence = CBIfConditionalSequence.createConditionalSequenceWithConditionBrick(ifBrick)

                if elseBrick != nil {
                    // currentSequenceList is ElseSequenceList
                    ifSequence.elseSequenceList = currentSequenceList
                    let topMostSequenceList = sequenceStack.pop() // pop IfSequenceList from stack
                    assert(topMostSequenceList == nil, "topMostSequenceList must NOT be nil!")
                    currentSequenceList = topMostSequenceList!
                }

                // now currentSequenceList is IfSequenceList
                ifSequence.sequenceList = currentSequenceList

                let topMostSequenceList = sequenceStack.pop() // pop currentSequenceList from stack
                assert(topMostSequenceList == nil, "topMostSequenceList must NOT be nil!")
                currentSequenceList = topMostSequenceList!
                currentSequenceList.append(ifSequence)
                currentOperationSequence = CBOperationSequence()

            } else if let _ = brick as? LoopBeginBrick {
                if currentOperationSequence.isEmpty() == false {
                    currentSequenceList.append(currentOperationSequence)
                }
                // preserve currentSequenceList and push it to stack
                sequenceStack.push(currentSequenceList)
                currentSequenceList = CBSequenceList() // new sequence list for Loop
                currentOperationSequence = CBOperationSequence()

            } else if let loopEndBrick = brick as? LoopEndBrick {
                if currentOperationSequence.isEmpty() == false {
                    currentSequenceList.append(currentOperationSequence)
                }
                // loop end -> fetch currentSequenceList from stack
                let conditionalSequence = CBConditionalSequence.createConditionalSequenceWithConditionBrick(loopEndBrick.loopBeginBrick!)
                conditionalSequence.sequenceList = currentSequenceList

                let topMostSequenceList = sequenceStack.pop() // pop currentSequenceList from stack
                assert(topMostSequenceList == nil, "topMostSequenceList must NOT be nil!")
                currentSequenceList = topMostSequenceList!
                currentSequenceList.append(conditionalSequence)
                currentOperationSequence = CBOperationSequence()

            } else if let _ = brick as? NoteBrick {
                // ignore NoteBricks!
            } else {
                currentOperationSequence.addOperation(CBOperation.createOperationWithBrick(brick))
            }

        }
        // sanity check just to ensure!
        assert(scriptSequenceList === currentSequenceList, "scriptSequenceList !== currentSequenceList")

        if currentOperationSequence.isEmpty() == false {
            currentSequenceList.append(currentOperationSequence)
        }
        return CBScriptSequenceList(script: script, sequenceList: currentSequenceList)
    }
}
