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

import XCTest

@testable import Pocket_Code

final class FormulaFunctionsTest: XCTestCase {
    var formulaManager: FormulaManager!
    var spriteObject: SpriteObject!

    let EPSILON = Double.epsilon

    override func setUp() {
        let screenSize = Util.screenSize(true)
        formulaManager = FormulaManager(sceneSize: screenSize)
        spriteObject = SpriteObject()
    }

    func getFormulaForFunction(tag: String, leftValue: String, rightValue: String?) -> Formula {
        let leftElement = FormulaElement(elementType: ElementType.NUMBER, value: leftValue, leftChild: nil, rightChild: nil, parent: nil)
        var rightElement: FormulaElement?

        if let right = rightValue {
            rightElement = FormulaElement(elementType: ElementType.NUMBER, value: right, leftChild: nil, rightChild: nil, parent: nil)
        }

        let formulaElement = FormulaElement(elementType: ElementType.FUNCTION, value: tag, leftChild: leftElement, rightChild: rightElement, parent: nil)

        let formula: Formula! = Formula(formulaElement: formulaElement)
        return formula
    }

    func testSin() {
        var formula: Formula = getFormulaForFunction(tag: SinFunction.tag, leftValue: "0", rightValue: nil)
        XCTAssertEqual(0, formulaManager.interpretDouble(formula, for: spriteObject), accuracy: EPSILON)

        formula = getFormulaForFunction(tag: SinFunction.tag, leftValue: "90", rightValue: nil)
        XCTAssertEqual(1, formulaManager.interpretDouble(formula, for: spriteObject), accuracy: EPSILON)

        formula = getFormulaForFunction(tag: SinFunction.tag, leftValue: "-90", rightValue: nil)
        XCTAssertEqual(-1, formulaManager.interpretDouble(formula, for: spriteObject), accuracy: EPSILON)

        formula = getFormulaForFunction(tag: SinFunction.tag, leftValue: "180", rightValue: nil)
        XCTAssertEqual(0, formulaManager.interpretDouble(formula, for: spriteObject), accuracy: EPSILON)

        formula = getFormulaForFunction(tag: SinFunction.tag, leftValue: "-180", rightValue: nil)
        XCTAssertEqual(0, formulaManager.interpretDouble(formula, for: spriteObject), accuracy: EPSILON)

        formula = getFormulaForFunction(tag: SinFunction.tag, leftValue: "360", rightValue: nil)
        XCTAssertEqual(0, formulaManager.interpretDouble(formula, for: spriteObject), accuracy: EPSILON)

        formula = getFormulaForFunction(tag: SinFunction.tag, leftValue: "750", rightValue: nil)
        XCTAssertEqual(0.5, formulaManager.interpretDouble(formula, for: spriteObject), accuracy: EPSILON)

        formula = getFormulaForFunction(tag: SinFunction.tag, leftValue: "-750", rightValue: nil)
        XCTAssertEqual(-0.5, formulaManager.interpretDouble(formula, for: spriteObject), accuracy: EPSILON)
    }

    func testCos() {
        var formula: Formula = getFormulaForFunction(tag: CosFunction.tag, leftValue: "0", rightValue: nil)
        XCTAssertEqual(1, formulaManager.interpretDouble(formula, for: spriteObject), accuracy: EPSILON)

        formula = getFormulaForFunction(tag: CosFunction.tag, leftValue: "90", rightValue: nil)
        XCTAssertEqual(0, formulaManager.interpretDouble(formula, for: spriteObject), accuracy: EPSILON)

        formula = getFormulaForFunction(tag: CosFunction.tag, leftValue: "-90", rightValue: nil)
        XCTAssertEqual(0, formulaManager.interpretDouble(formula, for: spriteObject), accuracy: EPSILON)

        formula = getFormulaForFunction(tag: CosFunction.tag, leftValue: "180", rightValue: nil)
        XCTAssertEqual(-1, formulaManager.interpretDouble(formula, for: spriteObject), accuracy: EPSILON)

        formula = getFormulaForFunction(tag: CosFunction.tag, leftValue: "-180", rightValue: nil)
        XCTAssertEqual(-1, formulaManager.interpretDouble(formula, for: spriteObject), accuracy: EPSILON)

        formula = getFormulaForFunction(tag: CosFunction.tag, leftValue: "360", rightValue: nil)
        XCTAssertEqual(1, formulaManager.interpretDouble(formula, for: spriteObject), accuracy: EPSILON)

        formula = getFormulaForFunction(tag: CosFunction.tag, leftValue: "-360", rightValue: nil)
        XCTAssertEqual(1, formulaManager.interpretDouble(formula, for: spriteObject), accuracy: EPSILON)

        formula = getFormulaForFunction(tag: CosFunction.tag, leftValue: "750", rightValue: nil)
        XCTAssertEqual(0.86602540378, formulaManager.interpretDouble(formula, for: spriteObject), accuracy: EPSILON)

        formula = getFormulaForFunction(tag: CosFunction.tag, leftValue: "-750", rightValue: nil)
        XCTAssertEqual(0.86602540378, formulaManager.interpretDouble(formula, for: spriteObject), accuracy: EPSILON)
    }

