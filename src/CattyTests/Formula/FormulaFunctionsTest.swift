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

final class FormulaFunctionsTest: XCTestCase {

    var formulaManager: FormulaManager?
    var spriteObject: SpriteObject?

    override func setUp() {
        formulaManager = FormulaManager(sceneSize: Util.screenSize(true))
        spriteObject = SpriteObject()
    }

    func getFormulaForFunction(_ tag: String?, withLeftValue leftValue: String?, andRightValue rightValue: String?) -> Formula? {
        let leftElement = FormulaElement(type: "NUMBER", value: leftValue, leftChild: nil, rightChild: nil, parent: nil)
        var rightElement: FormulaElement?

        if rightValue != nil {
            rightElement = FormulaElement(type: "NUMBER", value: rightValue, leftChild: nil, rightChild: nil, parent: nil)
        }

        let formulaElement = FormulaElement(type: "FUNCTION", value: tag, leftChild: leftElement, rightChild: rightElement, parent: nil)

        let formula = Formula(formulaElement: formulaElement)
        return formula
    }

    func testSin() {
        // TODO use Function property
        var formula: Formula? = getFormulaForFunction("SIN", withLeftValue: "0", andRightValue: nil)
        XCTAssertEqual(0, (formulaManager?.interpretDouble(formula!, for: spriteObject!))!, accuracy: Double.epsilon, "Wrong result for sin(0)")

        formula = getFormulaForFunction("SIN", withLeftValue: "90", andRightValue: nil)
        XCTAssertEqual(1, (formulaManager?.interpretDouble(formula!, for: spriteObject!))!, accuracy: Double.epsilon, "Wrong result for sin(90)")

        formula = getFormulaForFunction("SIN", withLeftValue: "-90", andRightValue: nil)
        XCTAssertEqual(-1, (formulaManager?.interpretDouble(formula!, for: spriteObject!))!, accuracy: Double.epsilon, "Wrong result for sin(-90)")

        formula = getFormulaForFunction("SIN", withLeftValue: "180", andRightValue: nil)
        XCTAssertEqual(0, (formulaManager?.interpretDouble(formula!, for: spriteObject!))!, accuracy: Double.epsilon, "Wrong result for sin(180)")

        formula = getFormulaForFunction("SIN", withLeftValue: "-180", andRightValue: nil)
        XCTAssertEqual(0, (formulaManager?.interpretDouble(formula!, for: spriteObject!))!, accuracy: Double.epsilon, "Wrong result for sin(-180)")

        formula = getFormulaForFunction("SIN", withLeftValue: "360", andRightValue: nil)
        XCTAssertEqual(0, (formulaManager?.interpretDouble(formula!, for: spriteObject!))!, accuracy: Double.epsilon, "Wrong result for sin(360)")

        formula = getFormulaForFunction("SIN", withLeftValue: "750", andRightValue: nil)
        XCTAssertEqual(0.5, (formulaManager?.interpretDouble(formula!, for: spriteObject!))!, accuracy: Double.epsilon, "Wrong result for sin(750)")

        formula = getFormulaForFunction("SIN", withLeftValue: "-750", andRightValue: nil)
        XCTAssertEqual(-0.5, (formulaManager?.interpretDouble(formula!, for: spriteObject!))!, accuracy: Double.epsilon, "Wrong result for sin(-750)")
    }

