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
    
    // MARK: - Properties
    
    private let dataSource: FeaturedProgramsStoreTableDataSource
    
    weak var importDelegate: FeaturedProgramsStoreTableDataSourceDelegete?
    
    //MARK: - Initializers
    
    required init?(coder aDecoder: NSCoder) {
        self.dataSource = FeaturedProgramsStoreTableDataSource.dataSource()
        super.init(style: UITableViewStyle.plain)
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
    
    private func setupTableView() {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        self.tableView.register(FeaturedProgramsCell.self, forCellReuseIdentifier: kFeaturedCell)
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

