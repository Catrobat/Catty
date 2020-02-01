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

final class RequiredResourcesTests: XCTestCase {
    func setUp() {
    	let screenSize = Util.screenSize(true)
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func getProjectWithOneSpriteWithBrick(brick:Brick?) -> Project? {
        let project = Project()
        let obj = SpriteObject()
        let script = Script()
        if let brick = brick {
            script.brickList.append(brick)
        }
        obj.scriptList.append(script)
        project.objectList.append(obj)

        return project
    }

// MARK:-Look
    func testHideBrickResources() {
        let brick = HideBrick()
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kNoResources, "Resourses HideBrick not correctly calculated")
    }

    func testShowBrickResources() {
        let brick = ShowBrick()
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kNoResources, "Resourses ShowBrick not correctly calculated")
    }

    func testSetTransparencyBrickResources() {
        let brick = SetTransparencyBrick()
        brick.transparency = Formula(value: 1)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kNoResources, "Resourses SetTransparencyBrick not correctly calculated")
    }

    func testSetTransparencyBrick2Resources() {
        let brick = SetTransparencyBrick()
        let element = FormulaElement(elementType: SENSOR, value: AccelerationXSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.transparency = Formula(formulaElement: element)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kDeviceMotion, "Resourses ShowBrick not correctly calculated")
    }

    func testSetSizeBrickResources() {
        var brick = SetSizeToBrick()
        brick.size = Formula(value: 1)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kNoResources, "Resourses SetSizeToBrick not correctly calculated")
    }

    func testSetSizeBrick2Resources() {
        var brick = SetSizeToBrick()
        let element = FormulaElement(elementType: SENSOR, value: AccelerationYSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.size = Formula(formulaElement: element)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kDeviceMotion, "Resourses SetSizeToBrick not correctly calculated")
    }

    func testSetBrightnessBrickResources() {
        let brick = SetBrightnessBrick()
        brick.brightness = Formula(value: 1)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kNoResources, "Resourses SetBrightnessBrick not correctly calculated")
    }

    func testSetBrightnessBrick2Resources() {
        let brick = SetBrightnessBrick()
        let element = FormulaElement(elementType: SENSOR, value: CompassDirectionSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.brightness = Formula(formulaElement: element)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kCompass, "Resourses SetBrightnessBrick not correctly calculated")
    }

    func testClearGraphicEffectBrickResources() {
        let brick = ClearGraphicEffectBrick()
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kNoResources, "Resourses ClearGraphicEffectBrick not correctly calculated")
    }

    func testChangeTransparencyByNBrickResources() {
        let brick = ChangeTransparencyByNBrick()
        brick.changeTransparency = Formula(value: 1)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kNoResources, "Resourses ChangeTransparencyByNBrick not correctly calculated")
    }

    func testChangeTransparencyByNBrick2Resources() {
        let brick = ChangeTransparencyByNBrick()
        let element = FormulaElement(elementType: SENSOR, value: InclinationXSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.changeTransparency = Formula(formulaElement: element)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kDeviceMotion, "Resourses ChangeTransparencyByNBrick not correctly calculated")
    }

    func testChangeBrightnessByNBrickResources() {
        let brick = ChangeBrightnessByNBrick()
        brick.changeBrightness = Formula(value: 1)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kNoResources, "Resourses ChangeBrightnessByNBrick not correctly calculated")
    }

    func testChangeBrightnessByNBrick2Resources() {
        let brick = ChangeBrightnessByNBrick()
        let element = FormulaElement(elementType: SENSOR, value: InclinationXSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.changeBrightness = Formula(formulaElement: element)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kDeviceMotion, "Resourses ChangeBrightnessByNBrick not correctly calculated")
    }

    func testChangeColorByNBrickResources() {
        let brick = ChangeColorByNBrick()
        brick.changeColor = Formula(value: 1)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kNoResources, "Resourses ChangeBrightnessByNBrick not correctly calculated")
    }

    func testChangeColorByNBrick2Resources() {
        let brick = ChangeColorByNBrick()
        let element = FormulaElement(elementType: SENSOR, value: InclinationYSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.changeColor = Formula(formulaElement: element)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kAccelerometerAndDeviceMotion, "Resourses ChangeBrightnessByNBrick not correctly calculated")
    }

    func testSetColorBrickResources() {
        let brick = SetColorBrick()
        brick.color = Formula(value: 1)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kNoResources, "Resourses SetColorBrick not correctly calculated")
    }

    func testSetColorBrick2Resources() {
        let brick = SetColorBrick()
        let element = FormulaElement(elementType: SENSOR, value: InclinationYSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.color = Formula(formulaElement: element)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kAccelerometerAndDeviceMotion, "Resourses SetColorBrick not correctly calculated")
    }

