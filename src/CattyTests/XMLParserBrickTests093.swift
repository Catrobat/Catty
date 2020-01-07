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

class XMLParserBrickTests093: XMLAbstractTest {
    var parserContext: CBXMLParserContext!
    var formulaManager: FormulaManager!

    override func setUp() {
        super.setUp()
        parserContext = CBXMLParserContext(languageVersion: CGFloat(Float32(0.93)))
        formulaManager = FormulaManager(sceneSize: Util.screenSize(true))
    }

    func testValidSetLookBrick() {
        let document = self.getXMLDocumentForPath(xmlPath: self.getPathForXML(xmlFile: "ValidProject"))
        let brickElement = self.getXMLElementsForXPath(document, xPath: "//program/objectList/object[1]/scriptList/script[1]/brickList/brick[1]")
        let objectArray = self.getXMLElementsForXPath(document, xPath: "//program/objectList/object[1]")

        XCTAssertEqual(brickElement!.count, 1)
        XCTAssertEqual(objectArray!.count, 1)
        let objectElement = objectArray!.first

        let lookList = SpriteObject.parseAndCreateLooks(objectElement, with: self.parserContext)
        let brickXMLElement = brickElement!.first

        self.parserContext!.spriteObject = SpriteObject()
        self.parserContext!.spriteObject.lookList = lookList
        let brick = self.parserContext!.parse(from: brickXMLElement, withClass: SetLookBrick.self as? CBXMLNodeProtocol.Type) as! Brick

        XCTAssertTrue(brick.isKind(of: SetLookBrick.self), "Invalid brick class")

        let setLookBrick = brick as! SetLookBrick

        let look = setLookBrick.look
        XCTAssertEqual(look!.name, "Background", "Invalid look name")
    }

    func testValidSetVariableBrick() {
        let document = self.getXMLDocumentForPath(xmlPath: self.getPathForXML(xmlFile: "ValidProject"))
        let brickElement = self.getXMLElementsForXPath(document, xPath: "//program/objectList/object[1]/scriptList/script[1]/brickList/brick[2]")

        XCTAssertEqual(brickElement!.count, 1)
        let brickXMLElement = brickElement!.first

        let brick = self.parserContext!.parse(from: brickXMLElement, withClass: SetVariableBrick.self) as! Brick
        XCTAssertTrue(brick.isKind(of: SetVariableBrick.self), "Invalid brick class")

        let setVariableBrick = brick as! SetVariableBrick

        XCTAssertEqual(setVariableBrick.userVariable.name, "random from", "Invalid user variable name")

        let formula = setVariableBrick.variableFormula
        XCTAssertEqual(formula!.formulaTree.type, ElementType.NUMBER, "Invalid variable type")
        XCTAssertEqual(formula!.formulaTree.value, "1", "Invalid variable value")
    }

    func testValidSetSizeToBrick() {
        let document = self.getXMLDocumentForPath(xmlPath: self.getPathForXML(xmlFile: "ValidProject"))
        let brickElement = self.getXMLElementsForXPath(document, xPath: "//program/objectList/object[2]/scriptList/script[1]/brickList/brick[1]")
        let objectArray = self.getXMLElementsForXPath(document, xPath: "//program/objectList/object[1]")

        XCTAssertEqual(brickElement!.count, 1)
        XCTAssertEqual(objectArray!.count, 1)

        let objectElement = objectArray!.first

        let lookList = SpriteObject.parseAndCreateLooks(objectElement, with: self.parserContext)
        let brickXMLElement = brickElement!.first

        let context = CBXMLParserContext()
        context.spriteObject = SpriteObject()
        context.spriteObject.lookList = lookList
        let brick = self.parserContext!.parse(from: brickXMLElement, withClass: SetSizeToBrick.self as? CBXMLNodeProtocol.Type) as! Brick

        XCTAssertTrue(brick.isKind(of: SetSizeToBrick.self), "Invalid brick class")

        let setSizeToBrick = brick as! SetSizeToBrick
        let formula = setSizeToBrick.size

        XCTAssertNotNil(formula, "Invalid formula")

        XCTAssertEqual(formula!.formulaTree.type, ElementType.NUMBER, "Invalid variable type")
        XCTAssertEqual(formula!.formulaTree.value, "30", "Invalid formula value")

        XCTAssertEqual(self.formulaManager.interpretDouble(formula!, for: context.spriteObject), 30, accuracy: 0.00001, "Formula not correctly parsed")
    }

