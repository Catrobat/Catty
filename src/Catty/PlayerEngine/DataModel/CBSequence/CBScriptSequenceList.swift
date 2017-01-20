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

final class CBScriptSequenceList : CBSequenceVisitProtocol {

    // MARK: - Properties
    final let script: Script
    final let sequenceList: CBSequenceList
    final var count: Int { return sequenceList.count }

    // MARK: - Initializers
    init(script : Script, sequenceList : CBSequenceList) {
        self.script = script
        self.sequenceList = sequenceList
        sequenceList.rootSequenceList = self
    }

    deinit {
        sequenceList.rootSequenceList = nil
    }

    // MARK: - Operations
    func accept(visitor: CBOptimizeSequenceVisitorProtocol) {
        visitor.visit(self)
    }

}
