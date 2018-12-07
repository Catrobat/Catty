/**
 *  Copyright (C) 2010-2018 The Catrobat Team
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

class BrickMoveManagerAbstractTest: XCTestCase {
    var spriteObject: SpriteObject?
    var startScript: StartScript?
    var whenScript: WhenScript?
    var viewController: ScriptCollectionViewController?

    func addForeverLoopWithWaitBrick(to script: Script?) -> Int {

        /* Setup:
            
             0  foreverBeginA
             1      waitA
             2  foreverEndA
            */
        var addedBricks: Int = 0

        let foreverBrickA = ForeverBrick()
        foreverBrickA.script = script
        script?.brickList.add(foreverBrickA as Any)
        addedBricks += 1

        let waitBrickA = WaitBrick()
        script?.brickList.add(waitBrickA as Any)
        addedBricks += 1

        let loopEndBrickA = LoopEndBrick()
        loopEndBrickA.script = script
        loopEndBrickA.loopBeginBrick = foreverBrickA
        script?.brickList.add(loopEndBrickA as Any)
        foreverBrickA.loopEndBrick = loopEndBrickA
        addedBricks += 1

        return addedBricks
    }

    func addRepeatLoopWithWaitBrick(to script: Script?) -> Int {

        /* Setup:
             
             0  foreverBeginA
             1      waitA
             2  foreverEndA
             */
        var addedBricks: Int = 0

        let repeatBrickA = RepeatBrick()
        repeatBrickA.script = script
        script?.brickList.add(repeatBrickA as Any)
        addedBricks += 1

        let waitBrickA = WaitBrick()
        script?.brickList.add(waitBrickA as Any)
        addedBricks += 1

        let loopEndBrickA = LoopEndBrick()
        loopEndBrickA.script = script
        loopEndBrickA.loopBeginBrick = repeatBrickA
        script?.brickList.add(loopEndBrickA as Any)
        repeatBrickA.loopEndBrick = loopEndBrickA
        addedBricks += 1

        return addedBricks
    }

    func addEmptyIfElseEndStructure(to script: Script?) -> Int {
        /*  Setup:
             
             0  ifBegin
             1  else
             2  ifEnd
             */

        var addedBricks: Int = 0

        let ifLogicBeginBrick = IfLogicBeginBrick()
        ifLogicBeginBrick.script = script
        script?.brickList.add(ifLogicBeginBrick as Any)
        addedBricks += 1

        let ifLogicElseBrick = IfLogicElseBrick()
        ifLogicElseBrick.script = script
        ifLogicElseBrick.ifBeginBrick = ifLogicBeginBrick
        script?.brickList.add(ifLogicElseBrick as Any)
        ifLogicBeginBrick.ifElseBrick = ifLogicElseBrick
        addedBricks += 1

        let ifLogicEndBrick = IfLogicEndBrick()
        ifLogicEndBrick.script = script
        ifLogicEndBrick.ifBeginBrick = ifLogicBeginBrick
        ifLogicEndBrick.ifElseBrick = ifLogicElseBrick
        script?.brickList.add(ifLogicEndBrick as Any)
        ifLogicBeginBrick.ifEndBrick = ifLogicEndBrick
        ifLogicElseBrick.ifEndBrick = ifLogicEndBrick
        addedBricks += 1

        return addedBricks
    }

    func addEmptyForeverLoop(to script: Script?) -> Int {
        /*  Setup:
             
             0  foreverBegin
             1  foreverEnd
             */

        var addedBricks: Int = 0

        let foreverBrick = ForeverBrick()
        foreverBrick.script = script
        script?.brickList.add(foreverBrick as Any)
        addedBricks += 1

        let loopEndBrick = LoopEndBrick()
        loopEndBrick.script = script
        loopEndBrick.loopBeginBrick = foreverBrick
        script?.brickList.add(loopEndBrick as Any)
        foreverBrick.loopEndBrick = loopEndBrick
        addedBricks += 1

        return addedBricks
    }

    func addEmptyRepeatLoop(to script: Script?) -> Int {
        /*  Setup:
             
             0  repeatBegin
             1  repeatEnd
             */

        var addedBricks: Int = 0

        let repeatBrick = RepeatBrick()
        repeatBrick.script = script
        script?.brickList.add(repeatBrick as Any)
        addedBricks += 1

        let loopEndBrick = LoopEndBrick()
        loopEndBrick.script = script
        loopEndBrick.loopBeginBrick = repeatBrick
        script?.brickList.add(loopEndBrick as Any)
        repeatBrick.loopEndBrick = loopEndBrick
        addedBricks += 1

        return addedBricks
    }

    func addNestedIfElseOfOrder1WithForeverLoopsWithWaitBricks(to script: Script?) -> Int {
        /*  Setup:
             
             0  ifBeginA
             1      ifBeginB
             2          foreverBeginA
             3              waitA
             4          foreverEndA
             5      elseB
             6          foreverBeginB
             7              waitB
             8          foreverEndB
             9      ifEndB
             10  elseA
             11      ifBeginC
             12          foreverBeginC
             13              waitC
             14          foreverEndC
             15      elseC
             16          foreverBeginD
             17              waitD
             18          foreverEndD
             19      ifEndC
             20  endIfA
             
             */

        var addedBricks: Int = 0

        // 1
        let ifLogicBeginBrickA = IfLogicBeginBrick()
        ifLogicBeginBrickA.script = script
        script?.brickList.add(ifLogicBeginBrickA as Any)
        addedBricks += 1

        // 2
        let ifLogicBeginBrickB = IfLogicBeginBrick()
        ifLogicBeginBrickB.script = script
        script?.brickList.add(ifLogicBeginBrickB as Any)
        addedBricks += 1

        // 3, 4, 5
        addedBricks += addForeverLoopWithWaitBrick(to: script)

        // 6
        let ifLogicElseBrickB = IfLogicElseBrick()
        ifLogicElseBrickB.script = script
        ifLogicElseBrickB.ifBeginBrick = ifLogicBeginBrickB
        script?.brickList.add(ifLogicElseBrickB as Any)
        ifLogicBeginBrickB.ifElseBrick = ifLogicElseBrickB
        addedBricks += 1

        // 7, 8, 9
        addedBricks += addForeverLoopWithWaitBrick(to: script)

        //10
        let ifLogicEndBrickB = IfLogicEndBrick()
        ifLogicEndBrickB.script = script
        ifLogicEndBrickB.ifBeginBrick = ifLogicBeginBrickB
        ifLogicEndBrickB.ifElseBrick = ifLogicElseBrickB
        script?.brickList.add(ifLogicEndBrickB as Any)
        ifLogicBeginBrickB.ifEndBrick = ifLogicEndBrickB
        ifLogicElseBrickB.ifEndBrick = ifLogicEndBrickB
        addedBricks += 1

        // 11
        let ifLogicElseBrickA = IfLogicElseBrick()
        ifLogicElseBrickA.script = script
        ifLogicElseBrickA.ifBeginBrick = ifLogicBeginBrickA
        script?.brickList.add(ifLogicElseBrickA as Any)
        ifLogicBeginBrickA.ifElseBrick = ifLogicElseBrickA
        addedBricks += 1

        // 12
        let ifLogicBeginBrickC = IfLogicBeginBrick()
        ifLogicBeginBrickC.script = script
        script?.brickList.add(ifLogicBeginBrickC as Any)
        addedBricks += 1

        // 13, 14, 15
        addedBricks += addForeverLoopWithWaitBrick(to: script)

        // 16
        let ifLogicElseBrickC = IfLogicElseBrick()
        ifLogicElseBrickC.script = script
        ifLogicElseBrickC.ifBeginBrick = ifLogicBeginBrickC
        script?.brickList.add(ifLogicElseBrickC as Any)
        ifLogicBeginBrickC.ifElseBrick = ifLogicElseBrickC
        addedBricks += 1

        // 17, 18, 19
        addedBricks += addForeverLoopWithWaitBrick(to: script)

        // 20
        let ifLogicEndBrickC = IfLogicEndBrick()
        ifLogicEndBrickC.script = script
        ifLogicEndBrickC.ifBeginBrick = ifLogicBeginBrickC
        ifLogicEndBrickC.ifElseBrick = ifLogicElseBrickC
        script?.brickList.add(ifLogicEndBrickC as Any)
        ifLogicBeginBrickC.ifEndBrick = ifLogicEndBrickC
        ifLogicElseBrickC.ifEndBrick = ifLogicEndBrickC
        addedBricks += 1

        // 21
        let ifLogicEndBrickA = IfLogicEndBrick()
        ifLogicEndBrickA.script = script
        ifLogicEndBrickA.ifBeginBrick = ifLogicBeginBrickA
        ifLogicEndBrickA.ifElseBrick = ifLogicElseBrickA
        script?.brickList.add(ifLogicEndBrickA as Any)
        ifLogicBeginBrickA.ifEndBrick = ifLogicEndBrickA
        ifLogicElseBrickA.ifEndBrick = ifLogicEndBrickA
        addedBricks += 1

        return addedBricks
    }

    func addNestedIfElseOfOrder1WithRepeatLoopsWithWaitBricks(to script: Script?) -> Int {
        /*  Setup:
             
             0  ifBeginA
             1      ifBeginB
             2          repeatBeginA
             3              waitA
             4          repeatEndA
             5      elseB
             6          repeatBeginB
             7              waitB
             8          repeatEndB
             9      ifEndB
             10  elseA
             11      ifBeginC
             12          repeatBeginC
             13              waitC
             14          repeatEndC
             15      elseC
             16          repeatBeginD
             17              waitD
             18          repeatEndD
             19      ifEndC
             20  endIfA
             
             */

        var addedBricks: Int = 0

        // 1
        let ifLogicBeginBrickA = IfLogicBeginBrick()
        ifLogicBeginBrickA.script = script
        script?.brickList.add(ifLogicBeginBrickA as Any)
        addedBricks += 1

        // 2
        let ifLogicBeginBrickB = IfLogicBeginBrick()
        ifLogicBeginBrickB.script = script
        script?.brickList.add(ifLogicBeginBrickB as Any)
        addedBricks += 1

        // 3, 4, 5
        addedBricks += addRepeatLoopWithWaitBrick(to: script)

        // 6
        let ifLogicElseBrickB = IfLogicElseBrick()
        ifLogicElseBrickB.script = script
        ifLogicElseBrickB.ifBeginBrick = ifLogicBeginBrickB
        script?.brickList.add(ifLogicElseBrickB as Any)
        ifLogicBeginBrickB.ifElseBrick = ifLogicElseBrickB
        addedBricks += 1

        // 7, 8, 9
        addedBricks += addRepeatLoopWithWaitBrick(to: script)

        //10
        let ifLogicEndBrickB = IfLogicEndBrick()
        ifLogicEndBrickB.script = script
        ifLogicEndBrickB.ifBeginBrick = ifLogicBeginBrickB
        ifLogicEndBrickB.ifElseBrick = ifLogicElseBrickB
        script?.brickList.add(ifLogicEndBrickB as Any)
        ifLogicBeginBrickB.ifEndBrick = ifLogicEndBrickB
        ifLogicElseBrickB.ifEndBrick = ifLogicEndBrickB
        addedBricks += 1

        // 11
        let ifLogicElseBrickA = IfLogicElseBrick()
        ifLogicElseBrickA.script = script
        ifLogicElseBrickA.ifBeginBrick = ifLogicBeginBrickA
        script?.brickList.add(ifLogicElseBrickA as Any)
        ifLogicBeginBrickA.ifElseBrick = ifLogicElseBrickA
        addedBricks += 1

        // 12
        let ifLogicBeginBrickC = IfLogicBeginBrick()
        ifLogicBeginBrickC.script = script
        script?.brickList.add(ifLogicBeginBrickC as Any)
        addedBricks += 1

        // 13, 14, 15
        addedBricks += addRepeatLoopWithWaitBrick(to: script)

        // 16
        let ifLogicElseBrickC = IfLogicElseBrick()
        ifLogicElseBrickC.script = script
        ifLogicElseBrickC.ifBeginBrick = ifLogicBeginBrickC
        script?.brickList.add(ifLogicElseBrickC as Any)
        ifLogicBeginBrickC.ifElseBrick = ifLogicElseBrickC
        addedBricks += 1

        // 17, 18, 19
        addedBricks += addRepeatLoopWithWaitBrick(to: script)

        // 20
        let ifLogicEndBrickC = IfLogicEndBrick()
        ifLogicEndBrickC.script = script
        ifLogicEndBrickC.ifBeginBrick = ifLogicBeginBrickC
        ifLogicEndBrickC.ifElseBrick = ifLogicElseBrickC
        script?.brickList.add(ifLogicEndBrickC as Any)
        ifLogicBeginBrickC.ifEndBrick = ifLogicEndBrickC
        ifLogicElseBrickC.ifEndBrick = ifLogicEndBrickC
        addedBricks += 1

        // 21
        let ifLogicEndBrickA = IfLogicEndBrick()
        ifLogicEndBrickA.script = script
        ifLogicEndBrickA.ifBeginBrick = ifLogicBeginBrickA
        ifLogicEndBrickA.ifElseBrick = ifLogicElseBrickA
        script?.brickList.add(ifLogicEndBrickA as Any)
        ifLogicBeginBrickA.ifEndBrick = ifLogicEndBrickA
        ifLogicElseBrickA.ifEndBrick = ifLogicEndBrickA
        addedBricks += 1

        return addedBricks
    }

    func addNestedRepeatOrder3WithWaitInHighestLevel(to script: Script?) -> Int {
        /*  Setup:
             
             0  reapeatBeginA
             1      repeatBeginB
             2          repeatBeginC
             3              waitA
             4          repeatEndC
             5      repeatEndB
             6  repeatEndA
             
             */

        var addedBricks: Int = 0

        // 0
        let repeatBrickA = RepeatBrick()
        repeatBrickA.script = script
        script?.brickList.add(repeatBrickA as Any)
        addedBricks += 1

        // 1
        let repeatBrickB = RepeatBrick()
        repeatBrickB.script = script
        script?.brickList.add(repeatBrickB as Any)
        addedBricks += 1

        // 2, 3, 4
        addedBricks += addRepeatLoopWithWaitBrick(to: script)

        // 5
        let loopEndBrickB = LoopEndBrick()
        loopEndBrickB.script = script
        loopEndBrickB.loopBeginBrick = repeatBrickB
        script?.brickList.add(loopEndBrickB as Any)
        repeatBrickB.loopEndBrick = loopEndBrickB
        addedBricks += 1

        // 6
        let loopEndBrickA = LoopEndBrick()
        loopEndBrickA.script = script
        loopEndBrickA.loopBeginBrick = repeatBrickA
        script?.brickList.add(loopEndBrickA as Any)
        repeatBrickA.loopEndBrick = loopEndBrickA
        addedBricks += 1

        return addedBricks
    }

    func addWaitSetXSetYWaitPlaceAtWaitBricks(to script: Script?) -> Int {
        /*  Setup:
             
             0  waitBrickA
             1  setXBrickA
             2  setYBrickA
             3  waitBrickB
             4  placeAtXYA
             5  waitBrickC
             
             */

        var addedBricks: Int = 0

        // 0
        let waitBrickA = WaitBrick()
        script?.brickList.add(waitBrickA as Any)
        addedBricks += 1

        // 1
        let position = Formula()
        let formulaTree = FormulaElement()
        formulaTree.type = ElementType.NUMBER
        formulaTree.value = "20"
        position.formulaTree = formulaTree

        let setXBrickA = SetXBrick()
        setXBrickA.script = script
        setXBrickA.xPosition = position
        script?.brickList.add(setXBrickA as Any)
        addedBricks += 1

        // 2
        let setYBrickA = SetYBrick()
        setYBrickA.script = script
        setYBrickA.yPosition = position
        script?.brickList.add(setYBrickA as Any)
        addedBricks += 1

        // 3
        let waitBrickB = WaitBrick()
        script?.brickList.add(waitBrickB as Any)
        addedBricks += 1

        // 4
        let yPosition = Formula()
        let formulaTree0 = FormulaElement()
        formulaTree0.type = ElementType.NUMBER
        formulaTree0.value = "20"
        yPosition.formulaTree = formulaTree0

        let xPosition = Formula()
        let formulaTree1 = FormulaElement()
        formulaTree1.type = ElementType.NUMBER
        formulaTree1.value = "20"
        xPosition.formulaTree = formulaTree1

        let placeAtXYA = PlaceAtBrick()
        placeAtXYA.script = script
        placeAtXYA.yPosition = yPosition
        placeAtXYA.xPosition = xPosition
        script?.brickList.add(placeAtXYA as Any)
        addedBricks += 1

        // 5
        let waitBrickC = WaitBrick()
        script?.brickList.add(waitBrickC as Any)
        addedBricks += 1

        return addedBricks
    }

    override func setUp() {
        super.setUp()
        spriteObject = SpriteObject()
        spriteObject?.name = "SpriteObject"

        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)

        viewController = ScriptCollectionViewController(collectionViewLayout: layout)

        XCTAssertNotNil(viewController, "ScriptCollectionViewController must not be nil")

        viewController?.object = spriteObject

        startScript = StartScript()
        startScript?.object = spriteObject
        whenScript = WhenScript()
        whenScript?.object = spriteObject

        if let aScript = startScript {
            spriteObject?.scriptList.add(aScript as Any)
        }

        XCTAssertEqual(1, viewController?.collectionView.numberOfSections)
        XCTAssertEqual(1, viewController?.collectionView.numberOfItems(inSection: 0))

        BrickMoveManager.sharedInstance().getReadyForNewBrickMovement()
    }
}
