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

final class CBSequenceList : CBSequenceProtocol, CBSequenceVisitProtocol, Sequence {

    // MARK: - Properties
    final weak var rootSequenceList: CBScriptSequenceList?
    lazy var sequenceList = [CBSequenceProtocol]()
    var count : Int { return sequenceList.count }

    // MARK: - Initializers
    init(rootSequenceList : CBScriptSequenceList?) {
        self.rootSequenceList = rootSequenceList
    }

    // MARK: - Operations
    func append(_ sequence : CBSequenceProtocol) {
        sequenceList.append(sequence)
    }

    // MARK: - Generator
    func makeIterator() -> AnyIterator<CBSequenceProtocol> {
        var i = 0
        return AnyIterator {
            if i >= self.sequenceList.count {
                return .none
            } else {
                let sequence = self.sequenceList[i]
                i += 1
                return sequence
            }
        }
    }

    func isEmpty() -> Bool {
        return count == 0
    }

    func accept(_ visitor: CBOptimizeSequenceVisitorProtocol) {
        visitor.visit(self)
    }

}

// MARK: - Custom operators
func +=(left: CBSequenceList, right: CBSequenceProtocol) {
    left.append(right)
}