    func testCos() {
        // TODO use Function property
        var formula: Formula? = getFormulaForFunction("COS", withLeftValue: "0", andRightValue: nil)
        XCTAssertEqual(1, (formulaManager?.interpretDouble(formula!, for: spriteObject!))!, accuracy: Double.epsilon, "Wrong result for cos(0)")

        formula = getFormulaForFunction("COS", withLeftValue: "90", andRightValue: nil)
        XCTAssertEqual(0, (formulaManager?.interpretDouble(formula!, for: spriteObject!))!, accuracy: Double.epsilon, "Wrong result for cos(90)")

        formula = getFormulaForFunction("COS", withLeftValue: "-90", andRightValue: nil)
        XCTAssertEqual(0, (formulaManager?.interpretDouble(formula!, for: spriteObject!))!, accuracy: Double.epsilon, "Wrong result for cos(-90)")

        formula = getFormulaForFunction("COS", withLeftValue: "180", andRightValue: nil)
        XCTAssertEqual(-1, (formulaManager?.interpretDouble(formula!, for: spriteObject!))!, accuracy: Double.epsilon, "Wrong result for cos(180)")

        formula = getFormulaForFunction("COS", withLeftValue: "-180", andRightValue: nil)
        XCTAssertEqual(-1, (formulaManager?.interpretDouble(formula!, for: spriteObject!))!, accuracy: Double.epsilon, "Wrong result for cos(-180)")

        formula = getFormulaForFunction("COS", withLeftValue: "360", andRightValue: nil)
        XCTAssertEqual(1, (formulaManager?.interpretDouble(formula!, for: spriteObject!))!, accuracy: Double.epsilon, "Wrong result for cos(360)")

        formula = getFormulaForFunction("COS", withLeftValue: "-360", andRightValue: nil)
        XCTAssertEqual(1, (formulaManager?.interpretDouble(formula!, for: spriteObject!))!, accuracy: Double.epsilon, "Wrong result for cos(-360)")

        formula = getFormulaForFunction("COS", withLeftValue: "750", andRightValue: nil)
        XCTAssertEqual(0.86602540378, (formulaManager?.interpretDouble(formula!, for: spriteObject!))!, accuracy: Double.epsilon, "Wrong result for cos(750)")

        formula = getFormulaForFunction("COS", withLeftValue: "-750", andRightValue: nil)
        XCTAssertEqual(0.86602540378, (formulaManager?.interpretDouble(formula!, for: spriteObject!))!, accuracy: Double.epsilon, "Wrong result for cos(-750)")
    }

    func testTan() {
        // TODO use Function property
        var formula: Formula? = getFormulaForFunction("TAN", withLeftValue: "0", andRightValue: nil)
        XCTAssertEqual(0, (formulaManager?.interpretDouble(formula!, for: spriteObject!))!, accuracy: Double.epsilon, "Wrong result for tan(0)")

        // for tan(90) see http://math.stackexchange.com/questions/536144/why-does-the-google-calculator-give-tan-90-degrees-1-6331779e16
        formula = getFormulaForFunction("TAN", withLeftValue: "90", andRightValue: nil)
        XCTAssertEqual(1.633123935319537 * pow(10, 16), (formulaManager?.interpretDouble(formula!, for: spriteObject!))!, accuracy: Double.epsilon, "Wrong result for tan(90)")
        //XCTAssertEqual(tan(1.57079637), [[formula interpretRecursiveForSprite:nil]doubleValue], accuracy: Double.epsilon, @"Wrong result for tan(90)");

        formula = getFormulaForFunction("TAN", withLeftValue: "-90", andRightValue: nil)
        XCTAssertEqual(-1.633123935319537 * pow(10, 16), (formulaManager?.interpretDouble(formula!, for: spriteObject!))!, accuracy: Double.epsilon, "Wrong result for tan(-90)")

        formula = getFormulaForFunction("TAN", withLeftValue: "180", andRightValue: nil)
        XCTAssertEqual(0, (formulaManager?.interpretDouble(formula!, for: spriteObject!))!, accuracy: Double.epsilon, "Wrong result for tan(180)")

        formula = getFormulaForFunction("TAN", withLeftValue: "-180", andRightValue: nil)
        XCTAssertEqual(0, (formulaManager?.interpretDouble(formula!, for: spriteObject!))!, accuracy: Double.epsilon, "Wrong result for tan(-180)")

        formula = getFormulaForFunction("TAN", withLeftValue: "360", andRightValue: nil)
        XCTAssertEqual(0, (formulaManager?.interpretDouble(formula!, for: spriteObject!))!, accuracy: Double.epsilon, "Wrong result for tan(360)")

        formula = getFormulaForFunction("TAN", withLeftValue: "-360", andRightValue: nil)
        XCTAssertEqual(0, (formulaManager?.interpretDouble(formula!, for: spriteObject!))!, accuracy: Double.epsilon, "Wrong result for tan(-360)")

        formula = getFormulaForFunction("TAN", withLeftValue: "750", andRightValue: nil)
        XCTAssertEqual(0.57735026919, (formulaManager?.interpretDouble(formula!, for: spriteObject!))!, accuracy: Double.epsilon, "Wrong result for tan(750)")

        formula = getFormulaForFunction("TAN", withLeftValue: "-750", andRightValue: nil)
        XCTAssertEqual(-0.57735026919, (formulaManager?.interpretDouble(formula!, for: spriteObject!))!, accuracy: Double.epsilon, "Wrong result for tan(-750)")
    }

