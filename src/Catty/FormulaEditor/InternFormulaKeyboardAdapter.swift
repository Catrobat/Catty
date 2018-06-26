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

import UIKit

class InternFormulaKeyboardAdapter: NSObject {
    
    func createInternTokenListByResourceId(resource: Int, name: String) -> [InternToken?] {
        // USER VARIABLES
        if (resource == 0 && name.count != 0) {
            return buildUserVariable(name: name)
        }
        
        // USER LISTS
        if (resource == 11 && name.count != 0) {
            return buildUserList(name: name)
        }
        
        // STRING
        if(resource == Int(TOKEN_TYPE_STRING.rawValue)) {
            return buildString(name: name)
        }
        
        switch (resource) {
            case Int(TOKEN_TYPE_NUMBER_0.rawValue):
                return buildNumber(numberValue: "0")
                break
            case Int(TOKEN_TYPE_NUMBER_1.rawValue):
                return buildNumber(numberValue: "1")
                break
            case Int(TOKEN_TYPE_NUMBER_2.rawValue):
                return buildNumber(numberValue: "2")
                break
            case TOKEN_TYPE_NUMBER_3:
                return buildNumber(numberValue: "3")
                break
            case TOKEN_TYPE_NUMBER_4:
                return buildNumber(numberValue: "4")
                break
            case TOKEN_TYPE_NUMBER_5:
                return buildNumber(numberValue: "5")
                break
            case TOKEN_TYPE_NUMBER_6:
                return buildNumber(numberValue: "6")
                break
            case TOKEN_TYPE_NUMBER_7:
                return buildNumber(numberValue: "7")
                break
            case TOKEN_TYPE_NUMBER_8:
                return buildNumber(numberValue: "8")
                break
            case TOKEN_TYPE_NUMBER_9:
                return buildNumber(numberValue: "9")
                break
            
            // FUNCTIONS
            case SIN:
                return buildSingleParameterFunction(function: SIN, firstParameterType: TOKEN_TYPE_NUMBER, firstParameterValue: "0")
                break
            case COS:
                return buildSingleParameterFunction(function: COS, firstParameterType: TOKEN_TYPE_NUMBER, firstParameterValue: "0")
                break
            case TAN:
                return buildSingleParameterFunction(function: TAN, firstParameterType: TOKEN_TYPE_NUMBER, firstParameterValue: "0")
                break
            case LN:
                return buildSingleParameterFunction(function: LN, firstParameterType: TOKEN_TYPE_NUMBER, firstParameterValue: "0")
                break
            case LOG:
                return buildSingleParameterFunction(function: LOG, firstParameterType: TOKEN_TYPE_NUMBER, firstParameterValue: "0")
                break
            case PI_F:
                return buildFunctionWithoutParametersAndBrackets(function: PI_F)
                break
            case SQRT:
                return buildSingleParameterFunction(function: SQRT, firstParameterType: TOKEN_TYPE_NUMBER, firstParameterValue: "0")
                break
            case RAND:
                return buildSingleParameterFunction(function: RAND, firstParameterType: TOKEN_TYPE_NUMBER, firstParameterValue: "0")
                break
            case ABS:
                return buildSingleParameterFunction(function: ABS, firstParameterType: TOKEN_TYPE_NUMBER, firstParameterValue: "0")
                break
            case ROUND:
                return buildSingleParameterFunction(function: ROUND, firstParameterType: TOKEN_TYPE_NUMBER, firstParameterValue: "0")
                break
            case MOD:
                return buildDoubleParameterFunction(function: MOD, firstParameterType: TOKEN_TYPE_NUMBER, firstParameterValue: "1", secondParameterType: TOKEN_TYPE_NUMBER, secondParameterValue: "1")
                break
            case ARCSIN:
                return buildSingleParameterFunction(function: ARCSIN, firstParameterType: TOKEN_TYPE_NUMBER, firstParameterValue: "0")
                break
            case ARCCOS:
                return buildSingleParameterFunction(function: ARCCOS, firstParameterType: TOKEN_TYPE_NUMBER, firstParameterValue: "0")
                break
            case ARCTAN:
                return buildSingleParameterFunction(function: ARCTAN, firstParameterType: TOKEN_TYPE_NUMBER, firstParameterValue: "0")
                break
            case EXP:
                return buildSingleParameterFunction(function: EXP, firstParameterType: TOKEN_TYPE_NUMBER, firstParameterValue: "1")
                break
            case MAX:
                return buildDoubleParameterFunction(function: MAX, firstParameterType: TOKEN_TYPE_NUMBER, firstParameterValue: "0", secondParameterType: TOKEN_TYPE_NUMBER, secondParameterValue: "1")
                break
            case MIN:
                return buildDoubleParameterFunction(function: MIN, firstParameterType: TOKEN_TYPE_NUMBER, firstParameterValue: "0", secondParameterType: TOKEN_TYPE_NUMBER, secondParameterValue: "1")
                break
            case TRUE_F:
                return buildFunctionWithoutParametersAndBrackets(function: TRUE_F)
                break
            case FALSE_F:
                return buildFunctionWithoutParametersAndBrackets(function: FALSE_F)
                break
            case POW:
                return buildDoubleParameterFunction(function: POW, firstParameterType: TOKEN_TYPE_NUMBER, firstParameterValue: "1", secondParameterType: TOKEN_TYPE_NUMBER, secondParameterValue: "1")
                break
            case LETTER:
                return buildDoubleParameterFunction(function: LETTER, firstParameterType: TOKEN_TYPE_NUMBER, firstParameterValue: "1", secondParameterType: TOKEN_TYPE_STRING, secondParameterValue: "hello world")
                break
            case LENGTH:
                return buildSingleParameterFunction(function: LENGTH, firstParameterType: TOKEN_TYPE_STRING, firstParameterValue: "hello world")
                break
            case JOIN:
                return buildDoubleParameterFunction(function: JOIN, firstParameterType: TOKEN_TYPE_STRING, firstParameterValue: "hello", secondParameterType: TOKEN_TYPE_STRING, secondParameterValue: " world")
                break
            case ARDUINODIGITAL:
                buildSingleParameterFunction(function: ARDUINODIGITAL, firstParameterType: TOKEN_TYPE_NUMBER, firstParameterValue: "0")
                break
            case ARDUINOANALOG:
                buildSingleParameterFunction(function: ARDUINOANALOG, firstParameterType: TOKEN_TYPE_NUMBER, firstParameterValue: "0")
                break
            case FLOOR:
                buildSingleParameterFunction(function: FLOOR, firstParameterType: TOKEN_TYPE_NUMBER, firstParameterValue: "0")
                break
            case CEIL:
                buildSingleParameterFunction(function: CEIL, firstParameterType: TOKEN_TYPE_NUMBER, firstParameterValue: "0")
                break
            case NUMBEROFITEMS:
                buildSingleParameterFunction(function: NUMBEROFITEMS, firstParameterType: TOKEN_TYPE_USER_LIST, firstParameterValue: "list name")
                break
            case ELEMENT:
                return buildDoubleParameterFunction(function: ELEMENT, firstParameterType: TOKEN_TYPE_NUMBER, firstParameterValue: "1", secondParameterType: TOKEN_TYPE_USER_LIST, secondParameterValue: "list name")
                break
            case CONTAINS:
                return buildDoubleParameterFunction(function: CONTAINS, firstParameterType: TOKEN_TYPE_USER_LIST, firstParameterValue: "list name", secondParameterType: TOKEN_TYPE_NUMBER, secondParameterValue: "1")
                break
            case MULTI_FINGER_TOUCHED:
                buildSingleParameterFunction(function: MULTI_FINGER_TOUCHED, firstParameterType: TOKEN_TYPE_NUMBER, firstParameterValue: "1")
                break
            case MULTI_FINGER_X:
                buildSingleParameterFunction(function: MULTI_FINGER_X, firstParameterType: TOKEN_TYPE_NUMBER, firstParameterValue: "1")
                break
            case MULTI_FINGER_Y:
                buildSingleParameterFunction(function: MULTI_FINGER_Y, firstParameterType: TOKEN_TYPE_NUMBER, firstParameterValue: "1")
                break
            
            // PERIOD
            case DECIMAL_MARK:
                return buildPeriod()
                break
            
            // OPERATOR
            
            case PLUS:
                return buildOperator(operator: PLUS)
                break
            case MINUS:
                return buildOperator(operator: MINUS)
                break
            case MULT:
                return buildOperator(operator: MULT)
                break
            case DIVIDE:
                return buildOperator(operator: DIVIDE)
                break
            case EQUAL:
                return buildOperator(operator: EQUAL)
                break
            case NOT_EQUAL:
                return buildOperator(operator: NOT_EQUAL)
                break
            case SMALLER_THAN:
                return buildOperator(operator: SMALLER_THAN)
                break
            case SMALLER_OR_EQUAL:
                return buildOperator(operator: SMALLER_OR_EQUAL)
                break
            case GREATER_THAN:
                return buildOperator(operator: GREATER_THAN)
                break
            case GREATER_OR_EQUAL:
                return buildOperator(operator: GREATER_OR_EQUAL)
                break
            case LOGICAL_AND:
                return buildOperator(operator: LOGICAL_AND)
                break
            case LOGICAL_OR:
                return buildOperator(operator: LOGICAL_OR)
                break
            case LOGICAL_NOT:
                return buildOperator(operator: LOGICAL_NOT)
                break
            
            // BRACKETS
            case BRACKET_OPEN:
                return buildOperator(operator: BRACKET_OPEN)
                break
            case BRACKET_CLOSE:
                return buildOperator(operator: BRACKET_CLOSE)
                break
            
            default:
                return nil
                break
        }
    }
    