// MARK:-Control
    func testWaitBrickResources() {
        let brick = WaitBrick()
        brick.timeToWaitInSeconds = Formula(value: 1)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kNoResources, "Resourses WaitBrick not correctly calculated")
    }

    func testWaitBrick2Resources() {
        let brick = WaitBrick()
        let element = FormulaElement(elementType: SENSOR, value: LoudnessSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.timeToWaitInSeconds = Formula(formulaElement: element)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kLoudness, "Resourses WaitBrick not correctly calculated")
    }

    func testRepeatBrickResources() {
        let brick = RepeatBrick()
        brick.timesToRepeat = Formula(value: 1)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kNoResources, "Resourses RepeatBrick not correctly calculated")
    }

    func testRepeatBrick2Resources() {
        let brick = RepeatBrick()
        let element = FormulaElement(elementType: SENSOR, value: LoudnessSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.timesToRepeat = Formula(formulaElement: element)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kLoudness, "Resourses RepeatBrick not correctly calculated")
    }

    func testNoteBrickResources() {
        let brick = NoteBrick()
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kNoResources, "Resourses NoteBrick not correctly calculated")
    }

    func testIfLogicBeginBrickResources() {
        let brick = IfLogicBeginBrick()
        brick.ifCondition = Formula(value: 1)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kNoResources, "Resourses IfLogicBeginBrick not correctly calculated")
    }

    func testIfLogicBeginBrick2Resources() {
        let brick = IfLogicBeginBrick()
        let element = FormulaElement(elementType: SENSOR, value: LoudnessSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.ifCondition = Formula(formulaElement: element)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kLoudness, "Resourses IfLogicBeginBrick not correctly calculated")
    }

    func testBroadcastBrickResources() {
        let brick = BroadcastBrick()
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kNoResources, "Resourses BroadcastBrick not correctly calculated")
    }

// MARK:-Data
    func testSetVariableBrickResources() {
        let brick = SetVariableBrick()
        brick.variableFormula = Formula(value: 1)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kNoResources, "Resourses SetVariableBrick not correctly calculated")
    }

    func testSetVariableBrick2Resources() {
        let brick = SetVariableBrick()
        let element = FormulaElement(elementType: SENSOR, value: "FACE_DETECTED", leftChild: nil, rightChild: nil, parent: nil)
        brick.variableFormula = Formula(formulaElement: element)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kFaceDetection, "Resourses SetVariableBrick not correctly calculated")
    }

    func testChangeVariableBrickResources() {
        let brick = ChangeVariableBrick()
        brick.variableFormula = Formula(value: 1)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kNoResources, "Resourses ChangeVariableBrick not correctly calculated")
    }

    func testChangeVariableBrick2Resources() {
        let brick = ChangeVariableBrick()
        let element = FormulaElement(elementType: SENSOR, value: LoudnessSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.variableFormula = Formula(formulaElement: element)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kLoudness, "Resourses ChangeVariableBrick not correctly calculated")
    }

// MARK:-Sound
    func testStopAllSoundsBrickResources() {
        let brick = StopAllSoundsBrick()
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kNoResources, "Resourses StopAllSoundsBrick not correctly calculated")
    }

    func testSpeakBrickResources() {
        let brick = SpeakBrick()
        brick.text = "Hallo"
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kTextToSpeech, "Resourses SpeakBrick not correctly calculated")
    }

    func testSetVolumeToBrickResources() {
        let brick = SetVolumeToBrick()
        brick.volume = Formula(value: 1)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kNoResources, "Resourses SetVolumeToBrick not correctly calculated")
    }

    func testSetVolumeToBrick2Resources() {
        let brick = SetVolumeToBrick()
        let element = FormulaElement(elementType: SENSOR, value: PhiroBottomLeftSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.volume = Formula(formulaElement: element)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kBluetoothPhiro, "Resourses SetVolumeToBrick not correctly calculated")
    }

    func testChangeVolumeByNBrickResources() {
        let brick = ChangeVolumeByNBrick()
        brick.volume = Formula(value: 1)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kNoResources, "Resourses SetVolumeToBrick not correctly calculated")
    }

    func testChangeVolumeByNBrick2Resources() {
        let brick = ChangeVolumeByNBrick()
        let element = FormulaElement(elementType: SENSOR, value: PhiroBottomLeftSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.volume = Formula(formulaElement: element)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kBluetoothPhiro, "Resourses SetVolumeToBrick not correctly calculated")
    }

