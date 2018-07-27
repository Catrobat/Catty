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

class RecentProgramsStoreViewController: UIViewController, SelectedFeaturedProgramsDataSource {
    
    
    @IBOutlet weak var RecentProgramsTableView: UITableView!
    @IBOutlet weak var RecentProgramsSegmentedControl: UISegmentedControl!
    
    func selectedCell(dataSource: FeaturedProgramsStoreTableDataSource, didSelectCellWith cell: FeaturedProgramsCell) {
        //
    }
 
    // MARK: - Properties

    private var dataSource: RecentProgramStoreDataSource

    var loadingView: LoadingView?
    var shouldHideLoadingView = false
    var programForSegue: StoreProgram?
    var catrobatProject: StoreProgram?

    // MARK: - Initializers
    
    required init?(coder aDecoder: NSCoder) {
        self.dataSource = RecentProgramStoreDataSource.dataSource()
        super.init(coder: aDecoder)
    }

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        //setupTableView()
        shouldHideLoadingView = false
        dataSource.delegate = self as? SelectedRecentProgramsDataSource
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //fetchData()
    }
}
