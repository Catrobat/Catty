/**
 *  Copyright (C) 2010-2018 The Catrobat Team
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

protocol FeaturedProgramsStoreViewControllerImportDelegate: class {
    func featuredProgramStoreViewController(_ featuredProgramStoreViewController: FeaturedProgramsStoreTableViewController, didPickItemsForImport items: [CBProgram])
}

final class FeaturedProgramsStoreTableViewController: UITableViewController {
    
    // MARK: - Constants
    
    private let dataSource: FeaturedProgramsStoreTableDataSource
    
    // MARK: - Properties
    
    
    var programForSegue: CBProgram?
    weak var importDelegate: FeaturedProgramsStoreTableDataSourceDelegete?
    
    //MARK: - Initializers
    
    required init?(coder aDecoder: NSCoder) {
        self.dataSource = FeaturedProgramsStoreTableDataSource.dataSource()
        super.init(coder: aDecoder)
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == kSegueToProgramDetail {
            if let programDetailStoreViewController = segue.destination as?
                ProgramDetailStoreViewController, let program = programForSegue {
                /// only a example!!!
                programDetailStoreViewController.project.projectID = String(program.projectId)
            }
        }
    }
    
    private func setupTableView() {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
//        self.tableView.register(FeaturedProgramsCell.self, forCellReuseIdentifier: kFeaturedCell)
        self.tableView.dataSource = self.dataSource
        self.tableView.delegate = self.dataSource
    }
    
    private func fetchData() {
        self.dataSource.fetchItems() { error in
            if error != nil {
                return
            }
            self.tableView.reloadData()
        }
    }
}

extension FeaturedProgramsStoreTableViewController: FeaturedProgramsCellProtocol {
    
    func imageTapped(sender: FeaturedProgramsCell) {
        if let program = sender.program {
            programForSegue = program
            performSegue(withIdentifier: kSegueToProgramDetail, sender: nil)
        }
    }
}
