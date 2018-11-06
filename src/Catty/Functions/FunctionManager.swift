/**
 *  Copyright (C) 2010-2018 The Catrobat Team
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

import BluetoothHelper

@objc class FunctionManager: NSObject, FunctionManagerProtocol {

    public static var defaultValueForUndefinedFunction: Double = 0
    private static var functionMap = [String: Function]() // TODO make instance let

    init(functions: [Function]) {
        super.init()
        registerFunctions(functionList: functions)
    }

    private func registerFunctions(functionList: [Function]) {
        type(of: self).functionMap.removeAll()
        functionList.forEach { type(of: self).functionMap[$0.tag()] = $0 }
    }

    func function(tag: String) -> Function? {
        return type(of: self).functionMap[tag]
    }

    func functions() -> [Function] {
        return Array(type(of: self).functionMap.values)
    }

    func isIdempotent(tag: String) -> Bool {
        guard let function = self.function(tag: tag) else { return false }
        return type(of: function).isIdempotent
    }

    @objc func value(tag: String, firstParameter: AnyObject?, secondParameter: AnyObject?, spriteObject: SpriteObject) -> AnyObject {
        guard let function = self.function(tag: tag) else { return type(of: self).defaultValueForUndefinedFunction as AnyObject }
        var value: AnyObject = type(of: self).defaultValueForUndefinedFunction as AnyObject

        if let function = function as? ZeroParameterDoubleFunction {
            value = function.value() as AnyObject
        } else if let function = function as? SingleParameterDoubleFunction {
            value = function.value(parameter: firstParameter) as AnyObject
        } else if let function = function as? DoubleParameterDoubleFunction {
            value = function.value(firstParameter: firstParameter, secondParameter: secondParameter) as AnyObject
        } else if let function = function as? ZeroParameterStringFunction {
            value = function.value() as AnyObject
        } else if let function = function as? SingleParameterStringFunction {
            value = function.value(parameter: firstParameter) as AnyObject
        } else if let function = function as? DoubleParameterStringFunction {
            value = function.value(firstParameter: firstParameter, secondParameter: secondParameter) as AnyObject
        } else if let function = function as? ZeroParameterFunction {
            value = function.value()
        } else if let function = function as? SingleParameterFunction {
            value = function.value(parameter: firstParameter)
        } else if let function = function as? DoubleParameterFunction {
            value = function.value(firstParameter: firstParameter, secondParameter: secondParameter)
        } else if let function = function as? ZeroParameterDoubleObjectFunction {
            value = function.value(spriteObject: spriteObject) as AnyObject
        } else if let function = function as? SingleParameterDoubleObjectFunction {
            value = function.value(parameter: firstParameter, spriteObject: spriteObject) as AnyObject
        } else if let function = function as? DoubleParameterDoubleObjectFunction {
            value = function.value(firstParameter: firstParameter, secondParameter: secondParameter, spriteObject: spriteObject) as AnyObject
        }

        return value
    }

    func formulaEditorItems() -> [FormulaEditorItem] {
        var items = [FormulaEditorItem]()

        for function in self.functions() {
            items.append(FormulaEditorItem(function: function))
        }

        return items
    }

    func exists(tag: String) -> Bool {
        return self.function(tag: tag) != nil
    }

    @objc static func requiredResource(tag: String) -> ResourceType {
        guard let function = functionMap[tag] else { return ResourceType.noResources }
        return type(of: function).requiredResource
    }

    @objc static func name(tag: String) -> String? {
        guard let function = functionMap[tag] else { return nil }
        return type(of: function).name
    }
}
