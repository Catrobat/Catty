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

final class CollisionFunctionTests: XMLAbstractTest {
    var skView: SKView!
    let stageSize = Util.screenSize(true)

    let collision = 1
    let noCollision = 2

    override func setUp() {
        self.skView = SKView(frame: CGRect(origin: .zero, size: stageSize))
    }

    func testCollisionWithObjectsOverlap() {
        let project = getProjectForXML(xmlFile: "collisionTest0993")
        let collisionVar = project.userData.getUserVariable(identifiedBy: "collisionVar")
        let filePath = Bundle(for: type(of: self)).path(forResource: "test.png", ofType: nil)!

        let look = LookMock(name: "look", absolutePath: filePath)
        project.scene.object(at: 1)?.lookList = [look]
        project.scene.object(at: 2)?.lookList = [look]

        let stage = createStage(project: project)
        let started = stage.startProject()

        XCTAssertTrue(started)
        expect(collisionVar?.value as? Int).toEventually(equal(collision), timeout: .seconds(5))

        stage.stopProject()
    }

    func testCollisionWithObjectsNoOverlap() {
        let project = getProjectForXML(xmlFile: "collisionTest0993")
        let collisionVar = project.userData.getUserVariable(identifiedBy: "collisionVar")
        let filePath = Bundle(for: type(of: self)).path(forResource: "test.png", ofType: nil)!

        let look = LookMock(name: "look", absolutePath: filePath)
        project.scene.object(at: 1)?.lookList = [look]
        project.scene.object(at: 2)?.lookList = [look]

        let stage = createStage(project: project)
        let started = stage.startProject()

        project.scene.object(at: 2)?.spriteNode.position = CGPoint(x: 200, y: 200)

        XCTAssertTrue(started)
        expect(collisionVar?.value as? Int).toEventually(equal(noCollision), timeout: .seconds(5))

        stage.stopProject()
    }

    func testCollisionWithObjectsTransparent() {
        let project = getProjectForXML(xmlFile: "collisionTest0993")
        let collisionVar = project.userData.getUserVariable(identifiedBy: "collisionVar")
        let filePath = Bundle(for: type(of: self)).path(forResource: "test.png", ofType: nil)!

        let look = LookMock(name: "look", absolutePath: filePath)
        project.scene.object(at: 1)?.lookList = [look]
        project.scene.object(at: 2)?.lookList = [look]

        let stage = createStage(project: project)
        let started = stage.startProject()

        project.scene.object(at: 2)?.spriteNode.catrobatTransparency = 100.0

        XCTAssertTrue(started)
        expect(collisionVar?.value as? Int).toEventually(equal(noCollision), timeout: .seconds(5))

        project.scene.object(at: 2)?.spriteNode.catrobatTransparency = 0.0
        project.scene.object(at: 1)?.spriteNode.catrobatTransparency = 100.0
        collisionVar?.value = 10

        expect(collisionVar?.value as? Int).toEventually(equal(noCollision), timeout: .seconds(5))

        stage.stopProject()
    }

    func testCollisionWithObjectsOverlapNoCollision() {
        let project = getProjectForXML(xmlFile: "collisionTest0993")
        let collisionVar = project.userData.getUserVariable(identifiedBy: "collisionVar")
        let filePath = Bundle(for: type(of: self)).path(forResource: "test.png", ofType: nil)!

        let look = LookMock(name: "look", absolutePath: filePath)
        project.scene.object(at: 1)?.lookList = [look]
        project.scene.object(at: 2)?.lookList = [look]

        let stage = createStage(project: project)
        let started = stage.startProject()

        project.scene.object(at: 1)?.spriteNode.position = CGPoint(x: 0, y: 0)
        project.scene.object(at: 2)?.spriteNode.position = CGPoint(x: 115, y: 58)

        XCTAssertTrue(started)
        expect(collisionVar?.value as? Int).toEventually(equal(noCollision), timeout: .seconds(5))

        let obj1PosX = project.scene.object(at: 1)?.spriteNode.position.x
        let obj1PosY = project.scene.object(at: 1)?.spriteNode.position.y
        let obj2PosX = project.scene.object(at: 2)?.spriteNode.position.x
        let obj2PosY = project.scene.object(at: 2)?.spriteNode.position.y
        let lookWidth = project.scene.object(at: 1)?.spriteNode.size.width
        let lookHeigth = project.scene.object(at: 1)?.spriteNode.size.height

        XCTAssertGreaterThan(obj1PosX! + (lookWidth! / 2), obj2PosX! - (lookWidth! / 2), "Images are not overlapping")
        XCTAssertGreaterThan(obj1PosY! + (lookHeigth! / 2), obj2PosY! - (lookHeigth! / 2), "Images are not overlapping")

        NSLog("objectnames list: \(project.physicsObjectNames)")

        stage.stopProject()
    }

    func testParseFromElementAndCheckPhysicsObjectNames() {
        let objectNameA = "objectNameA"
        let objectNameB = "objectNameB"

        let context = CBXMLParserContext(languageVersion: 0.992, andRootElement: nil)

        XCTAssertEqual(0, context!.physicsObjectNames.count)

        context?.spriteObject = SpriteObjectMock()
        context?.spriteObject.name = objectNameA

        let xmlElement = GDataXMLElement.element(withName: CollisionFunction.tag)
        xmlElement?.addChild(GDataXMLElement.element(withName: "value", stringValue: objectNameB))

        let formulaElement = CollisionFunction.parseFromElement(xmlElement!, context: context!)

        XCTAssertNotNil(formulaElement)
        XCTAssertEqual(2, context!.physicsObjectNames.count)
        XCTAssertTrue(context!.physicsObjectNames.contains(objectNameA))
        XCTAssertTrue(context!.physicsObjectNames.contains(objectNameB))
    }

    private func createStage(project: Project) -> Stage {
        let stageBuilder = StageBuilder(project: project)
            .withFormulaManager(formulaManager: FormulaManager(stageSize: stageSize, landscapeMode: false))
            .withAudioEngine(audioEngine: AudioEngineMock())
        let stage = stageBuilder.build()
        skView.presentScene(stage)
        return stage
    }
}
