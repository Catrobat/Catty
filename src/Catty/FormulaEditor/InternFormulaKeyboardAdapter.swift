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

struct resourceId {
    var resource: Int
    var name: String
}

class InternFormulaKeyboardAdapter: NSObject {
    
    var createInternTokenListByResourceId: [resourceId]
    var createInternTokenListBySensor: [CBSensor]
    
    func createInternTokenListByResourceId(resource: Int, name: String) {
        // USER VARIABLES
        if (resource == 0 && name.count != 0) {
            return buildUserVariable(name: name)
        }
        
        // USER LISTS
        if (resource == 11 && name.count != 0) {
            return buildUserList(name: name)
        }
        
        // STRING
        if(resource == TOKEN_TYPE_STRING) {
            return buildString(name: name)
        }
        
        switch (resource) {
            case TOKEN_TYPE_NUMBER_0:
                return buildNumber("0")
                break
            case TOKEN_TYPE_NUMBER_1:
                return buildNumber("1")
                break
            case TOKEN_TYPE_NUMBER_2:
                return buildNumber("2")
                break
            case TOKEN_TYPE_NUMBER_3:
                return buildNumber("3")
                break
            case TOKEN_TYPE_NUMBER_4:
                return buildNumber("4")
                break
            case TOKEN_TYPE_NUMBER_5:
                return buildNumber("5")
                break
            case TOKEN_TYPE_NUMBER_6:
                return buildNumber("6")
                break
            case TOKEN_TYPE_NUMBER_7:
                return buildNumber("7")
                break
            case TOKEN_TYPE_NUMBER_8:
                return buildNumber("8")
                break
            case TOKEN_TYPE_NUMBER_9:
                return buildNumber("9")
                break
            
            // FUNCTIONS
            case SIN:
                //add return
                break
            case COS:
                //add return
                break
            case TAN:
                //add return
                break
            case LN:
                //add return
                break
            case LOG:
                //add return
                break
            case PI_F:
                //add return
                break
            case SQRT:
                //add return
                break
            case RAND:
                //add return
                break
            case ABS:
                //add return
                break
            case ROUND:
                //add return
                break
            case MOD:
                //add return
                break
            case ARCSIN:
                //add return
                break
            case ARCCOS:
                //add return
                break
            case ARCTAN:
                //add return
                break
            case EXP:
                //add return
                break
            case MAX:
                //add return
                break
            case MIN:
                //add return
                break
            case TRUE_F:
                //add return
                break
            case FALSE_F:
                //add return
                break
            case POW:
                //add return
                break
            case LETTER:
                //add return
                break
            case LENGTH:
                //add return
                break
            case JOIN:
                //add return
                break
            case ARDUINODIGITAL:
                //add return
                break
            case ARDUINOANALOG:
                //add return
                break
            case FLOOR:
                //add return
                break
            case CEIL:
                //add return
                break
            case NUMBEROFITEMS:
                //add return
                break
            case ELEMENT:
                //add return
                break
            case CONTAINS:
                //add return
                break
            case MULTI_FINGER_TOUCHED:
                //add return
                break
            case MULTI_FINGER_X:
                //add return
                break
            case MULTI_FINGER_Y:
                //add return
                break
            
            // PERIOD
            case DECIMAL_MARK:
                //add return
                break
            
            // OPERATOR
            
            case PLUS:
                //add return
                break
            case MINUS:
                //add return
                break
            case MULT:
                //add return
                break
            case DIVIDE:
                //add return
                break
            case EQUAL:
                //add return
                break
            case NOT_EQUAL:
                //add return
                break
            case SMALLER_THAN:
                //add return
                break
            case SMALLER_OR_EQUAL:
                //add return
                break
            case GREATER_THAN:
                //add return
                break
            case GREATER_OR_EQUAL:
                //add return
                break
            case LOGICAL_AND:
                //add return
                break
            case LOGICAL_OR:
                //add return
                break
            case LOGICAL_NOT:
                //add return
                break
            case BRACKET_OPEN:
                //add return
                break
            case BRACKET_CLOSE:
                //add return
                break
            
            default:
                return nil
                break
        }
    }
    
    func createInternTokenListBySensor(sensor: [CBSensor]) -> [CBSensor] {
        
    }
    
    func buildUserVariable(name: String) -> [] {
        
    }
    
    func buildUserList(name: String) -> [] {
        
    }
    
    func buildString(name: String) -> [] {
        
    }
    
    func buildNumber(numberValue: String) -> [] {
        
    }
    
    func buildSingleParameterFunction() -> [] {
        
    }
    
    func buildFunctionWithoutParametersAndBrackets() -> [] {
        
    }
    
    func buildDoubleParameterFunction() -> [] {
        
    }
    
    func buildPeriod() -> [] {
        
    }
    
    func buildBracketOpen() -> [] {
        
    }
    
    func buildBracketClose() -> [] {
        
    }
    
    func buildOperator(operator: Operator) -> [] {
        
    }

    func buildSensor(sensor: CBSensor) -> [] {
        
    }
    
    func buildSingleParameterSensor(sensor: Any, firstParameterType: String) -> [] {
        
    }
}
