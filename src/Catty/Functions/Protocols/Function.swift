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

protocol Function { // TODO remove CB prefix
    
    // Display name (e.g. for formula editor)
    static var name: String { get }
    
    // Resources required in order to get value of this function (e.g. Accelerometer)
    static var requiredResource: ResourceType { get }
    
    // True if the value does not change when executed multiple times (e.g. sin(0)) or false if the value changes (e.g. random(0, 1))
    static var isIdempotent: Bool { get }
    
    // Tag for serialization
    func tag() -> String
    
    // Return the section to show sensor in formula editor (FormulaEditorSection) and the position within that section (Int)
    // Use .hidden to not show the sensor at all
    func formulaEditorSection() -> FormulaEditorSection
}

extension Function {
    static var parameterDelimiter: String { get { return ", " } }
    static var bracketOpen: String { get { return "(" } }
    static var bracketClose: String { get { return ")" } }
    
    func parameters() -> [FunctionParameter] {
        var parameters = [FunctionParameter]()
        
        if let function = self as? SingleParameterFunctionProtocol {
            parameters.append(function.firstParameter())
        } else if let function = self as? DoubleParameterFunctionProtocol {
            parameters.append(function.firstParameter())
            parameters.append(function.secondParameter())
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
    
    /* this function is used for the text functions and it allows to
     add both string and numbers as parameters, interpreting them as strings;
     if the number does not have a floating part, then it is
     interpreted as a whole number
     */
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

protocol DoubleFunction: Function {
    // Default value if function can not be computed
    static var defaultValue: Double { get }
}

protocol StringFunction: Function {
    // Default value if function can not be computed
    static var defaultValue: String { get }
}

protocol AnyFunction: Function {
    // Default value if function can not be computed
    static var defaultValue: AnyObject { get }
}

protocol SingleParameterFunctionProtocol: Function {
    func firstParameter() -> FunctionParameter
}

protocol DoubleParameterFunctionProtocol: Function {
    func firstParameter() -> FunctionParameter
    func secondParameter() -> FunctionParameter
}

protocol ZeroParameterDoubleFunction: DoubleFunction {
    func value() -> Double
}

protocol SingleParameterDoubleFunction: DoubleFunction, SingleParameterFunctionProtocol {
    func value(parameter: AnyObject?) -> Double
}

protocol DoubleParameterDoubleFunction: DoubleFunction, DoubleParameterFunctionProtocol {
    func value(firstParameter: AnyObject?, secondParameter: AnyObject?) -> Double
}

protocol ZeroParameterStringFunction: StringFunction {
    func value() -> String
}

protocol ZeroParameterDoubleObjectFunction: DoubleFunction {
    func value(spriteObject: SpriteObject) -> Double
}

protocol SingleParameterDoubleObjectFunction: DoubleFunction, SingleParameterFunctionProtocol {
    func value(parameter: AnyObject?, spriteObject: SpriteObject) -> Double
}

protocol DoubleParameterDoubleObjectFunction: DoubleFunction, DoubleParameterFunctionProtocol {
    func value(firstParameter: AnyObject?, secondParameter: AnyObject?, spriteObject: SpriteObject) -> Double
}

protocol SingleParameterStringFunction: StringFunction, SingleParameterFunctionProtocol {
    func value(parameter: AnyObject?) -> String
}

protocol DoubleParameterStringFunction: StringFunction, DoubleParameterFunctionProtocol {
    func value(firstParameter: AnyObject?, secondParameter: AnyObject?) -> String
}

protocol ZeroParameterFunction: AnyFunction {
    func value() -> AnyObject
}

protocol SingleParameterFunction: AnyFunction, SingleParameterDoubleFunction {
    func value(parameter: AnyObject?) -> AnyObject
}

protocol DoubleParameterFunction: AnyFunction, DoubleParameterFunctionProtocol {
    func value(firstParameter: AnyObject?, secondParameter: AnyObject?) -> AnyObject
}
