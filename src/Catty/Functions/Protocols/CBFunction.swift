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
    
    // Default value if function can not be computed
    static var defaultValue: AnyObject { get }
    
    // Resources required in order to get value of this function (e.g. Aceelerometer)
    static var requiredResource: ResourceType { get }
    
    // True if the value does not change when executed multiple times (e.g. sin(0)) or false if the value changes (e.g. random(0, 1))
    static var isIdempotent: Bool { get }
    
    // Return the section to show sensor in formula editor (FormulaEditorSection) and the position within that section (Int)
    // Use .hidden to not show the sensor at all
    static func formulaEditorSection() -> FormulaEditorSection
}

extension CBFunction {
    static var parameterDelimiter: String { get { return "," } }
    static var bracketOpen: String { get { return "(" } }
    static var bracketClose: String { get { return ")" } }
    
    func parameters() -> [FunctionParameter] {
        var parameters = [FunctionParameter]()
        
        if let function = self as? SingleParameterFunction {
            parameters.append(type(of: function).firstParameter())
        } else if let function = self as? DoubleParameterFunction {
            parameters.append(type(of: function).firstParameter())
            parameters.append(type(of: function).secondParameter())
        }
        
        return parameters
    }
    
    func nameWithParameters() -> String {
        var name = type(of: self).name + type(of: self).bracketOpen
        let params = self.parameters()
        var paramCount = 0
        
        for param in params {
            name += param.defaultValueString()
            paramCount += 1
            
            if paramCount > 1 && paramCount < params.count {
                name += type(of: self).parameterDelimiter
            }
        }
        
        name += type(of: self).bracketClose
        return name
    }
}

protocol ZeroParameterFunction: CBFunction {
    func value() -> AnyObject
}

protocol SingleParameterFunction: CBFunction {
    static func firstParameter() -> FunctionParameter
    
    func value(parameter: AnyObject?) -> AnyObject
}

protocol DoubleParameterFunction: CBFunction {
    static func firstParameter() -> FunctionParameter
    static func secondParameter() -> FunctionParameter
    
    func value(firstParameter: AnyObject?, secondParameter: AnyObject?) -> AnyObject
}
