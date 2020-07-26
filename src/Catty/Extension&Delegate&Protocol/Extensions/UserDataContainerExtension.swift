/**
 *  Copyright (C) 2010-2020 The Catrobat Team
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

@objc extension UserDataContainer {

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
        var objectVariables = [UserVariable]()
        if let variableList = object.userData.variables() {
            objectVariables.append(contentsOf: variableList)
        }
        return objectVariables
    }

    @objc(objectListsForObject:)
    static func objectLists(for object: SpriteObject) -> [UserList] {
        var objectList = [UserList]()
        if let listList = object.userData.lists() {
            objectList.append(contentsOf: listList)
        }
        return objectList
    }

    @objc(objectAndProjectVariablesForObject:)
    static func objectAndProjectVariables(for object: SpriteObject) -> [UserVariable] {
        var objectAndProjectVariables = [UserVariable]()
        if let project = object.project {
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
        if let project = object.project {
            if let lists = NSMutableArray(array: project.userData.lists()) as? [UserList] {
                objectAndProjectLists = lists
            }
        }
        objectAndProjectLists.append(contentsOf: UserDataContainer.objectLists(for: object))
        return objectAndProjectLists
    }

    @objc(objectOrProjectVariableForObject:andName:)
    static func objectOrProjectVariable(for object: SpriteObject, and name: String) -> UserVariable? {
        if let variable = object.userData.getUserVariable(withName: name) {
            return variable
        }
        if let project = object.project {
            return project.userData.getUserVariable(withName: name)
        }
        return nil
    }

    @objc(objectOrProjectListForObject:andName:)
    static func objectOrProjectList(for object: SpriteObject, and name: String) -> UserList? {
        if let list = object.userData.getUserList(withName: name) {
            return list
        }
        if let project = object.project {
            return project.userData.getUserList(withName: name)
        }
        return nil
    }

}
