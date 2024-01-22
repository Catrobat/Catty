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

import XCTest

@testable import Pocket_Code

final class SetRotationStyleBrickTests: AbstractBrickTest {

    var spriteObject: SpriteObject!
    var script: Script!
    var ifOnEdgeBounceBrick: IfOnEdgeBounceBrick!
    var setRotationStyleBrick: SetRotationStyleBrick!

    static let SCREEN_WIDTH = CGFloat(480)
    static let SCREEN_HEIGHT = CGFloat(800)
    static let OBJECT_WIDTH = CGFloat(100)
    static let OBJECT_HEIGHT = CGFloat(100)
    static let TOP_BORDER_POS = SCREEN_HEIGHT / 2
    static let BOTTOM_BORDER_POS = -TOP_BORDER_POS
    static let RIGHT_BORDER_POS = SCREEN_WIDTH / 2
    static let LEFT_BORDER_POS = -RIGHT_BORDER_POS
    static let BOUNCE_TOP_POS = TOP_BORDER_POS - (OBJECT_HEIGHT / 2)
    static let BOUNCE_BOTTOM_POS = -(BOUNCE_TOP_POS)
    static let BOUNCE_RIGHT_POS = RIGHT_BORDER_POS - (OBJECT_WIDTH / 2)
    static let BOUNCE_LEFT_POS = -(BOUNCE_RIGHT_POS)
    static let EPSILON = CGFloat(0.001)

    override func setUp() {
        super.setUp()
        self.stage = StageBuilder(project: ProjectMock(width: SetRotationStyleBrickTests.SCREEN_WIDTH, andHeight: SetRotationStyleBrickTests.SCREEN_HEIGHT)).build()

        let scene = Scene(name: "testScene")
        self.spriteObject = SpriteObject()
        self.spriteObject.scene = scene
        let spriteNode = CBSpriteNode(spriteObject: self.spriteObject)
        self.stage.addChild(spriteNode)
        spriteNode.color = UIColor.black
        spriteNode.size = CGSize(width: SetRotationStyleBrickTests.OBJECT_WIDTH, height: SetRotationStyleBrickTests.OBJECT_HEIGHT)
        self.spriteObject.spriteNode = spriteNode
        spriteNode.catrobatPosition = CBPosition(x: 0, y: 0)
        self.spriteObject.name = "Test"

        self.script = WhenScript()
        self.script.object = self.spriteObject

        self.setRotationStyleBrick = SetRotationStyleBrick()
        self.setRotationStyleBrick.script = self.script

        self.ifOnEdgeBounceBrick = IfOnEdgeBounceBrick()
        self.ifOnEdgeBounceBrick.script = self.script
    }

    // MARK: ROTATE ALL AROUND
    func testAllAroundTopBounce() {
        setRotationStyleBrick.selection = RotationStyle.allAround
        let setRotationStyleBrickAction = setRotationStyleBrick.actionBlock()
        setRotationStyleBrickAction()

        let rotationDegreeOffset = 90.0

        let rotations: [(Double, Double)] = [(90.0, 90.0), (120.0, 120.0), (150.0, 150.0), (180.0, 180.0),
                                             (-150.0, -150.0), (-120.0, -120.0), (-90.0, -90.0), (-60.0, -120.0),
                                             (-30.0, -150.0), (0.0, 180.0), (30.0, 150.0), (60.0, 120.0)]

        for rotation in rotations {
            let rotationBefore = rotation.0
            let rotationAfter = rotation.1
            setPosition(position: CBPosition(x: 0, y: SetRotationStyleBrickTests.TOP_BORDER_POS), rotation: rotationBefore)
            checkPosition(position: CBPosition(x: 0, y: SetRotationStyleBrickTests.BOUNCE_TOP_POS), rotation: rotationAfter, rotationDegreeOffset: rotationDegreeOffset)
        }
    }