    func testValidForeverBrickAndLoopEndlessBrick() {
        let context = CBXMLParserContext()
        let document = self.getXMLDocumentForPath(xmlPath: self.getPathForXML(xmlFile: "ValidProject"))
        let brickElement1 = self.getXMLElementsForXPath(document, xPath: "//program/objectList/object[2]/scriptList/script[1]/brickList/brick[2]")
        let brickElement2 = self.getXMLElementsForXPath(document, xPath: "//program/objectList/object[2]/scriptList/script[1]/brickList/brick[12]")

        XCTAssertEqual(brickElement1!.count, 1)
        XCTAssertEqual(brickElement2!.count, 1)

        let brickXMLElement1 = brickElement1!.first
        let brickXMLElement2 = brickElement2!.first

        let brick1 = self.parserContext!.parse(from: brickXMLElement1, withClass: ForeverBrick.self as? CBXMLNodeProtocol.Type) as! Brick
        let brick2 = self.parserContext!.parse(from: brickXMLElement2, withClass: LoopEndBrick.self as? CBXMLNodeProtocol.Type) as! Brick

        XCTAssertTrue(brick1.isKind(of: ForeverBrick.self), "Invalid brick class")
        XCTAssertTrue(brick2.isKind(of: LoopEndBrick.self), "Invalid brick class")

        XCTAssertTrue(context.openedNestingBricksStack.isEmpty(), "Nesting bricks not closed properly")
    }

    func testValidPlaceAtBrick() {
        let document = self.getXMLDocumentForPath(xmlPath: self.getPathForXML(xmlFile: "ValidProject"))
        let brickElement = self.getXMLElementsForXPath(document, xPath: "//program/objectList/object[2]/scriptList/script[1]/brickList/brick[3]")
        XCTAssertEqual(brickElement!.count, 1)

        let brickXMLElement = brickElement!.first
        let brick = self.parserContext!.parse(from: brickXMLElement, withClass: PlaceAtBrick.self as? CBXMLNodeProtocol.Type) as! Brick

        XCTAssertTrue(brick.isKind(of: PlaceAtBrick.self), "Invalid brick class")

        let placeAtBrick = brick as! PlaceAtBrick
        let xPosition = placeAtBrick.xPosition
        let yPosition = placeAtBrick.yPosition
        XCTAssertNotNil(xPosition, "Invalid formula for xPosition")
        XCTAssertNotNil(yPosition, "Invalid formula for yPosition")

        XCTAssertEqual(self.formulaManager.interpretDouble(xPosition!, for: SpriteObject()), -170, accuracy: 0.00001, "Formula not correctly parsed")
        XCTAssertEqual(self.formulaManager.interpretDouble(yPosition!, for: SpriteObject()), -115, accuracy: 0.00001, "Formula not correctly parsed")
    }

    func testValidWaitBrick() {
        let document = self.getXMLDocumentForPath(xmlPath: self.getPathForXML(xmlFile: "ValidProject"))
        let brickElement = self.getXMLElementsForXPath(document, xPath: "//program/objectList/object[2]/scriptList/script[1]/brickList/brick[4]")
        XCTAssertEqual(brickElement!.count, 1)

        let brickXMLElement = brickElement!.first
        let brick = self.parserContext!.parse(from: brickXMLElement, withClass: WaitBrick.self as? CBXMLNodeProtocol.Type) as! Brick

        XCTAssertTrue(brick.isKind(of: WaitBrick.self), "Invalid brick class")

        let waitBrick = brick as! WaitBrick
        let timeToWaitInSeconds = waitBrick.timeToWaitInSeconds
        XCTAssertNotNil(timeToWaitInSeconds, "Invalid formula")

        // result is either 1 or 2
        XCTAssertEqual(self.formulaManager.interpretDouble(timeToWaitInSeconds, for: SpriteObject()), 1, accuracy: 1, "Formula not correctly parsed")
    }

