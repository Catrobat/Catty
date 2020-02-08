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

final class RequiredResources: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func getProjectWithOneSpriteWithBrick(_ brick: Brick) -> Project {
        let project = Project()
        let obj = SpriteObject()
        let script = Script()
        script.brickList.add(brick)
        obj.scriptList.add(script)
        project.objectList.add(obj)

        return project
    }

    // MARK: - Look
    func testHideBrickResources() {
        let brick = HideBrick()
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.noResources.rawValue, "Resources HideBrick not correctly calculated")
    }

    func testShowBrickResources() {
        let brick = ShowBrick()
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.noResources.rawValue, "Resources ShowBrick not correctly calculated")
    }

    func testSetTransparencyBrickResources() {
        let brick = SetTransparencyBrick()
        brick.transparency = Formula(integer: 1)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.noResources.rawValue, "Resources SetTransparencyBrick not correctly calculated")
    }

    func testSetTransparencyBrickTwoResources() {
        let brick = SetTransparencyBrick()
        let element = FormulaElement(elementType: ElementType.SENSOR, value: AccelerationXSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.transparency = Formula(formulaElement: element)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.deviceMotion.rawValue, "Resources ShowBrick not correctly calculated")
    }

    func testSetSizeBrickResources() {
        let brick = SetSizeToBrick()
        brick.size = Formula(integer: 1)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.noResources.rawValue, "Resources SetSizeToBrick not correctly calculated")
    }

    func testSetSizeBrickTwoResources() {
        let brick = SetSizeToBrick()
        let element = FormulaElement(elementType: ElementType.SENSOR, value: AccelerationYSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.size = Formula(formulaElement: element)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.deviceMotion.rawValue, "Resources SetSizeToBrick not correctly calculated")
    }

    func testSetBrightnessBrickResources() {
        let brick = SetBrightnessBrick()
        brick.brightness = Formula(integer: 1)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.noResources.rawValue, "Resources SetBrightnessBrick not correctly calculated")
    }

    func testSetBrightnessBrickTwoResources() {
        let brick = SetBrightnessBrick()
        let element = FormulaElement(elementType: ElementType.SENSOR, value: CompassDirectionSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.brightness = Formula(formulaElement: element)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.compass.rawValue, "Resources SetBrightnessBrick not correctly calculated")
    }

    func testClearGraphicEffectBrickResources() {
        let brick = ClearGraphicEffectBrick()
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.noResources.rawValue, "Resources ClearGraphicEffectBrick not correctly calculated")
    }

    func testChangeTransparencyByNBrickResources() {
        let brick = ChangeTransparencyByNBrick()
        brick.changeTransparency = Formula(integer: 1)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.noResources.rawValue, "Resources ChangeTransparencyByNBrick not correctly calculated")
    }

    func testChangeTransparencyByNBrickTwoResources() {
        let brick = ChangeTransparencyByNBrick()
        let element = FormulaElement(elementType: ElementType.SENSOR, value: InclinationXSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.changeTransparency = Formula(formulaElement: element)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.deviceMotion.rawValue, "Resources ChangeTransparencyByNBrick not correctly calculated")
    }

    func testChangeBrightnessByNBrickResources() {
        let brick = ChangeBrightnessByNBrick()
        brick.changeBrightness = Formula(integer: 1)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.noResources.rawValue, "Resources ChangeBrightnessByNBrick not correctly calculated")
    }

    func testChangeBrightnessByNBrickTwoResources() {
        let brick = ChangeBrightnessByNBrick()
        let element = FormulaElement(elementType: ElementType.SENSOR, value: InclinationXSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.changeBrightness = Formula(formulaElement: element)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.deviceMotion.rawValue, "Resources ChangeBrightnessByNBrick not correctly calculated")
    }

    func testChangeColorByNBrickResources() {
        let brick = ChangeColorByNBrick()
        brick.changeColor = Formula(integer: 1)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.noResources.rawValue, "Resources ChangeBrightnessByNBrick not correctly calculated")
    }

    func testChangeColorByNBrickTwoResources() {
        let brick = ChangeColorByNBrick()
        let element = FormulaElement(elementType: ElementType.SENSOR, value: InclinationYSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.changeColor = Formula(formulaElement: element)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.accelerometerAndDeviceMotion.rawValue, "Resources ChangeBrightnessByNBrick not correctly calculated")
    }

    func testSetColorBrickResources() {
        let brick = SetColorBrick()
        brick.color = Formula(integer: 1)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.noResources.rawValue, "Resources SetColorBrick not correctly calculated")
    }

    func testSetColorBrickTwoResources() {
        let brick = SetColorBrick()
        let element = FormulaElement(elementType: ElementType.SENSOR, value: InclinationYSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.color = Formula(formulaElement: element)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.accelerometerAndDeviceMotion.rawValue, "Resources SetColorBrick not correctly calculated")
    }
    
    // MARK: - Control
    func testWaitBrickResources() {
        let brick = WaitBrick()
        brick.timeToWaitInSeconds = Formula(integer: 1)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.noResources.rawValue, "Resources WaitBrick not correctly calculated")
    }

    func testWaitBrickTwoResources() {
        let brick = WaitBrick()
        let element = FormulaElement(elementType: ElementType.SENSOR, value: LoudnessSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.timeToWaitInSeconds = Formula(formulaElement: element)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.loudness.rawValue, "Resources WaitBrick not correctly calculated")
    }

    func testRepeatBrickResources() {
        let brick = RepeatBrick()
        brick.timesToRepeat = Formula(integer: 1)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.noResources.rawValue, "Resources RepeatBrick not correctly calculated")
    }

    func testRepeatBrickTwoResources() {
        let brick = RepeatBrick()
        let element = FormulaElement(elementType: ElementType.SENSOR, value: LoudnessSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.timesToRepeat = Formula(formulaElement: element)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.loudness.rawValue, "Resources RepeatBrick not correctly calculated")
    }

    func testNoteBrickResources() {
        let brick = NoteBrick()
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.noResources.rawValue, "Resources NoteBrick not correctly calculated")
    }

    func testIfLogicBeginBrickResources() {
        let brick = IfLogicBeginBrick()
        brick.ifCondition = Formula(integer: 1)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.noResources.rawValue, "Resources IfLogicBeginBrick not correctly calculated")
    }

    func testIfLogicBeginBrickTwoResources() {
        let brick = IfLogicBeginBrick()
        let element = FormulaElement(elementType: ElementType.SENSOR, value: LoudnessSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.ifCondition = Formula(formulaElement: element)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.loudness.rawValue, "Resources IfLogicBeginBrick not correctly calculated")
    }

    func testBroadcastBrickResources() {
        let brick = BroadcastBrick()
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.noResources.rawValue, "Resources BroadcastBrick not correctly calculated")
    }
    
    // MARK: - Data
    func testSetVariableBrickResources() {
        let brick = SetVariableBrick()
        brick.variableFormula = Formula(integer: 1)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.noResources.rawValue, "Resources SetVariableBrick not correctly calculated")
    }

    func testSetVariableBrickTwoResources() {
        let brick = SetVariableBrick()
        let element = FormulaElement(elementType: ElementType.SENSOR, value: "FACE_DETECTED", leftChild: nil, rightChild: nil, parent: nil)
        brick.variableFormula = Formula(formulaElement: element)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.faceDetection.rawValue, "Resources SetVariableBrick not correctly calculated")
    }

    func testChangeVariableBrickResources() {
        let brick = ChangeVariableBrick()
        brick.variableFormula = Formula(integer: 1)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.noResources.rawValue, "Resources ChangeVariableBrick not correctly calculated")
    }

    func testChangeVariableBrickTwoResources() {
        let brick = ChangeVariableBrick()
        let element = FormulaElement(elementType: ElementType.SENSOR, value: LoudnessSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.variableFormula = Formula(formulaElement: element)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.loudness.rawValue, "Resources ChangeVariableBrick not correctly calculated")
    }
    
    // MARK: - Sound
    func testStopAllSoundsBrickResources() {
        let brick = StopAllSoundsBrick()
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.noResources.rawValue, "Resources StopAllSoundsBrick not correctly calculated")
    }

    func testSpeakBrickResources() {
        let brick = SpeakBrick()
        brick.text = "Hallo"
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.textToSpeech.rawValue, "Resources SpeakBrick not correctly calculated")
    }

    func testSetVolumeToBrickResources() {
        let brick = SetVolumeToBrick()
        brick.volume = Formula(integer: 1)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.noResources.rawValue, "Resources SetVolumeToBrick not correctly calculated")
    }

    func testSetVolumeToBrickTwoResources() {
        let brick = SetVolumeToBrick()
        let element = FormulaElement(elementType: ElementType.SENSOR, value: PhiroBottomLeftSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.volume = Formula(formulaElement: element)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.bluetoothPhiro.rawValue, "Resources SetVolumeToBrick not correctly calculated")
    }

    func testChangeVolumeByNBrickResources() {
        let brick = ChangeVolumeByNBrick()
        brick.volume = Formula(integer: 1)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.noResources.rawValue, "Resources SetVolumeToBrick not correctly calculated")
    }

    func testChangeVolumeByNBrickTwoResources() {
        let brick = ChangeVolumeByNBrick()
        let element = FormulaElement(elementType: ElementType.SENSOR, value: PhiroBottomLeftSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.volume = Formula(formulaElement: element)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.bluetoothPhiro.rawValue, "Resources SetVolumeToBrick not correctly calculated")
    }
    
    // MARK: - IO
    func testVibrationBrickResources() {
        let brick = VibrationBrick()
        brick.durationInSeconds = Formula(integer: 1)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.vibration.rawValue, "Resources VibrationBrick not correctly calculated")
    }

    func testLedOnBrickResources() {
        let brick = FlashBrick()
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.noResources.rawValue, "Resources FlashBrick not correctly calculated")
    }
    
    // MARK: - Motion
    func testTurnRightBrickResources() {
        let brick = TurnRightBrick()
        brick.degrees = Formula(integer: 1)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.noResources.rawValue, "Resources TurnRightBrick not correctly calculated")
    }

    func testTurnRightBrickTwoResources() {
        let brick = TurnRightBrick()
        let element = FormulaElement(elementType: ElementType.SENSOR, value: PhiroBottomLeftSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.degrees = Formula(formulaElement: element)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.bluetoothPhiro.rawValue, "Resources TurnRightBrick not correctly calculated")
    }

    func testTurnLeftBrickResources() {
        let brick = TurnLeftBrick()
        brick.degrees = Formula(integer: 1)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.noResources.rawValue, "Resources TurnLeftBrick not correctly calculated")
    }

    func testTurnLeftBrickTwoResources() {
        let brick = TurnLeftBrick()
        let element = FormulaElement(elementType: ElementType.SENSOR, value: PhiroBottomLeftSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.degrees = Formula(formulaElement: element)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.bluetoothPhiro.rawValue, "Resources TurnLeftBrick not correctly calculated")
    }

    func testSetYBrickResources() {
        let brick = SetYBrick()
        brick.yPosition = Formula(integer: 1)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.noResources.rawValue, "Resources SetYBrick not correctly calculated")
    }

    func testSetYBrickTwoResources() {
        let brick = SetYBrick()
        let element = FormulaElement(elementType: ElementType.SENSOR, value: PhiroBottomLeftSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.yPosition = Formula(formulaElement: element)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.bluetoothPhiro.rawValue, "Resources SetYBrick not correctly calculated")
    }

    func testSetXBrickResources() {
        let brick = SetXBrick()
        brick.xPosition = Formula(integer: 1)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.noResources.rawValue, "Resources SetXBrick not correctly calculated")
    }

    func testSetXBrickTwoResources() {
        let brick = SetXBrick()
        let element = FormulaElement(elementType: ElementType.SENSOR, value: PhiroBottomLeftSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.xPosition = Formula(formulaElement: element)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.bluetoothPhiro.rawValue, "Resources SetXBrick not correctly calculated")
    }

    func testPointToBrickResources() {
        let brick = PointToBrick()
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.noResources.rawValue, "Resources PointToBrick not correctly calculated")
    }

    func testPointInDirectionBrickResources() {
        let brick = PointInDirectionBrick()
        brick.degrees = Formula(integer: 1)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.noResources.rawValue, "Resources PointInDirectionBrick not correctly calculated")
    }

    func testPointInDirectionBrickTwoResources() {
        let brick = PointInDirectionBrick()
        let element = FormulaElement(elementType: ElementType.SENSOR, value: PhiroBottomLeftSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.degrees = Formula(formulaElement: element)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.bluetoothPhiro.rawValue, "Resources PointInDirectionBrick not correctly calculated")
    }

    func testPlaceAtBrickResources() {
        let brick = PlaceAtBrick()
        brick.xPosition = Formula(integer: 1)
        brick.yPosition = Formula(integer: 1)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.noResources.rawValue, "Resources PlaceAtBrick not correctly calculated")
    }

    func testPlaceAtBrickTwoResources() {
        let brick = PlaceAtBrick()
        let element = FormulaElement(elementType: ElementType.SENSOR, value: PhiroBottomLeftSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.xPosition = Formula(formulaElement: element)

        brick.yPosition = Formula(formulaElement: element)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.bluetoothPhiro.rawValue, "Resources PlaceAtBrick not correctly calculated")
    }

    func testMoveNStepsBrickResources() {
        let brick = MoveNStepsBrick()
        brick.steps = Formula(integer: 1)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.noResources.rawValue, "Resources MoveNStepsBrick not correctly calculated")
    }

    func testMoveNStepsBrickTwoResources() {
        let brick = MoveNStepsBrick()
        let element = FormulaElement(elementType: ElementType.SENSOR, value: PhiroBottomLeftSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.steps = Formula(formulaElement: element)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.bluetoothPhiro.rawValue, "Resources MoveNStepsBrick not correctly calculated")
    }

    func testIfOnEdgeBounceBrickResources() {
        let brick = IfOnEdgeBounceBrick()
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.noResources.rawValue, "Resources IfOnEdgeBounceBrick not correctly calculated")
    }

    func testGoNStepsBackBrickResources() {
        let brick = GoNStepsBackBrick()
        brick.steps = Formula(integer: 1)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.noResources.rawValue, "Resources GoNStepsBackBrick not correctly calculated")
    }

    func testGoNStepsBackBrickTwoResources() {
        let brick = GoNStepsBackBrick()
        let element = FormulaElement(elementType: ElementType.SENSOR, value: PhiroBottomLeftSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.steps = Formula(formulaElement: element)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.bluetoothPhiro.rawValue, "Resources GoNStepsBackBrick not correctly calculated")
    }

    func testGlideToBrickResources() {
        let brick = GlideToBrick()
        brick.durationInSeconds = Formula(integer: 1)
        brick.xDestination = Formula(integer: 1)
        brick.yDestination = Formula(integer: 1)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.noResources.rawValue, "Resources GlideToBrick not correctly calculated")
    }

    func testGlideToBrickTwoResources() {
        let brick = GlideToBrick()
        let element = FormulaElement(elementType: ElementType.SENSOR, value: PhiroBottomLeftSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.durationInSeconds = Formula(formulaElement: element)
        brick.xDestination = Formula(formulaElement: element)
        brick.yDestination = Formula(formulaElement: element)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.bluetoothPhiro.rawValue, "Resources GlideToBrick not correctly calculated")
    }

    func testComeToFrontBrickResources() {
        let brick = ComeToFrontBrick()
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.noResources.rawValue, "Resources ComeToFrontBrick not correctly calculated")
    }

    func testChangeYByNBrickResources() {
        let brick = ChangeYByNBrick()
        let element = FormulaElement(elementType: ElementType.SENSOR, value: PhiroBottomLeftSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.yMovement = Formula(formulaElement: element)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.bluetoothPhiro.rawValue, "Resources ChangeYByNBrick not correctly calculated")
    }

    func testChangeYByNBrickTwoResources() {
        let brick = ChangeYByNBrick()
        brick.yMovement = Formula(integer: 1)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.noResources.rawValue, "Resources ChangeYByNBrick not correctly calculated")
    }

    func testChangeXByNBrickResources() {
        let brick = ChangeXByNBrick()
        brick.xMovement = Formula(integer: 1)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.noResources.rawValue, "Resources ChangeXByNBrick not correctly calculated")
    }

    func testChangeXByNBrickTwoResources() {
        let brick = ChangeXByNBrick()
        let element = FormulaElement(elementType: ElementType.SENSOR, value: PhiroBottomLeftSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.xMovement = Formula(formulaElement: element)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.bluetoothPhiro.rawValue, "Resources ChangeXByNBrick not correctly calculated")
    }

    func testChangeSizeByNBrickResources() {
        let brick = ChangeSizeByNBrick()
        brick.size = Formula(integer: 1)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.noResources.rawValue, "Resources ChangeSizeByNBrick not correctly calculated")
    }

    func testChangeSizeByNBrickTwoResources() {
        let brick = ChangeSizeByNBrick()
        let element = FormulaElement(elementType: ElementType.SENSOR, value: PhiroBottomLeftSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.size = Formula(formulaElement: element)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.bluetoothPhiro.rawValue, "Resources ChangeSizeByNBrick not correctly calculated")
    }

    // MARK: - Arduino
    func testArduinoSendDigitalValueBrickResources() {
        let brick = ArduinoSendDigitalValueBrick()
        brick.pin = Formula(integer: 1)
        brick.value = Formula(integer: 1)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.bluetoothArduino.rawValue, "Resources ArduinoSendDigitalValueBrick not correctly calculated")
    }

    func testArduinoSendPWMValueBrickResources() {
        let brick = ArduinoSendPWMValueBrick()
        brick.pin = Formula(integer: 1)
        brick.value = Formula(integer: 1)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.bluetoothArduino.rawValue, "Resources ArduinoSendPWMValueBrick not correctly calculated")
    }
    
    // MARK: - Phiro
    func testPhiroMotorMoveBackwardBrickResources() {
        let brick = PhiroMotorMoveBackwardBrick()
        brick.formula = Formula(integer: 1)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.bluetoothPhiro.rawValue, "Resources PhiroMotorMoveBackwardBrick not correctly calculated")
    }

    func testPhiroMotorMoveForwardBrickResources() {
        let brick = PhiroMotorMoveForwardBrick()
        brick.formula = Formula(integer: 1)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.bluetoothPhiro.rawValue, "Resources PhiroMotorMoveForwardBrick not correctly calculated")
    }

    func testPhiroMotorStopBrickResources() {
        let brick = PhiroMotorStopBrick()
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.bluetoothPhiro.rawValue, "Resources PhiroMotorStopBrick not correctly calculated")
    }

    func testPhiroPlayToneBrickResources() {
        let brick = PhiroPlayToneBrick()
        brick.durationFormula = Formula(integer: 1)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.bluetoothPhiro.rawValue, "Resources PhiroPlayToneBrick not correctly calculated")
    }

    func testPhiroRGBLightBrickResources() {
        let brick = PhiroRGBLightBrick()
        brick.redFormula = Formula(integer: 1)
        brick.greenFormula = Formula(integer: 1)
        brick.blueFormula = Formula(integer: 1)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.bluetoothPhiro.rawValue, "Resources PhiroRGBLightBrick not correctly calculated")
    }

    // MARK: - NestedTests
    func testNestedResources() {
        let brick = GlideToBrick()
        var element = FormulaElement(elementType: ElementType.FUNCTION, value: ArduinoAnalogPinFunction.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.durationInSeconds = Formula(formulaElement: element)
        element = FormulaElement(elementType: ElementType.SENSOR, value: AccelerationXSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.xDestination = Formula(formulaElement: element)
        element = FormulaElement(elementType: ElementType.SENSOR, value: CompassDirectionSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.yDestination = Formula(formulaElement: element)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(ResourceType.deviceMotion.rawValue, resources & ResourceType.deviceMotion.rawValue, "Resources nested not correctly calculated")
        XCTAssertEqual(ResourceType.compass.rawValue, resources & ResourceType.compass.rawValue, "Resources nested not correctly calculated")
        XCTAssertEqual(ResourceType.bluetoothArduino.rawValue, resources & ResourceType.bluetoothArduino.rawValue, "Resources nested not correctly calculated")
        XCTAssertEqual(0, resources & ResourceType.bluetoothPhiro.rawValue, "Resources nested not correctly calculated")
        XCTAssertEqual(0, resources & ResourceType.faceDetection.rawValue, "Resources nested not correctly calculated")
        XCTAssertEqual(0, resources & ResourceType.magnetometer.rawValue, "Resources nested not correctly calculated")
        XCTAssertEqual(0, resources & ResourceType.loudness.rawValue, "Resources nested not correctly calculated")
    }

    func testNestedTwoResources() {
        let brick = GlideToBrick()
        var element = FormulaElement(elementType: ElementType.SENSOR, value: "FACE_DETECTED", leftChild: nil, rightChild: nil, parent: nil)
        brick.durationInSeconds = Formula(formulaElement: element)
        element = FormulaElement(elementType: ElementType.SENSOR, value: AccelerationYSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.xDestination = Formula(formulaElement: element)
        element = FormulaElement(elementType: ElementType.SENSOR, value: LoudnessSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.yDestination = Formula(formulaElement: element)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(ResourceType.loudness.rawValue, resources & ResourceType.loudness.rawValue, "Resources nested not correctly calculated")
        XCTAssertEqual(ResourceType.deviceMotion.rawValue, resources & ResourceType.deviceMotion.rawValue, "Resources nested not correctly calculated")
        XCTAssertEqual(ResourceType.faceDetection.rawValue, resources & ResourceType.faceDetection.rawValue, "Resources nested not correctly calculated")
        XCTAssertEqual(0, resources & ResourceType.bluetoothPhiro.rawValue, "Resources nested not correctly calculated")
        XCTAssertEqual(0, resources & ResourceType.bluetoothArduino.rawValue, "Resources nested not correctly calculated")
        XCTAssertEqual(0, resources & ResourceType.magnetometer.rawValue, "Resources nested not correctly calculated")
        XCTAssertEqual(0, resources & ResourceType.compass.rawValue, "Resources nested not correctly calculated")
    }

    func testNestedVibrationBrickResources() {
        let brick = VibrationBrick()
        let element = FormulaElement(elementType: ElementType.SENSOR, value: LoudnessSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.durationInSeconds = Formula(formulaElement: element)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(ResourceType.vibration.rawValue, resources & ResourceType.vibration.rawValue, "Resources nested not correctly calculated")
        XCTAssertEqual(ResourceType.loudness.rawValue, resources & ResourceType.loudness.rawValue, "Resources nested not correctly calculated")
        XCTAssertEqual(0, resources & ResourceType.bluetoothPhiro.rawValue, "Resources nested not correctly calculated")
    }

    func testNestedArduinoSendDigitalValueBrickResources() {
        let brick = ArduinoSendDigitalValueBrick()
        var element = FormulaElement(elementType: ElementType.SENSOR, value: LoudnessSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.pin = Formula(formulaElement: element)
        element = FormulaElement(elementType: ElementType.SENSOR, value: AccelerationYSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.value = Formula(formulaElement: element)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(ResourceType.bluetoothArduino.rawValue, resources & ResourceType.bluetoothArduino.rawValue, "Resources nested not correctly calculated")
        XCTAssertEqual(ResourceType.deviceMotion.rawValue, resources & ResourceType.deviceMotion.rawValue, "Resources nested not correctly calculated")
        XCTAssertEqual(ResourceType.loudness.rawValue, resources & ResourceType.loudness.rawValue, "Resources nested not correctly calculated")
        XCTAssertEqual(0, resources & ResourceType.bluetoothPhiro.rawValue, "Resources nested not correctly calculated")
        XCTAssertEqual(0, resources & ResourceType.magnetometer.rawValue, "Resources nested not correctly calculated")
        XCTAssertEqual(0, resources & ResourceType.compass.rawValue, "Resources nested not correctly calculated")
    }

    func testNestedArduinoSendPWMValueBrickResources() {
        let brick = ArduinoSendPWMValueBrick()
        var element = FormulaElement(elementType: ElementType.SENSOR, value: LoudnessSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.pin = Formula(formulaElement: element)
        element = FormulaElement(elementType: ElementType.SENSOR, value: AccelerationYSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.value = Formula(formulaElement: element)
        let project = getProjectWithOneSpriteWithBrick(brick)

        let resources = project.getRequiredResources()
        XCTAssertEqual(ResourceType.bluetoothArduino.rawValue, resources & ResourceType.bluetoothArduino.rawValue, "Resources nested not correctly calculated")
        XCTAssertEqual(ResourceType.deviceMotion.rawValue, resources & ResourceType.deviceMotion.rawValue, "Resources nested not correctly calculated")
        XCTAssertEqual(ResourceType.loudness.rawValue, resources & ResourceType.loudness.rawValue, "Resources nested not correctly calculated")
        XCTAssertEqual(0, resources & ResourceType.bluetoothPhiro.rawValue, "Resources nested not correctly calculated")
        XCTAssertEqual(0, resources & ResourceType.magnetometer.rawValue, "Resources nested not correctly calculated")
        XCTAssertEqual(0, resources & ResourceType.compass.rawValue, "Resources nested not correctly calculated")
    }

    // MARK: - MoreScripts
    func getProjectWithTwoScriptsWithBricks(_ brickArray: [Brick?], andBrickArray2 brickArray2: [Brick?]) -> Project {
        let project = Project()
        let obj = SpriteObject()
        let script = Script()
        let script2 = Script()
        for case let brick? in brickArray {
            script.brickList.add(brick)
         }
        for case let brick? in brickArray2 {
            script2.brickList.add(brick)
         }
        obj.scriptList.add(script)
        obj.scriptList.add(script2)
        project.objectList.add(obj)

        return project
    }

    func testNestedResourcesTwoScripts() {
        let brick = PlaceAtBrick()
        var element = FormulaElement(elementType: ElementType.SENSOR, value: ArduinoAnalogPinFunction.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.xPosition = Formula(formulaElement: element)
        element = FormulaElement(elementType: ElementType.SENSOR, value: AccelerationXSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.yPosition = Formula(formulaElement: element)
        let brick1 = GlideToBrick()
        element = FormulaElement(elementType: ElementType.SENSOR, value: "FACE_DETECTED", leftChild: nil, rightChild: nil, parent: nil)
        brick1.durationInSeconds = Formula(formulaElement: element)
        element = FormulaElement(elementType: ElementType.SENSOR, value: AccelerationYSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick1.xDestination = Formula(formulaElement: element)
        element = FormulaElement(elementType: ElementType.SENSOR, value: LoudnessSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick1.yDestination = Formula(formulaElement: element)
        let brickArray = [brick, brick1, nil]
        let brick2 = WaitBrick()
        brick2.timeToWaitInSeconds = Formula(integer: 1)
        let brick3 = HideBrick()
        let brick4 = ArduinoSendPWMValueBrick()
        element = FormulaElement(elementType: ElementType.SENSOR, value: LoudnessSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick4.pin = Formula(formulaElement: element)
        element = FormulaElement(elementType: ElementType.SENSOR, value: AccelerationYSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick4.value = Formula(formulaElement: element)
        let brickArray2 = [brick2, brick3, brick4, nil]

        let project = self.getProjectWithTwoScriptsWithBricks(brickArray, andBrickArray2: brickArray2)

        let resources = project.getRequiredResources()
        XCTAssertEqual(ResourceType.deviceMotion.rawValue, resources & ResourceType.deviceMotion.rawValue, "Resources nested not correctly calculated")
        XCTAssertEqual(ResourceType.loudness.rawValue, resources & ResourceType.loudness.rawValue, "Resources nested not correctly calculated")
        XCTAssertEqual(ResourceType.bluetoothArduino.rawValue, resources & ResourceType.bluetoothArduino.rawValue, "Resources nested not correctly calculated")
        XCTAssertEqual(0, resources & ResourceType.bluetoothPhiro.rawValue, "Resources nested not correctly calculated")
        XCTAssertEqual(ResourceType.faceDetection.rawValue, resources & ResourceType.faceDetection.rawValue, "Resources nested not correctly calculated")
        XCTAssertEqual(0, resources & ResourceType.magnetometer.rawValue, "Resources nested not correctly calculated")
        XCTAssertEqual(0, resources & ResourceType.compass.rawValue, "Resources nested not correctly calculated")
    }

    func testNestedResourcesTwoScriptsTwo() {
        let brick = SetXBrick()
        var element = FormulaElement(elementType: ElementType.SENSOR, value: CompassDirectionSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.xPosition = Formula(formulaElement: element)
        let brick1 = GlideToBrick()
        element = FormulaElement(elementType: ElementType.SENSOR, value: AccelerationXSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick1.durationInSeconds = Formula(formulaElement: element)
        element = FormulaElement(elementType: ElementType.SENSOR, value: AccelerationYSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick1.xDestination = Formula(formulaElement: element)
        element = FormulaElement(elementType: ElementType.SENSOR, value: AccelerationZSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick1.yDestination = Formula(formulaElement: element)
        let brickArray = [brick, brick1, nil]
        let brick2 = WaitBrick()
        brick2.timeToWaitInSeconds = Formula(integer: 1)
        let brick3 = HideBrick()

        let brick4 = ChangeTransparencyByNBrick()
         element = FormulaElement(elementType: ElementType.SENSOR, value: LoudnessSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick4.changeTransparency = Formula(formulaElement: element)

        let brickArray2 = [brick2, brick3, brick4, nil]

        let project = self.getProjectWithTwoScriptsWithBricks(brickArray, andBrickArray2: brickArray2)

        let resources = project.getRequiredResources()
        XCTAssertEqual(ResourceType.deviceMotion.rawValue, resources & ResourceType.deviceMotion.rawValue, "Resources nested not correctly calculated")
        XCTAssertEqual(ResourceType.loudness.rawValue, resources & ResourceType.loudness.rawValue, "Resources nested not correctly calculated")
        XCTAssertEqual(0, resources & ResourceType.bluetoothArduino.rawValue, "Resources nested not correctly calculated")
        XCTAssertEqual(0, resources & ResourceType.bluetoothPhiro.rawValue, "Resources nested not correctly calculated")
        XCTAssertEqual(0, resources & ResourceType.faceDetection.rawValue, "Resources nested not correctly calculated")
        XCTAssertEqual(0, resources & ResourceType.magnetometer.rawValue, "Resources nested not correctly calculated")
        XCTAssertEqual(ResourceType.compass.rawValue, resources & ResourceType.compass.rawValue, "Resources nested not correctly calculated")
    }

    // MARK: - MoreSprites
    func getProjectWithTwoSpritesWithBricks(_ brickArray: [Brick?], andBrickArray2 brickArray2: [Brick?]) -> Project {
        let project = Project()
        let obj = SpriteObject()
        let obj1 = SpriteObject()
        let script = Script()
        let script2 = Script()
        for case let brick? in brickArray {
            script.brickList.add(brick)
         }
        for case let brick? in brickArray2 {
            script2.brickList.add(brick)
         }
        obj.scriptList.add(script)
        obj1.scriptList.add(script2)
        project.objectList.add(obj)
        project.objectList.add(obj1)

        return project
    }

    func testNestedResourcesTwoSprites() {
        let brick = PlaceAtBrick()
        var element = FormulaElement(elementType: ElementType.SENSOR, value: PhiroSideLeftSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.xPosition = Formula(formulaElement: element)
        element = FormulaElement(elementType: ElementType.SENSOR, value: AccelerationXSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.yPosition = Formula(formulaElement: element)
        let brick1 = GlideToBrick()
        element = FormulaElement(elementType: ElementType.SENSOR, value: "FACE_DETECTED", leftChild: nil, rightChild: nil, parent: nil)
        brick1.durationInSeconds = Formula(formulaElement: element)
        element = FormulaElement(elementType: ElementType.SENSOR, value: AccelerationYSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick1.xDestination = Formula(formulaElement: element)
        element = FormulaElement(elementType: ElementType.SENSOR, value: LoudnessSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick1.yDestination = Formula(formulaElement: element)
        let brickArray: [Brick?] = [brick, brick1, nil]
        let brick2 = WaitBrick()
        brick2.timeToWaitInSeconds = Formula(integer: 1)
        let brick3 = HideBrick()
        let brick4 = ArduinoSendPWMValueBrick()
        element = FormulaElement(elementType: ElementType.SENSOR, value: LoudnessSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick4.pin = Formula(formulaElement: element)
        element = FormulaElement(elementType: ElementType.SENSOR, value: AccelerationYSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick4.value = Formula(formulaElement: element)
        let brickArray2: [Brick?] = [brick2, brick3, brick4, nil]

        let project = self.getProjectWithTwoSpritesWithBricks(brickArray, andBrickArray2: brickArray2)

        let resources = project.getRequiredResources()
        XCTAssertEqual(ResourceType.deviceMotion.rawValue, resources & ResourceType.deviceMotion.rawValue, "Resources nested not correctly calculated")
        XCTAssertEqual(ResourceType.loudness.rawValue, resources & ResourceType.loudness.rawValue, "Resources nested not correctly calculated")
        XCTAssertEqual(ResourceType.bluetoothArduino.rawValue, resources & ResourceType.bluetoothArduino.rawValue, "Resources nested not correctly calculated")
        XCTAssertEqual(ResourceType.bluetoothPhiro.rawValue, resources & ResourceType.bluetoothPhiro.rawValue, "Resources nested not correctly calculated")
        XCTAssertEqual(ResourceType.faceDetection.rawValue, resources & ResourceType.faceDetection.rawValue, "Resources nested not correctly calculated")
        XCTAssertEqual(0, resources & ResourceType.magnetometer.rawValue, "Resources nested not correctly calculated")
        XCTAssertEqual(0, resources & ResourceType.compass.rawValue, "Resources nested not correctly calculated")
    }

    func testNestedResourcesTwoSpritesTwo() {
        let brick = SetXBrick()
        var element = FormulaElement(elementType: ElementType.SENSOR, value: CompassDirectionSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.xPosition = Formula(formulaElement: element)
        let brick1 = GlideToBrick()
        element = FormulaElement(elementType: ElementType.SENSOR, value: AccelerationXSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick1.durationInSeconds = Formula(formulaElement: element)
        element = FormulaElement(elementType: ElementType.SENSOR, value: AccelerationYSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick1.xDestination = Formula(formulaElement: element)
        element = FormulaElement(elementType: ElementType.SENSOR, value: AccelerationZSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick1.yDestination = Formula(formulaElement: element)
        let brickArray: [Brick?] = [brick, brick1, nil]
        let brick2 = WaitBrick()
        brick2.timeToWaitInSeconds = Formula(integer: 1)
        let brick3 = HideBrick()

        let brick4 = ChangeTransparencyByNBrick()
        element = FormulaElement(elementType: ElementType.SENSOR, value: LoudnessSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick4.changeTransparency = Formula(formulaElement: element)

        let brickArray2: [Brick?] = [brick2, brick3, brick4, nil]

        let project = self.getProjectWithTwoSpritesWithBricks(brickArray, andBrickArray2: brickArray2)

        let resources = project.getRequiredResources()
        XCTAssertEqual(ResourceType.deviceMotion.rawValue, resources & ResourceType.deviceMotion.rawValue, "Resources nested not correctly calculated")
        XCTAssertEqual(ResourceType.loudness.rawValue, resources & ResourceType.loudness.rawValue, "Resources nested not correctly calculated")
        XCTAssertEqual(0, resources & ResourceType.bluetoothArduino.rawValue, "Resources nested not correctly calculated")
        XCTAssertEqual(0, resources & ResourceType.bluetoothPhiro.rawValue, "Resources nested not correctly calculated")
        XCTAssertEqual(0, resources & ResourceType.faceDetection.rawValue, "Resources nested not correctly calculated")
        XCTAssertEqual(0, resources & ResourceType.magnetometer.rawValue, "Resources nested not correctly calculated")
        XCTAssertEqual(ResourceType.compass.rawValue, resources & ResourceType.compass.rawValue, "Resources nested not correctly calculated")
    }

    // MARK: - Location
    func testLocationResources() {
        let formulaElement = FormulaElement(elementType: ElementType.SENSOR, value: LongitudeSensor.tag, leftChild: nil, rightChild: nil, parent: nil)

        let brick = ChangeSizeByNBrick()
        brick.size = Formula(formulaElement: formulaElement)
        let project = getProjectWithOneSpriteWithBrick(brick)

        XCTAssertEqual(ResourceType.location.rawValue, project.getRequiredResources(), "Resources for Longitude not correctly calculated")

        formulaElement?.value = LatitudeSensor.tag
        XCTAssertEqual(ResourceType.location.rawValue, project.getRequiredResources(), "Resources for Latitude not correctly calculated")

        formulaElement?.value = AltitudeSensor.tag
        XCTAssertEqual(ResourceType.location.rawValue, project.getRequiredResources(), "Resources for Altitude not correctly calculated")

        formulaElement?.value = LocationAccuracySensor.tag
        XCTAssertEqual(ResourceType.location.rawValue, project.getRequiredResources(), "Resources for Location Accuracy not correctly calculated")

        brick.size = Formula(integer: 0)
        XCTAssertEqual(ResourceType.noResources.rawValue, project.getRequiredResources(), "Resources for Location not correctly calculated")
    }
}
