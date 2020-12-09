/**
 *  Copyright (C) 2010-2023 The Catrobat Team
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

final class CBSpriteNodePhysicsTests: XMLAbstractTest {
    var skView: SKView!
    let stageSize = Util.screenSize(true)

    override func setUp() {
        self.skView = SKView(frame: CGRect(origin: .zero, size: stageSize))
    }

    func testPhysicsBodyRightAmountPhysicsObjectNames() {
        let project = getProjectForXML(xmlFile: "collisionTest0993")
        let filePath = Bundle(for: type(of: self)).path(forResource: "test.png", ofType: nil)!
        let look = LookMock(name: "look", absolutePath: filePath)

        guard let scene = project.scenes[0] as? Scene else {
         XCTFail("Project has no Scenes.")
            return
        }

        scene.object(at: 1)?.lookList = [look]
        scene.object(at: 2)?.lookList = [look]
        scene.object(at: 3)?.lookList = [look]

        let stage = createStage(project: project)
        let started = stage.startProject()

        XCTAssertTrue(started)

        XCTAssertEqual(scene.objects().count, 4)
        XCTAssertEqual(project.physicsObjectNames.count, 2)
        XCTAssertTrue(project.physicsObjectNames.contains("obj1"))
        XCTAssertTrue(project.physicsObjectNames.contains("obj2"))

        stage.stopProject()
    }

    func testPhysicsObjectsNamesManuallySet() {
        let project = getProjectForXML(xmlFile: "collisionTest0993")
        let filePath = Bundle(for: type(of: self)).path(forResource: "test.png", ofType: nil)!
        let look = LookMock(name: "look", absolutePath: filePath)

        guard let scene = project.scenes[0] as? Scene else {
         XCTFail("Project has no Scenes.")
            return
        }
        scene.object(at: 1)?.lookList = [look]
        scene.object(at: 2)?.lookList = [look]
        scene.object(at: 3)?.lookList = [look]

        let stage = createStage(project: project)

        project.physicsObjectNames.removeAllObjects()
        project.physicsObjectNames.add("obj3")

        let started = stage.startProject()

        XCTAssertTrue(started)

        XCTAssertEqual(scene.objects().count, 4)
        XCTAssertEqual(project.physicsObjectNames.count, 1)
        XCTAssertTrue(project.physicsObjectNames.contains("obj3"))

        var physicsNode = scene.object(at: 1)?.spriteNode.childNode(withName: SpriteKitDefines.physicsNodeName)
        XCTAssertNil(physicsNode)
        physicsNode = scene.object(at: 2)?.spriteNode.childNode(withName: SpriteKitDefines.physicsNodeName)
        XCTAssertNil(physicsNode)
        physicsNode = scene.object(at: 3)?.spriteNode.childNode(withName: SpriteKitDefines.physicsNodeName)
        XCTAssertNotNil(physicsNode)
        for child in physicsNode!.children {
            XCTAssertNotNil(child.physicsBody)
        }

        stage.stopProject()
    }

    func testPhysicsBodyRightAmountChildNotes() {
        let project = getProjectForXML(xmlFile: "collisionTest0993")
        let filePath = Bundle(for: type(of: self)).path(forResource: "test.png", ofType: nil)!
        let look = LookMock(name: "look", absolutePath: filePath)

        guard let scene = project.scenes[0] as? Scene else {
         XCTFail("Project has no Scenes.")
            return
        }

        scene.object(at: 1)?.lookList = [look]
        scene.object(at: 2)?.lookList = [look]

        let stage = createStage(project: project)
        let started = stage.startProject()

        XCTAssertTrue(started)

        var supernode = scene.object(at: 1)?.spriteNode.childNode(withName: SpriteKitDefines.physicsNodeName)
        var size = scene.object(at: 1)!.spriteNode.size
        var amountNodes = Int((size.height > size.width ?
                                size.height / CGFloat(SpriteKitDefines.physicsSubnodeSize) :
                                size.width / CGFloat(SpriteKitDefines.physicsSubnodeSize)
                                ).rounded(.up))
        XCTAssertEqual(supernode?.children.count, amountNodes * amountNodes)

        supernode = scene.object(at: 2)?.spriteNode.childNode(withName: SpriteKitDefines.physicsNodeName)
        size = scene.object(at: 2)!.spriteNode.size
        amountNodes = Int((size.height > size.width ?
                                size.height / CGFloat(SpriteKitDefines.physicsSubnodeSize) :
                                size.width / CGFloat(SpriteKitDefines.physicsSubnodeSize)
                                ).rounded(.up))
        XCTAssertEqual(supernode?.children.count, amountNodes * amountNodes)

        stage.stopProject()
    }

    func testRightAmountPhysicsBodys() {
        let project = getProjectForXML(xmlFile: "collisionTest0993")
        let filePath = Bundle(for: type(of: self)).path(forResource: "test.png", ofType: nil)!
        let look = LookMock(name: "look", absolutePath: filePath)

        guard let scene = project.scenes[0] as? Scene else {
         XCTFail("Project has no Scenes.")
            return
        }
        scene.object(at: 1)?.lookList = [look]
        scene.object(at: 2)?.lookList = [look]
        scene.object(at: 3)?.lookList = [look]

        let stage = createStage(project: project)
        let started = stage.startProject()

        XCTAssertTrue(started)

        XCTAssertEqual(scene.objects().count, 4)
        var physicsNode = scene.object(at: 1)?.spriteNode.childNode(withName: SpriteKitDefines.physicsNodeName)
        XCTAssertNotNil(physicsNode)
        for child in physicsNode!.children {
            XCTAssertNotNil(child.physicsBody)
        }
        physicsNode = scene.object(at: 2)?.spriteNode.childNode(withName: SpriteKitDefines.physicsNodeName)
        XCTAssertNotNil(physicsNode)
        for child in physicsNode!.children {
            XCTAssertNotNil(child.physicsBody)
        }
        physicsNode = scene.object(at: 3)?.spriteNode.childNode(withName: SpriteKitDefines.physicsNodeName)
        XCTAssertNil(physicsNode)

        stage.stopProject()
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
