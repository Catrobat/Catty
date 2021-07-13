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

import XCTest

@testable import Pocket_Code

class XMLParserTests0994: XMLAbstractTest {
    var formulaManager: FormulaManager!

    override func setUp() {
        super.setUp()
        formulaManager = FormulaManager(stageSize: Util.screenSize(true), landscapeMode: false)
    }

    func testAllBricks() {
        let project = self.getProjectForXML(xmlFile: "ValidProjectAllBricks0994")
        XCTAssertEqual(0, project.unsupportedElements.count)
    }

    func testAllSensors() {
        let project = self.getProjectForXML(xmlFile: "Sensors_0994")
        XCTAssertEqual(0, project.unsupportedElements.count)
    }

    func testSetPenColorBrick() {
        let project = self.getProjectForXML(xmlFile: "ValidProjectAllBricks0994")
        let setPenColorBrick = (project.scene.object(at: 0)!.scriptList.object(at: 0) as! Script).brickList.object(at: 45) as! Brick

        XCTAssertEqual(0, project.unsupportedElements.count)
        XCTAssertTrue(setPenColorBrick.isKind(of: SetPenColorBrick.self), "Invalid brick type")

        let castedBrick = setPenColorBrick as! SetPenColorBrick
        XCTAssertTrue(castedBrick.red!.isEqual(to: Formula(integer: 0)))
        XCTAssertTrue(castedBrick.blue!.isEqual(to: Formula(integer: 255)))
        XCTAssertTrue(castedBrick.green!.isEqual(to: Formula(integer: 0)))

    }

    func testGlideToBrick() {
        let project = self.getProjectForXML(xmlFile: "ValidProjectAllBricks0994")
        let glideToBrick = (project.scene.object(at: 0)!.scriptList.object(at: 0) as! Script).brickList.object(at: 10) as! Brick

        XCTAssertEqual(0, project.unsupportedElements.count)
        XCTAssertTrue(glideToBrick.isKind(of: GlideToBrick.self), "Invalid brick type")

        let castedBrick = glideToBrick as! GlideToBrick
        XCTAssertTrue(castedBrick.xDestination.isEqual(to: Formula(integer: 100)), "Invalid formula")
        XCTAssertTrue(castedBrick.yDestination.isEqual(to: Formula(integer: 200)), "Invalid formula")
        XCTAssertEqual("1.0", castedBrick.durationInSeconds.formulaTree.value, "Invalid formula")
    }

    func testThinkForBubbleBrick() {
        let project = self.getProjectForXML(xmlFile: "ValidProjectAllBricks0994")
        let thinkForBubbleBrick = (project.scene.object(at: 0)!.scriptList.object(at: 0) as! Script).brickList.object(at: 36) as! Brick

        XCTAssertEqual(0, project.unsupportedElements.count)
        XCTAssertTrue(thinkForBubbleBrick.isKind(of: ThinkForBubbleBrick.self), "Invalid brick type")

        let castedBrick = thinkForBubbleBrick as! ThinkForBubbleBrick
        XCTAssertTrue(castedBrick.stringFormula.isEqual(to: Formula(string: kLocalizedHmmmm)), "Invalid formula")
        XCTAssertEqual("1.0", castedBrick.intFormula.formulaTree.value, "Invalid formula")
    }

    func testSayForBubbleBrick() {
        let project = self.getProjectForXML(xmlFile: "ValidProjectAllBricks0994")
        let sayForBubbleBrick = (project.scene.object(at: 0)!.scriptList.object(at: 0) as! Script).brickList.object(at: 35) as! Brick

        XCTAssertEqual(0, project.unsupportedElements.count)
        XCTAssertTrue(sayForBubbleBrick.isKind(of: SayForBubbleBrick.self), "Invalid brick type")

        let castedBrick = sayForBubbleBrick as! SayForBubbleBrick
        XCTAssertTrue(castedBrick.stringFormula.isEqual(to: Formula(string: kLocalizedHello)), "Invalid formula")
        XCTAssertEqual("1.0", castedBrick.intFormula.formulaTree.value, "Invalid formula")
    }

    func testSoundList() {
        let project = self.getProjectForXML(xmlFile: "Flap_Pac_Man_0994")

        var soundList = (project.scene.object(at: 0)!.soundList)!
        XCTAssertEqual(0, soundList.count)

        soundList = (project.scene.object(at: 1)!.soundList)!
        XCTAssertEqual(2, soundList.count)

        var sound = soundList.object(at: 0) as! Sound
        XCTAssertTrue(sound.isKind(of: Sound.self), "Invalid Sound type")
        XCTAssertEqual(sound.name, "Evolution FX4", "Wrong Sound name")
        XCTAssertEqual(sound.fileName, "9fb111c07e3bdae5ee7f6546a44f1ddd_Evolution FX4.wav", "Wrong Sound fileName")

        sound = soundList.object(at: 1) as! Sound
        XCTAssertTrue(sound.isKind(of: Sound.self), "Invalid Sound type")
        XCTAssertEqual(sound.name, "Evo2MinusScore2", "Wrong Sound name")
        XCTAssertEqual(sound.fileName, "cb61b2020b42d8b6276bb374dda290e2_Evo2MinusScore2.wav", "Wrong Sound fileName")

        let playSoundBrick = (project.scene.object(at: 1)!.scriptList.object(at: 1) as! Script).brickList.object(at: 14) as! PlaySoundBrick
        XCTAssertTrue(playSoundBrick.sound.isEqual(sound), "Invalid Sound reference")
    }
}
