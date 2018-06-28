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

@objc extension InternFormula {
    
    @objc func createInternTokenListByResourceId(resource: Int, name: String) -> [InternToken] {
        // USER VARIABLES
        if (resource == 0 && name.count != 0) {
            return buildUserVariable(name: name)
        }
        
        // USER LISTS
        if (resource == 11 && name.count != 0) {
            return buildUserList(name: name)
        }
        
        // STRING
        if(resource == TOKEN_TYPE_STRING.rawValue) {
            return buildString(name: name)
        }
        
        switch (resource) {
        case Int(TOKEN_TYPE_NUMBER_0.rawValue):
            return buildNumber(numberValue: "0")
        case Int(TOKEN_TYPE_NUMBER_1.rawValue):
            return buildNumber(numberValue: "1")
        case Int(TOKEN_TYPE_NUMBER_2.rawValue):
            return buildNumber(numberValue: "2")
        case Int(TOKEN_TYPE_NUMBER_3.rawValue):
            return buildNumber(numberValue: "3")
        case Int(TOKEN_TYPE_NUMBER_4.rawValue):
            return buildNumber(numberValue: "4")
        case Int(TOKEN_TYPE_NUMBER_5.rawValue):
            return buildNumber(numberValue: "5")
        case Int(TOKEN_TYPE_NUMBER_6.rawValue):
            return buildNumber(numberValue: "6")
        case Int(TOKEN_TYPE_NUMBER_7.rawValue):
            return buildNumber(numberValue: "7")
        case Int(TOKEN_TYPE_NUMBER_8.rawValue):
            return buildNumber(numberValue: "8")
        case Int(TOKEN_TYPE_NUMBER_9.rawValue):
            return buildNumber(numberValue: "9")
            
        // FUNCTIONS
        case Int(SIN.rawValue):
            return buildSingleParameterFunction(function: SIN, firstParameterType: TOKEN_TYPE_NUMBER, firstParameterValue: "0")
        case Int(COS.rawValue):
            return buildSingleParameterFunction(function: COS, firstParameterType: TOKEN_TYPE_NUMBER, firstParameterValue: "0")
        case Int(TAN.rawValue):
            return buildSingleParameterFunction(function: TAN, firstParameterType: TOKEN_TYPE_NUMBER, firstParameterValue: "0")
        case Int(LN.rawValue):
            return buildSingleParameterFunction(function: LN, firstParameterType: TOKEN_TYPE_NUMBER, firstParameterValue: "0")
        case Int(LOG.rawValue):
            return buildSingleParameterFunction(function: LOG, firstParameterType: TOKEN_TYPE_NUMBER, firstParameterValue: "0")
        case Int(PI_F.rawValue):
            return buildFunctionWithoutParametersAndBrackets(function: PI_F)
        case Int(SQRT.rawValue):
            return buildSingleParameterFunction(function: SQRT, firstParameterType: TOKEN_TYPE_NUMBER, firstParameterValue: "0")
        case Int(RAND.rawValue):
            return buildSingleParameterFunction(function: RAND, firstParameterType: TOKEN_TYPE_NUMBER, firstParameterValue: "0")
        case Int(ABS.rawValue):
            return buildSingleParameterFunction(function: ABS, firstParameterType: TOKEN_TYPE_NUMBER, firstParameterValue: "0")
        case Int(ROUND.rawValue):
            return buildSingleParameterFunction(function: ROUND, firstParameterType: TOKEN_TYPE_NUMBER, firstParameterValue: "0")
        case Int(MOD.rawValue):
            return buildDoubleParameterFunction(function: MOD, firstParameterType: TOKEN_TYPE_NUMBER, firstParameterValue: "1", secondParameterType: TOKEN_TYPE_NUMBER, secondParameterValue: "1")
        case Int(ARCSIN.rawValue):
            return buildSingleParameterFunction(function: ARCSIN, firstParameterType: TOKEN_TYPE_NUMBER, firstParameterValue: "0")
        case Int(ARCCOS.rawValue):
            return buildSingleParameterFunction(function: ARCCOS, firstParameterType: TOKEN_TYPE_NUMBER, firstParameterValue: "0")
        case Int(ARCTAN.rawValue):
            return buildSingleParameterFunction(function: ARCTAN, firstParameterType: TOKEN_TYPE_NUMBER, firstParameterValue: "0")
        case Int(EXP.rawValue):
            return buildSingleParameterFunction(function: EXP, firstParameterType: TOKEN_TYPE_NUMBER, firstParameterValue: "1")
        case Int(MAX.rawValue):
            return buildDoubleParameterFunction(function: MAX, firstParameterType: TOKEN_TYPE_NUMBER, firstParameterValue: "0", secondParameterType: TOKEN_TYPE_NUMBER, secondParameterValue: "1")
        case Int(MIN.rawValue):
            return buildDoubleParameterFunction(function: MIN, firstParameterType: TOKEN_TYPE_NUMBER, firstParameterValue: "0", secondParameterType: TOKEN_TYPE_NUMBER, secondParameterValue: "1")
        case Int(TRUE_F.rawValue):
            return buildFunctionWithoutParametersAndBrackets(function: TRUE_F)
        case Int(FALSE_F.rawValue):
            return buildFunctionWithoutParametersAndBrackets(function: FALSE_F)
        case Int(POW.rawValue):
            return buildDoubleParameterFunction(function: POW, firstParameterType: TOKEN_TYPE_NUMBER, firstParameterValue: "1", secondParameterType: TOKEN_TYPE_NUMBER, secondParameterValue: "1")
        case Int(LETTER.rawValue):
            return buildDoubleParameterFunction(function: LETTER, firstParameterType: TOKEN_TYPE_NUMBER, firstParameterValue: "1", secondParameterType: TOKEN_TYPE_STRING, secondParameterValue: "hello world")
        case Int(LENGTH.rawValue):
            return buildSingleParameterFunction(function: LENGTH, firstParameterType: TOKEN_TYPE_STRING, firstParameterValue: "hello world")
        case Int(JOIN.rawValue):
            return buildDoubleParameterFunction(function: JOIN, firstParameterType: TOKEN_TYPE_STRING, firstParameterValue: "hello", secondParameterType: TOKEN_TYPE_STRING, secondParameterValue: " world")
        case Int(ARDUINODIGITAL.rawValue):
            return buildSingleParameterFunction(function: ARDUINODIGITAL, firstParameterType: TOKEN_TYPE_NUMBER, firstParameterValue: "0")
        case Int(ARDUINOANALOG.rawValue):
            return buildSingleParameterFunction(function: ARDUINOANALOG, firstParameterType: TOKEN_TYPE_NUMBER, firstParameterValue: "0")
        case Int(FLOOR.rawValue):
            return buildSingleParameterFunction(function: FLOOR, firstParameterType: TOKEN_TYPE_NUMBER, firstParameterValue: "0")
        case Int(CEIL.rawValue):
            return buildSingleParameterFunction(function: CEIL, firstParameterType: TOKEN_TYPE_NUMBER, firstParameterValue: "0")
        case Int(NUMBEROFITEMS.rawValue):
            return buildSingleParameterFunction(function: NUMBEROFITEMS, firstParameterType: TOKEN_TYPE_USER_LIST, firstParameterValue: "list name")
        case Int(ELEMENT.rawValue):
            return buildDoubleParameterFunction(function: ELEMENT, firstParameterType: TOKEN_TYPE_NUMBER, firstParameterValue: "1", secondParameterType: TOKEN_TYPE_USER_LIST, secondParameterValue: "list name")
        case Int(CONTAINS.rawValue):
            return buildDoubleParameterFunction(function: CONTAINS, firstParameterType: TOKEN_TYPE_USER_LIST, firstParameterValue: "list name", secondParameterType: TOKEN_TYPE_NUMBER, secondParameterValue: "1")
        case Int(MULTI_FINGER_TOUCHED.rawValue):
            return buildSingleParameterFunction(function: MULTI_FINGER_TOUCHED, firstParameterType: TOKEN_TYPE_NUMBER, firstParameterValue: "1")
        case Int(MULTI_FINGER_X.rawValue):
            return buildSingleParameterFunction(function: MULTI_FINGER_X, firstParameterType: TOKEN_TYPE_NUMBER, firstParameterValue: "1")
        case Int(MULTI_FINGER_Y.rawValue):
            return buildSingleParameterFunction(function: MULTI_FINGER_Y, firstParameterType: TOKEN_TYPE_NUMBER, firstParameterValue: "1")
            
        // PERIOD
        case Int(DECIMAL_MARK.rawValue):
            return buildPeriod()
            
        // OPERATOR
            
        case Int(PLUS.rawValue):
            return buildOperator(mathOperator: PLUS)
        case Int(MINUS.rawValue):
            return buildOperator(mathOperator: MINUS)
        case Int(MULT.rawValue):
            return buildOperator(mathOperator: MULT)
        case Int(DIVIDE.rawValue):
            return buildOperator(mathOperator: DIVIDE)
        case Int(EQUAL.rawValue):
            return buildOperator(mathOperator: EQUAL)
        case Int(NOT_EQUAL.rawValue):
            return buildOperator(mathOperator: NOT_EQUAL)
        case Int(SMALLER_THAN.rawValue):
            return buildOperator(mathOperator: SMALLER_THAN)
        case Int(SMALLER_OR_EQUAL.rawValue):
            return buildOperator(mathOperator: SMALLER_OR_EQUAL)
        case Int(GREATER_THAN.rawValue):
            return buildOperator(mathOperator: GREATER_THAN)
        case Int(GREATER_OR_EQUAL.rawValue):
            return buildOperator(mathOperator: GREATER_OR_EQUAL)
        case Int(LOGICAL_AND.rawValue):
            return buildOperator(mathOperator: LOGICAL_AND)
        case Int(LOGICAL_OR.rawValue):
            return buildOperator(mathOperator: LOGICAL_OR)
        case Int(LOGICAL_NOT.rawValue):
            return buildOperator(mathOperator: LOGICAL_NOT)
            
        // BRACKETS
        case Int(BRACKET_OPEN.rawValue):
            return buildBracketOpen()
        case Int(BRACKET_CLOSE.rawValue):
            return buildBracketClose()
            
        default:
            return []
        }
    }
    