    func createInternTokenListBySensor(sensor: CBSensor) -> [InternToken?] {
        // TODO arduino: buildSingleParameterFunction
        return buildSensor(sensor: sensor)
    }
    
    func buildUserVariable(name: String) -> [InternToken?] {
        let returnList = [InternToken.init(type: TOKEN_TYPE_USER_VARIABLE, andValue: name)]
        return returnList
    }
    
    func buildUserList(name: String) -> [InternToken?] {
        let returnList = [InternToken.init(type: TOKEN_TYPE_USER_LIST, andValue: name)]
        return returnList
    }
    
    func buildString(name: String) -> [InternToken?] {
        let returnList = [InternToken.init(type: TOKEN_TYPE_STRING, andValue: name)]
        return returnList
    }
    
    func buildNumber(numberValue: String) -> [InternToken?] {
        let returnList = [InternToken.init(type: TOKEN_TYPE_NUMBER, andValue: numberValue)]
        return returnList
    }
    
    func buildSingleParameterFunction(function: Function, firstParameterType:InternTokenType, firstParameterValue: String) -> [InternToken?] {
        let returnList = [InternToken.init(type: TOKEN_TYPE_FUNCTION_NAME, andValue: Functions.getName(function)),
                          InternToken.init(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN),
                          InternToken.init(type: firstParameterType, andValue: firstParameterValue),
                          InternToken.init(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE)
                        ]
        return returnList
        
    }
    
