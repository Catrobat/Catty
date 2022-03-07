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

@objc(CloneBrick)
@objcMembers class CloneBrick: Brick, BrickObjectWithOutBackgroundProtocol {

    var objectToClone: SpriteObject?
    static var nameCounter: Int = 1

    override required init() {
        super.init()
    }

    func category() -> kBrickCategoryType {
        kBrickCategoryType.eventBrick
    }

    override class func description() -> String {
        "CloneBrick"
    }

    override func getRequiredResources() -> Int {
        ResourceType.noResources.rawValue
    }

    override func brickCell() -> BrickCellProtocol.Type! {
        CloneBrickCell.self as BrickCellProtocol.Type
    }

    func setObject(_ object: SpriteObject?, forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) {
        if let object = object {
            objectToClone = object
        }
    }

    func object(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> SpriteObject? {
        self.objectToClone
    }

    override func setDefaultValuesFor(_ spriteObject: SpriteObject!) {
        if spriteObject != nil {
            objectToClone = spriteObject
        } else {
            objectToClone = self.script.object
        }
    }

    override func isDisabledForBackground() -> Bool {
        true
    }

    @objc(mutableCopyWithContext:)
    override func mutableCopy(with context: CBMutableCopyContext) -> Any {
        let brick = CloneBrick()
        if self.objectToClone != nil {
            brick.objectToClone = self.objectToClone
        }
        return brick
    }

    override func clone(with script: Script!) -> Brick! {
        let clone = CloneBrick()
        clone.script = script
        if self.objectToClone == self.script.object {
            clone.objectToClone = clone.script.object
        } else {
            clone.objectToClone = self.objectToClone
        }

        return clone
    }
}
