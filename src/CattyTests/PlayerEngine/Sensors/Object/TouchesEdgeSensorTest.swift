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

final class TouchesEdgeSensorTest: XMLAbstractTest {

    var skView: SKView!
    let stageSize = Util.screenSize(true)
    var sensor: TouchesEdgeSensor!
    var touchManager: TouchManagerMock!
    var spriteObjectA: SpriteObject!

    override func setUp() {
        skView = SKView(frame: CGRect(origin: .zero, size: stageSize))
        spriteObjectA = SpriteObject()
        touchManager = TouchManagerMock()
        sensor = TouchesEdgeSensor(touchManagerGetter: { self.touchManager })
    }

    override func tearDown() {
        touchManager = nil
        super.tearDown()
    }

    func testDefaultRawValue() {
        let sensor = TouchesEdgeSensor { nil }
        XCTAssertEqual(TouchesEdgeSensor.defaultRawValue, sensor.rawValue(for: spriteObjectA), accuracy: Double.epsilon)
    }

    func testRawValue() {
        let project = getProjectForXML(xmlFile: "TouchesEdgeSensor")
        let touchEdgeVar = project.userData.getUserVariable(identifiedBy: "touchEdgeVar")
        let filePath = Bundle(for: type(of: self)).path(forResource: "test.png", ofType: nil)!

        let look = LookMock(name: "look", absolutePath: filePath)
        project.scene.object(at: 1)?.lookList = [look]

        let screenHeight = Double(project.header.screenHeight as! Int / 2)
        let screenWidth = Double(project.header.screenHeight as! Int / 2)

        let stage = createStage(project: project)
        let started = stage.startProject()

        XCTAssertTrue(started)
        XCTAssertEqual(project.scene.objects().count, 2)

        //no edge touch
        expect(touchEdgeVar?.value as? Int).toEventually(equal(0), timeout: .seconds(5))
        XCTAssertEqual(sensor.rawValue(for: project.scene.object(at: 1)!), 0)

        //right edge touch
        project.scene.object(at: 1)?.spriteNode.catrobatPosition = CBPosition(x: screenWidth / 2, y: 0)
        expect(touchEdgeVar?.value as? Int).toEventually(equal(1), timeout: .seconds(5))
        XCTAssertEqual(sensor.rawValue(for: project.scene.object(at: 1)!), 1)

        //left edge touch
        project.scene.object(at: 1)?.spriteNode.catrobatPosition = CBPosition(x: -screenWidth / 2, y: 0)
        expect(touchEdgeVar?.value as? Int).toEventually(equal(1), timeout: .seconds(5))
        XCTAssertEqual(sensor.rawValue(for: project.scene.object(at: 1)!), 1)

        //top edge touch
        project.scene.object(at: 1)?.spriteNode.catrobatPosition = CBPosition(x: 0, y: screenHeight / 2)
        expect(touchEdgeVar?.value as? Int).toEventually(equal(1), timeout: .seconds(5))
        XCTAssertEqual(sensor.rawValue(for: project.scene.object(at: 1)!), 1)

        //bottom edge touch
        project.scene.object(at: 1)?.spriteNode.catrobatPosition = CBPosition(x: 0, y: -screenHeight / 2)
        expect(touchEdgeVar?.value as? Int).toEventually(equal(1), timeout: .seconds(5))
        XCTAssertEqual(sensor.rawValue(for: project.scene.object(at: 1)!), 1)

        //hidden spriteNode
        project.scene.object(at: 1)?.spriteNode.catrobatPosition = CBPosition(x: 0, y: -screenHeight / 2)
        project.scene.object(at: 1)?.spriteNode.isHidden = true
        expect(touchEdgeVar?.value as? Int).toEventually(equal(1), timeout: .seconds(5))
        XCTAssertEqual(sensor.rawValue(for: project.scene.object(at: 1)!), 1)
    }

    func testConvertToStandarized() {
        XCTAssertEqual(1, sensor.convertToStandardized(rawValue: 1, for: spriteObjectA))
        XCTAssertEqual(0, sensor.convertToStandardized(rawValue: 0, for: spriteObjectA))
    }

    func testTag() {
        XCTAssertEqual("COLLIDES_WITH_EDGE", sensor.tag())
    }

    func testRequiredResources() {
        XCTAssertEqual(ResourceType.touchHandler, type(of: sensor).requiredResource)
    }

    func testFormulaEditorSections() {
        let sections = sensor.formulaEditorSections(for: SpriteObject())
        XCTAssertEqual(1, sections.count)
        XCTAssertEqual(.object(position: type(of: sensor).position, subsection: .motion), sections.first)
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
