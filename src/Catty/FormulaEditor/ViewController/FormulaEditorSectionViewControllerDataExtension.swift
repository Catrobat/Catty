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

extension FormulaEditorSectionViewController {

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
            if let project = self.spriteObject?.scene.project {
                for variable in UserDataContainer.allVariables(for: project) where variable.name == name {
                    self.askForNewVariableName()
                    return
                }
            }
        } else {
            if let object = self.spriteObject {
                for variable in UserDataContainer.objectAndProjectVariables(for: object) where variable.name == name {
                    self.askForNewVariableName()
                    return
                }
            }
        }

        let userVariable = UserVariable(name: name)
        userVariable.value = Int(0)

        if self.newVarIsForProject {
            self.spriteObject?.scene.project?.userData.add(userVariable)
        } else {
            self.spriteObject?.userData.add(userVariable)
        }

        self.spriteObject?.scene.project?.saveToDisk(withNotification: false)
        self.reloadData()
    }

    @objc func saveList(name: String) {
        if self.newVarIsForProject {
            if let project = self.spriteObject?.scene.project {
                for variable in UserDataContainer.allLists(for: project) where variable.name == name {
                    self.askForNewVariableName()
                    return
                }
            }
        } else {
            if let object = self.spriteObject {
                for variable in UserDataContainer.objectAndProjectLists(for: object) where variable.name == name {
                    self.askForNewVariableName()
                    return
                }
            }
        }

        let userList = UserList(name: name)

        if self.newVarIsForProject {
            self.spriteObject?.scene.project?.userData.add(userList)
        } else {
            self.spriteObject?.userData.add(userList)
        }

        self.spriteObject?.scene.project?.saveToDisk(withNotification: false)
        self.reloadData()
    }

    func isVariableUsed(_ userVariable: UserVariable) -> Bool {

        guard let project = self.spriteObject?.scene.project else {
            fatalError("project of the spriteObject is nil")
        }

        if project.userData.contains(userVariable) {

            if let objects = self.spriteObject?.scene.objects() {

                for object in objects {

                    for scriptElement in object.scriptList {
                        if let script = scriptElement as? Script {

                            for brickElement in script.brickList where brickElement is Brick {
                                if let brick = brickElement as? Brick {
                                    if brick.isVariableUsed(variable: userVariable) {
                                        return true
                                    }
                                }
                            }

                        }
                    }

                }
            }
        } else {
            if let object = spriteObject {
                for scriptElement in object.scriptList {
                    if let script = scriptElement as? Script {

                        for brickElement in script.brickList where brickElement is Brick {
                            if let brick = brickElement as? Brick {
                                if brick.isVariableUsed(variable: userVariable) {
                                    return true
                                }
                            }
                        }

                    }
                }
            }
        }

        return false
    }

    func isListUsed(_ userList: UserList) -> Bool {

        guard let project = self.spriteObject?.scene.project else {
            fatalError("project of the spriteObject is nil")
        }

        if project.userData.contains(userList) {

            if let objects = self.spriteObject?.scene.objects() {

                for object in objects {

                    for scriptElement in object.scriptList {
                        if let script = scriptElement as? Script {

                            for brickElement in script.brickList where brickElement is Brick {
                                if let brick = brickElement as? Brick {
                                    if brick.isListUsed(list: userList) {
                                        return true
                                    }
                                }
                            }

                        }
                    }

                }
            }
        } else {
            if let object = spriteObject {
                for scriptElement in object.scriptList {
                    if let script = scriptElement as? Script {

                        for brickElement in script.brickList where brickElement is Brick {
                            if let brick = brickElement as? Brick {
                                if brick.isListUsed(list: userList) {
                                    return true
                                }
                            }
                        }

                    }
                }
            }
        }

        return false
    }

    func deleteVariable(userVariable: UserVariable) -> Bool {

        if !self.isVariableUsed(userVariable) {

            guard let object = self.spriteObject else {
                fatalError("spriteObject is nil")
            }

            guard let project = object.scene.project else {
                fatalError("project of the spriteObject is nil")
            }

            if !object.userData.removeUserVariable(identifiedBy: userVariable.name) {
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

            guard let object = self.spriteObject else {
                fatalError("spriteObject is nil")
            }

            guard let project = object.scene.project else {
                fatalError("project of the spriteObject is nil")
            }

            if !object.userData.removeUserList(identifiedBy: userList.name) {
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