    func testAllAroundBottomBounce() {
        setRotationStyleBrick.selection = RotationStyle.allAround
        let setRotationStyleBrickAction = setRotationStyleBrick.actionBlock()
        setRotationStyleBrickAction()

        let rotationDegreeOffset = 90.0

        let rotations: [(Double, Double)] = [(90.0, 90.0), (120.0, 60.0), (150.0, 30.0), (180.0, 0.0),
                                             (-150.0, -30.0), (-120.0, -60.0), (-90.0, -90.0), (-60.0, -60.0),
                                             (-30.0, -30.0), (0.0, 0.0), (30.0, 30.0), (60.0, 60.0)]

        for rotation in rotations {
            let rotationBefore = rotation.0
            let rotationAfter = rotation.1
            setPosition(position: CBPosition(x: 0, y: SetRotationStyleBrickTests.BOTTOM_BORDER_POS), rotation: rotationBefore)
            checkPosition(position: CBPosition(x: 0, y: SetRotationStyleBrickTests.BOUNCE_BOTTOM_POS), rotation: rotationAfter, rotationDegreeOffset: rotationDegreeOffset)
        }
    }

    func testAllAroundLeftBounce() {
        setRotationStyleBrick.selection = RotationStyle.allAround
        let setRotationStyleBrickAction = setRotationStyleBrick.actionBlock()
        setRotationStyleBrickAction()

        let rotationDegreeOffset = 90.0

        let rotations: [(Double, Double)] = [(90.0, 90.0), (120.0, 120.0), (150.0, 150.0), (180.0, 180.0),
                                             (-150.0, 150.0), (-120.0, 120.0), (-90.0, 90.0), (-60.0, 60.0),
                                             (-30.0, 30.0), (0.0, 0.0), (30.0, 30.0), (60.0, 60.0)]

        for rotation in rotations {
            let rotationBefore = rotation.0
            let rotationAfter = rotation.1
            setPosition(position: CBPosition(x: SetRotationStyleBrickTests.LEFT_BORDER_POS, y: 0), rotation: rotationBefore)
            checkPosition(position: CBPosition(x: SetRotationStyleBrickTests.BOUNCE_LEFT_POS, y: 0), rotation: rotationAfter, rotationDegreeOffset: rotationDegreeOffset)
        }
    }

    func testAllAroundRightBounce() {
        setRotationStyleBrick.selection = RotationStyle.allAround
        let setRotationStyleBrickAction = setRotationStyleBrick.actionBlock()
        setRotationStyleBrickAction()

        let rotationDegreeOffset = 90.0

        let rotations: [(Double, Double)] = [(90.0, -90.0), (120.0, -120.0), (150.0, -150.0), (180.0, 180.0),
                                             (-150.0, -150.0), (-120.0, -120.0), (-90.0, -90.0), (-60.0, -60.0),
                                             (-30.0, -30.0), (0.0, 0.0), (30.0, -30.0), (60.0, -60.0)]

        for rotation in rotations {
            let rotationBefore = rotation.0
            let rotationAfter = rotation.1
            setPosition(position: CBPosition(x: SetRotationStyleBrickTests.RIGHT_BORDER_POS, y: 0), rotation: rotationBefore)
            checkPosition(position: CBPosition(x: SetRotationStyleBrickTests.BOUNCE_RIGHT_POS, y: 0), rotation: rotationAfter, rotationDegreeOffset: rotationDegreeOffset)
        }
    }

    func testAllAroundUpLeftBounce() {
        setRotationStyleBrick.selection = RotationStyle.allAround
        let setRotationStyleBrickAction = setRotationStyleBrick.actionBlock()
        setRotationStyleBrickAction()

        let rotationDegreeOffset = 90.0

        setPosition(position: CBPosition(x: SetRotationStyleBrickTests.LEFT_BORDER_POS, y: SetRotationStyleBrickTests.TOP_BORDER_POS), rotation: 135)
        checkPosition(position: CBPosition(x: SetRotationStyleBrickTests.BOUNCE_LEFT_POS, y: SetRotationStyleBrickTests.BOUNCE_TOP_POS), rotation: 135, rotationDegreeOffset: rotationDegreeOffset)

        setPosition(position: CBPosition(x: SetRotationStyleBrickTests.LEFT_BORDER_POS, y: SetRotationStyleBrickTests.TOP_BORDER_POS), rotation: -45)
        checkPosition(position: CBPosition(x: SetRotationStyleBrickTests.BOUNCE_LEFT_POS, y: SetRotationStyleBrickTests.BOUNCE_TOP_POS), rotation: 135, rotationDegreeOffset: rotationDegreeOffset)
    }

