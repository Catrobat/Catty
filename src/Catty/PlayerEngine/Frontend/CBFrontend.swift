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

final class CBFrontend: CBFrontendProtocol {

    // MARK: - Properties
    let logger: CBLogger
    private(set) weak var program: Program?
    private lazy var _sequenceFilters = [CBFrontendSequenceFilterProtocol]()

    // MARK: - Initializers
    init(logger: CBLogger, program: Program?) {
        self.logger = logger
        self.program = program
    }

    // MARK: - Operations
    func addSequenceFilter(sequenceFilter: CBFrontendSequenceFilterProtocol) {
        _sequenceFilters += sequenceFilter
    }

    func computeSequenceListForScript(script : Script) -> CBScriptSequenceList {
        var currentSequenceList = CBSequenceList(rootSequenceList: nil)
        let scriptSequenceList = CBScriptSequenceList(script: script, sequenceList: currentSequenceList)
        var currentOperationSequence = CBOperationSequence(rootSequenceList: scriptSequenceList)
        let sequenceStack = CBStack<CBSequenceList>()

        for brick in (script.brickList as NSArray as! [Brick]) {

            switch brick {
            case _ as IfLogicBeginBrick,
                 _ as IfThenLogicBeginBrick,
                 _ as IfLogicElseBrick,
                 _ as IfLogicEndBrick,
                 _ as LoopBeginBrick,
                 _ as LoopEndBrick:

                if !currentOperationSequence.isEmpty() {
                    currentSequenceList += currentOperationSequence
                }

            default: break
            }

            switch brick {

            case is IfLogicBeginBrick:
                // preserve currentSequenceList and push it to stack
                sequenceStack.push(currentSequenceList)
                // new sequence list for If
                currentSequenceList = CBSequenceList(rootSequenceList: scriptSequenceList)
                currentOperationSequence = CBOperationSequence(rootSequenceList: scriptSequenceList)
                
            case is IfLogicElseBrick:
                // preserve currentSequenceList and push it to stack
                sequenceStack.push(currentSequenceList)
                // new sequence list for else
                currentSequenceList = CBSequenceList(rootSequenceList: scriptSequenceList)
                currentOperationSequence = CBOperationSequence(rootSequenceList: scriptSequenceList)

            case let ifLogicEndBrick as IfLogicEndBrick:
                let ifBrick = ifLogicEndBrick.ifBeginBrick
                let elseBrick = ifLogicEndBrick.ifElseBrick
                var ifSequence = CBIfConditionalSequence(rootSequenceList: scriptSequenceList,
                    conditionBrick: ifBrick!, sequenceList: currentSequenceList)

                if elseBrick != nil {
                    // currentSequenceList is ElseSequenceList
                    let elseSequenceList = currentSequenceList
                    let topMostSequenceList = sequenceStack.pop() // pop IfSequenceList from stack
                    assert(topMostSequenceList != nil, "topMostSequenceList must NOT be nil!")
                    currentSequenceList = topMostSequenceList!
                    ifSequence = CBIfConditionalSequence(rootSequenceList: scriptSequenceList,
                        conditionBrick: ifBrick!, ifSequenceList:currentSequenceList,
                        elseSequenceList: elseSequenceList)
                }
                let topMostSequenceList = sequenceStack.pop() // pop currentSequenceList from stack
                assert(topMostSequenceList != nil, "topMostSequenceList must NOT be nil!")
                currentSequenceList = topMostSequenceList!
                currentSequenceList += ifSequence
                currentOperationSequence = CBOperationSequence(rootSequenceList: scriptSequenceList)

            case is LoopBeginBrick:
                // preserve currentSequenceList and push it to stack
                sequenceStack.push(currentSequenceList)
                // new sequence list for Loop
                currentSequenceList = CBSequenceList(rootSequenceList: scriptSequenceList)
                currentOperationSequence = CBOperationSequence(rootSequenceList: scriptSequenceList)

            case let loopEndBrick as LoopEndBrick:
                // loop end -> fetch currentSequenceList from stack
                let conditionalSequence = CBConditionalSequence(rootSequenceList: scriptSequenceList,
                    conditionBrick: loopEndBrick.loopBeginBrick!, sequenceList: currentSequenceList)
                let topMostSequenceList = sequenceStack.pop() // pop currentSequenceList from stack
                assert(topMostSequenceList != nil, "topMostSequenceList must NOT be nil!")
                currentSequenceList = topMostSequenceList!
                currentSequenceList += conditionalSequence
                currentOperationSequence = CBOperationSequence(rootSequenceList: scriptSequenceList)

            case is NoteBrick:
                break // ignore NoteBricks!

            default:
                currentOperationSequence.addOperation(CBOperation(brick: brick))
            }
        }
        assert(scriptSequenceList.sequenceList === currentSequenceList)

        // add last operation sequence to script's sequence list
        if !currentOperationSequence.isEmpty() {
            scriptSequenceList.sequenceList += currentOperationSequence
        }

        // finally apply all filters on script's sequence list
        var filteredList = scriptSequenceList
        _sequenceFilters.forEach { filteredList = $0.filterScriptSequenceList(filteredList) }
        return filteredList
    }
}
