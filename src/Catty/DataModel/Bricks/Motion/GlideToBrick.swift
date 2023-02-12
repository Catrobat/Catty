/**
 *  Copyright (C) 2010-2022 The Catrobat Team
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

@objc(GlideToBrick)
@objcMembers class GlideToBrick: Brick, BrickVisualPlacementProtocol {
    var durationInSeconds: Formula
    var xPosition: Formula
    var yPosition: Formula

    override required init() {
        self.durationInSeconds = Formula(integer: 1)
        self.xPosition = Formula(integer: 100)
        self.yPosition = Formula(integer: 200)
        super.init()
    }

    func category() -> kBrickCategoryType {
        kBrickCategoryType.motionBrick
    }

    func formula(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> Formula? {
        if lineNumber == 0 && paramNumber == 0 {
            return self.durationInSeconds
        } else if lineNumber == 1 && paramNumber == 0 {
            return self.xPosition
        } else if lineNumber == 1 && paramNumber == 1 {
            return self.yPosition
        }

        return nil
    }

    func setFormula(_ formula: Formula, forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) {
        if lineNumber == 0 && paramNumber == 0 {
            self.durationInSeconds = formula
        } else if lineNumber == 1 && paramNumber == 0 {
            self.xPosition = formula
        } else if lineNumber == 1 && paramNumber == 1 {
            self.yPosition = formula
        }
    }

    func getFormulas() -> [Formula] {
        [self.durationInSeconds, self.xPosition, self.yPosition]
    }

    func allowsStringFormula() -> Bool {
        false
    }

    override func setDefaultValuesFor(_ spriteObject: SpriteObject!) {
        self.durationInSeconds = Formula(integer: 1)
        self.xPosition = Formula(integer: 100)
        self.yPosition = Formula(integer: 200)
    }

    override func description() -> String! {
        "GlideToBrick"
    }

    override func isEqual(to brick: Brick!) -> Bool {
        if brick is GlideToBrick {
            let glideToBrick = brick as! GlideToBrick
            return self.durationInSeconds.isEqual(to: glideToBrick.durationInSeconds) &&
            self.xPosition.isEqual(to: glideToBrick.xPosition) &&
            self.yPosition.isEqual(to: glideToBrick.yPosition)
        }
        return false
    }

    func isVisualPlacementFormula(_ formula: Formula) -> Bool {
        (formula.isEqual(to: xPosition) || formula.isEqual(to: yPosition)) &&
        doVisualPlacementBrickCellsContainOnlyValues()
    }

    func doVisualPlacementBrickCellsContainOnlyValues() -> Bool {
        xPosition.formulaTree.isSingleNumberFormula() && yPosition.formulaTree.isSingleNumberFormula()
    }

    override func getRequiredResources() -> Int {
        durationInSeconds.getRequiredResources() | xPosition.getRequiredResources() | yPosition.getRequiredResources()
    }
}