    @objc func createInternTokenListBySensor(sensor: CBSensor) -> [InternToken] {
        // TODO arduino: buildSingleParameterFunction
        return buildSensor(sensor: sensor)
    }
    
    func buildUserVariable(name: String) -> [InternToken] {
        return [InternToken.init(type: TOKEN_TYPE_USER_VARIABLE, andValue: name)]
    }
    
    func buildUserList(name: String) -> [InternToken] {
        return [InternToken.init(type: TOKEN_TYPE_USER_LIST, andValue: name)]
    }
    
    func buildString(name: String) -> [InternToken] {
        return [InternToken.init(type: TOKEN_TYPE_STRING, andValue: name)]
    }
    
    func buildNumber(numberValue: String) -> [InternToken] {
        return [InternToken.init(type: TOKEN_TYPE_NUMBER, andValue: numberValue)]
    }
    
    func buildSingleParameterFunction(function: Function, firstParameterType:InternTokenType, firstParameterValue: String) -> [InternToken] {
        return [InternToken.init(type: TOKEN_TYPE_FUNCTION_NAME, andValue: Functions.getName(function)),
                InternToken.init(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN),
                InternToken.init(type: firstParameterType, andValue: firstParameterValue),
                InternToken.init(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE)
        ]
    }
    
    func buildFunctionWithoutParametersAndBrackets(function: Function) -> [InternToken] {
        return [InternToken.init(type: TOKEN_TYPE_FUNCTION_NAME, andValue: Functions.getName(function))]
    }
    
