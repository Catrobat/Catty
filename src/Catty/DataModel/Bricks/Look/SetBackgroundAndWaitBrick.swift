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

@objc(SetBackgroundAndWaitBrick)
@objcMembers class SetBackgroundAndWaitBrick: Brick, BrickLookProtocol {
    @objc var look: Look?

    init(look: Look) {
        self.look = look
        super.init()
    }

    override public required init() {
        super.init()
    }

    func pathForLook() -> String {
        guard let currentlook = self.look else {
            fatalError("look should not be nil!")
        }

        guard let path = currentlook.path(for: self.script.object.scene) else {
            fatalError("path should not be nil")
        }

        return path
    }

    func category() -> [NSNumber]! {
        [NSNumber(value: kBrickCategoryType.lookBrick.rawValue)]
    }

    override func description() -> String {
        guard let currentLook = self.look else { return "SetBackgroundAndWaitBrick (Look: nil)" }
        return String(format: "SetBackgroundAndWaitBrick (Look: %@)", currentLook.name)
    }

    override func isEqual(to brick: Brick!) -> Bool {
        guard let setBackgroundAndWaitBrick = brick as? SetBackgroundAndWaitBrick else { return false }
        return self.look?.isEqual(setBackgroundAndWaitBrick.look) == true
    }

    override func getRequiredResources() -> Int {
        ResourceType.noResources.rawValue
    }

    override func brickCell() -> BrickCellProtocol.Type {
        SetBackgroundAndWaitBrickCell.self as BrickCellProtocol.Type
    }

    override func setDefaultValuesFor(_ spriteObject: SpriteObject!) {
        self.look = nil

        if spriteObject != nil {
            guard let looks = spriteObject.lookList as? [Look] else { return }

            if !looks.isEmpty {
                self.look = looks.first
            } else {
                self.look = nil
            }
        }
    }

    override func isDisabledForBackground() -> Bool {
        false
    }

    func look(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> Look! {
        self.look
    }

    func setLook(_ look: Look!, forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) {
        if look != nil {
            self.look = look
        }
    }

    @objc(mutableCopyWithContext:)
    override func mutableCopy(with context: CBMutableCopyContext!) -> Any! {
        guard context != nil else { fatalError("\(CBMutableCopyContext.Type.self)/" + " must not be nil!") }

        let brick = SetBackgroundAndWaitBrick.init()

        let updatedReference = context.updatedReference(forReference: self.look)

        if updatedReference != nil {
            brick.look = updatedReference as? Look
        } else {
            brick.look = self.look
        }

        return brick
    }
}
