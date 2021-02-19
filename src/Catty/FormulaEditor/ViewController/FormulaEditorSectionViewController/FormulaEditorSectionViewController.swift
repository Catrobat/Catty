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
}

@objc class FormulaEditorSectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @objc var formulaEditorSectionType: FormulaEditorSectionType = .none
    @objc var formulaManager: FormulaManager
    @objc var spriteObject: SpriteObject
    @objc var formulaEditorVC: FormulaEditorViewController

    private var items = [FormulaEditorItem]()
    var numberOfSections = 0
    var numberOfRowsInSection = [Int]()
    var titlesOfSections = [String]()

    var tableView = UITableView()

    @objc init(formulaManager: FormulaManager, spriteObject: SpriteObject, formulaEditorViewController: FormulaEditorViewController) {
        self.formulaManager = formulaManager
        self.spriteObject = spriteObject
        self.formulaEditorVC = formulaEditorViewController
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = UIView()
        self.view.backgroundColor = UIColor.white
    }

    override func viewDidLoad() {

        let tableViewTopConstraint = NSLayoutConstraint(item: self.tableView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0)
        let tableViewBottomConstraint = NSLayoutConstraint(item: self.tableView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0)
        let tableViewLeadingConstraint = NSLayoutConstraint(item: self.tableView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0)
        let tableViewTrailingConstraint = NSLayoutConstraint(item: self.tableView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.view.addSubview(self.tableView)
        self.view.addConstraints([tableViewTopConstraint, tableViewBottomConstraint, tableViewLeadingConstraint, tableViewTrailingConstraint])

    }

    override func viewWillAppear(_ animated: Bool) {
        self.reloadData()
    }

    func reloadData() {
        self.numberOfSections = 0
        self.numberOfRowsInSection.removeAll()
        self.titlesOfSections.removeAll()
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

        case .none:
            self.presentUnexpectedErrorAlert()
        }

        self.tableView.reloadData()
        self.tableView.tableFooterView = UIView()
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
        tableViewCell.textLabel?.text = items[getTableViewRowIndex(indexPath: indexPath)].title
        return tableViewCell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.formulaEditorVC.formulaEditorItemSelected(item: self.items[getTableViewRowIndex(indexPath: indexPath)])
        self.navigationController?.popViewController(animated: true)
    }

    func getTableViewRowIndex(indexPath: IndexPath) -> Int {
        var previousRows = 0

        for n in 1..<indexPath.section + 1 {
            previousRows += self.numberOfRowsInSection[n - 1]
        }

        return previousRows + indexPath.row
    }

    private func initFunctionItems() {
        self.items.removeAll()

        self.items = formulaManager.formulaEditorItemsForMathSection(spriteObject: spriteObject)

        self.numberOfRowsInSection = self.groupSubsectionWiseAndGetSize(items.first?.sections.first?.subsection() as? FunctionSubsection, items: &items)
        self.numberOfSections = numberOfRowsInSection.count
        self.titlesOfSections = [FunctionSubsection.maths.title, FunctionSubsection.texts.title, FunctionSubsection.lists.title]
    }

    private func initLogicItems() {
        self.items.removeAll()

        self.items = formulaManager.formulaEditorItemsForLogicSection(spriteObject: spriteObject)
        self.numberOfRowsInSection = self.groupSubsectionWiseAndGetSize(items.first?.sections.first?.subsection() as? LogicSubsection, items: &items)
        self.numberOfSections = numberOfRowsInSection.count
        self.titlesOfSections = [LogicSubsection.logical.title, LogicSubsection.comparison.title]

    }

    private func initObjectItems() {
        self.items.removeAll()

        self.items = formulaManager.formulaEditorItemsForObjectSection(spriteObject: spriteObject)

        self.numberOfRowsInSection = self.groupSubsectionWiseAndGetSize(items.first?.sections.first?.subsection() as? ObjectSubsection, items: &items)
        self.numberOfSections = numberOfRowsInSection.count
        self.titlesOfSections = [ObjectSubsection.general.title, ObjectSubsection.motion.title]

    }

    private func initSensorItems() {
        self.items.removeAll()

        self.items = formulaManager.formulaEditorItemsForDeviceSection(spriteObject: spriteObject)

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

    func presentUnexpectedErrorAlert() {
        let alert = UIAlertController(title: "Some unexpected error occured", message: nil, preferredStyle: .alert)
        let closeAction = UIAlertAction(title: kLocalizedClose, style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(closeAction)
        self.present(alert, animated: true, completion: nil)
    }

}
