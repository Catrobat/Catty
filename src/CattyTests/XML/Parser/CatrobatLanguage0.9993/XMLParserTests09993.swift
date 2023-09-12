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

class XMLParserTests09993: XMLAbstractTest {
    var formulaManager: FormulaManager!

    override func setUp() {
        super.setUp()
        formulaManager = FormulaManager(stageSize: Util.screenSize(true), landscapeMode: false)
    }

    func testAllBricks() {
        let project = self.getProjectForXML(xmlFile: "ValidProjectAllBricks09993")
        XCTAssertEqual(0, project.unsupportedElements.count)
    }

    func testAllFunctions() {
        let project = self.getProjectForXML(xmlFile: "Functions_09993")
        XCTAssertEqual(0, project.unsupportedElements.count)
    }

    func testAllSensors() {
        let project = self.getProjectForXML(xmlFile: "Sensors_09993")
        XCTAssertEqual(0, project.unsupportedElements.count)
    }

    func testBackwardsCompatibleFaceDetectionSensors() {
        let project = self.getProjectForXML(xmlFile: "BackwardsCompatibleFaceDetectionSensors")

        let objectCount = 2
        XCTAssertEqual((project.scenes[0] as! Scene).objects().count, objectCount, "Invalid object list")
        let object = (project.scenes[0] as! Scene).object(at: 1)!
        XCTAssertEqual(object.scriptList.count, 1, "Invalid script list")
        let script = object.scriptList.object(at: 0) as! Script
        XCTAssertEqual(script.brickList.count, 9, "Invalid brick list")

        let ifLogicBrick = script.brickList.object(at: 1) as! IfLogicBeginBrick
        let setSizeToBrick = script.brickList.object(at: 2) as! SetSizeToBrick
        let placeAtBrick = script.brickList.object(at: 3) as! PlaceAtBrick

        XCTAssertEqual(ElementType.SENSOR, ifLogicBrick.ifCondition.formulaTree.type)
        XCTAssertEqual(ElementType.SENSOR, setSizeToBrick.getFormulas()[0].formulaTree.type)
        XCTAssertEqual(ElementType.SENSOR, placeAtBrick.getFormulas()[0].formulaTree.type)
        XCTAssertEqual(ElementType.SENSOR, placeAtBrick.getFormulas()[1].formulaTree.type)

        XCTAssertEqual(FaceDetectedSensor.tag, ifLogicBrick.ifCondition.formulaTree.value)
        XCTAssertEqual(FaceSizeSensor.tag, setSizeToBrick.getFormulas()[0].formulaTree.value)
        XCTAssertEqual(FacePositionXSensor.tag, placeAtBrick.getFormulas()[0].formulaTree.value)
        XCTAssertEqual(FacePositionYSensor.tag, placeAtBrick.getFormulas()[1].formulaTree.value)
    }

