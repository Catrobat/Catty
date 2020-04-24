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

final class CBIfConditionalSequence: CBConditionalSequence {

    // MARK: - Properties

    let elseSequenceList: CBSequenceList?

    // MARK: - Initializers

    override init(rootSequenceList: CBScriptSequenceList, condition: CBConditionProtocol, sequenceList: CBSequenceList) {
        self.elseSequenceList = nil
        super.init(rootSequenceList: rootSequenceList, condition: condition, sequenceList: sequenceList)
    }

    init(rootSequenceList: CBScriptSequenceList, condition: CBConditionProtocol, ifSequenceList: CBSequenceList, elseSequenceList: CBSequenceList) {
        self.elseSequenceList = elseSequenceList
        super.init(rootSequenceList: rootSequenceList, condition: condition, sequenceList: ifSequenceList)
    }

    // MARK: - Operations

    override func isEmpty() -> Bool {
        super.isEmpty() && (elseSequenceList == nil || elseSequenceList!.isEmpty())
    }

    override func accept(_ visitor: CBOptimizeSequenceVisitorProtocol) {
        visitor.visit(self)
    }
}
