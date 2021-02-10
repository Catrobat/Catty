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

@objc enum FormulaEditorSectionType: Int {
    case none
    case functions
    case object
    case logic
    case sensors
    case data
}

@objc class FormulaEditorSectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private var placeHolderLabel = UILabel()
    private var addButton = UIBarButtonItem()
    @objc var formulaEditorVC: FormulaEditorViewController?
    @objc var formulaEditorSectionType: FormulaEditorSectionType = .none
    @objc var formulaManager: FormulaManager?
    @objc var spriteObject: SpriteObject?

    private var items = [FormulaEditorItem]()
    private var numberOfSections = 0
    private var numberOfRowsInSection = [Int]()
    private var titlesOfSections = [String]()

    var variableSourceProject = [UserVariable]()
    var variableSourceObject = [UserVariable]()
    var listSourceProject = [UserList]()
    var listSourceObject = [UserList]()
    var newVarIsForProject = false

    private struct VariableOrList {
        let name: String
        let isList: Bool
        let projectScope: Bool
    }

    private var allVariablesAndLists = [VariableOrList]()

    private var tableView = UITableView()

    override func viewDidLoad() {

        self.view.backgroundColor = .white

        self.addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addButtonTapped))
        self.addButton.tintColor = .light

        let tableViewTopConstraint = NSLayoutConstraint(item: self.tableView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0)
        let tableViewBottomConstraint = NSLayoutConstraint(item: self.tableView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0)
        let tableViewLeadingConstraint = NSLayoutConstraint(item: self.tableView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0)
        let tableViewTrailingConstraint = NSLayoutConstraint(item: self.tableView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.view.addSubview(self.tableView)
        self.view.addConstraints([tableViewTopConstraint, tableViewBottomConstraint, tableViewLeadingConstraint, tableViewTrailingConstraint])

        self.placeHolderLabel = UILabel(frame: CGRect(width: self.view.frame.width, height: 45))
        self.placeHolderLabel.text = kUIFEAddVariablesAndLists
        self.placeHolderLabel.textAlignment = .center
        self.placeHolderLabel.textColor = UIColor.medium
        self.placeHolderLabel.center = self.view.center
        self.placeHolderLabel.font = UIFont.systemFont(ofSize: 25)
        self.view.addSubview(self.placeHolderLabel)

    }

    override func viewWillAppear(_ animated: Bool) {
        self.reloadData()
    }

    func reloadData() {
        self.numberOfSections = 0
        self.numberOfRowsInSection.removeAll()
        self.titlesOfSections.removeAll()
        self.placeHolderLabel.isHidden = true
        self.navigationItem.rightBarButtonItem = nil

        switch formulaEditorSectionType {
        case .functions:
            self.initFunctionItems()

        case .object:
            self.initObjectItems()

        case .logic:
            self.initLogicItems()

        case .sensors:
            self.initSensorItems()

        case .data:
            self.initDataItems()
            self.navigationItem.rightBarButtonItem = self.addButton

        case .none:
            self.presentUnexpectedErrorAlert()
        }

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

    func numberOfSections(in tableView: UITableView) -> Int {
        self.numberOfSections
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        titlesOfSections[section]
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.numberOfRowsInSection[section]
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableViewCell = UITableViewCell()

        if self.formulaEditorSectionType == .data {
            tableViewCell.textLabel?.text = self.allVariablesAndLists[getTableViewRowIndex(indexPath: indexPath)].name
        } else {
            tableViewCell.textLabel?.text = items[getTableViewRowIndex(indexPath: indexPath)].title
        }

        return tableViewCell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if formulaEditorSectionType == .data {
            let selectedData = self.allVariablesAndLists[getTableViewRowIndex(indexPath: indexPath)]

            let buttonType: Int32 = selectedData.isList ? 11 : 0
            let variableName = tableView.cellForRow(at: indexPath)?.textLabel?.text
            self.formulaEditorVC?.internFormula.handleKeyInput(withName: variableName, buttonType: buttonType)
            self.formulaEditorVC?.handleInput()
        } else {
            self.formulaEditorVC?.formulaEditorItemSelected(item: self.items[getTableViewRowIndex(indexPath: indexPath)])
        }

        self.navigationController?.popViewController(animated: true)
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        if formulaEditorSectionType == .data {
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

        return nil
    }

    private func getTableViewRowIndex(indexPath: IndexPath) -> Int {
        var previousRows = 0

        for n in 1..<indexPath.section + 1 {
            previousRows += self.numberOfRowsInSection[n - 1]
        }

        return previousRows + indexPath.row
    }

    private func initFunctionItems() {
        self.items.removeAll()

        if let object = spriteObject, let manager = formulaManager {
            self.items = manager.formulaEditorItemsForMathSection(spriteObject: object)
        }

        self.numberOfRowsInSection = self.groupSubsectionWiseAndGetSize(items.first?.sections.first?.subsection() as? FunctionSubsection, items: &items)
        self.numberOfSections = numberOfRowsInSection.count
        self.titlesOfSections = [FunctionSubsection.maths.title, FunctionSubsection.texts.title, FunctionSubsection.lists.title]
    }

    private func initLogicItems() {
        self.items.removeAll()

        if let object = spriteObject, let manager = formulaManager {
            self.items = manager.formulaEditorItemsForLogicSection(spriteObject: object)
        }

        self.numberOfRowsInSection = self.groupSubsectionWiseAndGetSize(items.first?.sections.first?.subsection() as? LogicSubsection, items: &items)
        self.numberOfSections = numberOfRowsInSection.count
        self.titlesOfSections = [LogicSubsection.logical.title, LogicSubsection.comparison.title]

    }

    private func initObjectItems() {
        self.items.removeAll()

        if let object = spriteObject, let manager = formulaManager {
            self.items = manager.formulaEditorItemsForObjectSection(spriteObject: object)
        }

        self.numberOfRowsInSection = self.groupSubsectionWiseAndGetSize(items.first?.sections.first?.subsection() as? ObjectSubsection, items: &items)
        self.numberOfSections = numberOfRowsInSection.count
        self.titlesOfSections = [ObjectSubsection.general.title, ObjectSubsection.motion.title]

    }

    private func initSensorItems() {
        self.items.removeAll()

        if let object = spriteObject, let manager = formulaManager {
            self.items = manager.formulaEditorItemsForDeviceSection(spriteObject: object)
        }

        self.numberOfRowsInSection = self.groupSubsectionWiseAndGetSize(items.first?.sections.first?.subsection() as? SensorSubsection, items: &items)
        self.numberOfSections = numberOfRowsInSection.count
        self.titlesOfSections = [SensorSubsection.device.title,
                                 SensorSubsection.touch.title,
                                 SensorSubsection.visual.title,
                                 SensorSubsection.dateAndTime.title,
                                 SensorSubsection.arduino.title,
                                 SensorSubsection.phiro.title]
    }

    private func groupSubsectionWiseAndGetSize<SubsectionType: FormulaEditorSubsection & Hashable & CaseIterable>(_ subsectionType: SubsectionType?, items: inout [FormulaEditorItem]) -> [Int] {

        guard let _ = subsectionType else {
            return [Int]()
        }

        var sizes = [Int]()
        let dict = Dictionary(grouping: items, by: { $0.sections[0].subsection() as! SubsectionType })
        items.removeAll()

        for subsection in SubsectionType.allCases {
            if let groupedItems = dict[subsection] {
                items.append(contentsOf: groupedItems)
                sizes.append(groupedItems.count)
            }
        }

        return sizes
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

        guard let object = self.spriteObject else {
            self.presentUnexpectedErrorAlert()
            return
        }

        guard let project = object.scene.project else {
            self.presentUnexpectedErrorAlert()
            return
        }

        self.variableSourceProject = project.userData.variables()
        self.listSourceProject = project.userData.lists()
        self.variableSourceObject = UserDataContainer.objectVariables(for: object)
        self.listSourceObject = UserDataContainer.objectLists(for: object)

    }

    private func presentUnexpectedErrorAlert() {
        let alert = UIAlertController(title: "Some unexpected error occured", message: nil, preferredStyle: .alert)
        let closeAction = UIAlertAction(title: kLocalizedClose, style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(closeAction)
        self.present(alert, animated: true, completion: nil)
    }

}
