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
    static var defaultValue = "panda"
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

        let result = self.regularExpression(pattern: pattern, longText: longText)

        print("result", result)

        return result
    }

    func formulaEditorSections() -> [FormulaEditorSection] {
        return [.math(position: type(of: self).position)]
    }

    func regularExpression(pattern: String, longText: String) -> String {
        var resultString: String?

        let finalCompleteMatch = checkForComplete(pattern: pattern, inText: longText)
        if finalCompleteMatch == nil || (((finalCompleteMatch?.isEmpty) != nil) && (finalCompleteMatch!.isEmpty)) {
            if finalCompleteMatch == nil {
                //Invalid regex
                self.getErrorMessage(fromPatten: pattern) { (errorMessage) in
                    resultString = errorMessage
                }
            } else if finalCompleteMatch!.isEmpty {
                //no match found
                resultString = ""
            }
        } else {
            let eachGroup = getEachGroup(fromRegex: pattern)
            if !eachGroup.isEmpty {
                //Parenthesis group found
                if pattern.first != nil && String(pattern.first!) == SkipElement.openParenthesis.rawValue {
                    //patten strats with parenthesis
                    resultString = findInRegexStratingWithParenthesis(havingPattern: pattern, andText: longText)
                } else {
                    //patten does not  strats with parenthesis

                    var patternBeforeFirstParenthesis: String?
                    var patternAfterFirstParenthesis: String?
                    var textBeforeFirstparenthesis: String?
                    var completeMatchedText: String?

                    for eachChar in pattern {
                        if String(eachChar) != SkipElement.openParenthesis.rawValue && patternAfterFirstParenthesis == nil {
                            //extracting the regex befor first parenthesis
                            if patternBeforeFirstParenthesis == nil {
                                patternBeforeFirstParenthesis = String(eachChar)
                            } else {
                                patternBeforeFirstParenthesis! += String(eachChar)
                            }
                        } else {
                            //extracting the regex after and including first parenthesis
                            if String(eachChar) == SkipElement.openParenthesis.rawValue || patternAfterFirstParenthesis != nil {
                                if patternAfterFirstParenthesis == nil {
                                    patternAfterFirstParenthesis = String(eachChar)
                                } else {
                                    patternAfterFirstParenthesis! += String(eachChar)
                                }
                            }
                        }
                    }

                     textBeforeFirstparenthesis = checkForFirstGroup(withPattern: patternBeforeFirstParenthesis!, inTest: finalCompleteMatch!)
                     completeMatchedText = checkForComplete(pattern: pattern, inText: longText)

                    for eachChar in finalCompleteMatch! {
                        //removing the string before first parenthesis
                        if eachChar == textBeforeFirstparenthesis!.first {
                            completeMatchedText!.removeFirst()
                            textBeforeFirstparenthesis!.removeFirst()
                            if textBeforeFirstparenthesis!.isEmpty {
                                break
                            }
                            continue
                        }
                    }

                    resultString = findInRegexStratingWithParenthesis(havingPattern: patternAfterFirstParenthesis!, andText: completeMatchedText!)
                }
                if resultString == nil {
                    resultString = checkForFirstGroup(withPattern: pattern, inTest: longText)
                }
            } else {
                // no parenthesis found returning complete match
                resultString = finalCompleteMatch
            }
        }
        return resultString!
    }

}

extension RegularFunction {
    //For all private function , variable
   private enum SkipElement: String {
        case openParenthesis = "("
        case closedParenthesis = ")"
    }

   private func getEachGroup(fromRegex regex: String) -> [String] {
    //Function to extract each group from the pattern
        var isParanthesisStarted = false
        var eachGroup = [String]()
        var temp = ""

        for char in regex {
            if String(char) == SkipElement.openParenthesis.rawValue {
                isParanthesisStarted = true
            } else if String(char) == SkipElement.closedParenthesis.rawValue {
                isParanthesisStarted = false
            }

            if isParanthesisStarted || String(char) == SkipElement.closedParenthesis.rawValue {
                temp += String(char)
                if String(char) == SkipElement.closedParenthesis.rawValue {
                    eachGroup.append(temp)
                    temp.removeAll()
                }
            }
        }

        return eachGroup
    }

    private func getFirstParenthesisGroup(fromPattern pattern: String) -> String? {
        //Function to get the first group from the pattern
        let eachGroup = getEachGroup(fromRegex: pattern)

        if !eachGroup.isEmpty {
            return eachGroup.first
        } else {
            return nil
        }
    }

    private func checkForComplete(pattern: String, inText text: String) -> String? {
        //function to check the complete match of the pattern
        let regexOptions: NSRegularExpression.Options = []
        var finalResult: String?
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: regexOptions)

            let result = regex.matches(in: text, range: NSRange(location: 0, length: text.utf16.count))
            if !result.isEmpty {
                //matched with ful pattern
                result.map {
                    finalResult = String(text[Range($0.range, in: text)!])
                }
            } else {
                //did not matched
                finalResult = ""
            }
        } catch {
            //incorrect regex show error message
            print("invalid regex: \(error.localizedDescription)")
            finalResult = nil
        }
        return finalResult
    }

    private func checkForFirstGroup(withPattern pattern: String, inTest text: String) -> String? {
        //function to check the first match of the pattern
        var finalResult: String?
        let regexOptions: NSRegularExpression.Options = []

        do {
            let regex = try NSRegularExpression(pattern: pattern, options: regexOptions)
            let results = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text))
            results.map {
               finalResult = String(text[Range($0.range, in: text)!])
            }
        } catch {
            print("invalid regex: \(error.localizedDescription)")
            finalResult = nil
        }

        return finalResult
    }

    private func findInRegexStratingWithParenthesis(havingPattern pattern: String, andText text: String) -> String? {
        //function to find the first parenthesis group that matches
        let completeMatch = checkForFirstGroup(withPattern: pattern, inTest: text)//could be removed
        let firstParenthesisGroup = getFirstParenthesisGroup(fromPattern: pattern)
        if firstParenthesisGroup == nil {
            //only 1 parenthesis group found and nothing else
            return completeMatch
        }
        return checkForFirstGroup(withPattern: firstParenthesisGroup!, inTest: completeMatch!)
    }

    private func getErrorMessage(fromPatten pattern: String, completion:@escaping (String) -> Void) {
        //function to get the appropriate error message
        let regexOptions: NSRegularExpression.Options = []
        do {
            _ = try NSRegularExpression(pattern: pattern, options: regexOptions)
        } catch {
            completion(error.localizedDescription)
        }
    }

}
