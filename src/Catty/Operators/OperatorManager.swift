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

@objc class OperatorManager: NSObject, OperatorManagerProtocol {

    public static var defaultValueForUndefinedOperator: Double = 0
    private static var operatorMap = [String: Operator]()

    public required init(operators: [Operator]) {
        super.init()
        registerOperators(operatorList: operators)
    }

    private func registerOperators(operatorList: [Operator]) {
        type(of: self).operatorMap.removeAll()
        operatorList.forEach { type(of: self).operatorMap[type(of: $0).tag] = $0 }
    }

    func operators() -> [Operator] {
        return Array(type(of: self).operatorMap.values)
    }

    func getOperator(tag: String) -> Operator? {
        return type(of: self).operatorMap[tag]
    }

    func value(tag: String, leftParameter: AnyObject?, rightParameter: AnyObject?) -> AnyObject {
        guard let op = getOperator(tag: tag) else { return type(of: self).defaultValueForUndefinedOperator as AnyObject }

        if let op = op as? BinaryOperator, let leftParameter = leftParameter, let rightParameter = rightParameter {
            return op.value(left: leftParameter, right: rightParameter) as AnyObject
        } else if let op = op as? UnaryOperator, let rightParameter = rightParameter {
            return op.value(parameter: rightParameter) as AnyObject
        } else if let op = op as? BinaryLogicalOperator, let leftParameter = leftParameter, let rightParameter = rightParameter {
            return op.value(left: leftParameter, right: rightParameter) as AnyObject
        } else if let op = op as? UnaryLogicalOperator, let rightParameter = rightParameter {
            return op.value(parameter: rightParameter) as AnyObject
        }

        return type(of: self).defaultValueForUndefinedOperator as AnyObject
    }

    func exists(tag: String) -> Bool {
        return getOperator(tag: tag) != nil
    }

    func formulaEditorItems() -> [FormulaEditorItem] {
        var items = [FormulaEditorItem]()

        for op in self.operators() {
            items.append(FormulaEditorItem(op: op))
        }

        return items
    }

    @objc(nameWithTag:)
    static func name(tag: String) -> String? {
        guard let sensor = self.operatorMap[tag] else { return nil }
        return type(of: sensor).name
    }

    @objc static func comparePriority(of leftTag: String, with rightTag: String) -> Int {
        guard let leftOperator = self.operatorMap[leftTag] else { return 0 }
        guard let rightOperator = self.operatorMap[rightTag] else { return 0 }

        if type(of: leftOperator).priority > type(of: rightOperator).priority {
            return 1
        }
        if type(of: leftOperator).priority < type(of: rightOperator).priority {
            return -1
        }
        return 0
    }
}