    func testValidShowBrick() {
        let document = self.getXMLDocumentForPath(xmlPath: self.getPathForXML(xmlFile: "ValidProject"))
        let brickElement = self.getXMLElementsForXPath(document, xPath: "//program/objectList/object[2]/scriptList/script[1]/brickList/brick[5]")
        XCTAssertEqual(brickElement!.count, 1)

        let brickXMLElement = brickElement!.first
        let brick = self.parserContext!.parse(from: brickXMLElement, withClass: ShowBrick.self as? CBXMLNodeProtocol.Type) as! Brick

        XCTAssertTrue(brick.isKind(of: ShowBrick.self), "Invalid brick class")
    }

    func testValidGlideToBrick() {
        let document = self.getXMLDocumentForPath(xmlPath: self.getPathForXML(xmlFile: "ValidProject"))
        let brickElement = self.getXMLElementsForXPath(document, xPath: "//program/objectList/object[2]/scriptList/script[1]/brickList/brick[7]")
        XCTAssertEqual(brickElement!.count, 1)

        let brickXMLElement = brickElement!.first
        let brick = self.parserContext!.parse(from: brickXMLElement, withClass: GlideToBrick.self as? CBXMLNodeProtocol.Type) as! Brick

        XCTAssertTrue(brick.isKind(of: GlideToBrick.self), "Invalid brick class")

        let glideToBrick = brick as! GlideToBrick

        let durationInSeconds = glideToBrick.durationInSeconds
        XCTAssertNotNil(durationInSeconds, "Invalid formula")
        XCTAssertEqual(self.formulaManager.interpretDouble(durationInSeconds!, for: SpriteObject()), 0.1, accuracy: 0.00001, "Formula not correctly parsed")

        let xDestination = glideToBrick.xDestination
        XCTAssertNotNil(xDestination, "Invalid formula")
        XCTAssertEqual(self.formulaManager.interpretDouble(xDestination!, for: SpriteObject()), -170, accuracy: 0.00001, "Formula not correctly parsed")

        let yDestination = glideToBrick.yDestination
        XCTAssertNotNil(yDestination, "Invalid formula")
        XCTAssertEqual(self.formulaManager.interpretDouble(yDestination!, for: SpriteObject()), -100, accuracy: 0.00001, "Formula not correctly parsed")
    }

    func testValidHideBrick() {
        let document = self.getXMLDocumentForPath(xmlPath: self.getPathForXML(xmlFile: "ValidProject"))
        let brickElement = self.getXMLElementsForXPath(document, xPath: "//program/objectList/object[2]/scriptList/script[1]/brickList/brick[10]")
        XCTAssertEqual(brickElement!.count, 1)

        let brickXMLElement = brickElement!.first
        let brick = self.parserContext!.parse(from: brickXMLElement, withClass: HideBrick.self as? CBXMLNodeProtocol.Type) as! Brick

        XCTAssertTrue(brick.isKind(of: HideBrick.self), "Invalid brick class")
    }

