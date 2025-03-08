/**
 *  Copyright (C) 2010-2024 The Catrobat Team
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

extension InternFormula {

    @objc func createInternTokenListByResourceId(resource: Int, name: String) -> [InternToken] {
        // USER VARIABLES
        if resource == 0 && !name.isEmpty {
            return buildUserVariable(name: name)
        }

        // USER LISTS
        if resource == 11 && !name.isEmpty {
            return buildUserList(name: name)
        }

        // STRING
        if resource == TOKEN_TYPE_STRING.rawValue {
            return buildString(name: name)
        }

        switch resource {
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

        // PERIOD
        case Int(TOKEN_TYPE_DECIMAL_MARK.rawValue):
            return buildPeriod()

        // BRACKETS
        case Int(BRACKET_OPEN.rawValue):
            return buildBracketOpen()
        case Int(BRACKET_CLOSE.rawValue):
            return buildBracketClose()

        default:
            return []
        }
    }

    func handleKeyInput(for sensor: Sensor) {
        let keyInputInternTokenList = NSMutableArray(array: self.createInternTokenListForSensor(sensor: sensor))
        self.handleKeyInput(withInternTokenList: keyInputInternTokenList, andResourceId: Int32(TOKEN_TYPE_SENSOR.rawValue))
    }

    func handleKeyInput(for function: Function) {
        let keyInputInternTokenList = NSMutableArray(array: self.createInternTokenListForFunction(function: function))
        self.handleKeyInput(withInternTokenList: keyInputInternTokenList, andResourceId: Int32(TOKEN_TYPE_FUNCTION_NAME.rawValue))
    }

    func handleKeyInput(for op: Operator) {
        let keyInputInternTokenList = NSMutableArray(array: self.createInternTokenListForOperator(op: op))
        self.handleKeyInput(withInternTokenList: keyInputInternTokenList, andResourceId: Int32(TOKEN_TYPE_OPERATOR.rawValue))
    }

    private func createInternTokenListForSensor(sensor: Sensor) -> [InternToken] {
        buildSensor(sensor: sensor)
    }

    private func createInternTokenListForFunction(function: Function) -> [InternToken] {
        buildFunction(function: function)
    }

    private func createInternTokenListForOperator(op: Operator) -> [InternToken] {
        buildOperator(op: op)
    }

    private func buildUserVariable(name: String) -> [InternToken] {
        [InternToken.init(type: TOKEN_TYPE_USER_VARIABLE, andValue: name)]
    }

    private func buildUserList(name: String) -> [InternToken] {
        [InternToken.init(type: TOKEN_TYPE_USER_LIST, andValue: name)]
    }

    private func buildString(name: String) -> [InternToken] {
        [InternToken.init(type: TOKEN_TYPE_STRING, andValue: name)]
    }

    private func buildNumber(numberValue: String) -> [InternToken] {
        [InternToken.init(type: TOKEN_TYPE_NUMBER, andValue: numberValue)]
    }

    private func buildPeriod() -> [InternToken] {
        [InternToken.init(type: TOKEN_TYPE_PERIOD)]
    }

    private func buildBracketOpen() -> [InternToken] {
        [InternToken.init(type: TOKEN_TYPE_BRACKET_OPEN)]
    }

    private func buildBracketClose() -> [InternToken] {
        [InternToken.init(type: TOKEN_TYPE_BRACKET_CLOSE)]
    }

    private func buildOperator(op: Operator) -> [InternToken] {
        [InternToken.init(type: TOKEN_TYPE_OPERATOR, andValue: type(of: op).tag)]
    }

    private func buildSensor(sensor: Sensor) -> [InternToken] {
        [InternToken.init(type: TOKEN_TYPE_SENSOR, andValue: sensor.tag())]
    }

    private func buildFunction(function: Function) -> [InternToken] {
        var tokenList = [InternToken]()
        let parameters = function.parameters()
        var count = 0

        tokenList.append(InternToken.init(type: TOKEN_TYPE_FUNCTION_NAME, andValue: function.tag()))
        if parameters.isEmpty {
            return tokenList    // no parameter
        }

        tokenList.append(InternToken.init(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN))
        for parameter in parameters {
            tokenList.append(functionParameter(parameter: parameter))
            count += 1

            if count < parameters.count && parameters.count > 1 {
                tokenList.append(InternToken.init(type: TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER))
            }
        }

        tokenList.append(InternToken.init(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE))
        return tokenList
    }

    private func functionParameter(parameter: FunctionParameter) -> InternToken {
        let defaultValueString = parameter.defaultValueString()

        switch parameter {
        case .number:
            return InternToken.init(type: TOKEN_TYPE_NUMBER, andValue: defaultValueString)
        case .string:
            return InternToken.init(type: TOKEN_TYPE_STRING, andValue: defaultValueString)
        case .list:
            return InternToken.init(type: TOKEN_TYPE_USER_LIST, andValue: defaultValueString)
        }
    }
}