    func testFaceDetectionSensors() {
        let project = self.getProjectForXML(xmlFile: "FaceDetectionSensors")

        let objectCount = 3
        XCTAssertEqual((project.scenes[0] as! Scene).objects().count, objectCount, "Invalid object list")
        var object = (project.scenes[0] as! Scene).object(at: 1)!
        XCTAssertEqual(object.scriptList.count, 1, "Invalid script list")
        var script = object.scriptList.object(at: 0) as! Script
        XCTAssertEqual(script.brickList.count, 9, "Invalid brick list")

        var ifLogicBrick = script.brickList.object(at: 1) as! IfLogicBeginBrick
        var setSizeToBrick = script.brickList.object(at: 2) as! SetSizeToBrick
        var placeAtBrick = script.brickList.object(at: 3) as! PlaceAtBrick

        XCTAssertEqual(ElementType.SENSOR, ifLogicBrick.ifCondition.formulaTree.type)
        XCTAssertEqual(ElementType.SENSOR, setSizeToBrick.getFormulas()[0].formulaTree.type)
        XCTAssertEqual(ElementType.SENSOR, placeAtBrick.getFormulas()[0].formulaTree.type)
        XCTAssertEqual(ElementType.SENSOR, placeAtBrick.getFormulas()[1].formulaTree.type)

        XCTAssertEqual(FaceDetectedSensor.tag, ifLogicBrick.ifCondition.formulaTree.value)
        XCTAssertEqual(FaceSizeSensor.tag, setSizeToBrick.getFormulas()[0].formulaTree.value)
        XCTAssertEqual(FacePositionXSensor.tag, placeAtBrick.getFormulas()[0].formulaTree.value)
        XCTAssertEqual(FacePositionYSensor.tag, placeAtBrick.getFormulas()[1].formulaTree.value)

        object = (project.scenes[0] as! Scene).object(at: 2)!
        XCTAssertEqual(object.scriptList.count, 1, "Invalid script list")
        script = object.scriptList.object(at: 0) as! Script
        XCTAssertEqual(script.brickList.count, 9, "Invalid brick list")

        ifLogicBrick = script.brickList.object(at: 1) as! IfLogicBeginBrick
        setSizeToBrick = script.brickList.object(at: 2) as! SetSizeToBrick
        placeAtBrick = script.brickList.object(at: 3) as! PlaceAtBrick

        XCTAssertEqual(ElementType.SENSOR, ifLogicBrick.ifCondition.formulaTree.type)
        XCTAssertEqual(ElementType.SENSOR, setSizeToBrick.getFormulas()[0].formulaTree.type)
        XCTAssertEqual(ElementType.SENSOR, placeAtBrick.getFormulas()[0].formulaTree.type)
        XCTAssertEqual(ElementType.SENSOR, placeAtBrick.getFormulas()[1].formulaTree.type)

        XCTAssertEqual(SecondFaceDetectedSensor.tag, ifLogicBrick.ifCondition.formulaTree.value)
        XCTAssertEqual(SecondFaceSizeSensor.tag, setSizeToBrick.getFormulas()[0].formulaTree.value)
        XCTAssertEqual(SecondFacePositionXSensor.tag, placeAtBrick.getFormulas()[0].formulaTree.value)
        XCTAssertEqual(SecondFacePositionYSensor.tag, placeAtBrick.getFormulas()[1].formulaTree.value)
    }

    func testFacePoseSensors() {
        let project = self.getProjectForXML(xmlFile: "FacePoseSensors")
        let sensorTags: [String] = [LeftEyeInnerXSensor.tag, LeftEyeInnerYSensor.tag, LeftEyeCenterXSensor.tag, LeftEyeCenterYSensor.tag, LeftEyeOuterXSensor.tag, LeftEyeOuterYSensor.tag,
                          HeadTopXSensor.tag, HeadTopYSensor.tag, NoseXSensor.tag, NoseYSensor.tag, RightEyeInnerXSensor.tag, RightEyeInnerYSensor.tag, RightEyeCenterXSensor.tag,
                          RightEyeCenterYSensor.tag, RightEyeOuterXSensor.tag, RightEyeOuterYSensor.tag, LeftEarXSensor.tag, LeftEarYSensor.tag, RightEarXSensor.tag, RightEarYSensor.tag,
                          MouthLeftCornerXSensor.tag, MouthLeftCornerYSensor.tag, MouthRightCornerXSensor.tag, MouthRightCornerYSensor.tag, LeftEyebrowInnerXSensor.tag,
                          LeftEyebrowInnerYSensor.tag, LeftEyebrowCenterXSensor.tag, LeftEyebrowCenterYSensor.tag, LeftEyebrowOuterXSensor.tag, LeftEyebrowOuterYSensor.tag,
                          RightEyebrowInnerXSensor.tag, RightEyebrowInnerYSensor.tag, RightEyebrowCenterXSensor.tag, RightEyebrowCenterYSensor.tag, RightEyebrowOuterXSensor.tag,
                          RightEyebrowOuterYSensor.tag]

        var sensorIndex = 0
        let objectCount = 19

        XCTAssertEqual((project.scenes[0] as! Scene).objects().count, objectCount, "Invalid object list")
        for objectIndex in 1..<objectCount {
            let object = (project.scenes[0] as! Scene).object(at: objectIndex)!
            XCTAssertEqual(object.scriptList.count, 1, "Invalid script list")
            let script = object.scriptList.object(at: 0) as! Script
            XCTAssertEqual(script.brickList.count, 8, "Invalid brick list")

            let placeAtBrick = script.brickList.object(at: 2) as! PlaceAtBrick
            XCTAssertEqual(ElementType.SENSOR, placeAtBrick.getFormulas()[0].formulaTree.type)
            XCTAssertEqual(ElementType.SENSOR, placeAtBrick.getFormulas()[1].formulaTree.type)

            XCTAssertEqual(sensorTags[sensorIndex], placeAtBrick.getFormulas()[0].formulaTree.value, "Invalid sensor \(sensorTags[sensorIndex])")
            sensorIndex += 1
            XCTAssertEqual(sensorTags[sensorIndex], placeAtBrick.getFormulas()[1].formulaTree.value, "Invalid sensor \(sensorTags[sensorIndex])")
            sensorIndex += 1
        }

        XCTAssertEqual(0, project.unsupportedElements.count)
    }

