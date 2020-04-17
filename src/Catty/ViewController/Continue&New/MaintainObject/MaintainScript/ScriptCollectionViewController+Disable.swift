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

extension ScriptCollectionViewController {
    @objc func disableOrEnable(brick: Brick) {
        brick.isDisabled = !brick.isDisabled
        guard let brickList = brick.script.brickList as? [Brick] else {
            NSLog("Cannot cast bricklist to array of Brick elements!")
            return
        }

        if brick.isLoopBrick() {
            disableOrEnableLoop(brick: brick, brickList: brickList)
        } else if brick.isIfLogicBrick() {
            disableOrEnableIfLogic(brick: brick, brickList: brickList)
        }
    }

    fileprivate func disableOrEnableLoop(brick: Brick, brickList: [Brick]) {
        if let loopBegin = brick as? LoopBeginBrick {
            handleLoopBeginBrick(loopBeginBrick: loopBegin, brickList: brickList)
        } else if let loopEnd = brick as? LoopEndBrick {
            handleLoopEndBrick(loopEndBrick: loopEnd, brickList: brickList)
        }
    }

    fileprivate func handleLoopBeginBrick(loopBeginBrick: LoopBeginBrick, brickList: [Brick]) {
        let beginIndex = loopBeginBrick.script.brickList.index(of: loopBeginBrick)
        var loopIndex = beginIndex + 1
        var loopBrick: Brick = brickList[loopIndex]

        let loopEndBrick = loopBeginBrick.loopEndBrick as LoopEndBrick

        while loopBrick != loopEndBrick && loopIndex < (brickList.count - 1) {
            loopBrick.isDisabled = loopBeginBrick.isDisabled
            loopIndex += 1
            loopBrick = brickList[loopIndex]
        }
        loopEndBrick.isDisabled = loopBeginBrick.isDisabled
    }

    fileprivate func handleLoopEndBrick(loopEndBrick: LoopEndBrick, brickList: [Brick]) {
        let beginIndex = loopEndBrick.script.brickList.index(of: loopEndBrick)
        var loopIndex = beginIndex - 1
        var loopBrick: Brick = brickList[loopIndex]

        while loopBrick != loopEndBrick.loopBeginBrick && loopIndex > 0 {
            loopBrick.isDisabled = loopEndBrick.isDisabled
            loopIndex -= 1
            loopBrick = brickList[loopIndex]
        }
        loopEndBrick.loopBeginBrick.isDisabled = loopEndBrick.isDisabled
    }

    fileprivate func disableOrEnableIfLogic(brick: Brick, brickList: [Brick]) {
        if let ifBegin = brick as? IfLogicBeginBrick {
            handleLogicBeginBrick(logicBegin: ifBegin, containsElse: true, brickList: brickList)
        } else if let ifLogicElse = brick as? IfLogicElseBrick {
            let ifBegin = ifLogicElse.ifBeginBrick as IfLogicBeginBrick
            ifBegin.isDisabled = ifLogicElse.isDisabled
            handleLogicBeginBrick(logicBegin: ifBegin, containsElse: true, brickList: brickList)
        } else if let ifThenBegin = brick as? IfThenLogicBeginBrick {
            handleLogicBeginBrick(logicBegin: ifThenBegin, containsElse: false, brickList: brickList)
        } else if let ifEnd = brick as? IfLogicEndBrick {
            handleLogicEndBrick(logicEnd: ifEnd, containsElse: true, brickList: brickList)
        } else if let ifThenEnd = brick as? IfThenLogicEndBrick {
            handleLogicEndBrick(logicEnd: ifThenEnd, containsElse: false, brickList: brickList)
        }
    }

    fileprivate func handleLogicBeginBrick(logicBegin: Brick, containsElse: Bool, brickList: [Brick]) {
        let beginIndex = logicBegin.script.brickList.index(of: logicBegin)
        var logicIndex = beginIndex + 1
        var logicBrick: Brick = brickList[logicIndex]
        var end: Brick!

        if let ifLogicBeginBrick = logicBegin as? IfLogicBeginBrick {
            end = ifLogicBeginBrick.ifEndBrick
            ifLogicBeginBrick.ifEndBrick.isDisabled = logicBegin.isDisabled
        } else if let ifThenLogicBeginBrick = logicBegin as? IfThenLogicBeginBrick {
            end = ifThenLogicBeginBrick.ifEndBrick
            ifThenLogicBeginBrick.ifEndBrick.isDisabled = logicBegin.isDisabled
        } else {
            NSLog("No end block found")
            return
        }

        while logicBrick != end && logicIndex < (brickList.count - 1) {
            logicBrick.isDisabled = logicBegin.isDisabled
            logicIndex += 1
            logicBrick = brickList[logicIndex]
        }
    }

    fileprivate func handleLogicEndBrick(logicEnd: Brick, containsElse: Bool, brickList: [Brick]) {
        let beginIndex = logicEnd.script.brickList.index(of: logicEnd)
        var logicIndex = beginIndex - 1
        var logicBrick: Brick = brickList[logicIndex]
        let begin: Brick!

        if let ifLogicEndBrick = logicEnd as? IfLogicEndBrick {
            begin = ifLogicEndBrick.ifBeginBrick
            ifLogicEndBrick.ifBeginBrick.isDisabled = logicEnd.isDisabled
        } else if let ifThenLogicEndBrick = logicEnd as? IfThenLogicEndBrick {
            begin = ifThenLogicEndBrick.ifBeginBrick
            ifThenLogicEndBrick.ifBeginBrick.isDisabled = logicEnd.isDisabled
        } else {
            NSLog("No end block found")
            return
        }

        while logicBrick != begin && logicIndex > 0 {
            logicBrick.isDisabled = logicEnd.isDisabled
            logicIndex -= 1
            logicBrick = brickList[logicIndex]
        }
    }
}