    func testAllAroundUpRightBounce() {
        setRotationStyleBrick.selection = RotationStyle.allAround
        let setRotationStyleBrickAction = setRotationStyleBrick.actionBlock()
        setRotationStyleBrickAction()

        let rotationDegreeOffset = 90.0

        setPosition(position: CBPosition(x: SetRotationStyleBrickTests.RIGHT_BORDER_POS, y: SetRotationStyleBrickTests.TOP_BORDER_POS), rotation: -135)
        checkPosition(position: CBPosition(x: SetRotationStyleBrickTests.BOUNCE_RIGHT_POS, y: SetRotationStyleBrickTests.BOUNCE_TOP_POS), rotation: -135, rotationDegreeOffset: rotationDegreeOffset)

        setPosition(position: CBPosition(x: SetRotationStyleBrickTests.RIGHT_BORDER_POS, y: SetRotationStyleBrickTests.TOP_BORDER_POS), rotation: -45)
        checkPosition(position: CBPosition(x: SetRotationStyleBrickTests.BOUNCE_RIGHT_POS, y: SetRotationStyleBrickTests.BOUNCE_TOP_POS), rotation: -135, rotationDegreeOffset: rotationDegreeOffset)
    }

    func testAllAroundBottomLeftBounce() {
        setRotationStyleBrick.selection = RotationStyle.allAround
        let setRotationStyleBrickAction = setRotationStyleBrick.actionBlock()
        setRotationStyleBrickAction()

        let rotationDegreeOffset = 90.0

        setPosition(position: CBPosition(x: SetRotationStyleBrickTests.LEFT_BORDER_POS, y: SetRotationStyleBrickTests.BOTTOM_BORDER_POS), rotation: 45)
        checkPosition(position: CBPosition(x: SetRotationStyleBrickTests.BOUNCE_LEFT_POS, y: SetRotationStyleBrickTests.BOUNCE_BOTTOM_POS), rotation: 45, rotationDegreeOffset: rotationDegreeOffset)

        setPosition(position: CBPosition(x: SetRotationStyleBrickTests.LEFT_BORDER_POS, y: SetRotationStyleBrickTests.BOTTOM_BORDER_POS), rotation: -135)
        checkPosition(position: CBPosition(x: SetRotationStyleBrickTests.BOUNCE_LEFT_POS, y: SetRotationStyleBrickTests.BOUNCE_BOTTOM_POS), rotation: 45, rotationDegreeOffset: rotationDegreeOffset)
    }

    func testAllAroundBottomRightBounce() {
        setRotationStyleBrick.selection = RotationStyle.allAround
        let setRotationStyleBrickAction = setRotationStyleBrick.actionBlock()
        setRotationStyleBrickAction()

        let rotationDegreeOffset = 90.0

        setPosition(position: CBPosition(x: SetRotationStyleBrickTests.RIGHT_BORDER_POS, y: SetRotationStyleBrickTests.BOTTOM_BORDER_POS), rotation: -45)
        checkPosition(position: CBPosition(x: SetRotationStyleBrickTests.BOUNCE_RIGHT_POS, y: SetRotationStyleBrickTests.BOUNCE_BOTTOM_POS), rotation: -45, rotationDegreeOffset: rotationDegreeOffset)

        setPosition(position: CBPosition(x: SetRotationStyleBrickTests.RIGHT_BORDER_POS, y: SetRotationStyleBrickTests.BOTTOM_BORDER_POS), rotation: 135)
        checkPosition(position: CBPosition(x: SetRotationStyleBrickTests.BOUNCE_RIGHT_POS, y: SetRotationStyleBrickTests.BOUNCE_BOTTOM_POS), rotation: -45, rotationDegreeOffset: rotationDegreeOffset)
    }

    // MARK: DO NOT ROTATE
    func testNotAroundTopBounce() {
        setRotationStyleBrick.selection = RotationStyle.notRotate
        let setRotationStyleBrickAction = setRotationStyleBrick.actionBlock()
        setRotationStyleBrickAction()

        let rotations: [(Double, Double, Double)] = [(90.0, 90.0, 90.0), (120.0, 120.0, 120.0),
                                                     (150.0, 150.0, 150.0), (-180.0, 180.0, 180.0),
                                                     (-150.0, -150.0, -150.0), (-120.0, -120.0, -120.0),
                                                     (-90.0, -90.0, -90.0), (-60.0, -120.0, 240.0),
                                                     (-30.0, -150.0, 210.0), (0.0, 180.0, 180.0),
                                                     (30.0, 150.0, 150.0), (60.0, 120.0, 120.0)]

        for rotation in rotations {
            let rotationBefore = rotation.0
            let rotationAfter = rotation.1

            setPosition(position: CBPosition(x: 0, y: SetRotationStyleBrickTests.TOP_BORDER_POS), rotation: rotationBefore)
            checkPosition(position: CBPosition(x: 0, y: SetRotationStyleBrickTests.BOUNCE_TOP_POS), rotation: rotationAfter, rotationDegreeOffset: rotation.2)
        }
    }

