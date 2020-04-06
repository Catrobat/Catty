/**
 *  Copyright (C) 2010-2020 The Catrobat Team
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

class RegularFunction: DoubleParameterStringFunction {
    static var tag = "REGEX"
    static var name = "regex"
    static var defaultValue = ""
    static var requiredResource = ResourceType.noResources
    static var isIdempotent = true
    static let position = 85

    func tag() -> String {
        return type(of: self).tag
    }

    func firstParameter() -> FunctionParameter {
        return .string(defaultValue: " an? ([^ .]+)")
    }

    func secondParameter() -> FunctionParameter {
        return .string(defaultValue: "I am a panda")
    }

    func value(firstParameter: AnyObject?, secondParameter: AnyObject?) -> String {
        let pattern = type(of: self).interpretParameter(parameter: firstParameter)
        let longText = type(of: self).interpretParameter(parameter: secondParameter)

        return self.regularExpression(pattern: pattern, longText: longText)
    }

    func formulaEditorSections() -> [FormulaEditorSection] {
        return [.math(position: type(of: self).position)]
    }

    func regularExpression(pattern: String, longText: String) -> String {
        var finalResult: String?
        let regexOptions: NSRegularExpression.Options = []
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: regexOptions)
            let match = regex.firstMatch(in: longText, range: NSRange(0..<longText.utf16.count))
            if match != nil {
                if isParenthesesGroupPresent(in: pattern) {
                    //parenthesesGroup present
                    let firstParenthesssRange = match!.range(at: 1)
                    finalResult = firstParenthesssRange.location != NSNotFound ? (longText as NSString).substring(with: firstParenthesssRange) : nil
                } else {
                    //parenthesesGroup not present
                    match.map {
                        finalResult = String(longText[Range($0.range, in: longText)!])
                    }
                }
            }
        } catch {
            //Invalid pattern
            finalResult = error.localizedDescription
        }

        if finalResult == nil {
            //pattern did not match
            finalResult = RegularFunction.defaultValue
        }
        return finalResult!
    }

}

extension RegularFunction {
    //For all private function , variable
   private enum SkipElement: String {
        case openParenthesis = "("
        case closedParenthesis = ")"
    }

  private func isParenthesesGroupPresent(in pattern: String) -> Bool {
    //function to check if parentheses group is present or not 
       for eachChar in pattern {
           if String(eachChar) == SkipElement.openParenthesis.rawValue {
               return true
           }
       }
       return false
   }
}
