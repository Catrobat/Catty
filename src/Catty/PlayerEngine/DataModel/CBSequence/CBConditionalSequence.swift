/**
 *  Copyright (C) 2010-2022 The Catrobat Team
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

class CBConditionalSequence: CBSequenceProtocol, CBSequenceVisitProtocol {

    // MARK: - Properties
    final weak var rootSequenceList: CBScriptSequenceList?
    final let sequenceList: CBSequenceList
    final var lastLoopIterationStartTime = Date()
    final let condition: CBConditionProtocol

    // MARK: - Initializers
    init(rootSequenceList: CBScriptSequenceList, condition: CBConditionProtocol, sequenceList: CBSequenceList) {
        self.rootSequenceList = rootSequenceList
        self.sequenceList = sequenceList
        self.condition = condition
    }

    // MARK: - Operations
    func isEmpty() -> Bool {
        sequenceList.isEmpty()
    }

    final func checkCondition(context: CBScriptContextProtocol) -> Bool {
        condition.checkCondition(formulaInterpreter: context.formulaInterpreter)
    }

    final func resetCondition() {
        condition.resetCondition()
    }

    final func bufferCondition(context: CBScriptContextProtocol) {
        for formula in condition.conditionFormulas() {
            _ = context.formulaInterpreter.interpretAndCache(formula, for: context.spriteNode.spriteObject)
        }
    }

    final func hasBluetoothFormula() -> Bool {
        for formula in condition.conditionFormulas() where (formula.getRequiredResources() & ResourceType.bluetoothArduino.rawValue) > 0 {
            return true
        }
        return false
    }

    func accept(_ visitor: CBOptimizeSequenceVisitorProtocol) {
        visitor.visit(self)
    }

}