    func testValidPlaySoundBrick() {
        let document = self.getXMLDocumentForPath(xmlPath: self.getPathForXML(xmlFile: "ValidProject"))
        let brickElement = self.getXMLElementsForXPath(document, xPath: "//program/objectList/object[2]/scriptList/script[2]/brickList/brick[1]")
        let objectArray = self.getXMLElementsForXPath(document, xPath: "//program/objectList/object[2]")
        XCTAssertEqual(brickElement!.count, 1)
        XCTAssertEqual(objectArray!.count, 1)

        let objectElement = objectArray!.first
        let soundList = SpriteObject.parseAndCreateSounds(objectElement, with: self.parserContext)
        let brickXMLElement = brickElement!.first

        self.parserContext!.spriteObject = SpriteObject()
        self.parserContext!.spriteObject.soundList = soundList

        let brick = self.parserContext!.parse(from: brickXMLElement, withClass: PlaySoundBrick.self as? CBXMLNodeProtocol.Type) as! Brick

        XCTAssertTrue(brick.isKind(of: PlaySoundBrick.self), "Invalid brick class")

        let playSoundBrick = brick as! PlaySoundBrick
        let sound = playSoundBrick.sound
        XCTAssertNotNil(sound, "Invalid sound")
        XCTAssertEqual(sound!.name, "Hit", "Invalid sound name")
    }

    func testValidSetXBrick() {
        let document = self.getXMLDocumentForPath(xmlPath: self.getPathForXML(xmlFile: "ValidProjectAllBricks093"))
        let brickElement = self.getXMLElementsForXPath(document, xPath: "//program/objectList/object[1]/scriptList/script[1]/brickList/brick[2]")
        XCTAssertEqual(brickElement!.count, 1)

        let brickXMLElement = brickElement!.first
        let brick = self.parserContext!.parse(from: brickXMLElement, withClass: SetXBrick.self as? CBXMLNodeProtocol.Type) as! Brick

        XCTAssertTrue(brick.isKind(of: SetXBrick.self), "Invalid brick class")

        let setXBrick = brick as! SetXBrick
        let formula = setXBrick.xPosition

        XCTAssertNotNil(formula, "Invalid formula")
        XCTAssertEqual(formula!.formulaTree.type, ElementType.USER_VARIABLE, "Invalid variable type")
        XCTAssertEqual(formula!.formulaTree.value, "lokal", "Invalid formula value")
    }

    func testValidSetXBrickEqual() {
        let document = self.getXMLDocumentForPath(xmlPath: self.getPathForXML(xmlFile: "ValidProjectAllBricks093"))

        let brickElement = self.getXMLElementsForXPath(document, xPath: "//program/objectList/object[1]/scriptList/script[1]/brickList/brick[2]")
        XCTAssertEqual(brickElement!.count, 1)

        let brickXMLElement = brickElement!.first
        let brick = self.parserContext!.parse(from: brickXMLElement, withClass: SetXBrick.self as? CBXMLNodeProtocol.Type) as! Brick

        XCTAssertTrue(brick.isKind(of: SetXBrick.self), "Invalid brick class")

        let setXBrick = brick as! SetXBrick
        let formula = setXBrick.xPosition

        XCTAssertNotNil(formula, "Invalid formula")
        XCTAssertEqual(formula!.formulaTree.type, ElementType.USER_VARIABLE, "Invalid variable type")
        XCTAssertEqual(formula!.formulaTree.value, "lokal", "Invalid formula value")

        let secondBrick = SetXBrick()
        let secondFormula = Formula()
        let formulaTree = FormulaElement()
        formulaTree.type = ElementType.USER_VARIABLE
        formulaTree.value = "lokal"
        secondFormula.formulaTree = formulaTree
        secondBrick.xPosition = secondFormula

        XCTAssertTrue(secondFormula.isEqual(to: formula), "Formulas not equal")
        XCTAssertTrue(secondBrick.isEqual(to: setXBrick), "SetXBricks not equal")
    }