// MARK:-IO
    func testVibrationBrickResources() {
        let brick = VibrationBrick()
        brick.durationInSeconds = Formula(value: 1)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kVibration, "Resourses VibrationBrick not correctly calculated")
    }

    func testLedOnBrickResources() {
        let brick = FlashBrick()
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kNoResources, "Resourses FlashBrick not correctly calculated")
    }

// MARK:-Motion
    func testTurnRightBrickResources() {
        let brick = TurnRightBrick()
        brick.degrees = Formula(value: 1)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kNoResources, "Resourses TurnRightBrick not correctly calculated")
    }

    func testTurnRightBrick2Resources() {
        let brick = TurnRightBrick()
        let element = FormulaElement(elementType: SENSOR, value: PhiroBottomLeftSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.degrees = Formula(formulaElement: element)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kBluetoothPhiro, "Resourses TurnRightBrick not correctly calculated")
    }

    func testTurnLeftBrickResources() {
        let brick = TurnLeftBrick()
        brick.degrees = Formula(value: 1)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kNoResources, "Resourses TurnLeftBrick not correctly calculated")
    }

    func testTurnLeftBrick2Resources() {
        let brick = TurnLeftBrick()
        let element = FormulaElement(elementType: SENSOR, value: PhiroBottomLeftSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.degrees = Formula(formulaElement: element)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kBluetoothPhiro, "Resourses TurnLeftBrick not correctly calculated")
    }

    func testSetYBrickResources() {
        let brick = SetYBrick()
        brick.yPosition = Formula(value: 1)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kNoResources, "Resourses SetYBrick not correctly calculated")
    }

    func testSetYBrick2Resources() {
        let brick = SetYBrick()
        let element = FormulaElement(elementType: SENSOR, value: PhiroBottomLeftSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.yPosition = Formula(formulaElement: element)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kBluetoothPhiro, "Resourses SetYBrick not correctly calculated")
    }

    func testSetXBrickResources() {
        let brick = SetXBrick()
        brick.xPosition = Formula(value: 1)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kNoResources, "Resourses SetXBrick not correctly calculated")
    }

    func testSetXBrick2Resources() {
        let brick = SetXBrick()
        let element = FormulaElement(elementType: SENSOR, value: PhiroBottomLeftSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.xPosition = Formula(formulaElement: element)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kBluetoothPhiro, "Resourses SetXBrick not correctly calculated")
    }

    func testPointToBrickResources() {
        let brick = PointToBrick()
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kNoResources, "Resourses PointToBrick not correctly calculated")
    }

    func testPointInDirectionBrickResources() {
        let brick = PointInDirectionBrick()
        brick.degrees = Formula(value: 1)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kNoResources, "Resourses PointInDirectionBrick not correctly calculated")
    }

    func testPointInDirectionBrick2Resources() {
        let brick = PointInDirectionBrick()
        let element = FormulaElement(elementType: SENSOR, value: PhiroBottomLeftSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.degrees = Formula(formulaElement: element)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kBluetoothPhiro, "Resourses PointInDirectionBrick not correctly calculated")
    }

    func testPlaceAtBrickResources() {
        let brick = PlaceAtBrick()
        brick.xPosition = Formula(value: 1)
        brick.yPosition = Formula(value: 1)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kNoResources, "Resourses PlaceAtBrick not correctly calculated")
    }

    func testPlaceAtBrick2Resources() {
        let brick = PlaceAtBrick()
        let element = FormulaElement(elementType: SENSOR, value: PhiroBottomLeftSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.xPosition = Formula(formulaElement: element)

        brick.yPosition = Formula(formulaElement: element)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kBluetoothPhiro, "Resourses PlaceAtBrick not correctly calculated")
    }

    func testMoveNStepsBrickResources() {
        let brick = MoveNStepsBrick()
        brick.steps = Formula(value: 1)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kNoResources, "Resourses MoveNStepsBrick not correctly calculated")
    }

    func testMoveNStepsBrick2Resources() {
        let brick = MoveNStepsBrick()
        let element = FormulaElement(elementType: SENSOR, value: PhiroBottomLeftSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.steps = Formula(formulaElement: element)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kBluetoothPhiro, "Resourses MoveNStepsBrick not correctly calculated")
    }

    func testIfOnEdgeBounceBrickResources() {
        let brick = IfOnEdgeBounceBrick()
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kNoResources, "Resourses IfOnEdgeBounceBrick not correctly calculated")
    }

    func testGoNStepsBackBrickResources() {
        let brick = GoNStepsBackBrick()
        brick.steps = Formula(value: 1)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kNoResources, "Resourses GoNStepsBackBrick not correctly calculated")
    }

    func testGoNStepsBackBrick2Resources() {
        let brick = GoNStepsBackBrick()
        let element = FormulaElement(elementType: SENSOR, value: PhiroBottomLeftSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.steps = Formula(formulaElement: element)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kBluetoothPhiro, "Resourses GoNStepsBackBrick not correctly calculated")
    }

    func testGlideToBrickResources() {
        let brick = GlideToBrick()
        brick.durationInSeconds = Formula(value: 1)
        brick.xDestination = Formula(value: 1)
        brick.yDestination = Formula(value: 1)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kNoResources, "Resourses GlideToBrick not correctly calculated")
    }

    func testGlideToBrick2Resources() {
        let brick = GlideToBrick()
        let element = FormulaElement(elementType: SENSOR, value: PhiroBottomLeftSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.durationInSeconds = Formula(formulaElement: element)
        brick.xDestination = Formula(formulaElement: element)
        brick.yDestination = Formula(formulaElement: element)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kBluetoothPhiro, "Resourses GlideToBrick not correctly calculated")
    }

    func testComeToFrontBrickResources() {
        let brick = ComeToFrontBrick()
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kNoResources, "Resourses ComeToFrontBrick not correctly calculated")
    }

    func testChangeYByNBrickResources() {
        let brick = ChangeYByNBrick()
        let element = FormulaElement(elementType: SENSOR, value: PhiroBottomLeftSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.yMovement = Formula(formulaElement: element)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kBluetoothPhiro, "Resourses ChangeYByNBrick not correctly calculated")
    }

    func testChangeYByNBrick2Resources() {
        let brick = ChangeYByNBrick()
        brick.yMovement = Formula(value: 1)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kNoResources, "Resourses ChangeYByNBrick not correctly calculated")
    }

    func testChangeXByNBrickResources() {
        let brick = ChangeXByNBrick()
        brick.xMovement = Formula(value: 1)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kNoResources, "Resourses ChangeXByNBrick not correctly calculated")
    }

    func testChangeXByNBrick2Resources() {
        let brick = ChangeXByNBrick()
        let element = FormulaElement(elementType: SENSOR, value: PhiroBottomLeftSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.xMovement = Formula(formulaElement: element)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kBluetoothPhiro, "Resourses ChangeXByNBrick not correctly calculated")
    }

    func testChangeSizeByNBrickResources() {
        var brick = ChangeSizeByNBrick()
        brick.size = Formula(value: 1)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kNoResources, "Resourses ChangeSizeByNBrick not correctly calculated")
    }

    func testChangeSizeByNBrick2Resources() {
        var brick = ChangeSizeByNBrick()
        let element = FormulaElement(elementType: SENSOR, value: PhiroBottomLeftSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.size = Formula(formulaElement: element)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kBluetoothPhiro, "Resourses ChangeSizeByNBrick not correctly calculated")
    }

