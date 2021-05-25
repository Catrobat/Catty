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
@objc(Sound)
@objcMembers class Sound: NSObject, CBMutableCopying {

    var fileName: String
    var name: String
    var playing: Bool

    @objc(initWithName: andFileName:)
    init(name: String, fileName: String) {
        self.name = name
        self.fileName = fileName
        self.playing = false
        super.init()
    }

    @objc(pathForScene:)
    func path(for scene: Scene) -> String? {
        guard let soundsPath = scene.soundsPath() else {
            return nil
        }

        return String(format: "%@/%@", soundsPath, self.fileName)
    }

    @objc(mutableCopyWithContext:)
    func mutableCopy(with context: CBMutableCopyContext) -> Any! {
        let copiedSound = Sound(name: self.name, fileName: self.fileName)
        context.updateReference(self, withReference: copiedSound)

        return copiedSound
    }

    @objc override var description: String {
        String(format: "Sound: %@\r", self.name)
    }

    @objc var isPlaying: Bool {
        self.playing
    }

    @objc override func isEqual(_ object: Any?) -> Bool {
        guard let sound = object as? Sound else {
            return false
        }

        if (name == sound.name) && (fileName == sound.fileName) {
            return true
        }

        return false
    }

}
