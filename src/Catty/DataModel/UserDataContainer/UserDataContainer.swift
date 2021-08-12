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

@objc(UserDataContainer)
@objcMembers class UserDataContainer: NSObject, CBMutableCopying {

    private var _variables: SynchronizedArray<UserVariable>
    private var _lists: SynchronizedArray<UserList>

    override init() {
        self._variables = SynchronizedArray<UserVariable>()
        self._lists = SynchronizedArray<UserList>()
    }

    func variables() -> [UserVariable] {
        var variables = [UserVariable]()
        for index in 0..<self._variables.count {
            if let variable = self._variables[index] {
                variables.append(variable)
            }
        }
        return variables
    }

    func lists() -> [UserList] {
        var lists = [UserList]()
        for index in 0..<self._lists.count {
            if let list = self._lists[index] {
                lists.append(list)
            }
        }
        return lists
    }

    func removeAllVariables() {
        _variables.removeAll()
    }

    func removeAllLists() {
        _lists.removeAll()
    }

    func getUserVariable(identifiedBy name: String) -> UserVariable? {
        for index in 0..<_variables.count {
            if let variable = _variables[index], variable.name == name {
                return variable
            }
        }
        return nil
    }

    func getUserList(identifiedBy name: String) -> UserList? {
        for index in 0..<_lists.count {
            if let list = _lists[index], list.name == name {
                return list
            }
        }
        return nil
    }

    @objc(removeUserVariableIdentifiedBy:)
    func removeUserVariable(identifiedBy name: String) -> Bool {
        if let _ = getUserVariable(identifiedBy: name) {
            _variables.remove(name: name)
            return true
        }
        return false
    }

    @objc(removeUserListIdentifiedBy:)
    func removeUserList(identifiedBy name: String) -> Bool {
        if let _ = getUserList(identifiedBy: name) {
            _lists.remove(name: name)
            return true
        }
        return false
    }

    @objc(containsVariable:)
    func contains(_ variable: UserVariable) -> Bool {
        _variables.contains(variable)
    }

    @objc(containsList:)
    func contains(_ list: UserList) -> Bool {
        _lists.contains(list)
    }

    @objc(addVariable:)
    func add(_ variable: UserVariable) {
        if !_variables.contains(variable) {
            _variables.append(variable)
        }
    }

    @objc(addList:)
    func add(_ list: UserList) {
        if !_lists.contains(list) {
            _lists.append(list)
        }
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let userDataContainer = object as? UserDataContainer else { return false }

        if self.lists().count != userDataContainer.lists().count || self.variables().count != userDataContainer.variables().count {
            return false
        }

        for list in self.lists() {
            if !userDataContainer.contains(list) {
                return false
            }
        }
        for variable in self.variables() {
            if !userDataContainer.contains(variable) {
                return false
            }
        }

        return true
    }

    func mutableCopy(with context: CBMutableCopyContext) -> Any {
        let copiedUserDataContainer = UserDataContainer()

        for index in 0..<_variables.count {
            if let variable = _variables[index], let copiedVariable = variable.mutableCopy(with: context) as? UserVariable {
                copiedUserDataContainer.add(copiedVariable)
            }
        }
        for index in 0..<_lists.count {
            if let list = _lists[index], let copiedList = list.mutableCopy(with: context) as? UserList {
                copiedUserDataContainer.add(copiedList)
            }
        }

        return copiedUserDataContainer
    }

    @objc(allVariablesForProject:)
    static func allVariables(for project: Project) -> [UserVariable] {
        var allVariables = [UserVariable]()
        if let vars = NSMutableArray(array: project.userData.variables()) as? [UserVariable] {
            allVariables = vars
        }

        let allObjects = project.allObjects()
        for object in allObjects {
            let objectVariables = UserDataContainer.objectVariables(for: object)
            allVariables.append(contentsOf: objectVariables)
        }
        return allVariables
    }

    @objc(allListsForProject:)
    static func allLists(for project: Project) -> [UserList] {
        var allLists = [UserList]()
        if let lists = NSMutableArray(array: project.userData.lists()) as? [UserList] {
            allLists = lists
        }

        let allObjects = project.allObjects()
        for object in allObjects {
            let objectLists = UserDataContainer.objectLists(for: object)
            allLists.append(contentsOf: objectLists)
        }
        return allLists
    }

    @objc(objectVariablesForObject:)
    static func objectVariables(for object: SpriteObject) -> [UserVariable] {
        object.userData.variables()
    }

    @objc(objectListsForObject:)
    static func objectLists(for object: SpriteObject) -> [UserList] {
        object.userData.lists()
    }

    @objc(objectAndProjectVariablesForObject:)
    static func objectAndProjectVariables(for object: SpriteObject) -> [UserVariable] {
        var objectAndProjectVariables = [UserVariable]()
        if let project = object.scene.project {
            if let vars = NSMutableArray(array: project.userData.variables()) as? [UserVariable] {
                objectAndProjectVariables = vars
            }
        }
        objectAndProjectVariables.append(contentsOf: UserDataContainer.objectVariables(for: object))
        return objectAndProjectVariables
    }

    @objc(objectAndProjectListsForObject:)
    static func objectAndProjectLists(for object: SpriteObject) -> [UserList] {
        var objectAndProjectLists = [UserList]()
        if let project = object.scene.project {
            if let lists = NSMutableArray(array: project.userData.lists()) as? [UserList] {
                objectAndProjectLists = lists
            }
        }
        objectAndProjectLists.append(contentsOf: UserDataContainer.objectLists(for: object))
        return objectAndProjectLists
    }

    @objc(objectOrProjectVariableForObject:andName:)
    static func objectOrProjectVariable(for object: SpriteObject, and name: String) -> UserVariable? {
        if let variable = object.userData.getUserVariable(identifiedBy: name) {
            return variable
        }
        if let project = object.scene.project {
            return project.userData.getUserVariable(identifiedBy: name)
        }
        return nil
    }

    @objc(objectOrProjectListForObject:andName:)
    static func objectOrProjectList(for object: SpriteObject, and name: String) -> UserList? {
        if let list = object.userData.getUserList(identifiedBy: name) {
            return list
        }
        if let project = object.scene.project {
            return project.userData.getUserList(identifiedBy: name)
        }
        return nil
    }
}
