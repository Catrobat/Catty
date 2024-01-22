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

import XCTest

@testable import Pocket_Code

class TextBlockTextFunctionTest: XCTestCase {
    var textBlockFromCameraFunction: TextBlockFromCameraFunction!
    var textBlockLanguageFromCameraFunction: TextBlockLanguageFromCameraFunction!
    var visualDetectionManagerMock: VisualDetectionManagerMock!

    override func setUp() {
        super.setUp()
        self.visualDetectionManagerMock = VisualDetectionManagerMock()

        self.textBlockFromCameraFunction = TextBlockFromCameraFunction(visualDetectionManagerGetter: { [weak self] in
            self?.visualDetectionManagerMock })
        self.textBlockLanguageFromCameraFunction = TextBlockLanguageFromCameraFunction(visualDetectionManagerGetter: { [weak self] in
            self?.visualDetectionManagerMock })
    }

    override func tearDown() {
        self.visualDetectionManagerMock = nil
        self.textBlockFromCameraFunction = nil
        self.textBlockLanguageFromCameraFunction = nil
        super.tearDown()
    }

    func testDefaultValue() {
        visualDetectionManagerMock.setTextBlockTextRecognized(text: "Das ist ein Text.", language: "de")
        visualDetectionManagerMock.setTextBlockTextRecognized(text: "This is text.", language: "en")

        XCTAssertEqual(type(of: textBlockFromCameraFunction).defaultValue, textBlockFromCameraFunction.value(parameter: "invalidParameter" as AnyObject))
        XCTAssertEqual(type(of: textBlockFromCameraFunction).defaultValue, textBlockFromCameraFunction.value(parameter: nil))
        let textBlockFromCameraFunction = TextBlockFromCameraFunction(visualDetectionManagerGetter: { nil })
        XCTAssertEqual(type(of: textBlockFromCameraFunction).defaultValue, textBlockFromCameraFunction.value(parameter: 1 as AnyObject))

        XCTAssertEqual(type(of: textBlockLanguageFromCameraFunction).defaultValue, textBlockLanguageFromCameraFunction.value(parameter: "invalidParameter" as AnyObject))
        XCTAssertEqual(type(of: textBlockLanguageFromCameraFunction).defaultValue, textBlockLanguageFromCameraFunction.value(parameter: nil))
        let textBlockLanguageFromCameraFunction = TextBlockLanguageFromCameraFunction(visualDetectionManagerGetter: { nil })
        XCTAssertEqual(type(of: textBlockLanguageFromCameraFunction).defaultValue, textBlockLanguageFromCameraFunction.value(parameter: 1 as AnyObject))
    }

    func testValue() {
        visualDetectionManagerMock.setTextBlockTextRecognized(text: "Das ist ein Text.", language: "de")
        visualDetectionManagerMock.setTextBlockTextRecognized(text: "This is text.", language: "en")

        XCTAssertEqual(type(of: textBlockFromCameraFunction).defaultValue, textBlockFromCameraFunction.value(parameter: 0 as AnyObject))
        XCTAssertEqual(type(of: textBlockLanguageFromCameraFunction).defaultValue, textBlockLanguageFromCameraFunction.value(parameter: 0 as AnyObject))

        XCTAssertEqual("Das ist ein Text.", textBlockFromCameraFunction.value(parameter: 1 as AnyObject))
        XCTAssertEqual("de", textBlockLanguageFromCameraFunction.value(parameter: 1 as AnyObject))

        XCTAssertEqual("This is text.", textBlockFromCameraFunction.value(parameter: 2.6 as AnyObject))
        XCTAssertEqual("en", textBlockLanguageFromCameraFunction.value(parameter: 2.6 as AnyObject))

        XCTAssertEqual(type(of: textBlockFromCameraFunction).defaultValue, textBlockFromCameraFunction.value(parameter: 4 as AnyObject))
        XCTAssertEqual(type(of: textBlockLanguageFromCameraFunction).defaultValue, textBlockLanguageFromCameraFunction.value(parameter: 4 as AnyObject))
    }

    func testParameter() {
        XCTAssertEqual(.number(defaultValue: 1), textBlockFromCameraFunction.firstParameter())
        XCTAssertEqual(.number(defaultValue: 1), textBlockLanguageFromCameraFunction.firstParameter())
    }

    func testTag() {
        XCTAssertEqual("TEXT_BLOCK_FROM_CAMERA", type(of: textBlockFromCameraFunction).tag)
        XCTAssertEqual("TEXT_BLOCK_LANGUAGE_FROM_CAMERA", type(of: textBlockLanguageFromCameraFunction).tag)
    }

    func testName() {
        XCTAssertEqual(kUIFEFunctionTextBlockFromCamera, type(of: textBlockFromCameraFunction).name)
        XCTAssertEqual(kUIFEFunctionTextBlockLanguageFromCamera, type(of: textBlockLanguageFromCameraFunction).name)
    }

    func testRequiredResources() {
        XCTAssertEqual(ResourceType.textRecognition, type(of: textBlockFromCameraFunction).requiredResource)
        XCTAssertEqual(ResourceType.textRecognition, type(of: textBlockLanguageFromCameraFunction).requiredResource)
    }

    func testIsIdempotent() {
        XCTAssertFalse(type(of: textBlockFromCameraFunction).isIdempotent)
        XCTAssertFalse(type(of: textBlockLanguageFromCameraFunction).isIdempotent)
    }

    func testFormulaEditorSections() {
        var sections = textBlockFromCameraFunction.formulaEditorSections()
        XCTAssertEqual(1, sections.count)
        XCTAssertEqual(.sensors(position: type(of: textBlockFromCameraFunction).position, subsection: .textRecognition), sections.first)

        sections = textBlockLanguageFromCameraFunction.formulaEditorSections()
        XCTAssertEqual(1, sections.count)
        XCTAssertEqual(.sensors(position: type(of: textBlockLanguageFromCameraFunction).position, subsection: .textRecognition), sections.first)
    }
}
