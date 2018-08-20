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

@objc class FunctionManager: NSObject, FunctionManagerProtocol {
    
    @objc public static let shared = FunctionManager()
    public static var defaultValueForUndefinedFunction: Double = 0
    private var functionMap = [String: CBFunction]()
    
    private override init() {
        super.init()
        registerFunctions()
    }
    
    private func registerFunctions() {
        let functionList: [CBFunction] = [
            SinFunction(),
            JoinFunction(),
            LetterFunction(),
            LengthFunction(),
            ElementFunction(),
            NumberOfItemsFunction(),
            ContainsFunction()
        ]
        
        functionList.forEach { self.functionMap[type(of: $0).tag] = $0 }
    }
    
    @objc func requiredResource(tag: String) -> ResourceType {
        guard let function = self.function(tag: tag) else { return .noResources }
        return type(of: function).requiredResource
    }
    
    func function(tag: String) -> CBFunction? {
        return self.functionMap[tag]
    }
    
    @objc func name(tag: String) -> String? {
        guard let function = self.function(tag: tag) else { return nil }
        return type(of: function).name
    }
    
    @objc func exists(tag: String) -> Bool {
        return self.function(tag: tag) != nil
    }
    
    func isIdempotent(tag: String) -> Bool {
        guard let function = self.function(tag: tag) else { return false }
        return type(of: function).isIdempotent
    }
    
    @objc func value(tag: String, firstParameter: AnyObject?, secondParameter: AnyObject?) -> AnyObject {
        guard let function = self.function(tag: tag) else { return type(of: self).defaultValueForUndefinedFunction as AnyObject }
        var value: AnyObject = type(of: self).defaultValueForUndefinedFunction as AnyObject
        
        if let function = function as? ZeroParameterFunction {
            value = function.value() as AnyObject
        } else if let function = function as? SingleParameterFunction {
            value = function.value(parameter: firstParameter) as AnyObject
        } else if let function = function as? DoubleParameterFunction {
            value = function.value(firstParameter: firstParameter, secondParameter: secondParameter) as AnyObject
        } else if let function = function as? ZeroParameterStringFunction {
            value = function.value() as AnyObject
        } else if let function = function as? SingleParameterStringFunction {
            value = function.value(parameter: firstParameter) as AnyObject
        } else if let function = function as? DoubleParameterStringFunction {
            value = function.value(firstParameter: firstParameter, secondParameter: secondParameter) as AnyObject
        }
        
        return value
    }
    
    func setup(for program: Program, and scene: CBScene) {
        // TODO setup dependencies
    }
    
    func stop() {
        // TODO stop dependencies
    }
    
    func functions() -> [CBFunction] {
        var functions = [Int: CBFunction]()
        
        for function in self.functionMap.values {
            switch (type(of: function).formulaEditorSection()) {
            case let .math(position):
                functions[position] = function
            default:
                break;
            }
        }
        return functions.sorted(by: { $0.0 < $1.0 }).map{ $1}
    }
}
