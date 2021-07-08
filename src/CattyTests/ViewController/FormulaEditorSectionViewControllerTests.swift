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

import Nimble
import XCTest

@testable import Pocket_Code

final class FormulaEditorSectionViewControllerTests: XCTestCase {

    var viewController: FormulaEditorSectionViewController!
    var formulaEditorViewController: FormulaEditorViewController!
    var formulaManager: FormulaManager!
    var spriteObject: SpriteObject!

    override func setUp() {
        formulaEditorViewController = FormulaEditorViewController()

        formulaManager = FormulaManager(stageSize: Util.screenSize(true), landscapeMode: false)
        spriteObject = SpriteObject()

    }

    func testInitAndSelectFunctions() {
        let expectedItems = formulaManager.formulaEditorItemsForFunctionSection(spriteObject: spriteObject)
        var itemsInTableView = 0

        viewController = FormulaEditorSectionViewController(type: .functions, formulaManager: formulaManager, spriteObject: spriteObject, formulaEditorViewController: formulaEditorViewController)
        viewController.reloadData()

        XCTAssertTrue(viewController.numberOfSections >= 1)

        for section in 0..<viewController.numberOfSections {
            for row in 0..<viewController.numberOfRowsInSection[section] {

                let internFormula = InternFormula()
                formulaEditorViewController.internFormula = internFormula
                XCTAssertEqual(0, internFormula.getInternTokenList()?.count)

                viewController.tableView(viewController.tableView, didSelectRowAt: IndexPath(row: row, section: section))

                assertThatInputIsValid(for: internFormula, having: expectedItems)
                itemsInTableView += 1
            }
        }

        XCTAssertEqual(expectedItems.count, itemsInTableView)
    }

    func testInitAndSelectLogicSection() {
        let expectedItems = formulaManager.formulaEditorItemsForLogicSection(spriteObject: spriteObject)
        var itemsInTableView = 0

        viewController = FormulaEditorSectionViewController(type: .logic, formulaManager: formulaManager, spriteObject: spriteObject, formulaEditorViewController: formulaEditorViewController)
        viewController.reloadData()

        XCTAssertEqual(viewController.numberOfSections, 2)

        for section in 0..<viewController.numberOfSections {
            for row in 0..<viewController.numberOfRowsInSection[section] {

                let internFormula = InternFormula()
                formulaEditorViewController.internFormula = internFormula
                XCTAssertEqual(0, internFormula.getInternTokenList()?.count)

                viewController.tableView(viewController.tableView, didSelectRowAt: IndexPath(row: row, section: section))

                assertThatInputIsValid(for: internFormula, having: expectedItems)
                itemsInTableView += 1
            }
        }

        XCTAssertEqual(expectedItems.count, itemsInTableView)
    }

    func testInitAndSelectObjectSection() {
        let expectedItems = formulaManager.formulaEditorItemsForObjectSection(spriteObject: spriteObject)
        var itemsInTableView = 0

        viewController = FormulaEditorSectionViewController(type: .object, formulaManager: formulaManager, spriteObject: spriteObject, formulaEditorViewController: formulaEditorViewController)
        viewController.reloadData()

        XCTAssertEqual(viewController.numberOfSections, 2)

        for section in 0..<viewController.numberOfSections {
            for row in 0..<viewController.numberOfRowsInSection[section] {

                let internFormula = InternFormula()
                formulaEditorViewController.internFormula = internFormula
                XCTAssertEqual(0, internFormula.getInternTokenList()?.count)

                viewController.tableView(viewController.tableView, didSelectRowAt: IndexPath(row: row, section: section))

                assertThatInputIsValid(for: internFormula, having: expectedItems)
                itemsInTableView += 1
            }
        }

        XCTAssertEqual(expectedItems.count, itemsInTableView)

    }

    func testInitAndSelectSensorsSection() {
        let expectedItems = formulaManager.formulaEditorItemsForSensorsSection(spriteObject: spriteObject)
        var itemsInTableView = 0

        viewController = FormulaEditorSectionViewController(type: .sensors, formulaManager: formulaManager, spriteObject: spriteObject, formulaEditorViewController: formulaEditorViewController)
        viewController.reloadData()

        XCTAssertEqual(viewController.numberOfSections, 4)

        for section in 0..<viewController.numberOfSections {
            for row in 0..<viewController.numberOfRowsInSection[section] {

                let internFormula = InternFormula()
                formulaEditorViewController.internFormula = internFormula
                XCTAssertEqual(0, internFormula.getInternTokenList()?.count)

                viewController.tableView(viewController.tableView, didSelectRowAt: IndexPath(row: row, section: section))

                assertThatInputIsValid(for: internFormula, having: expectedItems)
                itemsInTableView += 1
            }
        }

        XCTAssertEqual(expectedItems.count, itemsInTableView)
    }

    private func assertThatInputIsValid(for internFormula: InternFormula, having expectedItems: [FormulaEditorItem]) {
        let tokens = internFormula.getInternTokenList()!
        XCTAssertFalse(tokens.isEmpty)

        XCTAssertEqual(1, expectedItems.filter { item in

            if let function = item.function {
                return function.tag() == tokens.first!.getStringValue()
            }

            if let sensor = item.sensor {
                return sensor.tag() == tokens.first!.getStringValue()
            }

            if let op = item.op {
                return type(of: op).tag == tokens.first!.getStringValue()
            }

            return false

        }.count)
    }
}