    func testTan() {
        var formula: Formula = getFormulaForFunction(tag: TanFunction.tag, leftValue: "0", rightValue: nil)
        XCTAssertEqual(0, formulaManager.interpretDouble(formula, for: spriteObject), accuracy: EPSILON)

        // for tan(90) see http://math.stackexchange.com/questions/536144/why-does-the-google-calculator-give-tan-90-degrees-1-6331779e16
        formula = getFormulaForFunction(tag: TanFunction.tag, leftValue: "90", rightValue: nil)
        XCTAssertEqual(1.633123935319537 * pow(10, 16), formulaManager.interpretDouble(formula, for: spriteObject), accuracy: EPSILON)

        formula = getFormulaForFunction(tag: TanFunction.tag, leftValue: "-90", rightValue: nil)
        XCTAssertEqual(-1.633123935319537 * pow(10, 16), formulaManager.interpretDouble(formula, for: spriteObject), accuracy: EPSILON)

        formula = getFormulaForFunction(tag: TanFunction.tag, leftValue: "180", rightValue: nil)
        XCTAssertEqual(0, formulaManager.interpretDouble(formula, for: spriteObject), accuracy: EPSILON)

        formula = getFormulaForFunction(tag: TanFunction.tag, leftValue: "-180", rightValue: nil)
        XCTAssertEqual(0, formulaManager.interpretDouble(formula, for: spriteObject), accuracy: EPSILON)

        formula = getFormulaForFunction(tag: TanFunction.tag, leftValue: "360", rightValue: nil)
        XCTAssertEqual(0, formulaManager.interpretDouble(formula, for: spriteObject), accuracy: EPSILON)

        formula = getFormulaForFunction(tag: TanFunction.tag, leftValue: "-360", rightValue: nil)
        XCTAssertEqual(0, formulaManager.interpretDouble(formula, for: spriteObject), accuracy: EPSILON)

        formula = getFormulaForFunction(tag: TanFunction.tag, leftValue: "750", rightValue: nil)
        XCTAssertEqual(0.57735026919, formulaManager.interpretDouble(formula, for: spriteObject), accuracy: EPSILON)

        formula = getFormulaForFunction(tag: TanFunction.tag, leftValue: "-750", rightValue: nil)
        XCTAssertEqual(-0.57735026919, formulaManager.interpretDouble(formula, for: spriteObject), accuracy: EPSILON)
    }

    func testArcSin() {
        var formula: Formula = getFormulaForFunction(tag: AsinFunction.tag, leftValue: "0", rightValue: nil)
        XCTAssertEqual(0, formulaManager.interpretDouble(formula, for: spriteObject), accuracy: EPSILON)

        let sin90: Double = sin(Util.degree(toRadians: 90.0))
        formula = getFormulaForFunction(tag: AsinFunction.tag, leftValue: String.init(format: "%f", sin90), rightValue: nil)
        XCTAssertEqual(90, formulaManager.interpretDouble(formula, for: spriteObject), accuracy: EPSILON)

        let sinMinus90: Double = sin(Util.degree(toRadians: -90.0))
        formula = getFormulaForFunction(tag: AsinFunction.tag, leftValue: String.init(format: "%f", sinMinus90), rightValue: nil)
        XCTAssertEqual(-90, formulaManager.interpretDouble(formula, for: spriteObject), accuracy: EPSILON)

        formula = getFormulaForFunction(tag: AsinFunction.tag, leftValue: "1.5", rightValue: nil)
        let result: Double = formulaManager.interpretDouble(formula, for: spriteObject)
        XCTAssertTrue(result.isNaN)
    }

    func testArcCos() {
        var formula = getFormulaForFunction(tag: AcosFunction.tag, leftValue: "0", rightValue: nil)
        XCTAssertEqual(90, formulaManager.interpretDouble(formula, for: spriteObject), accuracy: EPSILON)

        formula = getFormulaForFunction(tag: AcosFunction.tag, leftValue: "1", rightValue: nil)
        XCTAssertEqual(0, formulaManager.interpretDouble(formula, for: spriteObject), accuracy: EPSILON)

        formula = getFormulaForFunction(tag: AcosFunction.tag, leftValue: "-1", rightValue: nil)
        XCTAssertEqual(180, formulaManager.interpretDouble(formula, for: spriteObject), accuracy: EPSILON)

        let cos90: Double = cos(Util.degree(toRadians: 90.0))
        formula = getFormulaForFunction(tag: AcosFunction.tag, leftValue: String.init(format: "%f", cos90), rightValue: nil)
        XCTAssertEqual(90, formulaManager.interpretDouble(formula, for: spriteObject), accuracy: EPSILON)

        let cos180: Double = cos(Util.degree(toRadians: 180.0))
        formula = getFormulaForFunction(tag: AcosFunction.tag, leftValue: String.init(format: "%f", cos180), rightValue: nil)
        XCTAssertEqual(180, formulaManager.interpretDouble(formula, for: spriteObject), accuracy: EPSILON)

        formula = getFormulaForFunction(tag: AcosFunction.tag, leftValue: "1.5", rightValue: nil)
        let result: Double = formulaManager.interpretDouble(formula, for: spriteObject)
        XCTAssertTrue(result.isNaN)
    }

    func testArcTan() {
        var formula = getFormulaForFunction(tag: AtanFunction.tag, leftValue: "0", rightValue: nil)
        XCTAssertEqual(0, formulaManager.interpretDouble(formula, for: spriteObject), accuracy: EPSILON)

        let tan60: Double = tan(Util.degree(toRadians: 60.0))
        formula = getFormulaForFunction(tag: AtanFunction.tag, leftValue: String.init(format: "%f", tan60), rightValue: nil)
        XCTAssertEqual(60, formulaManager.interpretDouble(formula, for: spriteObject), accuracy: EPSILON)

        let tanMinus60: Double = tan(Util.degree(toRadians: -60.0))
        formula = getFormulaForFunction(tag: AtanFunction.tag, leftValue: String.init(format: "%f", tanMinus60), rightValue: nil)
        XCTAssertEqual(-60, formulaManager.interpretDouble(formula, for: spriteObject), accuracy: EPSILON)
    }
}