    func testUpperBodyPoseSensors() {
        let project = self.getProjectForXML(xmlFile: "UpperBodyPoseDetectionSensors")
        let sensorTags: [String] = [LeftShoulderXSensor.tag, LeftShoulderYSensor.tag, RightShoulderXSensor.tag, RightShoulderYSensor.tag,
                                    LeftElbowXSensor.tag, LeftElbowYSensor.tag, RightElbowXSensor.tag, RightElbowYSensor.tag, LeftWristXSensor.tag,
                                    LeftWristYSensor.tag, RightWristXSensor.tag, RightWristYSensor.tag, NeckXSensor.tag, NeckYSensor.tag]

        var sensorIndex = 0
        let objectCount = 8

        XCTAssertEqual((project.scenes[0] as! Scene).objects().count, objectCount, "Invalid object list")
        for objectIndex in 1..<objectCount {
            let object = (project.scenes[0] as! Scene).object(at: objectIndex)!
            XCTAssertEqual(object.scriptList.count, 1, "Invalid script list")
            let script = object.scriptList.object(at: 0) as! Script
            XCTAssertEqual(script.brickList.count, 3, "Invalid brick list")

            let placeAtBrick = script.brickList.object(at: 1) as! PlaceAtBrick
            XCTAssertEqual(ElementType.SENSOR, placeAtBrick.getFormulas()[0].formulaTree.type)
            XCTAssertEqual(ElementType.SENSOR, placeAtBrick.getFormulas()[1].formulaTree.type)

            XCTAssertEqual(sensorTags[sensorIndex], placeAtBrick.getFormulas()[0].formulaTree.value, "Invalid sensor \(sensorTags[sensorIndex])")
            sensorIndex += 1
            XCTAssertEqual(sensorTags[sensorIndex], placeAtBrick.getFormulas()[1].formulaTree.value, "Invalid sensor \(sensorTags[sensorIndex])")
            sensorIndex += 1
        }

        XCTAssertEqual(0, project.unsupportedElements.count)
    }

