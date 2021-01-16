/**
 *  Copyright (C) 2010-2021 The Catrobat Team
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

class RegularExpressionFunction: DoubleParameterStringFunction {
    static var tag = "REGEX"
    static var name = "regex"
    static var defaultValue = ""
    static var requiredResource = ResourceType.noResources
    static var isIdempotent = true
    static let position = 85

    func tag() -> String { type(of: self).tag }

    func firstParameter() -> FunctionParameter { .string(defaultValue: " an? ([^ .]+)") }

    func secondParameter() -> FunctionParameter { .string(defaultValue: "I am a panda") }

    func formulaEditorSections() -> [FormulaEditorSection] { [.math(position: type(of: self).position)] }

    func value(firstParameter: AnyObject?, secondParameter: AnyObject?) -> String {
        let pattern = type(of: self).interpretParameter(parameter: firstParameter)
        let longText = type(of: self).interpretParameter(parameter: secondParameter)

        return self.regularExpression(pattern: pattern, longText: longText)
    }

    func regularExpression(pattern: String, longText: String) -> String {
        var finalResult = RegularExpressionFunction.defaultValue
        let regexOptions: NSRegularExpression.Options = [.dotMatchesLineSeparators, .anchorsMatchLines]

        do {
            let regex = try NSRegularExpression(pattern: pattern, options: regexOptions)

            if let match = regex.firstMatch(in: longText, range: NSRange(0..<longText.utf16.count)) {
                var firstParenthesssRange = NSRange()
                if match.numberOfRanges > 1 {
                    firstParenthesssRange = match.range(at: 1)
                } else {
                    firstParenthesssRange = match.range(at: 0)
                }

                if firstParenthesssRange.location != NSNotFound {
                    finalResult = (longText as NSString).substring(with: firstParenthesssRange)
                }
            }
        } catch {
            finalResult = error.localizedDescription
        }
        return finalResult
    }

}
