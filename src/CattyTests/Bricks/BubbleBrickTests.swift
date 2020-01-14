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

let kIphoneXSceneHeight = 2436.0
let kIphoneXSceneWidth = 1125.0

let kBubbleFrameConstant = 2.1999969482421875
let kBubbleVerticalPadding = (kSceneLabelFontSize + 20)
let kBubbleSentenceHeight = (1 * kSceneLabelFontSize + 5)
let kBubbleBorderConstant = kBubbleVerticalPadding + Float(kBubbleFrameConstant)
let kBubbleHeightOneLine = (kBubbleBorderConstant + 1 * kBubbleSentenceHeight)
let kBubbleHeightTwoLines = (kBubbleBorderConstant + 2 * kBubbleSentenceHeight)
let kBubbleHeightThreeLines = (kBubbleBorderConstant + 3 * kBubbleSentenceHeight)

let kTopBorderConstant = 2318.7998046875

final class BubbleBrickTests: XMLAbstractTest {

    let bubbleReflected: CGFloat = -1.0
    let bubbleNotReflected: CGFloat = 1.0

    private func createSpriteNodeWithBubble(x xPosition: Double, y yPosition: Double, andSentence sentence: String) -> CBSpriteNode {
        let project = ProjectMock()

        let spriteObject = SpriteObject()
        spriteObject.name = "SpriteObjectName"

        let spriteNode = CBSpriteNodeMock(spriteObject: spriteObject)
        spriteObject.spriteNode = spriteNode
        spriteObject.project = project

        project.objectList.add(spriteObject)
        spriteNode.mockedScene = SceneBuilder(project: ProjectMock(width: CGFloat(kIphoneXSceneWidth), andHeight: CGFloat(kIphoneXSceneHeight))).build()

        BubbleBrickHelper.addBubble(to: spriteNode, withText: sentence, andType: CBBubbleType.thought)
        spriteNode.catrobatPosition = CGPoint(x: 0, y: 0)
        spriteNode.catrobatPosition = CGPoint(x: xPosition, y: yPosition)

        return spriteNode
    }

    func testFormulaForLineNumberSay() {
        let brick = SayBubbleBrick()

        brick.formula = Formula(double: 1)

        XCTAssertEqual(brick.formula, brick.formula(forLineNumber: 1, andParameterNumber: 1))
    }

    func testFormulaForLineNumberSayFor() {
        let brick = SayForBubbleBrick()

        brick.intFormula = Formula(double: 1)
        brick.stringFormula = Formula(string: "")

        XCTAssertEqual(brick.intFormula, brick.formula(forLineNumber: 1, andParameterNumber: 1))
        XCTAssertEqual(brick.stringFormula, brick.formula(forLineNumber: 2, andParameterNumber: 1))
    }

    func testFormulaForLineNumberThink() {
        let brick = ThinkBubbleBrick()

        brick.formula = Formula(double: 1)

        XCTAssertEqual(brick.formula, brick.formula(forLineNumber: 1, andParameterNumber: 1))
    }

    func testFormulaForLineNumberThinkFor() {
        let brick = ThinkForBubbleBrick()

        brick.intFormula = Formula(double: 1)
        brick.stringFormula = Formula(string: "")

        XCTAssertEqual(brick.intFormula, brick.formula(forLineNumber: 1, andParameterNumber: 1))
        XCTAssertEqual(brick.stringFormula, brick.formula(forLineNumber: 2, andParameterNumber: 1))
    }

    func testOneLineSentenceInBubble() {
        let spriteNode = createSpriteNodeWithBubble(x: 0, y: 0, andSentence: "Hello")
        let bubble = spriteNode.children.first
        let bubbleHeight = bubble!.frame.size.height

        XCTAssertTrue(bubbleHeight == CGFloat(kBubbleHeightOneLine))
    }

    func testTwoLineSentenceInBubble() {
        let spriteNode = createSpriteNodeWithBubble(x: 0, y: 0, andSentence: "That's a 2 line text")
        let bubble = spriteNode.children.first
        let bubbleHeight = bubble!.frame.size.height

        XCTAssertTrue(bubbleHeight == CGFloat(kBubbleHeightTwoLines))
    }

    func testThreeLineSentenceInBubble() {
        let spriteNode = createSpriteNodeWithBubble(x: 0, y: 0, andSentence: "This is a 3 line text :)")
        let bubble = spriteNode.children.first
        let bubbleHeight = bubble!.frame.size.height
        XCTAssertTrue(bubbleHeight == CGFloat(kBubbleHeightThreeLines))
    }
}
