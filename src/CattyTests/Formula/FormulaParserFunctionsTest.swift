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

import XCTest

@testable import Pocket_Code

final class FormulaParserFunctionsTest: XCTestCase {
    var formulaManager: FormulaManager?
    var spriteObject: SpriteObject?

    override func setUp() {
        super.setUp()
        formulaManager = FormulaManager(sceneSize: Util.screenSize(true))
        spriteObject = SpriteObject()
    }

    func testSin() {
        // TODO use Function property
        let formula = getFormula("SIN", value: "90")
        XCTAssertNotNil(formula, "Formula is not parsed correctly: sin(90)")
        XCTAssertEqual(1, formulaManager?.interpretDouble(formula!, for: spriteObject!), "Formula interpretation is not as expected")
    }

    func testCos() {
        // TODO use Function property
        let formula = getFormula("COS", value: "180")
        XCTAssertNotNil(formula, "Formula is not parsed correctly: cos(180)")
        XCTAssertEqual(-1, formulaManager?.interpretDouble(formula!, for: spriteObject!), "Formula interpretation is not as expected")
    }

    func testTan() {
        // TODO use Function property
        let formula = getFormula("TAN", value: "180")
        XCTAssertNotNil(formula, "Formula is not parsed correctly: tan(180)")
        XCTAssertEqual(0, (formulaManager?.interpretDouble(formula!, for: spriteObject!))!, accuracy: Double.epsilon, "Formula interpretation is not as expected")
    }

    func testLn() {
        // TODO use Function property
        let formula = getFormula("LN", value: "2.7182818")
        XCTAssertNotNil(formula, "Formula is not parsed correctly: ln(e)")
        XCTAssertEqual(1, (formulaManager?.interpretDouble(formula!, for: spriteObject!))!, accuracy: Double.epsilon, "Formula interpretation is not as expected")
    }

    func testLog() {
        // TODO use Function property
        let formula = getFormula("LOG", value: "10")
        XCTAssertNotNil(formula, "Formula is not parsed correctly: log(10)")
        XCTAssertEqual(1, formulaManager?.interpretDouble(formula!, for: spriteObject!), "Formula interpretation is not as expected")
    }