// MARK:-Arduino
    func testArduinoSendDigitalValueBrickResources() {
        let brick = ArduinoSendDigitalValueBrick()
        brick.pin = Formula(value: 1)
        brick.value = Formula(value: 1)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kBluetoothArduino, "Resourses ArduinoSendDigitalValueBrick not correctly calculated")
    }

    func testArduinoSendPWMValueBrickResources() {
        let brick = ArduinoSendPWMValueBrick()
        brick.pin = Formula(value: 1)
        brick.value = Formula(value: 1)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kBluetoothArduino, "Resourses ArduinoSendPWMValueBrick not correctly calculated")
    }

// MARK:-Phiro
    func testPhiroMotorMoveBackwardBrickResources() {
        let brick = PhiroMotorMoveBackwardBrick()
        brick.formula = Formula(value: 1)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kBluetoothPhiro, "Resourses PhiroMotorMoveBackwardBrick not correctly calculated")
    }

    func testPhiroMotorMoveForwardBrickResources() {
        let brick = PhiroMotorMoveForwardBrick()
        brick.formula = Formula(value: 1)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kBluetoothPhiro, "Resourses PhiroMotorMoveForwardBrick not correctly calculated")
    }

    func testPhiroMotorStopBrickResources() {
        let brick = PhiroMotorStopBrick()
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kBluetoothPhiro, "Resourses PhiroMotorStopBrick not correctly calculated")
    }

    func testPhiroPlayToneBrickResources() {
        let brick = PhiroPlayToneBrick()
        brick.durationFormula = Formula(value: 1)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kBluetoothPhiro, "Resourses PhiroPlayToneBrick not correctly calculated")
    }

    func testPhiroRGBLightBrickResources() {
        let brick = PhiroRGBLightBrick()
        brick.redFormula = Formula(value: 1)
        brick.greenFormula = Formula(value: 1)
        brick.blueFormula = Formula(value: 1)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(resources, kBluetoothPhiro, "Resourses PhiroRGBLightBrick not correctly calculated")
    }