    func testLowerBodyPoseSensors() {
        let project = self.getProjectForXML(xmlFile: "LowerBodyPoseDetectionSensors")
        let sensorTags: [String] = [LeftHipXSensor.tag, LeftHipYSensor.tag, RightHipXSensor.tag, RightHipYSensor.tag,
                                    LeftKneeXSensor.tag, LeftKneeYSensor.tag, RightKneeXSensor.tag, RightKneeYSensor.tag,
                                    LeftAnkleXSensor.tag, LeftAnkleYSensor.tag, RightAnkleXSensor.tag, RightAnkleYSensor.tag]

        var sensorIndex = 0
        let objectCount = 7

        XCTAssertEqual((project.scenes[0] as! Scene).objects().count, objectCount, "Invalid object list")
        for objectIndex in 1..<objectCount {
            let object = (project.scenes[0] as! Scene).object(at: objectIndex)!
            XCTAssertEqual(object.scriptList.count, 1, "Invalid script list")
            let script = object.scriptList.object(at: 0) as! Script
            XCTAssertEqual(script.brickList.count, 3, "Invalid brick list")

            let placeAtBrick = script.brickList.object(at: 1) as! PlaceAtBrick
            XCTAssertEqual(ElementType.SENSOR, placeAtBrick.getFormulas()[0].formulaTree.type)
            XCTAssertEqual(ElementType.SENSOR, placeAtBrick.getFormulas()[1].formulaTree.type)

            XCTAssertEqual(sensorTags[sensorIndex], placeAtBrick.getFormulas()[0].formulaTree.value, "Invalid sensor \(sensorTags[sensorIndex])")
            sensorIndex += 1
            XCTAssertEqual(sensorTags[sensorIndex], placeAtBrick.getFormulas()[1].formulaTree.value, "Invalid sensor \(sensorTags[sensorIndex])")
            sensorIndex += 1
        }

        XCTAssertEqual(0, project.unsupportedElements.count)
    }

    func testHandBodyPoseSensors() {
        let project = self.getProjectForXML(xmlFile: "HandPoseDetectionSensors")
        let sensorTags: [String] = [LeftPinkyKnuckleXSensor.tag, LeftPinkyKnuckleYSensor.tag, LeftIndexKnuckleXSensor.tag, LeftIndexKnuckleYSensor.tag,
                                    LeftThumbKnuckleXSensor.tag, LeftThumbKnuckleYSensor.tag, LeftRingFingerKnuckleXSensor.tag, LeftRingFingerKnuckleYSensor.tag,
                                    LeftMiddleFingerKnuckleXSensor.tag, LeftMiddleFingerKnuckleYSensor.tag, RightPinkyKnuckleXSensor.tag, RightPinkyKnuckleYSensor.tag,
                                    RightIndexKnuckleXSensor.tag, RightIndexKnuckleYSensor.tag, RightThumbKnuckleXSensor.tag, RightThumbKnuckleYSensor.tag,
                                    RightRingFingerKnuckleXSensor.tag, RightRingFingerKnuckleYSensor.tag, RightMiddleFingerKnuckleXSensor.tag, RightMiddleFingerKnuckleYSensor.tag]

        var sensorIndex = 0
        let objectCount = 11

        XCTAssertEqual((project.scenes[0] as! Scene).objects().count, objectCount, "Invalid object list")
        for objectIndex in 1..<objectCount {
            let object = (project.scenes[0] as! Scene).object(at: objectIndex)!
            XCTAssertEqual(object.scriptList.count, 1, "Invalid script list")
            let script = object.scriptList.object(at: 0) as! Script
            XCTAssertEqual(script.brickList.count, 3, "Invalid brick list")

            let placeAtBrick = script.brickList.object(at: 1) as! PlaceAtBrick
            XCTAssertEqual(ElementType.SENSOR, placeAtBrick.getFormulas()[0].formulaTree.type)
            XCTAssertEqual(ElementType.SENSOR, placeAtBrick.getFormulas()[1].formulaTree.type)

            XCTAssertEqual(sensorTags[sensorIndex], placeAtBrick.getFormulas()[0].formulaTree.value, "Invalid sensor \(sensorTags[sensorIndex])")
            sensorIndex += 1
            XCTAssertEqual(sensorTags[sensorIndex], placeAtBrick.getFormulas()[1].formulaTree.value, "Invalid sensor \(sensorTags[sensorIndex])")
            sensorIndex += 1
        }

        XCTAssertEqual(0, project.unsupportedElements.count)
    }

