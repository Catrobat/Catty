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

protocol CBFunction { // TODO remove CB prefix
    
    // Tag for serialization
    static var tag: String { get }
    
    // Display name (e.g. for formula editor)
    static var name: String { get }
    
    // Resources required in order to get value of this function (e.g. Aceelerometer)
    static var requiredResource: ResourceType { get }
    
    // True if the value does not change when executed multiple times (e.g. sin(0)) or false if the value changes (e.g. random(0, 1))
    static var isIdempotent: Bool { get }
    
    // Return the section to show sensor in formula editor (FormulaEditorSection) and the position within that section (Int)
    // Use .hidden to not show the sensor at all
    static func formulaEditorSection() -> FormulaEditorSection
}

extension CBFunction {
    static var parameterDelimiter: String { get { return ", " } }
    static var bracketOpen: String { get { return "(" } }
    static var bracketClose: String { get { return ")" } }
    
    func parameters() -> [FunctionParameter] {
        var parameters = [FunctionParameter]()
        
        if let function = self as? SingleParameterFunctionProtocol {
            parameters.append(type(of: function).firstParameter())
        } else if let function = self as? DoubleParameterFunctionProtocol {
            parameters.append(type(of: function).firstParameter())
            parameters.append(type(of: function).secondParameter())
        }
        
        return parameters
    }
    
    func nameWithParameters() -> String {
        var functionHeader = type(of: self).name
        let params = self.parameters()
        var count = 0
        
        if params.count == 0 {
            return functionHeader       // no parameter function
        }
        
        functionHeader += type(of: self).bracketOpen
        for param in params {
            
            // add the parameter value
            functionHeader += param.defaultValueForFunctionSignature()
            count += 1
            
            // add delimiter between parameters
            if count < params.count && params.count > 1 {
                functionHeader += type(of: self).parameterDelimiter
            }
        }
        
        functionHeader += type(of: self).bracketClose
        return functionHeader
    }
    
    /*  this function is used for the text functions and it allows to
     add both string and numbers as parameters, interpreting them as strings;
        if the number does not have a floating part, then it is
     interpreted as a whole number  */
    static func interpretParameter(parameter: AnyObject?) -> String {
        if let text = parameter as? String {
            return text
        }
        if let number = parameter as? Double {
            if floor(number) == number {
                return String(format: "%.0f", number)
            }
            return String(number)
        }
        return ""
    }
    
}

protocol DoubleFunction: CBFunction {
    // Default value if function can not be computed
    static var defaultValue: Double { get }
}

protocol StringFunction: CBFunction {
    // Default value if function can not be computed
    static var defaultValue: String { get }
}

protocol SingleParameterFunctionProtocol: CBFunction {
    static func firstParameter() -> FunctionParameter
}

protocol DoubleParameterFunctionProtocol: CBFunction {
    static func firstParameter() -> FunctionParameter
    static func secondParameter() -> FunctionParameter
}

protocol ZeroParameterFunction: DoubleFunction {
    func value() -> Double
}

protocol SingleParameterFunction: DoubleFunction, SingleParameterFunctionProtocol {
    func value(parameter: AnyObject?) -> Double
}

protocol DoubleParameterFunction: DoubleFunction, DoubleParameterFunctionProtocol {
    func value(firstParameter: AnyObject?, secondParameter: AnyObject?) -> Double
}

protocol ZeroParameterStringFunction: StringFunction {
    func value() -> String
}

protocol SingleParameterStringFunction: StringFunction, SingleParameterFunction {
    func value(parameter: AnyObject?) -> String
}

protocol DoubleParameterStringFunction: StringFunction, DoubleParameterFunctionProtocol {
    func value(firstParameter: AnyObject?, secondParameter: AnyObject?) -> String
}

protocol ZeroParameterDoubleFunctionWithSpriteObject: DoubleFunction {
    func value(spriteObject: SpriteObject) -> Double
}

protocol SingleParameterDoubleFunctionWithSpriteObject: DoubleFunction, SingleParameterFunctionProtocol {
    func value(parameter: AnyObject?, spriteObject: SpriteObject) -> Double
}

protocol DoubleParameterDoubleFunctionWithSpriteObject: DoubleFunction, DoubleParameterFunctionProtocol {
    func value(firstParameter: AnyObject?, secondParameter: AnyObject?, spriteObject: SpriteObject) -> Double
}

protocol ZeroParameterStringFunctionWithSpriteObject: StringFunction {
    func value(spriteObject: SpriteObject) -> String
}

protocol SingleParameterStringFunctionWithSpriteObject: StringFunction, SingleParameterFunctionProtocol {
    func value(parameter: AnyObject?, spriteObject: SpriteObject) -> String
}

protocol DoubleParameterStringFunctionWithSpriteObject: StringFunction, DoubleParameterFunctionProtocol {
    func value(firstParameter: AnyObject?, secondParameter: AnyObject?, spriteObject: SpriteObject) -> String
}

protocol ZeroParameterObjectFunction: DoubleFunction {
    func value(spriteObject: SpriteObject) -> Double
}

protocol SingleParameterObjectFunction: DoubleFunction, SingleParameterFunctionProtocol {
    func value(spriteObject: SpriteObject, parameter: AnyObject?) -> Double
}

protocol DoubleParameterObjectFunction: DoubleFunction, DoubleParameterFunctionProtocol {
    func value(spriteObject: SpriteObject, firstParameter: AnyObject?, secondParameter: AnyObject?) -> Double
}

protocol ZeroParameterStringObjectFunction: StringFunction {
    func value(spriteObject: SpriteObject) -> String
}

protocol SingleParameterStringObjectFunction: StringFunction, SingleParameterFunction {
    func value(spriteObject: SpriteObject, parameter: AnyObject?) -> String
}

protocol DoubleParameterStringObjectFunction: StringFunction, DoubleParameterFunctionProtocol {
    func value(spriteObject: SpriteObject, firstParameter: AnyObject?, secondParameter: AnyObject?) -> String
}