   func testNotAroundBottomBounce() {
        setRotationStyleBrick.selection = RotationStyle.notRotate
        let setRotationStyleBrickAction = setRotationStyleBrick.actionBlock()
        setRotationStyleBrickAction()

        let rotations: [(Double, Double, Double)] = [(90.0, 90.0, 90.0), (120.0, 60.0, 60.0),
                                                     (150.0, 30.0, 30.0), (-180.0, 0.0, 0.0),
                                                     (-150.0, -30.0, 330.0), (-120.0, -60.0, 300),
                                                     (-90.0, -90.0, -90.0), (-60.0, -60.0, -60.0),
                                                     (-30.0, -30.0, -30.0), (0.0, 0.0, 0.0),
                                                     (30.0, 30.0, 30.0), (60.0, 60.0, 60.0)]

        for rotation in rotations {
            let rotationBefore = rotation.0
            let rotationAfter = rotation.1
            setPosition(position: CBPosition(x: 0, y: SetRotationStyleBrickTests.BOTTOM_BORDER_POS), rotation: rotationBefore)
            checkPosition(position: CBPosition(x: 0, y: SetRotationStyleBrickTests.BOUNCE_BOTTOM_POS), rotation: rotationAfter, rotationDegreeOffset: rotation.2)
        }
    }

    func testNotAroundLeftBounce() {
        setRotationStyleBrick.selection = RotationStyle.notRotate
        let setRotationStyleBrickAction = setRotationStyleBrick.actionBlock()
        setRotationStyleBrickAction()

        let rotations: [(Double, Double)] = [(90.0, 90.0), (120.0, 120.0), (150.0, 150.0), (-180.0, 180.0),
                                             (-150.0, 150.0), (-120.0, 120.0), (-90.0, 90.0), (-60.0, 60.0),
                                             (-30.0, 30.0), (0.0, 0.0), (30.0, 30.0), (60.0, 60.0)]

        for rotation in rotations {
            let rotationBefore = rotation.0
            let rotationAfter = rotation.1
            setPosition(position: CBPosition(x: SetRotationStyleBrickTests.LEFT_BORDER_POS, y: 0), rotation: rotationBefore)
            checkPosition(position: CBPosition(x: SetRotationStyleBrickTests.BOUNCE_LEFT_POS, y: 0), rotation: rotationAfter, rotationDegreeOffset: rotationAfter)
        }
    }

    func testNotAroundRightBounce() {
        setRotationStyleBrick.selection = RotationStyle.notRotate
        let setRotationStyleBrickAction = setRotationStyleBrick.actionBlock()
        setRotationStyleBrickAction()

        let rotations: [(Double, Double)] = [(90.0, -90.0), (120.0, -120.0), (150.0, -150.0), (-180.0, 180.0),
                                             (-150.0, -150.0), (-120.0, -120.0), (-90.0, -90.0), (-60.0, -60.0),
                                             (-30.0, -30.0), (0.0, 0.0), (30.0, -30.0), (60.0, -60.0)]

        for rotation in rotations {
            let rotationBefore = rotation.0
            let rotationAfter = rotation.1
            setPosition(position: CBPosition(x: SetRotationStyleBrickTests.RIGHT_BORDER_POS, y: 0), rotation: rotationBefore)
            checkPosition(position: CBPosition(x: SetRotationStyleBrickTests.BOUNCE_RIGHT_POS, y: 0), rotation: rotationAfter, rotationDegreeOffset: rotationAfter)
        }
    }

