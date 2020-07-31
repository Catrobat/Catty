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

final class StageTests: XCTestCase {

    var screenSize: CGSize!

    var pocketCodeCenter: CGPoint!
    var pocketCodeBottomLeft: CGPoint!
    var pocketCodeBottomRight: CGPoint!
    var pocketCodeTopLeft: CGPoint!
    var pocketCodeTopRight: CGPoint!

    var stageCenter: CGPoint!
    var stageBottomLeft: CGPoint!
    var stageBottomRight: CGPoint!
    var stageTopLeft: CGPoint!
    var stageTopRight: CGPoint!

    override func setUp() {
        super.setUp()
        self.screenSize = Util.screenSize(false)

        self.pocketCodeCenter = CGPoint(x: 0, y: 0)
        self.pocketCodeBottomLeft = CGPoint(x: -240, y: -400)
        self.pocketCodeBottomRight = CGPoint(x: 240, y: -400)
        self.pocketCodeTopLeft = CGPoint(x: -240, y: 400)
        self.pocketCodeTopRight = CGPoint(x: 240, y: 400)

        self.stageCenter = CGPoint(x: 240, y: 400)
        self.stageBottomLeft = CGPoint(x: 0, y: 0)
        self.stageBottomRight = CGPoint(x: 480, y: 0)
        self.stageTopLeft = CGPoint(x: 0, y: 800)
        self.stageTopRight = CGPoint(x: 480, y: 800)
    }

    func testTouchConversionCenter() {
        let scaledStage = StageBuilder(project: ProjectMock(width: self.screenSize.width * 2, andHeight: self.screenSize.height * 2)).build()
        let scaledStageCenter = CGPoint(x: self.screenSize.width / 2, y: self.screenSize.height / 2)
        let convertedCenter = CBSceneHelper.convertTouchCoordinateToPoint(coordinate: scaledStageCenter, stageSize: scaledStage.size)
        XCTAssertEqual(convertedCenter, self.pocketCodeCenter, "The Scene Center is not correctly calculated")
    }

    func testTouchConversionCenterNoScale() {
        let scaledStage = StageBuilder(project: ProjectMock(width: self.screenSize.width, andHeight: self.screenSize.height)).build()
        let scaledStageCenter = CGPoint(x: self.screenSize.width / 2, y: self.screenSize.height / 2)
        let convertedCenter = CBSceneHelper.convertTouchCoordinateToPoint(coordinate: scaledStageCenter, stageSize: scaledStage.size)
        XCTAssertEqual(convertedCenter, self.pocketCodeCenter, "The Scene Center is not correctly calculated")
    }

    func testTouchConversionBottomLeft() {
        let scaledStage = StageBuilder(project: ProjectMock(width: self.screenSize.width * 2, andHeight: self.screenSize.height * 2)).build()
        let scaledStageBottomLeft = CGPoint(x: 0, y: self.screenSize.height)
        let pocketCodeBottomLeft = CGPoint(x: scaledStage.size.width / 2 * -1, y: scaledStage.size.height / 2 * -1)

        let convertedBottomLeft = CBSceneHelper.convertTouchCoordinateToPoint(coordinate: scaledStageBottomLeft, stageSize: scaledStage.size)
        XCTAssertEqual(convertedBottomLeft, pocketCodeBottomLeft, "The Bottom Left is not correctly calculated")
    }

    func testTouchConversionBottomRight() {
        let scaledStage = StageBuilder(project: ProjectMock(width: self.screenSize.width * 2, andHeight: self.screenSize.height * 2)).build()
        let scaledStageBottomRight = CGPoint(x: self.screenSize.width, y: self.screenSize.height)
        let pocketCodeBottomRight = CGPoint(x: scaledStage.size.width / 2, y: scaledStage.size.height / 2 * -1)

        let convertedBottomRight = CBSceneHelper.convertTouchCoordinateToPoint(coordinate: scaledStageBottomRight, stageSize: scaledStage.size)
        XCTAssertEqual(convertedBottomRight, pocketCodeBottomRight, "The Bottom Right is not correctly calculated")
    }

    func testTouchConversionTopLeft() {
        let scaledStage = StageBuilder(project: ProjectMock(width: self.screenSize.width * 2, andHeight: self.screenSize.height * 2)).build()
        let scaledStageTopLeft = CGPoint(x: 0, y: 0)
        let pocketCodeTopLeft = CGPoint(x: scaledStage.size.width / 2 * -1, y: scaledStage.size.height / 2)

        let convertedTopLeft = CBSceneHelper.convertTouchCoordinateToPoint(coordinate: scaledStageTopLeft, stageSize: scaledStage.size)
        XCTAssertEqual(convertedTopLeft, pocketCodeTopLeft, "The Top Left is not correctly calculated")
    }

    func testTouchConversionTopRight() {
        let scaledStage = StageBuilder(project: ProjectMock(width: self.screenSize.width * 2, andHeight: self.screenSize.height * 2)).build()
        let scaledStageTopRight = CGPoint(x: self.screenSize.width, y: 0)
        let pocketCodeTopRight = CGPoint(x: scaledStage.size.width / 2, y: scaledStage.size.height / 2)

        let convertedTopRight = CBSceneHelper.convertTouchCoordinateToPoint(coordinate: scaledStageTopRight, stageSize: scaledStage.size)
        XCTAssertEqual(convertedTopRight, pocketCodeTopRight, "The Top Right is not correctly calculated")
    }