    func buildDoubleParameterFunction(function: Function, firstParameterType:InternTokenType, firstParameterValue: String, secondParameterType:InternTokenType, secondParameterValue: String) -> [InternToken] {
        return [InternToken.init(type: TOKEN_TYPE_FUNCTION_NAME, andValue: Functions.getName(function)),
                InternToken.init(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN),
                InternToken.init(type: firstParameterType, andValue: firstParameterValue),
                InternToken.init(type: TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER),
                InternToken.init(type: secondParameterType, andValue: secondParameterValue),
                InternToken.init(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE)
        ]
    }
    
    func buildPeriod() -> [InternToken] {
        return [InternToken.init(type: TOKEN_TYPE_PERIOD)]
    }
    
    func buildBracketOpen() -> [InternToken] {
        return [InternToken.init(type: TOKEN_TYPE_BRACKET_OPEN)]
    }
    
    func buildBracketClose() -> [InternToken] {
        return [InternToken.init(type: TOKEN_TYPE_BRACKET_CLOSE)]
    }
    
    func buildOperator(mathOperator: Operator) -> [InternToken] {
        return [InternToken.init(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(mathOperator))]
    }
    
    func buildSensor(sensor: CBSensor) -> [InternToken] {
        let sensorTag = CBSensorManager.shared.tag(sensor: sensor)
        return [InternToken.init(type: TOKEN_TYPE_SENSOR, andValue: sensorTag)]
    }
    
    func buildSingleParameterSensor(sensor: Any, firstParameterType: InternTokenType, firstParameterValue: String) -> [InternToken] {
        let sensorTag: String
        sensorTag = CBSensorManager.shared.tag(sensor: sensor as! CBSensor)
        return [InternToken.init(type: TOKEN_TYPE_FUNCTION_NAME, andValue: sensorTag),
                InternToken.init(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN),
                InternToken.init(type: firstParameterType, andValue: firstParameterValue),
                InternToken.init(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE)]
        
    }
}
