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
        var name = type(of: self).name
        let params = self.parameters()
        var count = 0
        
        if params.count == 0 {
            return name        // no parameter function
        }
        
        name += type(of: self).bracketOpen
        for param in params {
            name += param.defaultValueString()
            count += 1
            
            if count < params.count && params.count > 1 {
                name += type(of: self).parameterDelimiter
            }
        }

        name += type(of: self).bracketClose
        return name
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
