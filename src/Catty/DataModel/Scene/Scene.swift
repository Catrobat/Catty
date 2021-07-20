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

@objc(Scene)
@objcMembers class Scene: NSObject, CBMutableCopying {
    private var _objects: [SpriteObject]
    var name: String
    var project: Project?

    override var description: String {
        allObjectNames().joined(separator: ", ")
    }

    override init() {
        _objects = [SpriteObject]()
        name = String()
    }

    init(name: String) {
        self.name = name
        self._objects = [SpriteObject]()
    }

    var count: Int {
        self._objects.count
    }

    func numberOfBackgroundObjects() -> Int {
        let numberOfTotalObjects = self.count
        if numberOfTotalObjects < kBackgroundObjects {
            return numberOfTotalObjects
        }
        return Int(kBackgroundObjects)
    }

    func numberOfNormalObjects() -> Int {
        let numberOfTotalObjects = self.count
        if numberOfTotalObjects > kBackgroundObjects {
            return numberOfTotalObjects - Int(kBackgroundObjects)
        }
        return 0
    }

    func width() -> String? {
        if let project = project, let screenWidth = project.header.screenWidth {
            return screenWidth.stringValue
        }
        return nil
    }

    func height() -> String? {
        if let project = project, let screenHeight = project.header.screenHeight {
            return screenHeight.stringValue
        }
        return nil
    }

    func objects() -> [SpriteObject] {
        self._objects
    }

    @objc(objectAtIndex:)
    func object(at index: Int) -> SpriteObject? {
        if index >= 0 && index < self._objects.count {
            return _objects[index]
        }
        return nil
    }

    @objc(insertObject:atIndex:)
    func insert(object: SpriteObject, at index: Int) {
        if index >= 0 && index <= self._objects.count {
            self._objects.insert(object, at: index)
        }
    }

    @objc(addObject:)
    func add(object: SpriteObject) {
        if !objects().contains(object) {
            object.scene = self
            self._objects.append(object)
        }
    }

    func addObject(withName name: String) {
        let object = SpriteObject()
        object.name = name

        object.name = Util.uniqueName(name, existingNames: allObjectNames())
        self.add(object: object)
        project?.saveToDisk(withNotification: false)
    }

    @objc(removeObjectAtIndex:)
    func removeObject(at index: Int) {
        if index >= 0 && index < self._objects.count {
            self._objects.remove(at: index)
        }
    }

    func removeObject(_ object: SpriteObject) {
        var index = 0
        for currentObject in self.objects() {
            if currentObject == object {
                currentObject.removeSounds(currentObject.soundList as? [Any], andSaveToDisk: false)
                currentObject.removeLooks(currentObject.lookList as? [Any], andSaveToDisk: false)
                currentObject.userData.removeAllVariables()
                currentObject.userData.removeAllLists()
                self.removeObject(at: index)
                break
            }
            index += 1
        }
    }

    func objectExists(withName objectName: String) -> Bool {
        for object in self.objects() where object.name == objectName {
            return true
        }
        return false
    }

    func hasObject(_ object: SpriteObject) -> Bool {
        _objects.contains(object)
    }

    func allObjectNames() -> [String] {
        var objectNames = [String]()
        for spriteObject in self.objects() {
            if let name = spriteObject.name {
                objectNames.append(name)
            }
        }
        return objectNames
    }

    func renameObject(_ object: SpriteObject, toName newObjectName: String) {
        if !hasObject(object) || (object.name == newObjectName) {
            return
        }
        object.name = Util.uniqueName(newObjectName, existingNames: allObjectNames())
        project?.saveToDisk(withNotification: true)
    }

    func getRequiredResources() -> Int {
        var resources = 0
        for obj in self.objects() {
            resources |= obj.getRequiredResources()
        }
        return resources
    }

    func imagesPath() -> String? {
        if let path = self.path() {
            return path + kProjectImagesDirName
        }
        return nil
    }

    func soundsPath() -> String? {
        if let path = self.path() {
            return path + kProjectSoundsDirName
        }
        return nil
    }

    func path() -> String? {
        if let project = project {
            return "\(project.projectPath() + self.name)/"
        }
        return nil
    }

    @objc(copyObject:withNameForCopiedObject:)
    func copy(_ sourceObject: SpriteObject, withNameForCopiedObject nameOfCopiedObject: String) -> SpriteObject? {
        if !self.hasObject(sourceObject) {
            return nil
        }
        let context = CBMutableCopyContext()
        var copiedVariables = [UserVariable]()
        var copiedLists = [UserList]()

        let variables = UserDataContainer.objectVariables(for: sourceObject)
        let lists = UserDataContainer.objectLists(for: sourceObject)

        for variable in variables {
            let copyVariable = UserVariable(variable: variable)
            copiedVariables.append(copyVariable)
            context.updateReference(variable, withReference: copyVariable)
        }

        for list in lists {
            let copyList = UserList(list: list)
            copiedLists.append(copyList)
            context.updateReference(list, withReference: copyList)
        }

        if let copiedObject = sourceObject.mutableCopy(with: context) as? SpriteObject {
            copiedObject.name = Util.uniqueName(nameOfCopiedObject, existingNames: allObjectNames())
            _objects.append(copiedObject)

            for variable in copiedVariables {
                copiedObject.userData.add(variable)
            }
            for list in copiedLists {
                copiedObject.userData.add(list)
            }
            project?.saveToDisk(withNotification: true)
            return copiedObject
        }

        return nil
    }

    @objc(copyObjects:)
    func copyObjects(_ objects: [SpriteObject]) -> [SpriteObject] {
        var objectsList = [SpriteObject]()
        for object in objects {
            guard let copiedObject = self.copy(object, withNameForCopiedObject: object.name) else {
                return objectsList
            }
            objectsList.append(copiedObject)
        }
        return objectsList
    }

    func mutableCopy(with context: CBMutableCopyContext) -> Any {
        let copyScene = Scene(name: self.name)
        copyScene.project = self.project
        for object in self.objects() {
            if let spriteObject = object.mutableCopy(with: context) as? SpriteObject {
                copyScene.add(object: spriteObject)
            }
        }
        return copyScene
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let scene = object as? Scene else { return false }

        if scene.name != self.name || scene.objects().count != self.objects().count { return false }

        for object in self._objects {
            var contains = false
            for compareObject in scene.objects() {
                if compareObject.isEqual(to: object) {
                    contains = true
                    break
                }
            }
            if !contains {
                return false
            }
        }

        return true
    }

}