    func testNotAroundUpLeftBounce() {
        setRotationStyleBrick.selection = RotationStyle.notRotate
        let setRotationStyleBrickAction = setRotationStyleBrick.actionBlock()
        setRotationStyleBrickAction()

        setPosition(position: CBPosition(x: SetRotationStyleBrickTests.LEFT_BORDER_POS, y: SetRotationStyleBrickTests.TOP_BORDER_POS), rotation: 135)
        checkPosition(position: CBPosition(x: SetRotationStyleBrickTests.BOUNCE_LEFT_POS, y: SetRotationStyleBrickTests.BOUNCE_TOP_POS), rotation: 135, rotationDegreeOffset: 135)

        setPosition(position: CBPosition(x: SetRotationStyleBrickTests.LEFT_BORDER_POS, y: SetRotationStyleBrickTests.TOP_BORDER_POS), rotation: -45)
        checkPosition(position: CBPosition(x: SetRotationStyleBrickTests.BOUNCE_LEFT_POS, y: SetRotationStyleBrickTests.BOUNCE_TOP_POS), rotation: 135, rotationDegreeOffset: 135)
    }

    func testNotAroundUpRightBounce() {
        setRotationStyleBrick.selection = RotationStyle.notRotate
        let setRotationStyleBrickAction = setRotationStyleBrick.actionBlock()
        setRotationStyleBrickAction()

        setPosition(position: CBPosition(x: SetRotationStyleBrickTests.RIGHT_BORDER_POS, y: SetRotationStyleBrickTests.TOP_BORDER_POS), rotation: -135)
        checkPosition(position: CBPosition(x: SetRotationStyleBrickTests.BOUNCE_RIGHT_POS, y: SetRotationStyleBrickTests.BOUNCE_TOP_POS), rotation: -135, rotationDegreeOffset: -135)

        setPosition(position: CBPosition(x: SetRotationStyleBrickTests.RIGHT_BORDER_POS, y: SetRotationStyleBrickTests.TOP_BORDER_POS), rotation: -45)
        checkPosition(position: CBPosition(x: SetRotationStyleBrickTests.BOUNCE_RIGHT_POS, y: SetRotationStyleBrickTests.BOUNCE_TOP_POS), rotation: -135, rotationDegreeOffset: 225)
    }

    func testNotAroundBottomLeftBounce() {
        setRotationStyleBrick.selection = RotationStyle.notRotate
        let setRotationStyleBrickAction = setRotationStyleBrick.actionBlock()
        setRotationStyleBrickAction()

        setPosition(position: CBPosition(x: SetRotationStyleBrickTests.LEFT_BORDER_POS, y: SetRotationStyleBrickTests.BOTTOM_BORDER_POS), rotation: 45)
        checkPosition(position: CBPosition(x: SetRotationStyleBrickTests.BOUNCE_LEFT_POS, y: SetRotationStyleBrickTests.BOUNCE_BOTTOM_POS), rotation: 45, rotationDegreeOffset: 45)

        setPosition(position: CBPosition(x: SetRotationStyleBrickTests.LEFT_BORDER_POS, y: SetRotationStyleBrickTests.BOTTOM_BORDER_POS), rotation: -135)
        checkPosition(position: CBPosition(x: SetRotationStyleBrickTests.BOUNCE_LEFT_POS, y: SetRotationStyleBrickTests.BOUNCE_BOTTOM_POS), rotation: 45, rotationDegreeOffset: 45)
    }

    func testNotAroundBottomRightBounce() {
        setRotationStyleBrick.selection = RotationStyle.notRotate
        let setRotationStyleBrickAction = setRotationStyleBrick.actionBlock()
        setRotationStyleBrickAction()

        setPosition(position: CBPosition(x: SetRotationStyleBrickTests.RIGHT_BORDER_POS, y: SetRotationStyleBrickTests.BOTTOM_BORDER_POS), rotation: -45)
        checkPosition(position: CBPosition(x: SetRotationStyleBrickTests.BOUNCE_RIGHT_POS, y: SetRotationStyleBrickTests.BOUNCE_BOTTOM_POS), rotation: -45, rotationDegreeOffset: -45)

        setPosition(position: CBPosition(x: SetRotationStyleBrickTests.RIGHT_BORDER_POS, y: SetRotationStyleBrickTests.BOTTOM_BORDER_POS), rotation: 135)
        checkPosition(position: CBPosition(x: SetRotationStyleBrickTests.BOUNCE_RIGHT_POS, y: SetRotationStyleBrickTests.BOUNCE_BOTTOM_POS), rotation: -45, rotationDegreeOffset: 315)
    }

