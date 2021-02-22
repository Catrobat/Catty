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

@objc class FormulaEditorDataSectionViewController: FormulaEditorSectionViewController {

    private var addButton = UIBarButtonItem()
    private var placeHolderLabel = UILabel()

    private var variableSourceProject = [UserVariable]()
    private var variableSourceObject = [UserVariable]()
    private var listSourceProject = [UserList]()
    private var listSourceObject = [UserList]()
    private var newVarIsForProject = false

    private struct VariableOrList {
        let name: String
        let isList: Bool
        let projectScope: Bool
    }

    @objc init(formulaManager: FormulaManager, spriteObject: SpriteObject, formulaEditorViewController: FormulaEditorViewController) {
        super.init(type: .data, formulaManager: formulaManager, spriteObject: spriteObject, formulaEditorViewController: formulaEditorViewController)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var allVariablesAndLists = [VariableOrList]()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addButtonTapped))
        self.addButton.tintColor = .light
        self.navigationItem.rightBarButtonItem = self.addButton

        self.placeHolderLabel = UILabel(frame: CGRect.zero)
        self.placeHolderLabel.translatesAutoresizingMaskIntoConstraints = false
        self.placeHolderLabel.numberOfLines = 2
        self.placeHolderLabel.text = kUIFEAddVariablesAndLists
        self.placeHolderLabel.textAlignment = .center
        self.placeHolderLabel.textColor = UIColor.medium
        self.placeHolderLabel.font = UIFont.systemFont(ofSize: 25)
        self.view.addSubview(self.placeHolderLabel)
        self.placeHolderLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10).isActive = true
        self.placeHolderLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10).isActive = true
        self.placeHolderLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true

        self.reloadData()
    }

    override func reloadData() {
        self.numberOfSections = 0
        self.placeHolderLabel.isHidden = true
        self.numberOfRowsInSection.removeAll()
        self.titlesOfSections.removeAll()

        self.initDataItems()
        self.tableView.reloadData()
        self.tableView.tableFooterView = UIView()
    }

    @objc func addButtonTapped() {
        AlertController(title: kUIFEVarOrList, message: nil, style: .actionSheet)
        .addCancelAction(title: kLocalizedCancel, handler: nil)
        .addDefaultAction(title: kUIFENewVar) {
            self.askProjectOrObject(isList: false)
        }
        .addDefaultAction(title: kUIFENewList) {
        self.askProjectOrObject(isList: true)
        }.build().showWithController(self)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableViewCell = UITableViewCell()
        tableViewCell.textLabel?.text = self.allVariablesAndLists[getTableViewRowIndex(indexPath: indexPath)].name
        return tableViewCell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedData = self.allVariablesAndLists[getTableViewRowIndex(indexPath: indexPath)]
        let buttonType: Int32 = selectedData.isList ? 11 : 0
        let variableName = tableView.cellForRow(at: indexPath)?.textLabel?.text
        self.formulaEditorVC.internFormula.handleKeyInput(withName: variableName, buttonType: buttonType)
        self.formulaEditorVC.handleInput()
        self.navigationController?.popViewController(animated: true)
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let tableViewRowAction = UITableViewRowAction(style: .destructive,
                                                      title: "Delete") { _, indexPath in

                                                        let selectedVariable = self.allVariablesAndLists[self.getTableViewRowIndex(indexPath: indexPath)]

                                                        if selectedVariable.isList {

                                                            var list: UserList?
                                                            for projectList in self.listSourceProject where projectList.name == selectedVariable.name {
                                                                list = projectList
                                                            }

                                                            if list == nil {
                                                                for objectList in self.listSourceObject where objectList.name == selectedVariable.name {
                                                                    list = objectList
                                                                }
                                                            }

                                                            guard let userList = list else {
                                                                fatalError("Could not find the list from the project or this object's scope")
                                                            }

                                                            if !self.deleteList(userList: userList) {
                                                                Util.showNotification(withMessage: kUIFEDeleteVarBeingUsed)
                                                            }

                                                        } else {

                                                            var variable: UserVariable?
                                                            for projectVariable in self.variableSourceProject where projectVariable.name == selectedVariable.name {
                                                                variable = projectVariable
                                                            }

                                                            if variable == nil {
                                                                for objectVariable in self.variableSourceObject where objectVariable.name == selectedVariable.name {
                                                                    variable = objectVariable
                                                                }
                                                            }

                                                            guard let userVariable = variable else {
                                                                fatalError("Could not find the variable from the project or this object's scope")
                                                            }

                                                            if !self.deleteVariable(userVariable: userVariable) {
                                                                Util.showNotification(withMessage: kUIFEDeleteVarBeingUsed)
                                                            }

                                                        }

        }

        return [tableViewRowAction]
    }

    private func initDataItems() {
        self.allVariablesAndLists.removeAll()

        self.variableSourceProject.removeAll()
        self.variableSourceObject.removeAll()
        self.listSourceProject.removeAll()
        self.listSourceObject.removeAll()

        self.updateUserVariablesAndLists()

        if !self.variableSourceProject.isEmpty {
            self.numberOfSections += 1
            self.numberOfRowsInSection.append(self.variableSourceProject.count)
            self.titlesOfSections.append(kUIFEProjectVariables)

            for variable in self.variableSourceProject {
                self.allVariablesAndLists.append(VariableOrList(name: variable.name, isList: false, projectScope: true))
            }
        }

        if !self.variableSourceObject.isEmpty {
            self.numberOfSections += 1
            self.numberOfRowsInSection.append(self.variableSourceObject.count)
            self.titlesOfSections.append(kUIFEObjectVariables)

            for variable in self.variableSourceObject {
                self.allVariablesAndLists.append(VariableOrList(name: variable.name, isList: false, projectScope: false))
            }
        }

        if !self.listSourceProject.isEmpty {
            self.numberOfSections += 1
            self.numberOfRowsInSection.append(self.listSourceProject.count)
            self.titlesOfSections.append(kUIFEProjectLists)

            for variable in self.listSourceProject {
                self.allVariablesAndLists.append(VariableOrList(name: variable.name, isList: true, projectScope: true))
            }
        }

        if !self.listSourceObject.isEmpty {
            self.numberOfSections += 1
            self.numberOfRowsInSection.append(self.listSourceObject.count)
            self.titlesOfSections.append(kUIFEObjectLists)

            for variable in self.listSourceObject {
                self.allVariablesAndLists.append(VariableOrList(name: variable.name, isList: true, projectScope: false))
            }
        }

        if self.allVariablesAndLists.isEmpty {
            self.placeHolderLabel.isHidden = false
        }

    }

    private func updateUserVariablesAndLists() {

        guard let project = self.spriteObject.scene.project else {
            self.presentUnexpectedErrorAlert()
            return
        }

        self.variableSourceProject = project.userData.variables()
        self.listSourceProject = project.userData.lists()
        self.variableSourceObject = UserDataContainer.objectVariables(for: self.spriteObject)
        self.listSourceObject = UserDataContainer.objectLists(for: self.spriteObject)

    }

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

    private func askForNewVariableName() {
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

    @objc private func saveVariable(name: String) {
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

    @objc private func saveList(name: String) {
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

    private func deleteVariable(userVariable: UserVariable) -> Bool {

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

    private func deleteList(userList: UserList) -> Bool {

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
