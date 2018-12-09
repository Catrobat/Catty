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

final class FormulaParserTest: XCTestCase {
    var formulaManager: FormulaManager?
    var object: SpriteObject?

    override func setUp() {
        super.setUp()
        formulaManager = FormulaManager(sceneSize: Util.screenSize(true))
        object = SpriteObject()
    }

    func testNumbers() {
        let internTokenList = NSMutableArray()
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1.0"))

        var internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        var parseTree: FormulaElement? = internParser!.parseFormula(for: nil)
        XCTAssertNotNil(parseTree, "Formula is not parsed correctly: 1.0")

        var formula = Formula(formulaElement: parseTree)
        XCTAssertEqual(1.0, formulaManager?.interpretDouble(formula!, for: object!))
        internTokenList.removeAllObjects()

        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))

        internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        parseTree = internParser!.parseFormula(for: nil)
        XCTAssertNotNil(parseTree, "Formula is not parsed correctly: 1")

        formula = Formula(formulaElement: parseTree)
        XCTAssertEqual(1.0, formulaManager?.interpretDouble(formula!, for: object!))
        internTokenList.removeAllObjects()

        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: ""))

        internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        parseTree = internParser!.parseFormula(for: nil)

        XCTAssertNil(parseTree, "Formula is not parsed correctly: <empty number> {}")
        XCTAssertEqual(0, internParser!.errorTokenIndex, "Parser error value not as expected")
        internTokenList.removeAllObjects()

        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "."))

        internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        parseTree = internParser!.parseFormula(for: nil)

        XCTAssertNil(parseTree, "Formula is not parsed correctly: .")
        XCTAssertEqual(0, internParser!.errorTokenIndex, "Parser error value not as expected")
        internTokenList.removeAllObjects()

        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: ".1"))

        internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        parseTree = internParser!.parseFormula(for: nil)

        XCTAssertNil(parseTree, "Formula is not parsed correctly: .1")
        XCTAssertEqual(0, internParser!.errorTokenIndex, "Parser error value not as expected")
        internTokenList.removeAllObjects()
    }

    func testLogicalOperators() {
        let internTokenList = NSMutableArray()
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "2"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.GREATER_THAN)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))

        var internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        var parseTree: FormulaElement? = internParser!.parseFormula(for: nil)
        XCTAssertNotNil(parseTree, "Formula is not parsed correctly: 2 > 1")

        var formula = Formula(formulaElement: parseTree)
        XCTAssertEqual(1.0, formulaManager?.interpretDouble(formula!, for: object!))
        internTokenList.removeAllObjects()

        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.GREATER_THAN)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))

        internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        parseTree = internParser!.parseFormula(for: nil)
        XCTAssertNotNil(parseTree, "Formula is not parsed correctly: 1 > 1")

        formula = Formula(formulaElement: parseTree)
        XCTAssertEqual(0.0, formulaManager?.interpretDouble(formula!, for: object!))
        internTokenList.removeAllObjects()

        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.GREATER_OR_EQUAL)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))

        internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        parseTree = internParser!.parseFormula(for: nil)
        XCTAssertNotNil(parseTree, "Formula is not parsed correctly: 1 >= 1")

        formula = Formula(formulaElement: parseTree)
        XCTAssertEqual(1.0, formulaManager?.interpretDouble(formula!, for: object!))
        internTokenList.removeAllObjects()

        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.GREATER_OR_EQUAL)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "2"))

        internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        parseTree = internParser!.parseFormula(for: nil)
        XCTAssertNotNil(parseTree, "Formula is not parsed correctly: 1 >= 2")

        formula = Formula(formulaElement: parseTree)
        XCTAssertEqual(0.0, formulaManager?.interpretDouble(formula!, for: object!))
        internTokenList.removeAllObjects()

        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.SMALLER_THAN)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "2"))

        internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        parseTree = internParser!.parseFormula(for: nil)
        XCTAssertNotNil(parseTree, "Formula is not parsed correctly: 1 < 2")

        formula = Formula(formulaElement: parseTree)
        XCTAssertEqual(1.0, formulaManager?.interpretDouble(formula!, for: object!))
        internTokenList.removeAllObjects()

        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.SMALLER_THAN)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))

        internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        parseTree = internParser!.parseFormula(for: nil)
        XCTAssertNotNil(parseTree, "Formula is not parsed correctly: 1 < 1")

        formula = Formula(formulaElement: parseTree)
        XCTAssertEqual(0.0, formulaManager?.interpretDouble(formula!, for: object!))
        internTokenList.removeAllObjects()

        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.SMALLER_OR_EQUAL)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))

        internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        parseTree = internParser?.parseFormula(for: nil)
        XCTAssertNotNil(parseTree, "Formula is not parsed correctly: 1 <= 1")

        formula = Formula(formulaElement: parseTree)
        XCTAssertEqual(1.0, formulaManager?.interpretDouble(formula!, for: object!))
        internTokenList.removeAllObjects()

        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "2"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.SMALLER_OR_EQUAL)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))

        internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        parseTree = internParser!.parseFormula(for: nil)
        XCTAssertNotNil(parseTree, "Formula is not parsed correctly: 2 <= 1")

        formula = Formula(formulaElement: parseTree)
        XCTAssertEqual(0.0, formulaManager?.interpretDouble(formula!, for: object!))
        internTokenList.removeAllObjects()

        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.EQUAL)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))

        internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        parseTree = internParser!.parseFormula(for: nil)
        XCTAssertNotNil(parseTree, "Formula is not parsed correctly: 1 = 1")

        formula = Formula(formulaElement: parseTree)
        XCTAssertEqual(1.0, formulaManager?.interpretDouble(formula!, for: object!))
        internTokenList.removeAllObjects()

        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "2"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.EQUAL)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))

        internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        parseTree = internParser!.parseFormula(for: nil)
        XCTAssertNotNil(parseTree, "Formula is not parsed correctly: 2 = 1")

        formula = Formula(formulaElement: parseTree)
        XCTAssertEqual(0.0, formulaManager?.interpretDouble(formula!, for: object!))
        internTokenList.removeAllObjects()

        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "2"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.NOT_EQUAL)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))

        internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        parseTree = internParser!.parseFormula(for: nil)
        XCTAssertNotNil(parseTree, "Formula is not parsed correctly: 2 != 1")

        formula = Formula(formulaElement: parseTree)
        XCTAssertEqual(1.0, formulaManager?.interpretDouble(formula!, for: object!))
        internTokenList.removeAllObjects()

        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.NOT_EQUAL)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))

        internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        parseTree = internParser!.parseFormula(for: nil)
        XCTAssertNotNil(parseTree, "Formula is not parsed correctly: 1 != 1")

        formula = Formula(formulaElement: parseTree)
        XCTAssertEqual(0.0, formulaManager?.interpretDouble(formula!, for: object!))
        internTokenList.removeAllObjects()

        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.LOGICAL_NOT)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "0"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.LOGICAL_AND)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))

        internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        parseTree = internParser!.parseFormula(for: nil)
        XCTAssertNotNil(parseTree, "Formula is not parsed correctly: NOT 0 AND 1")

        formula = Formula(formulaElement: parseTree)
        XCTAssertEqual(1.0, formulaManager?.interpretDouble(formula!, for: object!))
        internTokenList.removeAllObjects()

        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.LOGICAL_NOT)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.LOGICAL_AND)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "0"))

        internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        parseTree = internParser!.parseFormula(for: nil)
        XCTAssertNotNil(parseTree, "Formula is not parsed correctly: NOT 1 OR 0")

        formula = Formula(formulaElement: parseTree)
        XCTAssertEqual(0.0, formulaManager?.interpretDouble(formula!, for: object!))
        internTokenList.removeAllObjects()

        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.LOGICAL_NOT)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "0"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.LOGICAL_OR)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "0"))

        internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        parseTree = internParser!.parseFormula(for: nil)
        XCTAssertNotNil(parseTree, "Formula is not parsed correctly: NOT 0 OR 0")

        formula = Formula(formulaElement: parseTree)
        XCTAssertEqual(1.0, formulaManager?.interpretDouble(formula!, for: object!))
        internTokenList.removeAllObjects()

        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.LOGICAL_NOT)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "0"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.LOGICAL_AND)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "0"))

        internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        parseTree = internParser!.parseFormula(for: nil)
        XCTAssertNotNil(parseTree, "Formula is not parsed correctly: NOT 0 AND 0")

        formula = Formula(formulaElement: parseTree)
        XCTAssertEqual(0.0, formulaManager?.interpretDouble(formula!, for: object!))
        internTokenList.removeAllObjects()
    }

    func testUnaryMinus() {
        let internTokenList = NSMutableArray()
        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.MINUS)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "42.42"))

        let internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        let parseTree: FormulaElement? = internParser!.parseFormula(for: nil)
        XCTAssertNotNil(parseTree, "Formula is not parsed correctly: - 42.42")

        let formula = Formula(formulaElement: parseTree)
        XCTAssertEqual(-42.42, formulaManager?.interpretDouble(formula!, for: object!))
    }

    func testOperatorPriority() {
        let internTokenList = NSMutableArray()
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.MINUS)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "2"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.MULT)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "2"))

        let internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        let parseTree: FormulaElement? = internParser!.parseFormula(for: nil)
        XCTAssertNotNil(parseTree, "Formula is not parsed correctly:  1 - 2 x 2")

        let formula = Formula(formulaElement: parseTree)
        XCTAssertEqual(-3.0, formulaManager?.interpretDouble(formula!, for: object!))
    }

    func testOperatorLeftBinding() {
        var internTokenList = NSMutableArray()
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "5"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.MINUS)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "4"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.MINUS)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))

        var internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        var parseTree: FormulaElement? = internParser!.parseFormula(for: nil)
        XCTAssertNotNil(parseTree, "Formula is not parsed correctly:  5 - 4 - 1")

        var formula = Formula(formulaElement: parseTree)
        XCTAssertEqual(0.0, formulaManager?.interpretDouble(formula!, for: object!))

        internTokenList = NSMutableArray()
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "100"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.DIVIDE)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "10"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.DIVIDE)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "10"))

        internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        parseTree = internParser!.parseFormula(for: nil)
        XCTAssertNotNil(parseTree, "Formula is not parsed correctly:  100 ÷ 10 ÷ 10")

        formula = Formula(formulaElement: parseTree)
        XCTAssertEqual(1.0, formulaManager?.interpretDouble(formula!, for: object!))
    }

    func testOperatorChain() {
        let internTokenList = NSMutableArray()
        internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: "POW"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.PLUS)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "2"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.MULT)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "3"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "2"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE))
        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.PLUS)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))

        var internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        var parseTree: FormulaElement? = internParser!.parseFormula(for: nil)
        XCTAssertNotNil(parseTree, "Formula is not parsed correctly:  (1 + 2 × 3) ^ 2 + 1")

        var formula = Formula(formulaElement: parseTree)
        XCTAssertEqual(50.0, formulaManager?.interpretDouble(formula!, for: object!))

        internTokenList.removeAllObjects()
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.PLUS)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: "POW"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "2"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "3"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.MULT)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "2"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE))

        internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        parseTree = internParser!.parseFormula(for: nil)
        XCTAssertNotNil(parseTree, "Formula is not parsed correctly:  1 + 2 ^ (3 * 2)")

        formula = Formula(formulaElement: parseTree)
        XCTAssertEqual(65.0, formulaManager?.interpretDouble(formula!, for: object!))
    }

    func testBracket() {
        let internTokenList = NSMutableArray()
        internTokenList.add(InternToken(type: TOKEN_TYPE_BRACKET_OPEN))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.PLUS)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "2"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_BRACKET_CLOSE))
        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.MULT)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_BRACKET_OPEN))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.PLUS)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "2"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_BRACKET_CLOSE))

        var internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        var parseTree: FormulaElement? = internParser!.parseFormula(for: nil)
        XCTAssertNotNil(parseTree, "Formula is not parsed correctly:  (1+2) x (1+2)")

        var formula = Formula(formulaElement: parseTree)
        XCTAssertEqual(9.0, formulaManager?.interpretDouble(formula!, for: object!))

        internTokenList.removeAllObjects()
        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.MINUS)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_BRACKET_OPEN))
        internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: "POW"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "2"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE))
        internTokenList.add(InternToken(type: TOKEN_TYPE_BRACKET_CLOSE))
        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.MINUS)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.MINUS)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_BRACKET_OPEN))
        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.MINUS)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.MINUS)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.MINUS)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "2"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_BRACKET_CLOSE))

        internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        parseTree = internParser!.parseFormula(for: nil)
        XCTAssertNotNil(parseTree, "Formula is not parsed correctly:  -(1^2)--(-1--2)")

        formula = Formula(formulaElement: parseTree)
        XCTAssertEqual(0.0, formulaManager?.interpretDouble(formula!, for: object!))
    }

    func testEmptyInput() {
        let internTokenList = NSMutableArray()
        let internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        let parseTree: FormulaElement? = internParser!.parseFormula(for: nil)

        XCTAssertNil(parseTree, "Formula is not parsed correctly: EMPTY FORMULA {}")
        XCTAssertEqual(FORMULA_PARSER_NO_INPUT, FormulaParserStatus(rawValue: internParser!.errorTokenIndex), "Formula error value not as expected")
    }

    func testFuctionalAndSimpleBracketsCorrection() {
        let internTokenList = NSMutableArray()
        internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: "ABS"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "2"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.MULT)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_BRACKET_OPEN))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "5"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.MINUS)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "10"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE))
        internTokenList.add(InternToken(type: TOKEN_TYPE_BRACKET_CLOSE))

        var internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        var parseTree: FormulaElement? = internParser!.parseFormula(for: nil)
        XCTAssertNotNil(parseTree, "Formula is not parsed correctly: abs(2 * (5 - 10))")

        var formula = Formula(formulaElement: parseTree)
        XCTAssertEqual(10.0, formulaManager?.interpretDouble(formula!, for: object!))

        internTokenList.removeAllObjects()
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "3"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.MULT)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_BRACKET_OPEN))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "2"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.PLUS)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: "COS"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "0"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_BRACKET_CLOSE))
        internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE))

        internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        parseTree = internParser!.parseFormula(for: nil)
        XCTAssertNotNil(parseTree, "Formula is not parsed correctly: 3 * (2 + cos(0)) ")

        formula = Formula(formulaElement: parseTree)
        XCTAssertEqual(9.0, formulaManager?.interpretDouble(formula!, for: object!))

        internTokenList.removeAllObjects()
        internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: "MOD"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER))
        internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: "MOD"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER))
        internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: "MOD"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "5"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER))
        internTokenList.add(InternToken(type: TOKEN_TYPE_BRACKET_OPEN))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "3"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE))
        internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE))
        internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE))
        internTokenList.add(InternToken(type: TOKEN_TYPE_BRACKET_CLOSE))

        internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        parseTree = internParser!.parseFormula(for: nil)
        XCTAssertNotNil(parseTree, "Formula is not parsed correctly: mod( 1 , mod( 1 , mod( 5 , ( 3 )))) ")

        formula = Formula(formulaElement: parseTree)
        XCTAssertEqual(0.0, formulaManager?.interpretDouble(formula!, for: object!))
    }
}
