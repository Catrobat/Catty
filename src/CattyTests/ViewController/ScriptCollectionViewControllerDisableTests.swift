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

final class ScriptCollectionViewControllerDisableTests: XCTestCase {

    var layout: UICollectionViewFlowLayout!
    var viewController: ScriptCollectionViewController!

    override func setUp() {
        super.setUp()
        layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)
        viewController = ScriptCollectionViewController(collectionViewLayout: layout)
        XCTAssertNotNil(viewController, "ScriptCollectionViewController must not be nil")
    }

    func testDisableAndEnableBrick() {
        let startScript = StartScript()
        let setVariableBrick = SetVariableBrick()
        startScript.brickList = NSMutableArray(array: [setVariableBrick])
        setVariableBrick.script = startScript

        viewController.disableOrEnable(brick: setVariableBrick)

        XCTAssertTrue(setVariableBrick.isDisabled)

        viewController.disableOrEnable(brick: setVariableBrick)

        XCTAssertFalse(setVariableBrick.isDisabled)

    }

    func testDisableAndEnableIfLogicByBeginBrick() {
        let startScript = StartScript()
        let setVariableBrick = SetVariableBrick()
        let ifLogicBeginBrick = IfLogicBeginBrick()
        let changeVariableBrick1 = ChangeVariableBrick()
        let ifLogicElseBrick = IfLogicElseBrick()
        let changeVariableBrick2 = ChangeVariableBrick()
        let ifLogicEndBrick = IfLogicEndBrick()
        let showTextBrick = ShowTextBrick()
        ifLogicBeginBrick.ifElseBrick = ifLogicElseBrick
        ifLogicBeginBrick.ifEndBrick = ifLogicEndBrick
        ifLogicElseBrick.ifBeginBrick = ifLogicBeginBrick
        ifLogicElseBrick.ifEndBrick = ifLogicEndBrick
        ifLogicEndBrick.ifBeginBrick = ifLogicBeginBrick
        ifLogicEndBrick.ifElseBrick = ifLogicElseBrick

        let scriptBrickList = [setVariableBrick, ifLogicBeginBrick, changeVariableBrick1, ifLogicElseBrick, changeVariableBrick2, ifLogicEndBrick, showTextBrick]
        startScript.brickList = NSMutableArray(array: scriptBrickList)

        scriptBrickList.forEach({ $0.script = startScript })

        viewController.disableOrEnable(brick: ifLogicBeginBrick)
        //before if block
        XCTAssertFalse(setVariableBrick.isDisabled)
        //if block
        XCTAssertTrue(ifLogicBeginBrick.isDisabled)
        XCTAssertTrue(changeVariableBrick1.isDisabled)
        XCTAssertTrue(ifLogicElseBrick.isDisabled)
        XCTAssertTrue(changeVariableBrick2.isDisabled)
        XCTAssertTrue(ifLogicEndBrick.isDisabled)
        //after if block
        XCTAssertFalse(showTextBrick.isDisabled)

        viewController.disableOrEnable(brick: ifLogicBeginBrick)
        XCTAssertFalse(setVariableBrick.isDisabled)
        //if block
        XCTAssertFalse(ifLogicBeginBrick.isDisabled)
        XCTAssertFalse(changeVariableBrick1.isDisabled)
        XCTAssertFalse(ifLogicElseBrick.isDisabled)
        XCTAssertFalse(changeVariableBrick2.isDisabled)
        XCTAssertFalse(ifLogicEndBrick.isDisabled)
        //after if block
        XCTAssertFalse(showTextBrick.isDisabled)
    }

    func testDisableAndEnableIfLogicByElseBrick() {
        let startScript = StartScript()
        let setVariableBrick = SetVariableBrick()
        let ifLogicBeginBrick = IfLogicBeginBrick()
        let changeVariableBrick1 = ChangeVariableBrick()
        let ifLogicElseBrick = IfLogicElseBrick()
        let changeVariableBrick2 = ChangeVariableBrick()
        let ifLogicEndBrick = IfLogicEndBrick()
        let showTextBrick = ShowTextBrick()
        ifLogicBeginBrick.ifElseBrick = ifLogicElseBrick
        ifLogicBeginBrick.ifEndBrick = ifLogicEndBrick
        ifLogicElseBrick.ifBeginBrick = ifLogicBeginBrick
        ifLogicElseBrick.ifEndBrick = ifLogicEndBrick
        ifLogicEndBrick.ifBeginBrick = ifLogicBeginBrick
        ifLogicEndBrick.ifElseBrick = ifLogicElseBrick

        let scriptBrickList = [setVariableBrick, ifLogicBeginBrick, changeVariableBrick1, ifLogicElseBrick, changeVariableBrick2, ifLogicEndBrick, showTextBrick]
        startScript.brickList = NSMutableArray(array: scriptBrickList)

        scriptBrickList.forEach({ $0.script = startScript })

        viewController.disableOrEnable(brick: ifLogicElseBrick)
        //before if block
        XCTAssertFalse(setVariableBrick.isDisabled)
        //if block
        XCTAssertTrue(ifLogicBeginBrick.isDisabled)
        XCTAssertTrue(changeVariableBrick1.isDisabled)
        XCTAssertTrue(ifLogicElseBrick.isDisabled)
        XCTAssertTrue(changeVariableBrick2.isDisabled)
        XCTAssertTrue(ifLogicEndBrick.isDisabled)
        //after if block
        XCTAssertFalse(showTextBrick.isDisabled)

        viewController.disableOrEnable(brick: ifLogicElseBrick)
        XCTAssertFalse(setVariableBrick.isDisabled)
        //if block
        XCTAssertFalse(ifLogicBeginBrick.isDisabled)
        XCTAssertFalse(changeVariableBrick1.isDisabled)
        XCTAssertFalse(ifLogicElseBrick.isDisabled)
        XCTAssertFalse(changeVariableBrick2.isDisabled)
        XCTAssertFalse(ifLogicEndBrick.isDisabled)
        //after if block
        XCTAssertFalse(showTextBrick.isDisabled)
    }

    func testDisableAndEnableIfLogicByEndBrick() {
        let startScript = StartScript()
        let setVariableBrick = SetVariableBrick()
        let ifLogicBeginBrick = IfLogicBeginBrick()
        let changeVariableBrick1 = ChangeVariableBrick()
        let ifLogicElseBrick = IfLogicElseBrick()
        let changeVariableBrick2 = ChangeVariableBrick()
        let ifLogicEndBrick = IfLogicEndBrick()
        let showTextBrick = ShowTextBrick()
        ifLogicBeginBrick.ifElseBrick = ifLogicElseBrick
        ifLogicBeginBrick.ifEndBrick = ifLogicEndBrick
        ifLogicElseBrick.ifBeginBrick = ifLogicBeginBrick
        ifLogicElseBrick.ifEndBrick = ifLogicEndBrick
        ifLogicEndBrick.ifBeginBrick = ifLogicBeginBrick
        ifLogicEndBrick.ifElseBrick = ifLogicElseBrick

        let scriptBrickList = [setVariableBrick, ifLogicBeginBrick, changeVariableBrick1, ifLogicElseBrick, changeVariableBrick2, ifLogicEndBrick, showTextBrick]
        startScript.brickList = NSMutableArray(array: scriptBrickList)

        scriptBrickList.forEach({ $0.script = startScript })

        viewController.disableOrEnable(brick: ifLogicEndBrick)
        //before if block
        XCTAssertFalse(setVariableBrick.isDisabled)
        //if block
        XCTAssertTrue(ifLogicBeginBrick.isDisabled)
        XCTAssertTrue(changeVariableBrick1.isDisabled)
        XCTAssertTrue(ifLogicElseBrick.isDisabled)
        XCTAssertTrue(changeVariableBrick2.isDisabled)
        XCTAssertTrue(ifLogicEndBrick.isDisabled)
        //after if block
        XCTAssertFalse(showTextBrick.isDisabled)

        viewController.disableOrEnable(brick: ifLogicEndBrick)
        XCTAssertFalse(setVariableBrick.isDisabled)
        //if block
        XCTAssertFalse(ifLogicBeginBrick.isDisabled)
        XCTAssertFalse(changeVariableBrick1.isDisabled)
        XCTAssertFalse(ifLogicElseBrick.isDisabled)
        XCTAssertFalse(changeVariableBrick2.isDisabled)
        XCTAssertFalse(ifLogicEndBrick.isDisabled)
        //after if block
        XCTAssertFalse(showTextBrick.isDisabled)
    }

    func testDisableAndEnableIfThenLogicByBeginBrick() {
        let startScript = StartScript()
        let setVariableBrick = SetVariableBrick()
        let ifThenLogicBeginBrick = IfThenLogicBeginBrick()
        let changeVariableBrick1 = ChangeVariableBrick()
        let ifThenLogicEndBrick = IfThenLogicEndBrick()
        let showTextBrick = ShowTextBrick()
        ifThenLogicBeginBrick.ifEndBrick = ifThenLogicEndBrick
        ifThenLogicEndBrick.ifBeginBrick = ifThenLogicBeginBrick

        let scriptBrickList = [setVariableBrick, ifThenLogicBeginBrick, changeVariableBrick1, ifThenLogicEndBrick, showTextBrick]
        startScript.brickList = NSMutableArray(array: scriptBrickList)

        scriptBrickList.forEach({ $0.script = startScript })

        viewController.disableOrEnable(brick: ifThenLogicBeginBrick)
        //before if block
        XCTAssertFalse(setVariableBrick.isDisabled)
        //if block
        XCTAssertTrue(ifThenLogicBeginBrick.isDisabled)
        XCTAssertTrue(changeVariableBrick1.isDisabled)
        XCTAssertTrue(ifThenLogicEndBrick.isDisabled)
        //after if block
        XCTAssertFalse(showTextBrick.isDisabled)

        viewController.disableOrEnable(brick: ifThenLogicBeginBrick)
        //before if block
        XCTAssertFalse(setVariableBrick.isDisabled)
        //if block
        XCTAssertFalse(ifThenLogicBeginBrick.isDisabled)
        XCTAssertFalse(changeVariableBrick1.isDisabled)
        XCTAssertFalse(ifThenLogicEndBrick.isDisabled)
        //after if block
        XCTAssertFalse(showTextBrick.isDisabled)
    }

    func testDisableAndEnableIfThenLogicByEndBrick() {
        let startScript = StartScript()
        let setVariableBrick = SetVariableBrick()
        let ifThenLogicBeginBrick = IfThenLogicBeginBrick()
        let changeVariableBrick1 = ChangeVariableBrick()
        let ifThenLogicEndBrick = IfThenLogicEndBrick()
        let showTextBrick = ShowTextBrick()
        ifThenLogicBeginBrick.ifEndBrick = ifThenLogicEndBrick
        ifThenLogicEndBrick.ifBeginBrick = ifThenLogicBeginBrick

        let scriptBrickList = [setVariableBrick, ifThenLogicBeginBrick, changeVariableBrick1, ifThenLogicEndBrick, showTextBrick]
        startScript.brickList = NSMutableArray(array: scriptBrickList)

        scriptBrickList.forEach({ $0.script = startScript })

        viewController.disableOrEnable(brick: ifThenLogicEndBrick)
        //before if block
        XCTAssertFalse(setVariableBrick.isDisabled)
        //if block
        XCTAssertTrue(ifThenLogicBeginBrick.isDisabled)
        XCTAssertTrue(changeVariableBrick1.isDisabled)
        XCTAssertTrue(ifThenLogicEndBrick.isDisabled)
        //after if block
        XCTAssertFalse(showTextBrick.isDisabled)

        viewController.disableOrEnable(brick: ifThenLogicEndBrick)
        //before if block
        XCTAssertFalse(setVariableBrick.isDisabled)
        //if block
        XCTAssertFalse(ifThenLogicBeginBrick.isDisabled)
        XCTAssertFalse(changeVariableBrick1.isDisabled)
        XCTAssertFalse(ifThenLogicEndBrick.isDisabled)
        //after if block
        XCTAssertFalse(showTextBrick.isDisabled)
    }

    func testDisableAndEnableForeverLoopByBeginBrick() {
        let startScript = StartScript()
        let setVariableBrick = SetVariableBrick()
        let loopBeginBrick = LoopBeginBrick()
        let changeVariableBrick1 = ChangeVariableBrick()
        let loopEndBrick = LoopEndBrick()
        let showTextBrick = ShowTextBrick()
        loopBeginBrick.loopEndBrick = loopEndBrick
        loopEndBrick.loopBeginBrick = loopBeginBrick

        let scriptBrickList = [setVariableBrick, loopBeginBrick, changeVariableBrick1, loopEndBrick, showTextBrick]
        startScript.brickList = NSMutableArray(array: scriptBrickList)

        scriptBrickList.forEach({ $0.script = startScript })

        viewController.disableOrEnable(brick: loopBeginBrick)
        //before loop
        XCTAssertFalse(setVariableBrick.isDisabled)
        //loop
        XCTAssertTrue(loopBeginBrick.isDisabled)
        XCTAssertTrue(changeVariableBrick1.isDisabled)
        XCTAssertTrue(loopEndBrick.isDisabled)
        //after loop
        XCTAssertFalse(showTextBrick.isDisabled)

        viewController.disableOrEnable(brick: loopBeginBrick)
        //before loop
        XCTAssertFalse(setVariableBrick.isDisabled)
        //loop
        XCTAssertFalse(loopBeginBrick.isDisabled)
        XCTAssertFalse(changeVariableBrick1.isDisabled)
        XCTAssertFalse(loopEndBrick.isDisabled)
        //after loop
        XCTAssertFalse(showTextBrick.isDisabled)
    }

    func testDisableAndEnableForeverLoopByEndBrick() {
        let startScript = StartScript()
        let setVariableBrick = SetVariableBrick()
        let loopBeginBrick = LoopBeginBrick()
        let changeVariableBrick1 = ChangeVariableBrick()
        let loopEndBrick = LoopEndBrick()
        let showTextBrick = ShowTextBrick()
        loopBeginBrick.loopEndBrick = loopEndBrick
        loopEndBrick.loopBeginBrick = loopBeginBrick

        let scriptBrickList = [setVariableBrick, loopBeginBrick, changeVariableBrick1, loopEndBrick, showTextBrick]
        startScript.brickList = NSMutableArray(array: scriptBrickList)

        scriptBrickList.forEach({ $0.script = startScript })

        viewController.disableOrEnable(brick: loopEndBrick)
        //before loop
        XCTAssertFalse(setVariableBrick.isDisabled)
        //loop
        XCTAssertTrue(loopBeginBrick.isDisabled)
        XCTAssertTrue(changeVariableBrick1.isDisabled)
        XCTAssertTrue(loopEndBrick.isDisabled)
        //after loop
        XCTAssertFalse(showTextBrick.isDisabled)

        viewController.disableOrEnable(brick: loopEndBrick)
        //before loop
        XCTAssertFalse(setVariableBrick.isDisabled)
        //loop
        XCTAssertFalse(loopBeginBrick.isDisabled)
        XCTAssertFalse(changeVariableBrick1.isDisabled)
        XCTAssertFalse(loopEndBrick.isDisabled)
        //after loop
        XCTAssertFalse(showTextBrick.isDisabled)
    }

    func testDisableAndEnableRepeatByBeginBrick() {
        let startScript = StartScript()
        let setVariableBrick = SetVariableBrick()
        let repeatBrick = RepeatBrick()
        let changeVariableBrick1 = ChangeVariableBrick()
        let loopEndBrick = LoopEndBrick()
        let showTextBrick = ShowTextBrick()
        repeatBrick.loopEndBrick = loopEndBrick
        loopEndBrick.loopBeginBrick = repeatBrick

        let scriptBrickList = [setVariableBrick, repeatBrick, changeVariableBrick1, loopEndBrick, showTextBrick]
        startScript.brickList = NSMutableArray(array: scriptBrickList)

        scriptBrickList.forEach({ $0.script = startScript })

        viewController.disableOrEnable(brick: repeatBrick)
        //before loop
        XCTAssertFalse(setVariableBrick.isDisabled)
        //loop
        XCTAssertTrue(repeatBrick.isDisabled)
        XCTAssertTrue(changeVariableBrick1.isDisabled)
        XCTAssertTrue(loopEndBrick.isDisabled)
        //after loop
        XCTAssertFalse(showTextBrick.isDisabled)

        viewController.disableOrEnable(brick: repeatBrick)
        //before loop
        XCTAssertFalse(setVariableBrick.isDisabled)
        //loop
        XCTAssertFalse(repeatBrick.isDisabled)
        XCTAssertFalse(changeVariableBrick1.isDisabled)
        XCTAssertFalse(loopEndBrick.isDisabled)
        //after loop
        XCTAssertFalse(showTextBrick.isDisabled)
    }

    func testDisableAndEnableRepeatByEndBrick() {
        let startScript = StartScript()
        let setVariableBrick = SetVariableBrick()
        let repeatBrick = RepeatBrick()
        let changeVariableBrick1 = ChangeVariableBrick()
        let loopEndBrick = LoopEndBrick()
        let showTextBrick = ShowTextBrick()
        repeatBrick.loopEndBrick = loopEndBrick
        loopEndBrick.loopBeginBrick = repeatBrick

        let scriptBrickList = [setVariableBrick, repeatBrick, changeVariableBrick1, loopEndBrick, showTextBrick]
        startScript.brickList = NSMutableArray(array: scriptBrickList)

        scriptBrickList.forEach({ $0.script = startScript })

        viewController.disableOrEnable(brick: loopEndBrick)
        //before loop
        XCTAssertFalse(setVariableBrick.isDisabled)
        //loop
        XCTAssertTrue(repeatBrick.isDisabled)
        XCTAssertTrue(changeVariableBrick1.isDisabled)
        XCTAssertTrue(loopEndBrick.isDisabled)
        //after loop
        XCTAssertFalse(showTextBrick.isDisabled)

        viewController.disableOrEnable(brick: loopEndBrick)
        //before loop
        XCTAssertFalse(setVariableBrick.isDisabled)
        //loop
        XCTAssertFalse(repeatBrick.isDisabled)
        XCTAssertFalse(changeVariableBrick1.isDisabled)
        XCTAssertFalse(loopEndBrick.isDisabled)
        //after loop
        XCTAssertFalse(showTextBrick.isDisabled)
    }

    func testDisableAndEnableRepeatUntilByBeginBrick() {
        let startScript = StartScript()
        let setVariableBrick = SetVariableBrick()
        let repeatUntilBrick = RepeatUntilBrick()
        let changeVariableBrick1 = ChangeVariableBrick()
        let loopEndBrick = LoopEndBrick()
        let showTextBrick = ShowTextBrick()
        repeatUntilBrick.loopEndBrick = loopEndBrick
        loopEndBrick.loopBeginBrick = repeatUntilBrick

        let scriptBrickList = [setVariableBrick, repeatUntilBrick, changeVariableBrick1, loopEndBrick, showTextBrick]
        startScript.brickList = NSMutableArray(array: scriptBrickList)

        scriptBrickList.forEach({ $0.script = startScript })

        viewController.disableOrEnable(brick: repeatUntilBrick)
        //before loop
        XCTAssertFalse(setVariableBrick.isDisabled)
        //loop
        XCTAssertTrue(repeatUntilBrick.isDisabled)
        XCTAssertTrue(changeVariableBrick1.isDisabled)
        XCTAssertTrue(loopEndBrick.isDisabled)
        //after loop
        XCTAssertFalse(showTextBrick.isDisabled)

        viewController.disableOrEnable(brick: repeatUntilBrick)
        //before loop
        XCTAssertFalse(setVariableBrick.isDisabled)
        //loop
        XCTAssertFalse(repeatUntilBrick.isDisabled)
        XCTAssertFalse(changeVariableBrick1.isDisabled)
        XCTAssertFalse(loopEndBrick.isDisabled)
        //after loop
        XCTAssertFalse(showTextBrick.isDisabled)
    }

    func testDisableAndEnableRepeatUntilByEndBrick() {
        let startScript = StartScript()
        let setVariableBrick = SetVariableBrick()
        let repeatUntilBrick = RepeatUntilBrick()
        let changeVariableBrick1 = ChangeVariableBrick()
        let loopEndBrick = LoopEndBrick()
        let showTextBrick = ShowTextBrick()
        repeatUntilBrick.loopEndBrick = loopEndBrick
        loopEndBrick.loopBeginBrick = repeatUntilBrick

        let scriptBrickList = [setVariableBrick, repeatUntilBrick, changeVariableBrick1, loopEndBrick, showTextBrick]
        startScript.brickList = NSMutableArray(array: scriptBrickList)

        scriptBrickList.forEach({ $0.script = startScript })

        viewController.disableOrEnable(brick: loopEndBrick)
        //before loop
        XCTAssertFalse(setVariableBrick.isDisabled)
        //loop
        XCTAssertTrue(repeatUntilBrick.isDisabled)
        XCTAssertTrue(changeVariableBrick1.isDisabled)
        XCTAssertTrue(loopEndBrick.isDisabled)
        //after loop
        XCTAssertFalse(showTextBrick.isDisabled)

        viewController.disableOrEnable(brick: loopEndBrick)
        //before loop
        XCTAssertFalse(setVariableBrick.isDisabled)
        //loop
        XCTAssertFalse(repeatUntilBrick.isDisabled)
        XCTAssertFalse(changeVariableBrick1.isDisabled)
        XCTAssertFalse(loopEndBrick.isDisabled)
        //after loop
        XCTAssertFalse(showTextBrick.isDisabled)
    }

    func testBrickIsDisabledInsideLoopBrick() {
        let startScript = StartScript()
        let loopBeginBrick = LoopBeginBrick()
        let changeVariableBrick = ChangeVariableBrick()
        let loopEndBrick = LoopEndBrick()
        loopBeginBrick.loopEndBrick = loopEndBrick

        let scriptBrickList = [loopBeginBrick, changeVariableBrick, loopEndBrick]
        startScript.brickList = NSMutableArray(array: scriptBrickList)

        scriptBrickList.forEach({ $0.script = startScript })

        viewController.disableOrEnable(brick: loopBeginBrick)
        XCTAssertTrue(loopBeginBrick.isDisabled)
        XCTAssertTrue(changeVariableBrick.isDisabled)
        XCTAssertTrue(loopEndBrick.isDisabled)

        XCTAssertFalse(viewController.isInsideDisabledLoopOrIf(brick: loopBeginBrick))
        XCTAssertTrue(viewController.isInsideDisabledLoopOrIf(brick: changeVariableBrick))
        XCTAssertFalse(viewController.isInsideDisabledLoopOrIf(brick: loopEndBrick))
    }

    func testBrickIsDisabledInsideIfLogicBeginBrick() {
        let startScript = StartScript()
        let ifLogicBeginBrick = IfLogicBeginBrick()
        let changeVariableBrick = ChangeVariableBrick()
        let ifLogicEndBrick = IfLogicEndBrick()
        ifLogicBeginBrick.ifEndBrick = ifLogicEndBrick
        ifLogicEndBrick.ifBeginBrick = ifLogicBeginBrick

        let scriptBrickList = [ifLogicBeginBrick, changeVariableBrick, ifLogicEndBrick]
        startScript.brickList = NSMutableArray(array: scriptBrickList)

        scriptBrickList.forEach({ $0.script = startScript })

        viewController.disableOrEnable(brick: ifLogicBeginBrick)
        XCTAssertTrue(ifLogicBeginBrick.isDisabled)
        XCTAssertTrue(changeVariableBrick.isDisabled)
        XCTAssertTrue(ifLogicEndBrick.isDisabled)

        XCTAssertFalse(viewController.isInsideDisabledLoopOrIf(brick: ifLogicBeginBrick))
        XCTAssertTrue(viewController.isInsideDisabledLoopOrIf(brick: changeVariableBrick))
        XCTAssertFalse(viewController.isInsideDisabledLoopOrIf(brick: ifLogicEndBrick))
    }

    func testBrickIsDisabledInsideIfThenLogicBrick() {
        let startScript = StartScript()
        let ifThenLogicBeginBrick = IfThenLogicBeginBrick()
        let changeVariableBrick = ChangeVariableBrick()
        let ifThenLogicEndBrick = IfThenLogicEndBrick()
        ifThenLogicBeginBrick.ifEndBrick = ifThenLogicEndBrick
        ifThenLogicEndBrick.ifBeginBrick = ifThenLogicBeginBrick

        let scriptBrickList = [ifThenLogicBeginBrick, changeVariableBrick, ifThenLogicEndBrick]
        startScript.brickList = NSMutableArray(array: scriptBrickList)

        scriptBrickList.forEach({ $0.script = startScript })

        viewController.disableOrEnable(brick: ifThenLogicBeginBrick)
        XCTAssertTrue(ifThenLogicBeginBrick.isDisabled)
        XCTAssertTrue(changeVariableBrick.isDisabled)
        XCTAssertTrue(ifThenLogicEndBrick.isDisabled)

        XCTAssertFalse(viewController.isInsideDisabledLoopOrIf(brick: ifThenLogicBeginBrick))
        XCTAssertTrue(viewController.isInsideDisabledLoopOrIf(brick: changeVariableBrick))
        XCTAssertFalse(viewController.isInsideDisabledLoopOrIf(brick: ifThenLogicEndBrick))
    }
    
    FUNC
}