    func buildFunctionWithoutParametersAndBrackets(function: Function) -> [InternToken?] {
        let returnList = [InternToken.init(type: TOKEN_TYPE_FUNCTION_NAME, andValue: Functions.getName(function))]
        return returnList
        
    }
    
    func buildDoubleParameterFunction(function: Function, firstParameterType:InternTokenType, firstParameterValue: String, secondParameterType:InternTokenType, secondParameterValue: String) -> [InternToken?] {
        let returnList = [InternToken.init(type: TOKEN_TYPE_FUNCTION_NAME, andValue: Functions.getName(function)),
                          InternToken.init(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN),
                          InternToken.init(type: firstParameterType, andValue: firstParameterValue),
                          InternToken.init(type: TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER),
                          InternToken.init(type: secondParameterType, andValue: secondParameterValue),
                          InternToken.init(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE)
        ]
        return returnList
        
    }
    
    func buildPeriod() -> [InternToken?] {
        let returnList = [InternToken.init(type: TOKEN_TYPE_PERIOD)]
        return returnList
    }
    
    func buildBracketOpen() -> [InternToken?] {
        let returnList = [InternToken.init(type: TOKEN_TYPE_BRACKET_OPEN)]
        return returnList
    }
    
    func buildBracketClose() -> [InternToken?] {
        let returnList = [InternToken.init(type: TOKEN_TYPE_BRACKET_CLOSE)]
        return returnList
    }
    
    func buildOperator(operator: Operator) -> [InternToken?] {
        let returnList = [InternToken.init(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(operator))]
        return returnList
    }

    func buildSensor(sensor: CBSensor) -> [InternToken?] {
        let sensorTag: String
        sensorTag = CBSensorManager.shared.tag(sensor: sensor)
        let returnList = [InternToken.init(type: TOKEN_TYPE_SENSOR, andValue: sensorTag)]
        return returnList
    }
    
    func buildSingleParameterSensor(sensor: Any, firstParameterType: InternTokenType, firstParameterValue: String) -> [InternToken?] {
        let sensorTag: String
        sensorTag = CBSensorManager.shared.tag(sensor: sensor as! CBSensor)
        let returnList = [InternToken.init(type: TOKEN_TYPE_FUNCTION_NAME, andValue: sensorTag),
                          InternToken.init(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN),
                          InternToken.init(type: firstParameterType, andValue: firstParameterValue),
                          InternToken.init(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE)]
        return returnList
    }
}
