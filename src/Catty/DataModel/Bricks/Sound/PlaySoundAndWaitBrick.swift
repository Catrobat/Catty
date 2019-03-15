/**
 *  Copyright (C) 2010-2019 The Catrobat Team
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

@objc(PlaySoundAndWaitBrick) class PlaySoundAndWaitBrick: Brick, BrickSoundProtocol {

    func setSound(_ sound: Sound!, forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) {
        self.sound = sound
    }

    func sound(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> Sound! {
        return self.sound
    }

    @objc public var sound: Sound!

    override init() {
        super.init()
    }

    override var brickTitle: String! {
        return kLocalizedPlaySoundAndWait + "\n%@"
    }

    override func setDefaultValuesFor(_ spriteObject: SpriteObject!) {
        if let spriteObject = spriteObject {
            let sounds = spriteObject.soundList as! [Sound]
            if !sounds.isEmpty {
                self.sound = sounds[0]
            } else {
                self.sound = nil
            }
        }
    }

    override func mutableCopy(with context: CBMutableCopyContext!) -> Any! {
        let brick = PlaySoundAndWaitBrick()
        let updatedReference = context.updatedReference(forReference: self.sound)

        if updatedReference != nil {
            brick.sound = updatedReference as? Sound
        } else {
            brick.sound = self.sound
        }

        return brick
    }

    override func isEqual(to brick: Brick!) -> Bool {
        if !self.sound.isEqual(to: (brick as! PlaySoundAndWaitBrick).sound) {
            return false
        }
        return true
    }

    override func getRequiredResources() -> Int {
        return ResourceType.noResources.rawValue
    }

    override func description() -> String! {
        return "PlaySoundAndWait (File Name: \(String(describing: self.sound.fileName))"
    }
}