// MARK:-NestedTests
    func testNestedResources() {
        let brick = GlideToBrick()
        var element = FormulaElement(elementType: FUNCTION, value: ArduinoAnalogPinFunction.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.durationInSeconds = Formula(formulaElement: element)
        element = FormulaElement(elementType: SENSOR, value: AccelerationXSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.xDestination = Formula(formulaElement: element)
        element = FormulaElement(elementType: SENSOR, value: CompassDirectionSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.yDestination = Formula(formulaElement: element)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(kDeviceMotion, resources & kDeviceMotion, "Resourses nested not correctly calculated")
        XCTAssertEqual(kCompass, resources & kCompass, "Resourses nested not correctly calculated")
        XCTAssertEqual(kBluetoothArduino, resources & kBluetoothArduino, "Resourses nested not correctly calculated")
        XCTAssertEqual(0, resources & kBluetoothPhiro, "Resourses nested not correctly calculated")
        XCTAssertEqual(0, resources & kFaceDetection, "Resourses nested not correctly calculated")
        XCTAssertEqual(0, resources & kMagnetometer, "Resourses nested not correctly calculated")
        XCTAssertEqual(0, resources & kLoudness, "Resourses nested not correctly calculated")
    }

    func testNested2Resources() {
        let brick = GlideToBrick()
        var element = FormulaElement(elementType: SENSOR, value: "FACE_DETECTED", leftChild: nil, rightChild: nil, parent: nil)
        brick.durationInSeconds = Formula(formulaElement: element)
        element = FormulaElement(elementType: SENSOR, value: AccelerationYSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.xDestination = Formula(formulaElement: element)
        element = FormulaElement(elementType: SENSOR, value: LoudnessSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.yDestination = Formula(formulaElement: element)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(kLoudness, resources & kLoudness, "Resourses nested not correctly calculated")
        XCTAssertEqual(kDeviceMotion, resources & kDeviceMotion, "Resourses nested not correctly calculated")
        XCTAssertEqual(kFaceDetection, resources & kFaceDetection, "Resourses nested not correctly calculated")
        XCTAssertEqual(0, resources & kBluetoothPhiro, "Resourses nested not correctly calculated")
        XCTAssertEqual(0, resources & kBluetoothArduino, "Resourses nested not correctly calculated")
        XCTAssertEqual(0, resources & kMagnetometer, "Resourses nested not correctly calculated")
        XCTAssertEqual(0, resources & kCompass, "Resourses nested not correctly calculated")
    }

    func testNestedVibrationBrickResources() {
        let brick = VibrationBrick()
        let element = FormulaElement(elementType: SENSOR, value: LoudnessSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.durationInSeconds = Formula(formulaElement: element)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(kVibration, resources & kVibration, "Resourses nested not correctly calculated")
        XCTAssertEqual(kLoudness, resources & kLoudness, "Resourses nested not correctly calculated")
        XCTAssertEqual(0, resources & kBluetoothPhiro, "Resourses nested not correctly calculated")
    }

    func testNestedArduinoSendDigitalValueBrickResources() {
        let brick = ArduinoSendDigitalValueBrick()
        var element = FormulaElement(elementType: SENSOR, value: LoudnessSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.pin = Formula(formulaElement: element)
        element = FormulaElement(elementType: SENSOR, value: AccelerationYSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.value = Formula(formulaElement: element)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(kBluetoothArduino, resources & kBluetoothArduino, "Resourses nested not correctly calculated")
        XCTAssertEqual(kDeviceMotion, resources & kDeviceMotion, "Resourses nested not correctly calculated")
        XCTAssertEqual(kLoudness, resources & kLoudness, "Resourses nested not correctly calculated")
        XCTAssertEqual(0, resources & kBluetoothPhiro, "Resourses nested not correctly calculated")
        XCTAssertEqual(0, resources & kMagnetometer, "Resourses nested not correctly calculated")
        XCTAssertEqual(0, resources & kCompass, "Resourses nested not correctly calculated")
    }

    func testNestedArduinoSendPWMValueBrickResources() {
        let brick = ArduinoSendPWMValueBrick()
        var element = FormulaElement(elementType: SENSOR, value: LoudnessSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.pin = Formula(formulaElement: element)
        element = FormulaElement(elementType: SENSOR, value: AccelerationYSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.value = Formula(formulaElement: element)
        let project = getProjectWithOneSprite(with: brick)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(kBluetoothArduino, resources & kBluetoothArduino, "Resourses nested not correctly calculated")
        XCTAssertEqual(kDeviceMotion, resources & kDeviceMotion, "Resourses nested not correctly calculated")
        XCTAssertEqual(kLoudness, resources & kLoudness, "Resourses nested not correctly calculated")
        XCTAssertEqual(0, resources & kBluetoothPhiro, "Resourses nested not correctly calculated")
        XCTAssertEqual(0, resources & kMagnetometer, "Resourses nested not correctly calculated")
        XCTAssertEqual(0, resources & kCompass, "Resourses nested not correctly calculated")
    }

// MARK:-MoreScripts
    func getProjectWithTwoScriptsWithBricks(brickArray:[AnyObject]?, andBrickArray2 brickArray2:[AnyObject]?) -> Project? {
        let project = Project()
        let obj = SpriteObject()
        let script = Script()
        let script2 = Script()
        for brick in brickArray ?? [] {
            guard let brick = brick as? Brick else {
                continue
            }
            script.brickList.append(brick)
        }
        for brick in brickArray2 ?? [] {
            guard let brick = brick as? Brick else {
                continue
            }
            script2.brickList.append(brick)
        }
        obj.scriptList.append(script)
        obj.scriptList.append(script2)
        project.objectList.append(obj)

        return project
    }

    func testNestedResourcesTwoScripts(){
        let brick = PlaceAtBrick()
        var element = FormulaElement(elementType: SENSOR, value: ArduinoAnalogPinFunction.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.xPosition = Formula(formulaElement: element)
        element = FormulaElement(elementType: SENSOR, value: AccelerationXSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.yPosition = Formula(formulaElement: element)
        let brick1 = GlideToBrick()
        element = FormulaElement(elementType: SENSOR, value: "FACE_DETECTED", leftChild: nil, rightChild: nil, parent: nil)
        brick1.durationInSeconds = Formula(formulaElement: element)
        element = FormulaElement(elementType: SENSOR, value: AccelerationYSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick1.xDestination = Formula(formulaElement: element)
        element = FormulaElement(elementType: SENSOR, value: LoudnessSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick1.yDestination = Formula(formulaElement: element)
        let brickArray = [brick, brick1]
        let brick2 = WaitBrick()
        brick2.timeToWaitInSeconds = Formula(value: 1)
        let brick3 = HideBrick()
        let brick4 = ArduinoSendPWMValueBrick()
        element = FormulaElement(elementType: SENSOR, value: LoudnessSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick4.pin = Formula(formulaElement: element)
        element = FormulaElement(elementType: SENSOR, value: AccelerationYSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick4.value = Formula(formulaElement: element)
        let brickArray2 = [brick2, brick3, brick4]

        let project = getProjectWithTwoScripts(withBricks: brickArray, andBrickArray2: brickArray2)
        let resources = project.getRequiredResources()
        XCTAssertEqual(kDeviceMotion, resources & kDeviceMotion, "Resourses nested not correctly calculated")
        XCTAssertEqual(kLoudness, resources & kLoudness, "Resourses nested not correctly calculated")
        XCTAssertEqual(kBluetoothArduino, resources & kBluetoothArduino, "Resourses nested not correctly calculated")
        XCTAssertEqual(0, resources & kBluetoothPhiro, "Resourses nested not correctly calculated")
        XCTAssertEqual(kFaceDetection, resources & kFaceDetection, "Resourses nested not correctly calculated")
        XCTAssertEqual(0, resources & kMagnetometer, "Resourses nested not correctly calculated")
        XCTAssertEqual(0, resources & kCompass, "Resourses nested not correctly calculated")
    }

    func testNestedResourcesTwoScripts2() {
        let brick = SetXBrick()
        var element = FormulaElement(elementType: SENSOR, value: CompassDirectionSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.xPosition = Formula(formulaElement: element)
        let brick1 = GlideToBrick()
        element = FormulaElement(elementType: SENSOR, value: AccelerationXSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick1.durationInSeconds = Formula(formulaElement: element)
        element = FormulaElement(elementType: SENSOR, value: AccelerationYSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick1.xDestination = Formula(formulaElement: element)
        element = FormulaElement(elementType: SENSOR, value: AccelerationZSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick1.yDestination = Formula(formulaElement: element)
        let brickArray = [brick, brick1]
        let brick2 = WaitBrick()
                brick2.timeToWaitInSeconds = Formula(value: 1)
        let brick3 = HideBrick()

        let brick4 = ChangeTransparencyByNBrick()
        element = FormulaElement(elementType: SENSOR, value: LoudnessSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick4.changeTransparency = Formula(formulaElement: element)

        let brickArray2 = [brick2, brick3, brick4]

        let project = getProjectWithTwoScripts(withBricks: brickArray, andBrickArray2: brickArray2)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(kDeviceMotion, resources & kDeviceMotion, "Resourses nested not correctly calculated")
        XCTAssertEqual(kLoudness, resources & kLoudness, "Resourses nested not correctly calculated")
        XCTAssertEqual(0, resources & kBluetoothArduino, "Resourses nested not correctly calculated")
        XCTAssertEqual(0, resources & kBluetoothPhiro, "Resourses nested not correctly calculated")
        XCTAssertEqual(0, resources & kFaceDetection, "Resourses nested not correctly calculated")
        XCTAssertEqual(0, resources & kMagnetometer, "Resourses nested not correctly calculated")
        XCTAssertEqual(kCompass, resources & kCompass, "Resourses nested not correctly calculated")
    }

// MARK:-MoreSprites
    func getProjectWithTwoSpritesWithBricks(brickArray:[AnyObject]?, andBrickArray2 brickArray2:[AnyObject]?) -> Project? {
        let project = Project()
        let obj = SpriteObject()
        let obj1 = SpriteObject()
        let script = Script()
        let script2 = Script()
        for brick in brickArray ?? [] {
            guard let brick = brick as? Brick else {
                continue
            }
            script.brickList.append(brick)
        }
        for brick in brickArray2 ?? [] {
            guard let brick = brick as? Brick else {
                continue
            }
            script2.brickList.append(brick)
        }
        obj.scriptList.append(script)
        obj1.scriptList.append(script2)
        project.objectList.append(obj)
        project.objectList.append(obj1)
        return project;
}

    func testNestedResourcesTwoSprites() {
        let brick = PlaceAtBrick()
        var element = FormulaElement(elementType: SENSOR, value: PhiroSideLeftSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.xPosition = Formula(formulaElement: element)
        element = FormulaElement(elementType: SENSOR, value: AccelerationXSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.yPosition = Formula(formulaElement: element)
        let brick1 = GlideToBrick()
        element = FormulaElement(elementType: SENSOR, value: "FACE_DETECTED", leftChild: nil, rightChild: nil, parent: nil)
        brick1.durationInSeconds = Formula(formulaElement: element)
        element = FormulaElement(elementType: SENSOR, value: AccelerationYSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
                brick1.xDestination = Formula(formulaElement: element)
        element = FormulaElement(elementType: SENSOR, value: LoudnessSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick1.yDestination = Formula(formulaElement: element)
        let brickArray = [brick, brick1]
        let brick2 = WaitBrick()
        brick2.timeToWaitInSeconds = Formula(value: 1)
        let brick3 = HideBrick()
        let brick4 = ArduinoSendPWMValueBrick()
        element = FormulaElement(elementType: SENSOR, value: LoudnessSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick4.pin = Formula(formulaElement: element)
        element = FormulaElement(elementType: SENSOR, value: AccelerationYSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
                brick4.value = Formula(formulaElement: element)
        let brickArray2 = [brick2, brick3, brick4]

        let project = getProjectWithTwoSprites(withBricks: brickArray, andBrickArray2: brickArray2)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(kDeviceMotion, resources & kDeviceMotion, "Resourses nested not correctly calculated")
        XCTAssertEqual(kLoudness, resources & kLoudness, "Resourses nested not correctly calculated")
        XCTAssertEqual(kBluetoothArduino, resources & kBluetoothArduino, "Resourses nested not correctly calculated")
        XCTAssertEqual(kBluetoothPhiro, resources & kBluetoothPhiro, "Resourses nested not correctly calculated")
        XCTAssertEqual(kFaceDetection, resources & kFaceDetection, "Resourses nested not correctly calculated")
        XCTAssertEqual(0, resources & kMagnetometer, "Resourses nested not correctly calculated")
        XCTAssertEqual(0, resources & kCompass, "Resourses nested not correctly calculated")
}

    func testNestedResourcesTwoSprites2() {
        let brick = SetXBrick()
        var element = FormulaElement(elementType: SENSOR, value: CompassDirectionSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick.xPosition = Formula(formulaElement: element)
        let brick1 = GlideToBrick()
        element = FormulaElement(elementType: SENSOR, value: AccelerationXSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick1.durationInSeconds = Formula(formulaElement: element)
        element = FormulaElement(elementType: SENSOR, value: AccelerationYSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick1.xDestination = Formula(formulaElement: element)
        element = FormulaElement(elementType: SENSOR, value: AccelerationZSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
                brick1.yDestination = Formula(formulaElement: element)
        let brickArray = [brick, brick1]
        let brick2 = WaitBrick()
        brick2.timeToWaitInSeconds = Formula(value: 1)
        let brick3 = HideBrick()

        let brick4 = ChangeTransparencyByNBrick()
        element = FormulaElement(elementType: SENSOR, value: LoudnessSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        brick4.changeTransparency = Formula(formulaElement: element)

        let brickArray2 = [brick2, brick3, brick4]

        let project = getProjectWithTwoSprites(withBricks: brickArray, andBrickArray2: brickArray2)

        let resources = project?.getRequiredResources() ?? 0
        XCTAssertEqual(kDeviceMotion, resources & kDeviceMotion, "Resourses nested not correctly calculated")
        XCTAssertEqual(kLoudness, resources & kLoudness, "Resourses nested not correctly calculated")
        XCTAssertEqual(0, resources & kBluetoothArduino, "Resourses nested not correctly calculated")
        XCTAssertEqual(0, resources & kBluetoothPhiro, "Resourses nested not correctly calculated")
        XCTAssertEqual(0, resources & kFaceDetection, "Resourses nested not correctly calculated")
        XCTAssertEqual(0, resources & kMagnetometer, "Resourses nested not correctly calculated")
        XCTAssertEqual(kCompass, resources & kCompass, "Resourses nested not correctly calculated")
    }

// MARK: -Location
    func testLocationResources() {
        let formulaElement = FormulaElement(elementType: SENSOR, value: LongitudeSensor.tag, leftChild: nil, rightChild: nil, parent: nil)

        var brick = ChangeSizeByNBrick()
        brick.size = Formula(formulaElement: formulaElement)
        let project = getProjectWithOneSprite(with: brick)

        XCTAssertEqual(kLocation, project?.getRequiredResources(), "Resourses for Longitude not correctly calculated")

        formulaElement.value = LatitudeSensor.tag
        XCTAssertEqual(kLocation, project?.getRequiredResources(), "Resourses for Latitude not correctly calculated")

        formulaElement.value = AltitudeSensor.tag
        XCTAssertEqual(kLocation, project?.getRequiredResources(), "Resourses for Altitude not correctly calculated")

        formulaElement.value = LocationAccuracySensor.tag
        XCTAssertEqual(kLocation, project.getRequiredResources(), "Resourses for Location Accuracy not correctly calculated")

        brick.size = Formula()
        XCTAssertEqual(kNoResources, project.getRequiredResources(), "Resourses for Location not correctly calculated")
    }
}