    // MARK: ROTATE LEFT RIGHT
    func testOrientationRight() {
        setRotationStyleBrick.selection = RotationStyle.leftRight
        let setRotationStyleBrickAction = setRotationStyleBrick.actionBlock()
        setRotationStyleBrickAction()

        let rotations: [Double] = [0, 15.0, 45.0, 90.0, 120.0, 150.0, 180.0]

         for rotation in rotations {
            setPosition(position: CBPosition(x: 0, y: 0), rotation: rotation)
            XCTAssertTrue(self.spriteObject.spriteNode.xScale == 1)
        }
    }

    func testOrientationLeft() {
        setRotationStyleBrick.selection = RotationStyle.leftRight
        let setRotationStyleBrickAction = setRotationStyleBrick.actionBlock()
        setRotationStyleBrickAction()

        let rotations: [Double] = [-15.0, -45.0, -90.0, -120.0, -150.0]

         for rotation in rotations {
            setPosition(position: CBPosition(x: 0, y: 0), rotation: rotation)
            XCTAssertTrue(self.spriteObject.spriteNode.xScale == -1)
        }
    }

    func testRotateLRTopBounce() {
        setRotationStyleBrick.selection = RotationStyle.leftRight
        let setRotationStyleBrickAction = setRotationStyleBrick.actionBlock()
        setRotationStyleBrickAction()

        let rotations: [(Double, Double, Double)] = [(90.0, 90.0, 90.0), (120.0, 120.0, 120.0),
                                                     (150.0, 150.0, 150.0), (-180.0, 180.0, 180.0),
                                                     (-150.0, -150.0, -150.0), (-120.0, -120.0, -120.0),
                                                     (-90.0, -90.0, -90.0), (-60.0, -120.0, 240.0),
                                                     (-30.0, -150.0, 210.0), (0.0, 180.0, 180.0),
                                                     (30.0, 150.0, 150.0), (60.0, 120.0, 120.0)]

        for rotation in rotations {
             let rotationBefore = rotation.0
             let rotationAfter = rotation.1

             setPosition(position: CBPosition(x: 0, y: SetRotationStyleBrickTests.TOP_BORDER_POS), rotation: rotationBefore)
            checkPosition(position: CBPosition(x: 0, y: SetRotationStyleBrickTests.BOUNCE_TOP_POS), rotation: rotationAfter, rotationDegreeOffset: rotation.2)
        }
    }

    func testRotateLRBottomBounce() {
        setRotationStyleBrick.selection = RotationStyle.leftRight
        let setRotationStyleBrickAction = setRotationStyleBrick.actionBlock()
        setRotationStyleBrickAction()

        let rotations: [(Double, Double, Double)] = [(90.0, 90.0, 90.0), (120.0, 60.0, 60.0),
                                                     (150.0, 30.0, 30.0), (-180.0, 0.0, 0.0),
                                                     (-150.0, -30.0, 330.0), (-120.0, -60.0, 300),
                                                     (-90.0, -90.0, -90.0), (-60.0, -60.0, -60.0),
                                                     (-30.0, -30.0, -30.0), (0.0, 0.0, 0.0),
                                                     (30.0, 30.0, 30.0), (60.0, 60.0, 60.0)]

        for rotation in rotations {
            let rotationBefore = rotation.0
            let rotationAfter = rotation.1
            setPosition(position: CBPosition(x: 0, y: SetRotationStyleBrickTests.BOTTOM_BORDER_POS), rotation: rotationBefore)
            checkPosition(position: CBPosition(x: 0, y: SetRotationStyleBrickTests.BOUNCE_BOTTOM_POS), rotation: rotationAfter, rotationDegreeOffset: rotation.2)
        }
    }

    func testRotateLRLeftBounce() {
        setRotationStyleBrick.selection = RotationStyle.leftRight
        let setRotationStyleBrickAction = setRotationStyleBrick.actionBlock()
        setRotationStyleBrickAction()

        let rotations: [(Double, Double)] = [(90.0, 90.0), (120.0, 120.0), (150.0, 150.0), (-180.0, 180.0),
                                            (-150.0, 150.0), (-120.0, 120.0), (-90.0, 90.0), (-60.0, 60.0),
                                            (-30.0, 30.0), (0.0, 0.0), (30.0, 30.0), (60.0, 60.0)]

        for rotation in rotations {
            let rotationBefore = rotation.0
            let rotationAfter = rotation.1
            setPosition(position: CBPosition(x: SetRotationStyleBrickTests.LEFT_BORDER_POS, y: 0), rotation: rotationBefore)
            checkPosition(position: CBPosition(x: SetRotationStyleBrickTests.BOUNCE_LEFT_POS, y: 0), rotation: rotationAfter, rotationDegreeOffset: rotationAfter)
        }
    }

