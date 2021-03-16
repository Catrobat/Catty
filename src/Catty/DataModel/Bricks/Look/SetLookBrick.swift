/**
 *  Copyright (C) 2010-2021 The Catrobat Team
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

@objc(SetLookBrick)
@objcMembers class SetLookBrick: Brick, BrickLookProtocol {
    @objc var look: Look?

    init(look: Look) {
        self.look = look
        super.init()
    }

    func category() -> kBrickCategoryType {
        kBrickCategoryType.lookBrick
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public required init() {
        super.init()
    }

    override func isDisabledForBackground() -> Bool {
        true
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
    override func description() -> String {
        guard let currentLook = self.look else { return "SetLookBrick (Look: nil)" }
           return String(format: "SetLookBrick (Look: %@)", currentLook.name)
       }

    override func brickCell() -> BrickCellProtocol.Type {
        SetLookBrickCell.self as BrickCellProtocol.Type
    }

    override func isEqual(to brick: Brick) -> Bool {
        guard let brick = brick as? SetLookBrick else { return false }
        return (self.look?.isEqual(brick.look)) == true
    }

    func look(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> Look! {
        self.look
    }

    func setLook(_ look: Look?, forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) {
        if look != nil {
            self.look = look
        }
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

    override func getRequiredResources() -> Int {
        ResourceType.noResources.rawValue
    }

    @objc(mutableCopyWithContext:)
    override func mutableCopy(with context: CBMutableCopyContext) -> Any {
        let brick = SetLookBrick.init()

        let updatedReference = context.updatedReference(forReference: self.look)

        if updatedReference != nil {
            brick.look = updatedReference as? Look
        } else {
            brick.look = self.look
        }

        return brick
    }
}