    func testTextRecognitionSensors() {
        let project = self.getProjectForXML(xmlFile: "TextRecognitionSensors")
        let sensorTags: [String] = [TextBlocksNumberSensor.tag, TextBlockSizeFunction.tag, TextBlockXFunction.tag, TextBlockYFunction.tag,
                                    TextFromCameraSensor.tag, TextBlockFromCameraFunction.tag, TextBlockLanguageFromCameraFunction.tag]

        let objectCount = 3
        let brickCount = 12
        var sensorIndex = 0
        var brickIndex = 1

        XCTAssertEqual((project.scenes[0] as! Scene).objects().count, objectCount, "Invalid object list")
        let textDetectorObject = (project.scenes[0] as! Scene).object(at: 1)!

        XCTAssertEqual(textDetectorObject.scriptList.count, 1, "Invalid script list")
        let script = textDetectorObject.scriptList.object(at: 0) as! Script
        XCTAssertEqual(script.brickList.count, brickCount, "Invalid brick list")

        let ifLogicBeginBrick = script.brickList.object(at: brickIndex) as! IfLogicBeginBrick
        XCTAssertEqual(ElementType.SENSOR, ifLogicBeginBrick.getFormulas()[0].formulaTree.leftChild.type)
        XCTAssertEqual(sensorTags[sensorIndex], ifLogicBeginBrick.getFormulas()[0].formulaTree.leftChild.value, "Invalid sensor \(sensorTags[sensorIndex])")
        sensorIndex += 1
        brickIndex += 1

        let setSizeToBrick = script.brickList.object(at: brickIndex) as! SetSizeToBrick
        XCTAssertEqual(ElementType.FUNCTION, setSizeToBrick.getFormulas()[0].formulaTree.type)
        XCTAssertEqual(sensorTags[sensorIndex], setSizeToBrick.getFormulas()[0].formulaTree.value, "Invalid sensor \(sensorTags[sensorIndex])")
        sensorIndex += 1
        brickIndex += 1

        let placeAtBrick = script.brickList.object(at: brickIndex) as! PlaceAtBrick
        XCTAssertEqual(ElementType.FUNCTION, placeAtBrick.getFormulas()[0].formulaTree.type)
        XCTAssertEqual(sensorTags[sensorIndex], placeAtBrick.getFormulas()[0].formulaTree.value, "Invalid sensor \(sensorTags[sensorIndex])")
        sensorIndex += 1
        XCTAssertEqual(ElementType.FUNCTION, placeAtBrick.getFormulas()[1].formulaTree.type)
        XCTAssertEqual(sensorTags[sensorIndex], placeAtBrick.getFormulas()[1].formulaTree.value, "Invalid sensor \(sensorTags[sensorIndex])")
        sensorIndex += 1
        brickIndex += 1

        var setVariableBrick = script.brickList.object(at: brickIndex) as! SetVariableBrick
        XCTAssertEqual(ElementType.SENSOR, setVariableBrick.getFormulas()[0].formulaTree.type)
        XCTAssertEqual(sensorTags[sensorIndex], setVariableBrick.getFormulas()[0].formulaTree.value, "Invalid sensor \(sensorTags[sensorIndex])")
        sensorIndex += 1
        brickIndex += 1

        setVariableBrick = script.brickList.object(at: brickIndex) as! SetVariableBrick
        XCTAssertEqual(ElementType.FUNCTION, setVariableBrick.getFormulas()[0].formulaTree.type)
        XCTAssertEqual(sensorTags[sensorIndex], setVariableBrick.getFormulas()[0].formulaTree.value, "Invalid sensor \(sensorTags[sensorIndex])")
        sensorIndex += 1
        brickIndex += 1

        setVariableBrick = script.brickList.object(at: brickIndex) as! SetVariableBrick
        XCTAssertEqual(ElementType.FUNCTION, setVariableBrick.getFormulas()[0].formulaTree.type)
        XCTAssertEqual(sensorTags[sensorIndex], setVariableBrick.getFormulas()[0].formulaTree.value, "Invalid sensor \(sensorTags[sensorIndex])")
        sensorIndex += 1
        brickIndex += 1

        XCTAssertEqual(0, project.unsupportedElements.count)
    }

