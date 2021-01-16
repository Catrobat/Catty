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
@objc(Look)
@objcMembers class Look: NSObject, CBMutableCopying {

    var fileName: String
    var name: String

    @objc(initWithName: andPath:)
    init(name: String, filePath: String) {
        self.name = name
        self.fileName = filePath
        super.init()
    }

    @objc(pathForScene:)
    func path(for scene: Scene) -> String? {
        guard let imgPath = scene.imagesPath() else {
            return String(format: "/%@", self.fileName)
        }

        return String(format: "%@/%@", imgPath, self.fileName)
    }

    @objc func mutableCopy(with context: CBMutableCopyContext) -> Any! {
        let copiedLook = Look(name: self.name, filePath: self.fileName)
        context.updateReference(self, withReference: copiedLook)

        return copiedLook
    }

    @objc override var description: String {
        String(format: "Name: %@\rPath: %@\r", self.name, self.fileName)
    }

    @objc override func isEqual(_ object: Any?) -> Bool {
        guard let look = object as? Look else {
            return false
        }

        if (name == look.name) && (fileName == look.fileName) {
            return true
        }

        return false
    }

}
