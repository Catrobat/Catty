/**
 *  Copyright (C) 2010-2022 The Catrobat Team
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

@objc class CreateVariableOrListViewController: FormTableViewController {

    @objc init(spriteObject: SpriteObject, shouldCreateList: Bool = false, hideCreateList: Bool = false, addedCompletion: @escaping (String) -> Void) {
        self.spriteObject = spriteObject
        self.isCreateListHidden = hideCreateList
        self.addedCompletion = addedCompletion
        self.name = ""
        self.isList = shouldCreateList
        self.scope = .project

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private enum Scope {
        case project, object
    }

    @objc private let spriteObject: SpriteObject
    @objc private let isCreateListHidden: Bool
    @objc private let addedCompletion: (String) -> Void
    private var name: String
    private var isList: Bool
    private var scope: Scope

    private let variableTypeSection = 1
    private let variableSectionHeaders: [String?] = [
        kUIFEVariableName, kUIFEActionVar, nil
    ]
    private let listSectionHeaders: [String?] = [
        kUIFEListNameForm, kUIFEActionList, nil
    ]

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupFormItems()
        setupDefaultValues()
    }

    // MARK: - UI

    private func setupViews() {
        setupNavigationBar()
        setupTableView()
    }

    private func setupNavigationBar() {
        let cancelItem = UIBarButtonItem(title: kLocalizedCancel, style: .plain, target: self, action: #selector(cancelButtonTapped))
        let doneItem = UIBarButtonItem(title: kLocalizedDone, style: .plain, target: self, action: #selector(doneButtonTapped))

        self.navigationItem.title = isList ? kUIFENewList : kUIFENewVar
        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItem = cancelItem
        self.navigationItem.rightBarButtonItem = doneItem
    }

    private func setupTableView() {
        tableView.allowsMultipleSelection = true
    }

    // MARK: - TableView

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        switch indexPath.section {
        case variableTypeSection:
            if let selected = tableView.indexPathsForSelectedRows {
                for selectedIndexPath in selected where selectedIndexPath.section == indexPath.section {
                    tableView.deselectRow(at: selectedIndexPath, animated: false)
                }
            }
            return indexPath
        default:
            return nil
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section != variableTypeSection {
            super.tableView(tableView, didSelectRowAt: indexPath)
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        isList ? listSectionHeaders[section] : variableSectionHeaders[section]
    }

    // MARK: - Functions

    private func setupFormItems() {
        formItems = [
            [
                FormTextFieldItem(typeAction: { text in
                    self.name = text
                }, returnAction: {
                    self.view.endEditing(true)
                }, placeholder: kLocalizedName)
            ],
            [
                FormCheckItem(title: kUIFEActionVarPro, selectAction: {
                    self.scope = .project
                }),
                FormCheckItem(title: kUIFEActionVarObj, selectAction: {
                    self.scope = .object
                })
            ]
        ]

        if !isCreateListHidden {
            formItems.append([
                FormSwitchItem(title: kUIFECreateAsList, switchAction: { isOn in
                    self.isList = isOn
                    self.updateViews()
                })
            ])
        }
    }

    private func setupDefaultValues() {
        let indexPath = IndexPath(row: 0, section: variableTypeSection)
        self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
    }

    private func updateViews() {
        self.navigationItem.title = isList ? kUIFENewList : kUIFENewVar
        self.tableView.reloadData()
    }

    @objc private func cancelButtonTapped() {

        self.dismiss(animated: true)
    }

    @objc private func doneButtonTapped() {

        guard validateNameLength(), validateNameUniqueness() else {
            return
        }

        if isList {
            saveList()
        } else {
            saveVariable()
        }

        self.addedCompletion(self.name)
        self.dismiss(animated: true)
    }

    private func validateNameLength() -> Bool {
        let minCharacters = UInt(kMinNumOfVariableNameCharacters)
        let maxCharacters = UInt(kMaxNumOfVariableNameCharacters)
        var invalidNameMessage: String?

        if self.name.count < minCharacters {
            invalidNameMessage = Util.normalizedDescription(
                withFormat: kLocalizedNoOrTooShortInputDescription,
                formatParameter: minCharacters)
        } else if self.name.count > maxCharacters {
            invalidNameMessage = Util.normalizedDescription(
                withFormat: kLocalizedTooLongInputDescription,
                formatParameter: maxCharacters)
        } else {
            return true
        }

        AlertController(title: kLocalizedPocketCode, message: invalidNameMessage, style: .alert)
            .addDefaultAction(title: kLocalizedOK, handler: nil)
            .build().showWithController(self)

        return false
    }

    private func validateNameUniqueness() -> Bool {

        switch self.scope {
        case .project:
            if let project = self.spriteObject.scene.project {
                if UserDataContainer.allVariables(for: project).contains(where: { $0.name == self.name }) ||
                    UserDataContainer.allLists(for: project).contains(where: { $0.name == self.name }) {
                    showNameUniquenessAlert()
                    return false
                }
            }
        case .object:
            if UserDataContainer.objectAndProjectVariables(for: self.spriteObject).contains(where: { $0.name == self.name }) ||
                UserDataContainer.objectAndProjectLists(for: self.spriteObject).contains(where: { $0.name == self.name }) {
                showNameUniquenessAlert()
                return false
            }
        }

        return true
    }

    private func showNameUniquenessAlert() {
        AlertController(title: kLocalizedPocketCode, message: kUIFENewVarExists, style: .alert)
            .addDefaultAction(title: kLocalizedOK, handler: nil)
            .build().showWithController(self)
    }

    private func saveVariable() {
        let userVariable = UserVariable(name: self.name)
        userVariable.value = Int(0)

        switch self.scope {
        case .project:
            self.spriteObject.scene.project?.userData.add(userVariable)
        case .object:
            self.spriteObject.userData.add(userVariable)
        }

        self.spriteObject.scene.project?.saveToDisk(withNotification: false)
    }

    private func saveList() {
        let userList = UserList(name: self.name)

        switch self.scope {
        case .project:
            self.spriteObject.scene.project?.userData.add(userList)
        case .object:
            self.spriteObject.userData.add(userList)
        }

        self.spriteObject.scene.project?.saveToDisk(withNotification: false)
    }
}