    func testRotateLRRightBounce() {
        setRotationStyleBrick.selection = RotationStyle.leftRight
        let setRotationStyleBrickAction = setRotationStyleBrick.actionBlock()
        setRotationStyleBrickAction()

        let rotations: [(Double, Double)] = [(90.0, -90.0), (120.0, -120.0), (150.0, -150.0), (-180.0, 180.0),
                                            (-150.0, -150.0), (-120.0, -120.0), (-90.0, -90.0), (-60.0, -60.0),
                                            (-30.0, -30.0), (0.0, 0.0), (30.0, -30.0), (60.0, -60.0)]

        for rotation in rotations {
            let rotationBefore = rotation.0
            let rotationAfter = rotation.1
            setPosition(position: CBPosition(x: SetRotationStyleBrickTests.RIGHT_BORDER_POS, y: 0), rotation: rotationBefore)
            checkPosition(position: CBPosition(x: SetRotationStyleBrickTests.BOUNCE_RIGHT_POS, y: 0), rotation: rotationAfter, rotationDegreeOffset: rotationAfter)
        }
    }

    func testRotateLRUpLeftBounce() {
        setRotationStyleBrick.selection = RotationStyle.leftRight
        let setRotationStyleBrickAction = setRotationStyleBrick.actionBlock()
        setRotationStyleBrickAction()

        setPosition(position: CBPosition(x: SetRotationStyleBrickTests.LEFT_BORDER_POS, y: SetRotationStyleBrickTests.TOP_BORDER_POS), rotation: 135)
        checkPosition(position: CBPosition(x: SetRotationStyleBrickTests.BOUNCE_LEFT_POS, y: SetRotationStyleBrickTests.BOUNCE_TOP_POS), rotation: 135, rotationDegreeOffset: 135)

        setPosition(position: CBPosition(x: SetRotationStyleBrickTests.LEFT_BORDER_POS, y: SetRotationStyleBrickTests.TOP_BORDER_POS), rotation: -45)
        checkPosition(position: CBPosition(x: SetRotationStyleBrickTests.BOUNCE_LEFT_POS, y: SetRotationStyleBrickTests.BOUNCE_TOP_POS), rotation: 135, rotationDegreeOffset: 135)
    }

    func testRotateLRUpRightBounce() {
        setRotationStyleBrick.selection = RotationStyle.leftRight
        let setRotationStyleBrickAction = setRotationStyleBrick.actionBlock()
        setRotationStyleBrickAction()

        setPosition(position: CBPosition(x: SetRotationStyleBrickTests.RIGHT_BORDER_POS, y: SetRotationStyleBrickTests.TOP_BORDER_POS), rotation: -135)
        checkPosition(position: CBPosition(x: SetRotationStyleBrickTests.BOUNCE_RIGHT_POS, y: SetRotationStyleBrickTests.BOUNCE_TOP_POS), rotation: -135, rotationDegreeOffset: -135)

        setPosition(position: CBPosition(x: SetRotationStyleBrickTests.RIGHT_BORDER_POS, y: SetRotationStyleBrickTests.TOP_BORDER_POS), rotation: -45)
        checkPosition(position: CBPosition(x: SetRotationStyleBrickTests.BOUNCE_RIGHT_POS, y: SetRotationStyleBrickTests.BOUNCE_TOP_POS), rotation: -135, rotationDegreeOffset: 225)
    }

