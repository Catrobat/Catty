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

extension FormulaEditorDataSectionViewController {

    func askProjectOrObject(isList: Bool) {
        let promptTitle = isList ? kUIFEActionList : kUIFEActionVar

        AlertController(title: promptTitle, message: nil, style: .actionSheet)
            .addCancelAction(title: kLocalizedCancel, handler: nil)
            .addDefaultAction(title: kUIFEActionVarPro) {
                if isList {
                    self.addNewList(isProjectList: true)
                } else {
                    self.addNewVariable(isProjectVariable: true)
                }
            }
            .addDefaultAction(title: kUIFEActionVarObj) {
            if isList {
                self.addNewList(isProjectList: false)
                } else {
                self.addNewVariable(isProjectVariable: false)
                }
            }.build().showWithController(self)
    }

    private func addNewList(isProjectList: Bool) {
        self.newVarIsForProject = isProjectList
        Util.askUser(forVariableNameAndPerformAction: #selector(saveList(name:)),
                     target: self,
                     promptTitle: kUIFENewList,
                     promptMessage: kUIFEListName,
                     minInputLength: UInt(kMinNumOfVariableNameCharacters),
                     maxInputLength: UInt(kMaxNumOfVariableNameCharacters),
                     isList: true,
                     andTextField: nil,
                     initialText: "")
    }

    private func addNewVariable(isProjectVariable: Bool) {
        self.newVarIsForProject = isProjectVariable
        Util.askUser(forVariableNameAndPerformAction: #selector(saveVariable(name:)),
                     target: self,
                     promptTitle: kUIFENewVar,
                     promptMessage: kUIFEVarName,
                     minInputLength: UInt(kMinNumOfVariableNameCharacters),
                     maxInputLength: UInt(kMaxNumOfVariableNameCharacters),
                     isList: false,
                     andTextField: nil,
                     initialText: "")

    }

    func askForNewVariableName() {
        Util.askUser(forVariableNameAndPerformAction: #selector(saveVariable(name:)),
                     target: self,
                     promptTitle: kUIFENewVarExists,
                     promptMessage: kUIFEOtherName,
                     minInputLength: UInt(kMinNumOfVariableNameCharacters),
                     maxInputLength: UInt(kMaxNumOfVariableNameCharacters),
                     isList: false,
                     andTextField: nil,
                     initialText: "")
    }

    @objc func saveVariable(name: String) {
        if self.newVarIsForProject {
            if let project = self.spriteObject.scene.project {
                for variable in UserDataContainer.allVariables(for: project) where variable.name == name {
                    self.askForNewVariableName()
                    return
                }
            }
        } else {
            for variable in UserDataContainer.objectAndProjectVariables(for: spriteObject) where variable.name == name {
                self.askForNewVariableName()
                return
            }
        }

        let userVariable = UserVariable(name: name)
        userVariable.value = Int(0)

        if self.newVarIsForProject {
            self.spriteObject.scene.project?.userData.add(userVariable)
        } else {
            self.spriteObject.userData.add(userVariable)
        }

        self.spriteObject.scene.project?.saveToDisk(withNotification: false)
        self.reloadData()
    }

    @objc func saveList(name: String) {
        if self.newVarIsForProject {
            if let project = self.spriteObject.scene.project {
                for variable in UserDataContainer.allLists(for: project) where variable.name == name {
                    self.askForNewVariableName()
                    return
                }
            }
        } else {
            for variable in UserDataContainer.objectAndProjectLists(for: spriteObject) where variable.name == name {
                self.askForNewVariableName()
                return
            }
        }

        let userList = UserList(name: name)

        if self.newVarIsForProject {
            self.spriteObject.scene.project?.userData.add(userList)
        } else {
            self.spriteObject.userData.add(userList)
        }

        self.spriteObject.scene.project?.saveToDisk(withNotification: false)
        self.reloadData()
    }

    private func getAllBricks(for object: SpriteObject) -> [Brick] {
        var bricks = [Brick]()

        for scriptElement in object.scriptList {
            if let script = scriptElement as? Script {

                for brickElement in script.brickList where brickElement is Brick {
                    if let brick = brickElement as? Brick {
                        bricks.append(brick)
                    }
                }

            }
        }

        return bricks
    }

    func isVariableUsed(_ userVariable: UserVariable) -> Bool {

        guard let project = self.spriteObject.scene.project else {
            fatalError("project of the spriteObject is nil")
        }

        if project.userData.contains(userVariable) {

            for object in project.allObjects() {
                for brick in self.getAllBricks(for: object) {
                    if brick.isVariableUsed(variable: userVariable) {
                        return true
                    }
                }
            }

        } else {
            for brick in self.getAllBricks(for: spriteObject) {
                if brick.isVariableUsed(variable: userVariable) {
                    return true
                }
            }
        }

        return false
    }

    func isListUsed(_ userList: UserList) -> Bool {

        guard let project = self.spriteObject.scene.project else {
            fatalError("project of the spriteObject is nil")
        }

        if project.userData.contains(userList) {
            for object in project.allObjects() {
                for brick in self.getAllBricks(for: object) {
                    if brick.isListUsed(list: userList) {
                        return true
                    }
                }

            }
        } else {
            for brick in self.getAllBricks(for: spriteObject) {
                if brick.isListUsed(list: userList) {
                    return true
                }
            }
        }

        return false
    }

    func deleteVariable(userVariable: UserVariable) -> Bool {

        if !self.isVariableUsed(userVariable) {

            guard let project = self.spriteObject.scene.project else {
                fatalError("project of the spriteObject is nil")
            }

            if !self.spriteObject.userData.removeUserVariable(identifiedBy: userVariable.name) {
                if !project.userData.removeUserVariable(identifiedBy: userVariable.name) {
                    fatalError("Could not remove the variable")
                }
            }

            project.saveToDisk(withNotification: false)
            self.reloadData()

            return true

        } else {

            return false

        }
    }

    func deleteList(userList: UserList) -> Bool {

        if !self.isListUsed(userList) {

            guard let project = self.spriteObject.scene.project else {
                fatalError("project of the spriteObject is nil")
            }

            if !self.spriteObject.userData.removeUserList(identifiedBy: userList.name) {
                if !project.userData.removeUserList(identifiedBy: userList.name) {
                    fatalError("Could not remove the list")
                }
            }

            project.saveToDisk(withNotification: false)
            self.reloadData()

            return true

        } else {

            return false

        }

    }

}