    func testPi() {
        // TODO use Function property
        let internTokenList = NSMutableArray()
        internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: "PI"))

        let internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        let parseTree: FormulaElement? = internParser!.parseFormula(for: nil)

        XCTAssertNotNil(parseTree, "Formula is not parsed correctly: pi")

        let formula = Formula(formulaElement: parseTree)
        XCTAssertEqual(.pi, formulaManager?.interpretDouble(formula!, for: spriteObject!), "Formula interpretation is not as expected")
    }

    func testSqrt() {
        // TODO use Function property
        let formula = getFormula("SQRT", value: "100")
        XCTAssertNotNil(formula, "Formula is not parsed correctly: sqrt(100)")
        XCTAssertEqual(10, formulaManager?.interpretDouble(formula!, for: spriteObject!), "Formula interpretation is not as expected")
    }

    func testExp() {
        // TODO use Function property
        let formula = getFormula("EXP", value: "3")
        XCTAssertNotNil(formula, "Formula is not parsed correctly: exp(0)")
        XCTAssertEqual(20.08, (formulaManager?.interpretDouble(formula!, for: spriteObject!))!, accuracy: 0.1, "Formula interpretation is not as expected")
    }

    func testRandomNaturalNumbers() {
        // TODO use Function property
        let internTokenList = NSMutableArray()
        internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: "RAND"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "0"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE))

        let internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        let parseTree: FormulaElement? = internParser!.parseFormula(for: nil)

        XCTAssertNotNil(parseTree, "Formula is not parsed correctly: random(0,1)")

        let formula = Formula(formulaElement: parseTree)
        let result = formulaManager?.interpretDouble(formula!, for: spriteObject!)
        XCTAssertTrue(result == 0 || result == 1, "Formula interpretation is not as expected")
    }

    func testRound() {
        let formula = getFormula("ROUND", value: "1.33333")
        XCTAssertNotNil(formula, "Formula is not parsed correctly: round(1.33333)")
        XCTAssertEqual(1, formulaManager?.interpretDouble(formula!, for: spriteObject!), "Formula interpretation is not as expected")
    }

    func testMod() {
        for offset in 0..<10 {
            let dividend: Int = 1 + offset
            let divisor: Int = 1 + offset

            let internTokenList = NSMutableArray()
            internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: "MOD"))
            internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN))
            internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: String(format: "%i", dividend)))
            internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER))
            internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: String(format: "%i", divisor)))
            internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE))

            let internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
            let parseTree: FormulaElement? = internParser!.parseFormula(for: nil)

            XCTAssertNotNil(parseTree, String(format: "Formula is not parsed correctly: mod(%i, %i)", dividend, divisor))

            let formula = Formula(formulaElement: parseTree)
            XCTAssertEqual(0, (formulaManager?.interpretDouble(formula!, for: spriteObject!))!, accuracy: Double.epsilon, "Formula interpretation is not as expected")
        }

        var offset = 0
        while offset < 100 {
            let dividend: Int = 3 + offset
            let divisor: Int = 2 + offset

            let internTokenList = NSMutableArray()
            internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: "MOD"))
            internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN))
            internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: String(format: "%i", dividend)))
            internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER))
            internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: String(format: "%i", divisor)))
            internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE))

            let internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
            let parseTree: FormulaElement? = internParser!.parseFormula(for: nil)

            XCTAssertNotNil(parseTree, String(format: "Formula is not parsed correctly: mod(%i, %i)", dividend, divisor))

            let formula = Formula(formulaElement: parseTree)
            XCTAssertEqual(Double(1), (formulaManager?.interpretDouble(formula!, for: spriteObject!))!, accuracy: Double.epsilon, "Formula interpretation is not as expected")
            offset += 2
        }

        for offset in 0..<10 {
            let dividend: Int = 3 + offset
            let divisor: Int = 5 + offset

            let internTokenList = NSMutableArray()
            internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: "MOD"))
            internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN))
            internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: String(format: "%i", dividend)))
            internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER))
            internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: String(format: "%i", divisor)))
            internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE))

            let internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
            let parseTree: FormulaElement? = internParser!.parseFormula(for: nil)

            XCTAssertNotNil(parseTree, String(format: "Formula is not parsed correctly: mod(%i, %i)", dividend, divisor))

            let formula = Formula(formulaElement: parseTree)
            XCTAssertEqual(Double(dividend), (formulaManager?.interpretDouble(formula!, for: spriteObject!))!, accuracy: Double.epsilon, "Formula interpretation is not as expected")
        }

        for offset in 0..<10 {
            let dividend: Int = -3 - offset
            let divisor: Int = 2 + offset

            var internTokenList: [AnyHashable] = []
            internTokenList.append(InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: "MOD"))
            internTokenList.append(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN))
            internTokenList.append(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.MINUS)))
            internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: String(format: "%i", abs(dividend))))
            internTokenList.append(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER))
            internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: String(format: "%i", divisor)))
            internTokenList.append(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE))

            let internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
            let parseTree: FormulaElement? = internParser!.parseFormula(for: nil)

            XCTAssertNotNil(parseTree, String(format: "Formula is not parsed correctly: mod(%i, %i)", dividend, divisor))

            let formula = Formula(formulaElement: parseTree)
            XCTAssertEqual(Double(1 + offset), (formulaManager?.interpretDouble(formula!, for: spriteObject!))!, accuracy: Double.epsilon, "Formula interpretation is not as expected")
        }
    }

    func testAbs() {
        let internTokenList = NSMutableArray()
        internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: "ABS"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN))
        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.MINUS)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE))

        let internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        let parseTree: FormulaElement? = internParser!.parseFormula(for: nil)

        XCTAssertNotNil(parseTree, "Formula is not parsed correctly: abs(-1)")

        let formula = Formula(formulaElement: parseTree)
        XCTAssertEqual(1, formulaManager?.interpretDouble(formula!, for: spriteObject!), "Formula interpretation is not as expected")
    }

    func testInvalidFunction() {
        let internTokenList = NSMutableArray()
        internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: "INVALID_FUNCTION"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE))

        let internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        let parseTree: FormulaElement? = internParser!.parseFormula(for: nil)

        XCTAssertNil(parseTree, "Formula parsed but should not: INVALID_FUNCTION(1)")
        XCTAssertEqual(0, internParser!.errorTokenIndex, "Formula error value is not as expected")
    }

    func testTrue() {
        let internTokenList = NSMutableArray()
        internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: "TRUE"))

        let internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        let parseTree: FormulaElement? = internParser!.parseFormula(for: nil)

        XCTAssertNotNil(parseTree, "Formula is not parsed correctly: true")

        let formula = Formula(formulaElement: parseTree)
        XCTAssertEqual(1.0, formulaManager?.interpretDouble(formula!, for: spriteObject!), "Formula interpretation is not as expected")
    }

    func testFalse() {
        let internTokenList = NSMutableArray()
        internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: "FALSE"))

        let internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        let parseTree: FormulaElement? = internParser!.parseFormula(for: nil)

        XCTAssertNotNil(parseTree, "Formula is not parsed correctly: false")

        let formula = Formula(formulaElement: parseTree)
        XCTAssertEqual(0.0, formulaManager?.interpretDouble(formula!, for: spriteObject!), "Formula interpretation is not as expected")
    }

    func testArcsin() {
        let formula = getFormula("ASIN", value: "1")
        XCTAssertNotNil(formula, "Formula is not parsed correctly: arcsin(1)")
        XCTAssertEqual(90, (formulaManager?.interpretDouble(formula!, for: spriteObject!))!, accuracy: Double.epsilon, "Formula interpretation is not as expected")
    }

    func testArccos() {
        let formula = getFormula("ACOS", value: "0")
        XCTAssertNotNil(formula, "Formula is not parsed correctly: arccos(0)")
        XCTAssertEqual(90, (formulaManager?.interpretDouble(formula!, for: spriteObject!))!, accuracy: Double.epsilon, "Formula interpretation is not as expected")
    }

    func testArctan() {
        let formula = getFormula("ATAN", value: "1")
        XCTAssertNotNil(formula, "Formula is not parsed correctly: arctan(1)")
        XCTAssertEqual(45, (formulaManager?.interpretDouble(formula!, for: spriteObject!))!, accuracy: Double.epsilon, "Formula interpretation is not as expected")
    }

    func testMax() {
        let internTokenList = NSMutableArray()
        internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: "MAX"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "3"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "4"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE))

        let internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        let parseTree: FormulaElement? = internParser!.parseFormula(for: nil)

        XCTAssertNotNil(parseTree, "Formula is not parsed correctly: max(3,4)")

        let formula = Formula(formulaElement: parseTree)
        XCTAssertEqual(4, formulaManager?.interpretDouble(formula!, for: spriteObject!), "Formula interpretation is not as expected")
    }

    func testMin() {
        let internTokenList = NSMutableArray()
        internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: "MIN"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "3"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "4"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE))

        let internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        let parseTree: FormulaElement? = internParser!.parseFormula(for: nil)

        XCTAssertNotNil(parseTree, "Formula is not parsed correctly: min(3,4)")

        let formula = Formula(formulaElement: parseTree)
        XCTAssertEqual(3, formulaManager?.interpretDouble(formula!, for: spriteObject!), "Formula interpretation is not as expected")
    }

    func getFormula(_ tag: String?, value: String?) -> Formula? {
        let internTokenList = NSMutableArray()
        internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: tag))
        internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: value))
        internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE))

        let internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        return Formula(formulaElement: internParser!.parseFormula(for: nil))
    }
}
