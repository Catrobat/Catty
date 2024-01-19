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

import Nimble
import XCTest

@testable import Pocket_Code

final class BrickCellFormulaDataTests: XCTestCase {

    func testFormulaSavedNotification() {
        let formula = Formula(integer: 123)
        let expectedNotification = Notification(name: .formulaSaved, object: formula)

        let formulaData = BrickCellFormulaData()

        expect(formulaData.save(formula)).to(postNotifications(contain(expectedNotification)))
    }

    func testCalcMaxInputFormulaFrameLengthWithOneFormula() {
        let brickCell = BrickCell()
        brickCell.maxInputFormulaFrameLength = 0

        let partLabels = ["x: ", "y: ", ""]
        let frame = CGRect(origin: CGPoint(x: 0, y: 30), size: CGSize(width: 321, height: 30))
        let params = ["{FLOAT;range=(-inf,inf)}", ""]

        XCTAssertEqual(brickCell.maxInputFormulaFrameLength, 0)

        brickCell.calcMaxInputFormulaFrameLength(partLabels, withFrame: frame, withParams: params)

        XCTAssertEqual(brickCell.maxInputFormulaFrameLength, 259, accuracy: 0.1)
    }

    func testCalcMaxInputFormulaFrameLengthWithTwoFormula() {
        let brickCell = BrickCell()
        brickCell.maxInputFormulaFrameLength = 0

        let partLabels = ["x: ", "y: ", ""]
        let frame = CGRect(origin: CGPoint(x: 0, y: 30), size: CGSize(width: 321, height: 30))
        let params = ["{FLOAT;range=(-inf,inf)}", "{INT;range=(-inf,inf)}"]

        XCTAssertEqual(brickCell.maxInputFormulaFrameLength, 0)

        brickCell.calcMaxInputFormulaFrameLength(partLabels, withFrame: frame, withParams: params)

        XCTAssertEqual(brickCell.maxInputFormulaFrameLength, 129.5, accuracy: 0.1)
    }

    func testCalcMaxInputFormulaFrameLengthWithoutFormula() {
        let brickCell = BrickCell()
        brickCell.maxInputFormulaFrameLength = 0

        let partLabels = ["x: ", "y: ", ""]
        let frame = CGRect(origin: CGPoint(x: 0, y: 30), size: CGSize(width: 321, height: 30))
        let params = ["", ""]

        XCTAssertEqual(brickCell.maxInputFormulaFrameLength, 0)

        brickCell.calcMaxInputFormulaFrameLength(partLabels, withFrame: frame, withParams: params)

        XCTAssertEqual(brickCell.maxInputFormulaFrameLength, 0)
    }
}