    func testValidSetYBrick() {
        let document = self.getXMLDocumentForPath(xmlPath: self.getPathForXML(xmlFile: "ValidProjectAllBricks093"))
        let brickElement = self.getXMLElementsForXPath(document, xPath: "//program/objectList/object[1]/scriptList/script[1]/brickList/brick[3]")
        XCTAssertEqual(brickElement!.count, 1)

        let brickXMLElement = brickElement!.first
        let brick = self.parserContext!.parse(from: brickXMLElement, withClass: SetYBrick.self as? CBXMLNodeProtocol.Type) as! Brick

        XCTAssertTrue(brick.isKind(of: SetYBrick.self), "Invalid brick class")

        let setYBrick = brick as! SetYBrick
        let formula = setYBrick.yPosition

        XCTAssertNotNil(formula, "Invalid formula")
        XCTAssertEqual(formula!.formulaTree.type, ElementType.USER_VARIABLE, "Invalid variable type")
        XCTAssertEqual(formula!.formulaTree.value, "global", "Invalid formula value")
    }

    func testValidChangeXByNBrick() {
        let document = self.getXMLDocumentForPath(xmlPath: self.getPathForXML(xmlFile: "ValidProjectAllBricks093"))
        let brickElement = self.getXMLElementsForXPath(document, xPath: "//program/objectList/object[1]/scriptList/script[1]/brickList/brick[4]")
        XCTAssertEqual(brickElement!.count, 1)

        let brickXMLElement = brickElement!.first
        let brick = self.parserContext!.parse(from: brickXMLElement, withClass: ChangeXByNBrick.self as? CBXMLNodeProtocol.Type) as! Brick

        XCTAssertTrue(brick.isKind(of: ChangeXByNBrick.self), "Invalid brick class")

        let changeXByNBrick = brick as! ChangeXByNBrick
        let formula = changeXByNBrick.xMovement

        XCTAssertNotNil(formula, "Invalid formula")
        XCTAssertEqual(formula!.formulaTree.type, ElementType.SENSOR, "Invalid variable type")
        XCTAssertEqual(formula!.formulaTree.value, "OBJECT_BRIGHTNESS", "Invalid formula value")
    }

    func testValidChangeYByNBrick() {
        let document = self.getXMLDocumentForPath(xmlPath: self.getPathForXML(xmlFile: "ValidProjectAllBricks093"))
        let brickElement = self.getXMLElementsForXPath(document, xPath: "//program/objectList/object[1]/scriptList/script[1]/brickList/brick[5]")
        XCTAssertEqual(brickElement!.count, 1)

        let brickXMLElement = brickElement!.first
        let brick = self.parserContext!.parse(from: brickXMLElement, withClass: ChangeYByNBrick.self as? CBXMLNodeProtocol.Type) as! Brick

        XCTAssertTrue(brick.isKind(of: ChangeYByNBrick.self), "Invalid brick class")

        let changeYByNBrick = brick as! ChangeYByNBrick
        let formula = changeYByNBrick.yMovement

        XCTAssertNotNil(formula, "Invalid formula")
        XCTAssertEqual(self.formulaManager.interpretDouble(formula!, for: SpriteObject()), 10, accuracy: 0.00001, "Formula not correctly parsed")
    }

    func testValidMoveNStepsBrick() {
        let document = self.getXMLDocumentForPath(xmlPath: self.getPathForXML(xmlFile: "ValidProjectAllBricks093"))
        let brickElement = self.getXMLElementsForXPath(document, xPath: "//program/objectList/object[1]/scriptList/script[1]/brickList/brick[6]")
        XCTAssertEqual(brickElement!.count, 1)

        let brickXMLElement = brickElement!.first
        let brick = self.parserContext!.parse(from: brickXMLElement, withClass: MoveNStepsBrick.self) as! Brick

        XCTAssertTrue(brick.isKind(of: MoveNStepsBrick.self), "Invalid brick class")

        let moveNStepsBrick = brick as! MoveNStepsBrick
        let formula = moveNStepsBrick.steps

        XCTAssertNotNil(formula, "Invalid formula")
        XCTAssertEqual(self.formulaManager.interpretDouble(formula!, for: SpriteObject()), log10(sqrt(5)) / log10(10), accuracy: 0.00001, "Formula not correctly parsed")
    }

