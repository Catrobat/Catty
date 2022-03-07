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

import Foundation

@objc(WhenBackgroundChangesScript)
class WhenBackgroundChangesScript: Script, BrickLookProtocol {
    @objc var look: Look?

    init(look: Look) {
        super.init()
        self.look = look
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public required init() {
        super.init()
    }

    public func category() -> kBrickCategoryType {
        kBrickCategoryType.eventBrick
    }

    override func description() -> String {
        guard let currentLook = self.look else { return "WhenBackgroundChangesScript (Look: nil)" }
        return String(format: "WhenBackgroundChangesScript (Look: %@)", currentLook.name)
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

    public func look(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> Look? {
        self.look
    }

    public func setLook(_ look: Look!, forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) {
        if look != nil {
            self.look = look
        }
    }

    override func getRequiredResources() -> Int {
        ResourceType.noResources.rawValue
    }

    @objc(mutableCopyWithContext:)
    override func mutableCopy(with context: CBMutableCopyContext!) -> Any! {
        guard context != nil else { fatalError("\(CBMutableCopyContext.Type.self)/" + " must not be nil!") }

        let brick = WhenBackgroundChangesScript.init()
        brick.look = nil

        if let currentLook = self.look {
            let updatedReference = context.updatedReference(forReference: currentLook)

            if updatedReference != nil {
                brick.look = updatedReference as? Look
            } else {
                brick.look = currentLook
            }
        }

        return brick
    }

    override func clone(with object: SpriteObject!) -> Script! {
        let clone = WhenBackgroundChangesScript()
        clone.object = object
        clone.look = self.look

        return clone
    }
}