    func testObjectDetectionSensors() {
        let project = self.getProjectForXML(xmlFile: "ObjectRecognitionSensors")
        let sensorTags: [String] = [IDOfDetectedObjectFunction.tag, ObjectWithIDVisibleFunction.tag, LabelOfObjectWithIDFunction.tag, XOfObjectWithIDFunction.tag, YOfObjectWithIDFunction.tag,
                                    WidthOfObjectWithIDFunction.tag, HeightOfObjectWithIDFunction.tag]

        let objectCount = 4
        let brickCount = 14
        var sensorIndex = 0
        var brickIndex = 1

        XCTAssertEqual((project.scenes[0] as! Scene).objects().count, objectCount, "Invalid object list")
        let objectDetectorObject = (project.scenes[0] as! Scene).object(at: 1)!

        XCTAssertEqual(objectDetectorObject.scriptList.count, 1, "Invalid script list")
        let script = objectDetectorObject.scriptList.object(at: 0) as! Script
        XCTAssertEqual(script.brickList.count, brickCount, "Invalid brick list")

        var setVariableBrick = script.brickList.object(at: brickIndex) as! SetVariableBrick
        XCTAssertEqual(ElementType.FUNCTION, setVariableBrick.getFormulas()[0].formulaTree.type)
        XCTAssertEqual(sensorTags[sensorIndex], setVariableBrick.getFormulas()[0].formulaTree.value, "Invalid sensor \(sensorTags[sensorIndex])")
        sensorIndex += 1
        brickIndex += 1

        let ifLogicBeginBrick = script.brickList.object(at: brickIndex) as! IfLogicBeginBrick
        XCTAssertEqual(ElementType.FUNCTION, ifLogicBeginBrick.getFormulas()[0].formulaTree.leftChild.parent.type)
        XCTAssertEqual(sensorTags[sensorIndex], ifLogicBeginBrick.getFormulas()[0].formulaTree.leftChild.parent.value, "Invalid sensor \(sensorTags[sensorIndex])")
        sensorIndex += 1
        brickIndex += 1

        setVariableBrick = script.brickList.object(at: brickIndex) as! SetVariableBrick
        XCTAssertEqual(ElementType.FUNCTION, setVariableBrick.getFormulas()[0].formulaTree.type)
        XCTAssertEqual(sensorTags[sensorIndex], setVariableBrick.getFormulas()[0].formulaTree.value, "Invalid sensor \(sensorTags[sensorIndex])")
        sensorIndex += 1
        brickIndex += 1

        let placeAtBrick = script.brickList.object(at: brickIndex) as! PlaceAtBrick
        XCTAssertEqual(ElementType.FUNCTION, placeAtBrick.getFormulas()[0].formulaTree.type)
        XCTAssertEqual(sensorTags[sensorIndex], placeAtBrick.getFormulas()[0].formulaTree.value, "Invalid sensor \(sensorTags[sensorIndex])")
        sensorIndex += 1
        XCTAssertEqual(ElementType.FUNCTION, placeAtBrick.getFormulas()[1].formulaTree.type)
        XCTAssertEqual(sensorTags[sensorIndex], placeAtBrick.getFormulas()[1].formulaTree.value, "Invalid sensor \(sensorTags[sensorIndex])")
        sensorIndex += 1
        brickIndex += 1

        setVariableBrick = script.brickList.object(at: brickIndex) as! SetVariableBrick
        XCTAssertEqual(ElementType.FUNCTION, setVariableBrick.getFormulas()[0].formulaTree.type)
        XCTAssertEqual(sensorTags[sensorIndex], setVariableBrick.getFormulas()[0].formulaTree.value, "Invalid sensor \(sensorTags[sensorIndex])")
        sensorIndex += 1
        brickIndex += 1

        setVariableBrick = script.brickList.object(at: brickIndex) as! SetVariableBrick
        XCTAssertEqual(ElementType.FUNCTION, setVariableBrick.getFormulas()[0].formulaTree.type)
        XCTAssertEqual(sensorTags[sensorIndex], setVariableBrick.getFormulas()[0].formulaTree.value, "Invalid sensor \(sensorTags[sensorIndex])")

        XCTAssertEqual(0, project.unsupportedElements.count)
   }