    func testValidTurnLeftBrick() {
        let document = self.getXMLDocumentForPath(xmlPath: self.getPathForXML(xmlFile: "ValidProjectAllBricks093"))
        let brickElement = self.getXMLElementsForXPath(document, xPath: "//program/objectList/object[1]/scriptList/script[1]/brickList/brick[7]")
        XCTAssertEqual(brickElement!.count, 1)

        let brickXMLElement = brickElement!.first
        let brick = self.parserContext!.parse(from: brickXMLElement, withClass: TurnLeftBrick.self as? CBXMLNodeProtocol.Type) as! Brick

        XCTAssertTrue(brick.isKind(of: TurnLeftBrick.self), "Invalid brick class")

        let turnLeftBrick = brick as! TurnLeftBrick
        let formula = turnLeftBrick.degrees

        XCTAssertNotNil(formula, "Invalid formula")
        XCTAssertEqual(self.formulaManager.interpretDouble(formula!, for: SpriteObject()), 15, accuracy: 0.00001, "Formula not correctly parsed")
    }

    func testValidTurnRightBrick() {
        let document = self.getXMLDocumentForPath(xmlPath: self.getPathForXML(xmlFile: "ValidProjectAllBricks093"))
        let brickElement = self.getXMLElementsForXPath(document, xPath: "//program/objectList/object[1]/scriptList/script[1]/brickList/brick[8]")
        XCTAssertEqual(brickElement!.count, 1)

        let brickXMLElement = brickElement!.first
        let brick = self.parserContext!.parse(from: brickXMLElement, withClass: TurnRightBrick.self as? CBXMLNodeProtocol.Type) as! Brick

        XCTAssertTrue(brick.isKind(of: TurnRightBrick.self), "Invalid brick class")

        let turnRightBrick = brick as! TurnRightBrick
        let formula = turnRightBrick.degrees

        XCTAssertNotNil(formula, "Invalid formula")
        XCTAssertEqual(self.formulaManager.interpretDouble(formula!, for: SpriteObject()), 15, accuracy: 0.00001, "Formula not correctly parsed")
    }

    func testValidPointInDirectionBrick() {
        let document = self.getXMLDocumentForPath(xmlPath: self.getPathForXML(xmlFile: "ValidProjectAllBricks093"))
        let brickElement = self.getXMLElementsForXPath(document, xPath: "//program/objectList/object[1]/scriptList/script[1]/brickList/brick[9]")
        XCTAssertEqual(brickElement!.count, 1)

        let brickXMLElement = brickElement!.first
        let brick = self.parserContext!.parse(from: brickXMLElement, withClass: PointInDirectionBrick.self as? CBXMLNodeProtocol.Type) as! Brick

        XCTAssertTrue(brick.isKind(of: PointInDirectionBrick.self), "Invalid brick class")

        let pointInDirectionBrick = brick as! PointInDirectionBrick
        let formula = pointInDirectionBrick.degrees

        XCTAssertNotNil(formula, "Invalid formula")
        XCTAssertEqual(self.formulaManager.interpretDouble(formula!, for: SpriteObject()), 90, accuracy: 0.00001, "Formula not correctly parsed")
    }

    func testValidStopAllSoundBrick() {
        let document = self.getXMLDocumentForPath(xmlPath: self.getPathForXML(xmlFile: "ValidProjectAllBricks093"))
        let brickElement = self.getXMLElementsForXPath(document,
                                                       xPath: "//program/objectList/object[1]/scriptList/script[1]/brickList/brick[10]/pointedObject[1]/scriptList/script[1]/brickList/brick[2]")
        XCTAssertEqual(brickElement!.count, 1)
        let brickXMLElement = brickElement!.first

        let brick = self.parserContext!.parse(from: brickXMLElement, withClass: StopAllSoundsBrick.self as? CBXMLNodeProtocol.Type) as! Brick

        XCTAssertTrue(brick.isKind(of: StopAllSoundsBrick.self), "Invalid brick class")
    }

