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

class FeaturedProgramsStoreTableViewController: UITableViewController, SelectedFeaturedProgramsDataSource {

    private var dataSource: FeaturedProgramsStoreTableDataSource

    var loadingView: LoadingView?
    var shouldHideLoadingView = false

    required init?(coder aDecoder: NSCoder) {
        self.dataSource = FeaturedProgramsStoreTableDataSource.dataSource()
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        shouldHideLoadingView = false
        dataSource.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
    }

    private func setupTableView() {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        self.tableView.dataSource = self.dataSource
        self.tableView.delegate = self.dataSource
    }
    
    private func fetchData() {
        self.showLoadingView()
        self.dataSource.fetchItems() { error in
            if error != nil {
                self.shouldHideLoadingView = true
                self.hideLoadingView()
                return
            }
            self.tableView.reloadData()
            self.shouldHideLoadingView = true
            self.hideLoadingView()
        }
    }
    
    func showLoadingView() {
        if loadingView == nil {
            loadingView = LoadingView()
            view.addSubview(loadingView!)
        }
        loadingView!.show()
        loadingIndicator(true)
    }
    
    func hideLoadingView() {
        if shouldHideLoadingView {
            loadingView!.hide()
            loadingIndicator(false)
            self.shouldHideLoadingView = false
        }
    }
    
    func loadingIndicator(_ value: Bool) {
        let app = UIApplication.shared
        app.isNetworkActivityIndicatorVisible = value
    }
}

extension FeaturedProgramsStoreTableViewController: FeaturedProgramsCellProtocol {    
    func selectedCell(dataSource datasource: FeaturedProgramsStoreTableDataSource, didSelectCellWith cell: FeaturedProgramsCell) {
        print(cell.program?.projectName)
        performSegue(withIdentifier: kSegueToProgramDetail, sender: self)
    }
}