    func testGlideToBrick() {
        let project = self.getProjectForXML(xmlFile: "ValidProjectAllBricks0998")
        let glideToBrick = ((project.scenes[0] as! Scene).object(at: 0)!.scriptList.object(at: 0) as! Script).brickList.object(at: 10) as! Brick

        XCTAssertEqual(0, project.unsupportedElements.count)
        XCTAssertTrue(glideToBrick.isKind(of: GlideToBrick.self), "Invalid brick type")

        let castedBrick = glideToBrick as! GlideToBrick
        XCTAssertTrue(castedBrick.xDestination.isEqual(to: Formula(integer: 100)), "Invalid formula")
        XCTAssertTrue(castedBrick.yDestination.isEqual(to: Formula(integer: 200)), "Invalid formula")
        XCTAssertEqual("1.0", castedBrick.durationInSeconds.formulaTree.value, "Invalid formula")
    }

    func testThinkForBubbleBrick() {
        let project = self.getProjectForXML(xmlFile: "ValidProjectAllBricks0998")
        let thinkForBubbleBrick = ((project.scenes[0] as! Scene).object(at: 0)!.scriptList.object(at: 0) as! Script).brickList.object(at: 37) as! Brick

        XCTAssertEqual(0, project.unsupportedElements.count)
        XCTAssertTrue(thinkForBubbleBrick.isKind(of: ThinkForBubbleBrick.self), "Invalid brick type")

        let castedBrick = thinkForBubbleBrick as! ThinkForBubbleBrick
        XCTAssertTrue(castedBrick.stringFormula.isEqual(to: Formula(string: kLocalizedHmmmm)), "Invalid formula")
        XCTAssertEqual("1.0", castedBrick.intFormula.formulaTree.value, "Invalid formula")
    }

    func testParseLocalLists() {
        let project = self.getProjectForXML(xmlFile: "UserLists_09993")
        let objects = (project.scenes[0] as! Scene).objects()
        XCTAssertEqual(3, objects.count)

        let backgroundObject = (project.scenes[0] as! Scene).object(at: 0)
        XCTAssertEqual("Background", backgroundObject?.name)

        let localLists = backgroundObject?.userData.lists()
        XCTAssertEqual(1, localLists?.count)
        XCTAssertEqual("localListBackground", localLists?[0].name)

        let object = (project.scenes[0] as! Scene).object(at: 1)
        XCTAssertEqual("Object1", object?.name)

        let localListsObject = object?.userData.lists()
        XCTAssertEqual(1, localListsObject?.count)
        XCTAssertEqual("localListObject1", localListsObject?[0].name)
    }

    func testParseGlobalLists() {
        let project = self.getProjectForXML(xmlFile: "UserLists_09993")
        let list = project.userData.lists()
        XCTAssertEqual(1, list.count)
        XCTAssertEqual("globalList", list.first?.name)
    }

    func testParseLocalVariables() {
        let project = self.getProjectForXML(xmlFile: "UserVariables_09993")
        let objects = (project.scenes[0] as! Scene).objects()
        XCTAssertEqual(3, objects.count)

        let backgroundObject = (project.scenes[0] as! Scene).object(at: 0)
        XCTAssertEqual("Background", backgroundObject?.name)

        let localVariables = backgroundObject?.userData.variables()
        XCTAssertEqual(2, localVariables?.count)
        XCTAssertEqual("localBackground", localVariables?[0].name)
        XCTAssertEqual("localBackground2", localVariables?[1].name)

        let object = (project.scenes[0] as! Scene).object(at: 1)
        XCTAssertEqual("A", object?.name)

        let localVariablesObject = object?.userData.variables()
        XCTAssertEqual(1, localVariablesObject?.count)
        XCTAssertEqual("localB", localVariablesObject?[0].name)
    }

    func testParseGlobalVariables() {
        let project = self.getProjectForXML(xmlFile: "UserVariables_09993")
        let variables = project.userData.variables()
        XCTAssertEqual(3, variables.count)
        XCTAssertEqual("global1", variables[0].name)
        XCTAssertEqual("global2", variables[1].name)
        XCTAssertEqual("global3", variables[2].name)
    }
}