    func testValidPointToBrick() {
        let document = self.getXMLDocumentForPath(xmlPath: self.getPathForXML(xmlFile: "ValidProjectAllBricks093"))
        let brickElement = self.getXMLElementsForXPath(document, xPath: "//program/objectList/object[1]/scriptList/script[1]/brickList/brick[10]")
        XCTAssertEqual(brickElement!.count, 1)

        let brickXMLElement = brickElement!.first
        let brick = self.parserContext!.parse(from: brickXMLElement, withClass: PointToBrick.self) as! Brick

        XCTAssertTrue(brick.isKind(of: PointToBrick.self), "Invalid brick class")

        let pointToBrick = brick as! PointToBrick
        let spriteObject = pointToBrick.pointedObject

        XCTAssertNotNil(spriteObject, "Invalid SpriteObject")
        XCTAssertEqual(spriteObject!.name, "stickers", "Invalid object name")
    }

    func testValidPointToBrickWithoutSpriteObject() {
        let project = self.getProjectForXML(xmlFile: "PointToBrickWithoutSpriteObject")
        XCTAssertNotNil(project, "Project must not be nil!")

        let moleTwo = project.objectList.object(at: 1) as! SpriteObject
        XCTAssertNotNil(moleTwo, "SpriteObject must not be nil!")
        XCTAssertEqual(moleTwo.name, "Mole 2", "Invalid object name!")

        let script = moleTwo.scriptList.object(at: 0) as! Script
        XCTAssertNotNil(script, "Script must not be nil!")

        let pointToBrick = script.brickList.object(at: 7) as! PointToBrick
        XCTAssertNotNil(pointToBrick, "PointToBrick must not be nil!")

        let pointedObject = pointToBrick.pointedObject
        XCTAssertNotNil(pointedObject, "pointedObject must not be nil!")
        XCTAssertEqual(pointedObject!.name, "Mole 2", "Invalid object name!")
    }

    func testValidSetColorBrick() {
        let document = self.getXMLDocumentForPath(xmlPath: self.getPathForXML(xmlFile: "ValidProjectAllBricks093"))
        let brickElement = self.getXMLElementsForXPath(document, xPath: "//program/objectList/object[1]/scriptList/script[1]/brickList/brick[15]")
        XCTAssertEqual(brickElement!.count, 1)

        let brickXMLElement = brickElement!.first
        let brick = self.parserContext!.parse(from: brickXMLElement, withClass: SetColorBrick.self as? CBXMLNodeProtocol.Type) as! Brick

        XCTAssertTrue(brick.isKind(of: SetColorBrick.self), "Invalid brick class")

        let setColorBrick = brick as! SetColorBrick

        XCTAssertEqual(1, self.formulaManager.interpretInteger(setColorBrick.color, for: SpriteObject()), "Invalid formula")
    }

    func testValidChangeColorByNBrick() {
        let document = self.getXMLDocumentForPath(xmlPath: self.getPathForXML(xmlFile: "ValidProjectAllBricks093"))
        let brickElement = self.getXMLElementsForXPath(document, xPath: "//program/objectList/object[1]/scriptList/script[1]/brickList/brick[16]")
        XCTAssertEqual(brickElement!.count, 1)

        let brickXMLElement = brickElement!.first
        let brick = self.parserContext!.parse(from: brickXMLElement, withClass: ChangeColorByNBrick.self as? CBXMLNodeProtocol.Type) as! Brick

        XCTAssertTrue(brick.isKind(of: ChangeColorByNBrick.self), "Invalid brick class")

        let changeColorByNBrick = brick as! ChangeColorByNBrick
        XCTAssertEqual(2, self.formulaManager.interpretInteger(changeColorByNBrick.changeColor, for: SpriteObject()), "Invalid formula")
    }
}
