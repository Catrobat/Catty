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

final class CBIfConditionalSequence : CBConditionalSequence, CBSequenceVisitProtocol {

    // MARK: - Properties
    let elseSequenceList : CBSequenceList?

    // MARK: - Initializers
    override init(rootSequenceList: CBScriptSequenceList, conditionBrick : BrickConditionalBranchProtocol, sequenceList : CBSequenceList) {
        self.elseSequenceList = nil
        super.init(rootSequenceList: rootSequenceList, conditionBrick: conditionBrick, sequenceList: sequenceList)
    }

    init(rootSequenceList: CBScriptSequenceList, conditionBrick : BrickConditionalBranchProtocol, ifSequenceList : CBSequenceList,
        elseSequenceList : CBSequenceList) {
        self.elseSequenceList = elseSequenceList
        super.init(rootSequenceList: rootSequenceList, conditionBrick: conditionBrick, sequenceList: ifSequenceList)
    }

    // MARK: - Operations
    override func isEmpty() -> Bool {
        return (super.isEmpty() && (elseSequenceList?.count == 0))
    }

    override func accept(visitor: CBOptimizeSequenceVisitorProtocol) {
        visitor.visit(self)
    }

}
