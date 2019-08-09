/**
 *  Copyright (C) 2010-2019 The Catrobat Team
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

extension FormulaManager {

    @objc(interpretDouble: forSpriteObject:)
    func interpretDouble(_ formula: Formula, for spriteObject: SpriteObject) -> Double {
        let value = interpretRecursive(formulaElement: formula.formulaTree, for: spriteObject)
        if let doubleValue = value as? Double {
            return Double(doubleValue)
        }
        if let stringValue = value as? String, let doubleValue = Double(stringValue) {
            return doubleValue
        }
        return Double(0)
    }

    @objc(interpretFloat: forSpriteObject:)
    func interpretFloat(_ formula: Formula, for spriteObject: SpriteObject) -> Float {
        return Float(interpretDouble(formula, for: spriteObject))
    }

    @objc(interpretInteger: forSpriteObject:)
    func interpretInteger(_ formula: Formula, for spriteObject: SpriteObject) -> Int {
        let doubleValue = interpretDouble(formula, for: spriteObject)

        if doubleValue > Double(Int.max) {
            return Int.max
        }
        if doubleValue.isNaN {
            return 0
        }

        return Int(doubleValue)
    }

    @objc(interpretBool: forSpriteObject:)
    func interpretBool(_ formula: Formula, for spriteObject: SpriteObject) -> Bool {
        let value = interpretInteger(formula, for: spriteObject)
        return Bool(value != 0)
    }

    @objc(interpretString: forSpriteObject:)
    func interpretString(_ formula: Formula, for spriteObject: SpriteObject) -> String {
        let value = interpretRecursive(formulaElement: formula.formulaTree, for: spriteObject)
        if let doubleValue = value as? Double {
            return String(format: "%lf", doubleValue)
        } else if let intValue = value as? Int {
            return String(format: "%ld", intValue)
        } else if let stringValue = value as? String {
            return stringValue
        }
        return String("")
    }

    @objc(interpret: forSpriteObject:)
    func interpret(_ formula: Formula, for spriteObject: SpriteObject) -> AnyObject {
        return interpretRecursive(formulaElement: formula.formulaTree, for: spriteObject)
    }

    func interpretAndCache(_ formula: Formula, for spriteObject: SpriteObject) -> AnyObject {
        invalidateCache(formula)

        let result = interpretRecursive(formulaElement: formula.formulaTree, for: spriteObject)
        cacheResult(formula.formulaTree, result: result)

        return result
    }

    func isIdempotent(_ formula: Formula) -> Bool {
        guard let formulaElement = formula.formulaTree else { return false }
        return isIdempotent(formulaElement)
    }

    func invalidateCache() {
        cachedResults.removeAll()
    }

    func invalidateCache(_ formula: Formula) {
        if let formulaTree = formula.formulaTree {
            invalidateCache(formulaTree)
        }
    }

    private func invalidateCache(_ formulaElement: FormulaElement) {
        cachedResults.removeValue(forKey: formulaElement)

        if let leftChild = formulaElement.leftChild {
            invalidateCache(leftChild)
        }
        if let rightChild = formulaElement.rightChild {
            invalidateCache(rightChild)
        }
    }

    private func isIdempotent(_ formulaElement: FormulaElement) -> Bool {
        if formulaElement.idempotenceState != .NOT_CHECKED { // cached result!
            return (formulaElement.idempotenceState == .IDEMPOTENT)
        }

        let isLeftChildIdempotent = formulaElement.leftChild != nil ? self.isIdempotent(formulaElement.leftChild) : true
        let isRightChildIdempotent = formulaElement.rightChild != nil ? self.isIdempotent(formulaElement.rightChild) : true

        if isLeftChildIdempotent == false {
            formulaElement.idempotenceState = .NOT_IDEMPOTENT
            return false
        }
        if isRightChildIdempotent == false {
            formulaElement.idempotenceState = .NOT_IDEMPOTENT
            return false
        }
        if formulaElement.type == .FUNCTION {
            let result = functionManager.isIdempotent(tag: formulaElement.value)
            formulaElement.idempotenceState = result ? .IDEMPOTENT : .NOT_IDEMPOTENT
            return result
        }
        if (formulaElement.type == .OPERATOR) || (formulaElement.type == .NUMBER) || (formulaElement.type == .BRACKET) {
            formulaElement.idempotenceState = .IDEMPOTENT
            return true
        }
        if (formulaElement.type == .USER_LIST) || (formulaElement.type == .USER_VARIABLE) || (formulaElement.type == .SENSOR) || (formulaElement.type == .STRING) {
            formulaElement.idempotenceState = .NOT_IDEMPOTENT
            return false
        }

        formulaElement.idempotenceState = .NOT_IDEMPOTENT
        return false
    }

    private func interpretRecursive(formulaElement: FormulaElement?, for spriteObject: SpriteObject) -> AnyObject {
        guard let formulaElement = formulaElement else { return 0 as AnyObject }
        var result: AnyObject

        if let cachedResult = cachedResults[formulaElement] {
            return cachedResult
        }

        switch formulaElement.type {
        case .OPERATOR:
            result = interpretOperator(formulaElement, for: spriteObject)
        case .FUNCTION:
            result = interpretFunction(formulaElement, for: spriteObject)
        case .NUMBER:
            result = interpretDouble(formulaElement, for: spriteObject)
        case .SENSOR:
            result = interpretSensor(formulaElement, for: spriteObject)
        case .USER_VARIABLE:
            result = interpretVariable(formulaElement, for: spriteObject)
        case .USER_LIST:
            result = interpretList(formulaElement, for: spriteObject)
        case .BRACKET:
            result = self.interpretRecursive(formulaElement: formulaElement.rightChild, for: spriteObject)
        case .STRING:
            result = formulaElement.value as AnyObject
        @unknown default:
            fatalError("ERROR: case not handled by switch statement")
        }

        if isIdempotent(formulaElement) {
            cacheResult(formulaElement, result: result)
        }

        return result
    }

    private func interpretDouble(_ formulaElement: FormulaElement, for spriteObject: SpriteObject) -> AnyObject {
        return Double(formulaElement.value) as AnyObject
    }

    private func boolResult(value: Bool) -> Double {
        return Double(value ? 1.0 : 0.0)
    }

    private func interpretVariable(_ formulaElement: FormulaElement, for spriteObject: SpriteObject) -> AnyObject {
        guard let project = spriteObject.project,
            let variable = project.variables.getUserVariableNamed(formulaElement.value, for: spriteObject),
            let value = variable.value else { return 0 as AnyObject }

        return value as AnyObject
    }

    private func interpretList(_ formulaElement: FormulaElement, for spriteObject: SpriteObject) -> AnyObject {
        guard let project = spriteObject.project,
            let list = project.variables.getUserListNamed(formulaElement.value, for: spriteObject),
            let value = list.value,
            let listElements = value as? [Any] else { return 0 as AnyObject }

        var stringElements = [String]()

        for listElement in listElements {
            if let stringElem = listElement as? String {
                stringElements.append(stringElem)
            } else if let intElem = listElement as? Int {
                stringElements.append(String(intElem))
            } else if let doubleElem = listElement as? Double {
                stringElements.append(String(doubleElem))
            }
        }

        return stringElements.joined(separator: " ") as AnyObject
    }

    private func interpretSensor(_ formulaElement: FormulaElement, for spriteObject: SpriteObject) -> AnyObject {
        return sensorManager.value(tag: formulaElement.value, spriteObject: spriteObject)
    }

    private func interpretFunction(_ formulaElement: FormulaElement, for spriteObject: SpriteObject) -> AnyObject {
        let leftParam = functionParameter(formulaElement: formulaElement.leftChild, spriteObject: spriteObject)
        let rightParam = functionParameter(formulaElement: formulaElement.rightChild, spriteObject: spriteObject)

        return functionManager.value(tag: formulaElement.value, firstParameter: leftParam, secondParameter: rightParam, spriteObject: spriteObject)
    }

    private func interpretOperator(_ formulaElement: FormulaElement, for spriteObject: SpriteObject) -> AnyObject {
        let leftParam = functionParameter(formulaElement: formulaElement.leftChild, spriteObject: spriteObject)
        let rightParam = functionParameter(formulaElement: formulaElement.rightChild, spriteObject: spriteObject)

        return operatorManager.value(tag: formulaElement.value, leftParameter: leftParam, rightParameter: rightParam)
    }

    private func functionParameter(formulaElement: FormulaElement?, spriteObject: SpriteObject) -> AnyObject? {
        guard let formulaElement = formulaElement else { return nil }

        if formulaElement.type == .USER_LIST {
            return spriteObject.project.variables.getUserListNamed(formulaElement.value, for: spriteObject)
        }

        return interpretRecursive(formulaElement: formulaElement, for: spriteObject)
    }

    private func cacheResult(_ formulaElement: FormulaElement, result: AnyObject) {
        cachedResults[formulaElement] = result
    }
}
