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

class RecentProgramsStoreViewController: UIViewController, SelectedRecentProgramsDataSource {
    
    @IBOutlet weak var RecentProgramsTableView: UITableView!
    @IBOutlet weak var RecentProgramsSegmentedControl: UISegmentedControl!
    
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
        initSegmentedControl()
        shouldHideLoadingView = false
        dataSource.delegate = self
    }
    
    func initSegmentedControl() {
        RecentProgramsSegmentedControl?.setTitle(kLocalizedMostDownloaded, forSegmentAt: 0)
        RecentProgramsSegmentedControl?.setTitle(kLocalizedMostViewed, forSegmentAt: 1)
        RecentProgramsSegmentedControl?.setTitle(kLocalizedNewest, forSegmentAt: 2)
        fetchData(type: .mostDownloaded)
        
//        if(IS_IPHONE4||IS_IPHONE5) {
//            let font = UIFont.systemFont(ofSize: 10)
//            RecentProgramsSegmentedControl.setTitleTextAttributes([NSAttributedStringKey.font: font], for: .normal)
//        }
    }
    
    @IBAction func segmentTapped(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            print("first")
            fetchData(type: .mostDownloaded)
        case 1:
            print("second")
            fetchData(type: .mostViewed)
        case 2:
            print("third")
            fetchData(type: .mostRecent)
        default:
            break
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
    
    private func fetchData(type: ProgramType) {
        if RecentProgramsTableView.visibleCells.isEmpty {
            self.showLoadingView()
            self.dataSource.fetchItems(type: type) { error in
                if error != nil {
                    self.shouldHideLoadingView = true
                    self.hideLoadingView()
                    return
                }
                self.RecentProgramsTableView.reloadData()
                self.shouldHideLoadingView = true
                self.hideLoadingView()
            }
        }
        else {
            self.shouldHideLoadingView = true
            self.hideLoadingView()
        }
    }
}

extension RecentProgramsStoreViewController: RecentProgramCellProtocol{
    func selectedCell(dataSource datasource: RecentProgramStoreDataSource, didSelectCellWith cell: RecentProgramCell) {
        // segue
    }
}