    func testArcSin() {
        // TODO use Function property
        var formula: Formula? = getFormulaForFunction("ASIN", withLeftValue: "0", andRightValue: nil)
        XCTAssertEqual(0, (formulaManager?.interpretDouble(formula!, for: spriteObject!))!, accuracy: Double.epsilon, "Wrong result for arcsin(0)")

        let sin90 = sin(Util.degree(toRadians: 90))
        formula = getFormulaForFunction("ASIN", withLeftValue: "\(sin90)", andRightValue: nil)
        XCTAssertEqual(90, (formulaManager?.interpretDouble(formula!, for: spriteObject!))!, accuracy: Double.epsilon, "Wrong result for arcsin(sin(90))")

        let sinMinus90 = sin(Util.degree(toRadians: -90))
        formula = getFormulaForFunction("ASIN", withLeftValue: "\(sinMinus90)", andRightValue: nil)
        XCTAssertEqual(-90, (formulaManager?.interpretDouble(formula!, for: spriteObject!))!, accuracy: Double.epsilon, "Wrong result for arcsin(sin(-90))")

        formula = getFormulaForFunction("ASIN", withLeftValue: "1.5", andRightValue: nil)
        let result = formulaManager?.interpretDouble(formula!, for: spriteObject!)
        XCTAssertTrue((result?.isNaN)!, "Wrong result for arcsin(1.5)")
    }

    func testArcCos() {
        // TODO use Function property
        var formula: Formula? = getFormulaForFunction("ACOS", withLeftValue: "0", andRightValue: nil)
        XCTAssertEqual(90, (formulaManager?.interpretDouble(formula!, for: spriteObject!))!, accuracy: Double.epsilon, "Wrong result for arccos(0)")

        formula = getFormulaForFunction("ACOS", withLeftValue: "1", andRightValue: nil)
        XCTAssertEqual(0, (formulaManager?.interpretDouble(formula!, for: spriteObject!))!, accuracy: Double.epsilon, "Wrong result for arccos(1)")

        formula = getFormulaForFunction("ACOS", withLeftValue: "-1", andRightValue: nil)
        XCTAssertEqual(180, (formulaManager?.interpretDouble(formula!, for: spriteObject!))!, accuracy: Double.epsilon, "Wrong result for arccos(-1)")

        let cos90 = cos(Util.degree(toRadians: 90))
        formula = getFormulaForFunction("ACOS", withLeftValue: "\(cos90)", andRightValue: nil)
        XCTAssertEqual(90, (formulaManager?.interpretDouble(formula!, for: spriteObject!))!, accuracy: Double.epsilon, "Wrong result for arccos(cos(90))")

        let cos180 = cos(Util.degree(toRadians: 180))
        formula = getFormulaForFunction("ACOS", withLeftValue: "\(cos180)", andRightValue: nil)
        XCTAssertEqual(180, (formulaManager?.interpretDouble(formula!, for: spriteObject!))!, accuracy: Double.epsilon, "Wrong result for arccos(cos(180))")

        formula = getFormulaForFunction("ACOS", withLeftValue: "1.5", andRightValue: nil)
        let result = formulaManager?.interpretDouble(formula!, for: spriteObject!)
        XCTAssertTrue((result?.isNaN)!, "Wrong result for arccos(1.5)")
    }

    func testArcTan() {
        // TODO use Function property
        var formula: Formula? = getFormulaForFunction("ATAN", withLeftValue: "0", andRightValue: nil)
        XCTAssertEqual(0, (formulaManager?.interpretDouble(formula!, for: spriteObject!))!, accuracy: Double.epsilon, "Wrong result for arctan(0)")

        let tan60 = tan(Util.degree(toRadians: 60))
        formula = getFormulaForFunction("ATAN", withLeftValue: "\(tan60)", andRightValue: nil)
        XCTAssertEqual(60, (formulaManager?.interpretDouble(formula!, for: spriteObject!))!, accuracy: Double.epsilon, "Wrong result for arctan(tan(60))")

        let tanMinus60 = tan(Util.degree(toRadians: -60))
        formula = getFormulaForFunction("ATAN", withLeftValue: "\(tanMinus60)", andRightValue: nil)
        XCTAssertEqual(-60, (formulaManager?.interpretDouble(formula!, for: spriteObject!))!, accuracy: Double.epsilon, "Wrong result for arctan(tan(-60))")
    }
}
