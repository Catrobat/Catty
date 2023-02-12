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

@objc(PlaceAtBrick)
@objcMembers class PlaceAtBrick: Brick, BrickVisualPlacementProtocol {
    var xPosition: Formula
    var yPosition: Formula

    override required init () {
        self.xPosition = Formula(integer: 100)
        self.yPosition = Formula(integer: 200)
        super.init()
    }

    func formula(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> Formula? {
        if paramNumber == 0 {
            return self.xPosition
        } else if paramNumber == 1 {
            return self.yPosition
        }
        return nil
    }

    func setFormula(_ formula: Formula, forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) {
        if paramNumber == 0 {
            self.xPosition = formula
        } else if paramNumber == 1 {
            self.yPosition = formula
        }
    }

    func getFormulas() -> [Formula]! {
        [self.xPosition, self.yPosition]
    }

    func allowsStringFormula() -> Bool {
        false
    }

    override func setDefaultValuesFor(_ spriteObject: SpriteObject) {
        self.xPosition = Formula(integer: 100)
        self.yPosition = Formula(integer: 200)
    }

    func category() -> kBrickCategoryType {
        kBrickCategoryType.motionBrick
    }

    override class func description() -> String {
        "PlaceAtBrick"
    }

    func isVisualPlacementFormula(_ formula: Formula) -> Bool {
        doVisualPlacementBrickCellsContainOnlyValues()
    }

    func doVisualPlacementBrickCellsContainOnlyValues() -> Bool {
        xPosition.formulaTree.isSingleNumberFormula() && yPosition.formulaTree.isSingleNumberFormula()
    }

    override func getRequiredResources() -> Int {
        xPosition.getRequiredResources() | yPosition.getRequiredResources()
    }
}