    func testRotateLRBottomLeftBounce() {
        setRotationStyleBrick.selection = RotationStyle.leftRight
        let setRotationStyleBrickAction = setRotationStyleBrick.actionBlock()
        setRotationStyleBrickAction()

        setPosition(position: CBPosition(x: SetRotationStyleBrickTests.LEFT_BORDER_POS, y: SetRotationStyleBrickTests.BOTTOM_BORDER_POS), rotation: 45)
        checkPosition(position: CBPosition(x: SetRotationStyleBrickTests.BOUNCE_LEFT_POS, y: SetRotationStyleBrickTests.BOUNCE_BOTTOM_POS), rotation: 45, rotationDegreeOffset: 45)

        setPosition(position: CBPosition(x: SetRotationStyleBrickTests.LEFT_BORDER_POS, y: SetRotationStyleBrickTests.BOTTOM_BORDER_POS), rotation: -135)
        checkPosition(position: CBPosition(x: SetRotationStyleBrickTests.BOUNCE_LEFT_POS, y: SetRotationStyleBrickTests.BOUNCE_BOTTOM_POS), rotation: 45, rotationDegreeOffset: 45)
    }

    func testRotateLRBottomRightBounce() {
        setRotationStyleBrick.selection = RotationStyle.leftRight
        let setRotationStyleBrickAction = setRotationStyleBrick.actionBlock()
        setRotationStyleBrickAction()

        setPosition(position: CBPosition(x: SetRotationStyleBrickTests.RIGHT_BORDER_POS, y: SetRotationStyleBrickTests.BOTTOM_BORDER_POS), rotation: -45)
        checkPosition(position: CBPosition(x: SetRotationStyleBrickTests.BOUNCE_RIGHT_POS, y: SetRotationStyleBrickTests.BOUNCE_BOTTOM_POS), rotation: -45, rotationDegreeOffset: -45)

        setPosition(position: CBPosition(x: SetRotationStyleBrickTests.RIGHT_BORDER_POS, y: SetRotationStyleBrickTests.BOTTOM_BORDER_POS), rotation: 135)
        checkPosition(position: CBPosition(x: SetRotationStyleBrickTests.BOUNCE_RIGHT_POS, y: SetRotationStyleBrickTests.BOUNCE_BOTTOM_POS), rotation: -45, rotationDegreeOffset: 315)
    }

    func testFlippedWithRotationStyleAllAroundAfterLeftRight() {
        setRotationStyleBrick.selection = RotationStyle.leftRight
        var setRotationStyleBrickAction = setRotationStyleBrick.actionBlock()
        setRotationStyleBrickAction()

        setPosition(position: CBPosition(x: 0, y: 0), rotation: -90)
        XCTAssertTrue(self.spriteObject.spriteNode.xScale == -1)

        setRotationStyleBrick.selection = RotationStyle.allAround
        setRotationStyleBrickAction = setRotationStyleBrick.actionBlock()
        setRotationStyleBrickAction()

        setPosition(position: CBPosition(x: 0, y: 0), rotation: -90)
        XCTAssertTrue(self.spriteObject.spriteNode.xScale == 1)
    }

    private func setPosition(position: CBPosition, rotation: Double) {
        self.spriteObject.spriteNode.catrobatPosition = position
        self.spriteObject.spriteNode.catrobatRotation = rotation

        let action = ifOnEdgeBounceBrick.actionBlock()
        action()
    }

    private func checkPosition(position: CBPosition, rotation: Double, rotationDegreeOffset: Double) {
        XCTAssertEqual(position.x, self.spriteObject.spriteNode.catrobatPosition.x, accuracy: Double(SetRotationStyleBrickTests.EPSILON), "Wrong x after bounce")
        XCTAssertEqual(position.y, self.spriteObject.spriteNode.catrobatPosition.y, accuracy: Double(SetRotationStyleBrickTests.EPSILON), "Wrong y after bounce")
        XCTAssertEqual(rotation, self.spriteObject.spriteNode.catrobatRotation, accuracy: Double(SetRotationStyleBrickTests.EPSILON), "Wrong rotation after bounce")
        XCTAssertEqual(rotationDegreeOffset, self.spriteObject.spriteNode.rotationDegreeOffset, accuracy: Double(SetRotationStyleBrickTests.EPSILON), "Wrong degree offset after bounce")
    }

    func testMutableCopy() {
        let copiedBrick: SetRotationStyleBrick = setRotationStyleBrick.mutableCopy(with: CBMutableCopyContext(), andErrorReporting: true) as! SetRotationStyleBrick

        XCTAssertTrue(setRotationStyleBrick.isEqual(to: copiedBrick))
        XCTAssertFalse(setRotationStyleBrick === copiedBrick)
    }
}