    func testVariableLabel() {
        let project = ProjectMock(width: self.screenSize.width, andHeight: self.screenSize.height)
        project.scene = Scene()
        let stage = StageBuilder(project: project).build()

        let userVariable = UserVariable(name: "testName")
        project.userData.add(userVariable)

        XCTAssertNil(userVariable.textLabel)
        XCTAssertTrue(stage.startProject())
        XCTAssertNotNil(userVariable.textLabel)
        XCTAssertTrue(userVariable.textLabel?.isHidden == true)
        XCTAssertEqual(SKLabelHorizontalAlignmentMode.left, userVariable.textLabel?.horizontalAlignmentMode)
        XCTAssertEqual(CGFloat(SpriteKitDefines.defaultLabelFontSize), userVariable.textLabel?.fontSize)
        XCTAssertEqual(0, userVariable.textLabel?.text?.count)
        stage.stopProject()
    }

    func testUpdate() {

        let stage = StageBuilder(project: ProjectMock()).build()

        let object = SpriteObject()
        let scene = Scene(name: "testScene")
        object.scene = scene
        let spriteNode1 = CBSpriteNodeMock(spriteObject: object)
        spriteNode1.name = "testObject1"
        spriteNode1.scene = stage
        stage.scheduler.registerSpriteNode(spriteNode1)

        let spriteNode2 = CBSpriteNodeMock(spriteObject: object)
        spriteNode2.name = "testObject2"
        spriteNode2.scene = stage
        stage.scheduler.registerSpriteNode(spriteNode2)

        XCTAssertEqual(spriteNode1.updateMethodCallCount, 0)
        XCTAssertEqual(spriteNode2.updateMethodCallCount, 0)

        stage.update(CACurrentMediaTime())
        XCTAssertEqual(spriteNode1.updateMethodCallCount, 0)
        XCTAssertEqual(spriteNode2.updateMethodCallCount, 0)

        stage.update(CACurrentMediaTime())
        XCTAssertEqual(spriteNode1.updateMethodCallCount, 0)
        XCTAssertEqual(spriteNode2.updateMethodCallCount, 0)

        stage.update(CACurrentMediaTime())
        XCTAssertEqual(spriteNode1.updateMethodCallCount, 1)
        XCTAssertEqual(spriteNode2.updateMethodCallCount, 1)

        stage.update(CACurrentMediaTime())
        XCTAssertEqual(spriteNode1.updateMethodCallCount, 1)
        XCTAssertEqual(spriteNode2.updateMethodCallCount, 1)

        stage.update(CACurrentMediaTime())
        XCTAssertEqual(spriteNode1.updateMethodCallCount, 2)
        XCTAssertEqual(spriteNode2.updateMethodCallCount, 2)
    }

    func testPenClearLines() {
        let stage = StageBuilder(project: ProjectMock()).build()

        let line1 = LineShapeNode(pathStartPoint: CGPoint.zero, pathEndPoint: CGPoint(x: 1, y: 1))
        line1.name = SpriteKitDefines.penShapeNodeName
        stage.addChild(line1)

        let line2 = LineShapeNode(pathStartPoint: CGPoint(x: 1, y: 1), pathEndPoint: CGPoint(x: 2, y: 2))
        line2.name = SpriteKitDefines.penShapeNodeName
        stage.addChild(line2)

        var allLineShapeNodes = [LineShapeNode]()
        stage.enumerateChildNodes(withName: SpriteKitDefines.penShapeNodeName) { node, _ in
            guard let line = node as? LineShapeNode else {
                XCTFail("Could not cast SKNode to LineShapeNode")
                return
            }
            allLineShapeNodes.append(line)
        }

        XCTAssertEqual(allLineShapeNodes.count, 2)

        stage.clearPenLines()

        allLineShapeNodes.removeAll()
        stage.enumerateChildNodes(withName: SpriteKitDefines.penShapeNodeName) { node, _ in
            guard let line = node as? LineShapeNode else {
                XCTFail("Could not cast SKNode to LineShapeNode")
                return
            }
            allLineShapeNodes.append(line)
        }

        XCTAssertEqual(allLineShapeNodes.count, 0)

    }

    func testClearStampSpriteNode() {
        let stage = StageBuilder(project: ProjectMock()).build()

        let object = SpriteObject()
        let scene = Scene(name: "testScene")
        object.scene = scene
        let cbSpriteNode1 = CBSpriteNode(spriteObject: object)
        cbSpriteNode1.name = "testName1"
        stage.addChild(cbSpriteNode1)

        let cbSpriteNode2 = CBSpriteNode(spriteObject: object)
        cbSpriteNode2.name = "testName2"
        stage.addChild(cbSpriteNode2)

        let stampedSpriteNode1 = SKSpriteNode(color: UIColor.blue, size: CGSize(width: 100, height: 50))
        stampedSpriteNode1.name = SpriteKitDefines.stampedSpriteNodeName
        stage.addChild(stampedSpriteNode1)

        let stampedSpriteNode2 = SKSpriteNode(color: UIColor.red, size: CGSize(width: 200, height: 100))
        stampedSpriteNode2.name = SpriteKitDefines.stampedSpriteNodeName
        stage.addChild(stampedSpriteNode2)

        XCTAssertNotNil(stage.childNode(withName: SpriteKitDefines.stampedSpriteNodeName))
        XCTAssertEqual(stage.children.count, 4)

        stage.clearStampedSpriteNodes()

        XCTAssertNil(stage.childNode(withName: SpriteKitDefines.stampedSpriteNodeName))
        XCTAssertNotNil(stage.childNode(withName: "testName1"))
        XCTAssertNotNil(stage.childNode(withName: "testName2"))
        XCTAssertEqual(stage.children.count, 2)
    }
}
