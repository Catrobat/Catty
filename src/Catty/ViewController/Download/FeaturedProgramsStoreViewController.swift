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

import Foundation
let FeaturedProgramsMaxResults = 10

class FeaturedProgramsStoreViewController : BaseTableViewController, NSURLConnectionDataDelegate {
    private var dataTask: URLSessionDataTask?
    private var projects: [AnyHashable] = []
    private var featuredSize: NSArray = []
    private var loadingView: LoadingView?
    private var shouldShowAlert = false
    private var shouldHideLoadingView = false
    
    override convenience init(style: UITableViewStyle) {
    self.init(style: style)
  }

    lazy var session: URLSession = {
        // Initialize Session Configuration
        let sessionConfiguration = URLSessionConfiguration.default
        // Configure Session Configuration
        sessionConfiguration.httpAdditionalHeaders = ["Accept": "application/json"]
        // Initialize Session
        return URLSession(configuration: sessionConfiguration)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadFeaturedProjects()
        navigationItem.title = kLocalizedFeaturedPrograms
        //  CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
        //  self.tableView.contentInset = UIEdgeInsetsMake(navigationBarHeight, 0, 0, 0);
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        shouldShowAlert = true
        shouldHideLoadingView = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isTranslucent = true
        navigationController?.navigationBar.isTranslucent = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    deinit {
        loadingView?.removeFromSuperview()
        loadingView = nil

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = nil
        cell = self.cell(forProjectsTableView: tableView, at: indexPath)
        if let aCell = cell {
            return aCell
        }
        return UITableViewCell()
    }

    func cell(forProjectsTableView tableView: UITableView?, at indexPath: IndexPath?) -> UITableViewCell? {
        let CellIdentifier = kFeaturedCell
        var cell: UITableViewCell? = nil
        if let aPath = indexPath {
            cell = tableView?.dequeueReusableCell(withIdentifier: CellIdentifier, for: aPath)
        }
        if cell == nil {
            print("Should Never happen - since iOS5 Storyboard *always* instantiates our cell!")
            abort()
        }
        if (cell is DarkBlueGradientFeaturedCell) {
            let project = projects[indexPath?.row ?? 0] as? CatrobatProgram
            let imageCell = cell as? DarkBlueGradientFeaturedCell
            loadImage(project?.featuredImage, for: imageCell, at: indexPath)
            if !(imageCell?.featuredImage.image == UIImage(named: "programs")) {
                imageCell?.featuredImage.frame = (cell?.frame)!
                imageCell?.featuredImage.frame = CGRect(x: 0, y: 0, width: imageCell?.featuredImage.frame.size.width ?? 0.0, height: imageCell?.featuredImage.frame.size.height ?? 0.0)
                loadingIndicator(false)
            }
        }
        return cell
    }
    
    func loadImage(_ imageURLString: String?, for imageCell: DarkBlueGradientFeaturedCell?, at indexPath: IndexPath?) {
        loadingIndicator(true)
        let image = UIImage(contentsOf: URL(string: imageURLString ?? ""), placeholderImage: UIImage(named: "programs"), onCompletion: { img in
                DispatchQueue.main.async(execute: {
                    self.tableView.beginUpdates()
                    let cell = self.tableView.cellForRow(at: indexPath!) as? DarkBlueGradientFeaturedCell
                    if cell != nil {
                        cell?.featuredImage.image = img
                        cell?.featuredImage.frame = (cell?.frame)!
                        cell?.featuredImage.frame = CGRect(x: 30, y: 0, width: self.view.frame.size.width, height: cell?.featuredImage.frame.size.height ?? 0.0)
                        self.featuredSize = [Float(img?.size.width ?? 0.0), Float(img?.size.height ?? 0.0)]
                        NSLog("%f", (img?.size.height ?? 0.0) / ((img?.size.width ?? 0.0) / Util.screenWidth()))
                        //                                                    CGFloat factor = img.size.width / [Util screenWidth];
                        //                                                    NSDebug(@"%f",img.size.height/factor);
                        self.loadingIndicator(false)
                        cell?.frame = CGRect(x: cell?.frame.origin.x ?? 0.0, y: cell?.frame.origin.y ?? 0.0, width: cell?.frame.size.width ?? 0.0, height: cell?.featuredImage.frame.size.height ?? 0.0)
                    }
                    self.tableView.endUpdates()
                    self.tableView.reloadData()
                })
            })
        imageCell?.featuredImage.image = image
        featuredSize = [Float((image?.size.width)!), Float((image?.size.height)!)] //FIXME
        imageCell?.featuredImage.contentMode = .scaleAspectFit
    }

    func loadFeaturedProjects() {
            //self.data = [[NSMutableData alloc] init];
        let url = URL(string: "\(kConnectionHost)/\(kConnectionFeatured)?\(kProgramsLimit)%i")
        var request: URLRequest? = nil
        if let parsedUrl = url {
            request = URLRequest(url: parsedUrl, cachePolicy: .useProtocolCachePolicy, timeoutInterval: TimeInterval(kConnectionTimeout))
        }
        if let aRequest = request {
            dataTask = session.dataTask(with: aRequest, completionHandler: { data, response, error in
                if error != nil {
                    if try! Util.isNetworkError(error) {
                        Util.defaultAlertForNetworkError()
                        self.shouldHideLoadingView = true
                        self.hideLoadingView()
                    }
                } else {
                    DispatchQueue.main.async(execute: {
                        //self.loadIDs(with: data, andResponse: response)
                    })
                }
            })
        }
        if dataTask != nil {
            dataTask?.resume()
            showLoadingView()
        }
    }

//    func loadIDs(with data: Data?, andResponse response: URLResponse?) {
//        if data == nil {
//            if shouldShowAlert {
//                shouldShowAlert = false
//                Util.defaultAlertForNetworkError()
//            }
//            return
//        }
//        var error: Error? = nil
//        var jsonObject: Any? = nil
//        if let aData = data {
//            jsonObject = try? JSONSerialization.jsonObject(with: aData, options: .mutableContainers)
//        }
//        //NSLog("array: %@", jsonObject)
//
//        if (jsonObject is [AnyHashable : Any]) {
//            let catrobatInformation = jsonObject?["CatrobatInformation"] as? [AnyHashable : Any]
//            let information = CatrobatInformation(dict: catrobatInformation)
//            let catrobatProjects = jsonObject?["CatrobatProjects"] as? [Any]
//            if catrobatProjects != nil {
//                projects = [AnyHashable](repeating: 0, count: catrobatProjects?.count ?? 0)
//                for projectDict: [AnyHashable : Any]? in catrobatProjects as? [[AnyHashable : Any]?] ?? [[AnyHashable : Any]?]() {
//                    let project = CatrobatProgram(dict: projectDict, andBaseUrl: information.baseURL)
//                    projects.append(project)
//                }
//            } else {
//                Util.defaultAlertForUnknownError()
//                shouldHideLoadingView = true
//                hideLoadingView()
//                return
//            }
//        }
//        update()
//        for project: CatrobatProgram? in projects {
//            var url: URL? = nil
//            if let anID = project?.projectID {
//                url = URL(string: "\(kConnectionHost)/\(kConnectionIDQuery)?id=\(anID)")
//            }
//            var request: URLRequest? = nil
//            if let anUrl = url {
//                request = URLRequest(url: anUrl, cachePolicy: .useProtocolCachePolicy, timeoutInterval: kConnectionTimeout)
//            }
//            var task: URLSessionDataTask? = nil
//            if let anError = error, let aRequest = request {
//                task = session.dataTask(with: aRequest, completionHandler: { data, response, error in
//                                if error != nil {
//                                    if (error as NSError?)?.code != CFNetworkErrors.cfurlErrorCancelled.rawValue {
//                                        print("\(anError)")
//                                    }
//                                } else {
//                                    DispatchQueue.main.async(execute: {
//                                        self.loadInfos(with: data, andResponse: response)
//                                    })
//                                }
//                            })
//            }
//            if task != nil {
//                task?.resume()
//                showLoadingView()
//            }
//        }
//        showLoadingView()
//    }
//
//    func loadInfos(with data: Data?, andResponse response: URLResponse?) {
//        if data == nil {
//            if shouldShowAlert {
//                shouldShowAlert = false
//                Util.defaultAlertForNetworkError()
//            }
//            return
//        }
//        var jsonObject = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
//
//
//
//        //NSLog("array: %@", jsonObject)
//        if (jsonObject is [AnyHashable : Any]) {
//            let catrobatInformation = jsonObject?["CatrobatInformation"] as? [AnyHashable : Any]
//            let information = CatrobatInformation(dict: catrobatInformation)
//            let catrobatProjects = jsonObject?["CatrobatProjects"] as? [Any]
//            if catrobatProjects != nil {
//                var loadedProject: CatrobatProgram?
//                let projectDict = catrobatProjects?[(catrobatProjects?.count ?? 0) - 1] as? [AnyHashable : Any]
//                loadedProject = CatrobatProgram(dict: projectDict, andBaseUrl: information.baseURL)
//                for project: CatrobatProgram? in projects {
//                    if (project?.projectID == loadedProject?.projectID) {
//                        let lockQueue = DispatchQueue(label: "projects")
//                        lockQueue.sync {
//                            loadedProject?.featuredImage = project?.featuredImage ?? ""
//                            if let aProject = project {
//                                while let elementIndex = projects.index(of: aProject) { projects.remove(at: elementIndex) }
//                            }
//                            if let aProject = loadedProject {
//                                projects.insert(aProject, at: counter)
//                            }
//                        }
//                        break
//                    }
//                }
//            } else {
//                Util.defaultAlertForUnknownError()
//            }
//        }
//        update()
//        shouldHideLoadingView = true
//        hideLoadingView()
//    }

    override func showLoadingView() {
        if loadingView == nil {
            loadingView = LoadingView()
            //        [self.loadingView setBackgroundColor:[UIColor globalTintColor]];
            view.addSubview(loadingView!)
        }
        loadingView?.show()
        loadingIndicator(true)
    }

    override func hideLoadingView() {
        if shouldHideLoadingView {
            loadingView?.hide()
            loadingIndicator(false)
            shouldHideLoadingView = false
        }
    }

    func loadingIndicator(_ value: Bool) {
        let app = UIApplication.shared
        app.isNetworkActivityIndicatorVisible = value
    }

//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if featuredSize.count > 0 {
//            let width = featuredSize[0]
//            let height = featuredSize[1]
//            let factor = CGFloat(width) / Util.screenWidth())
//            let realCellHeigt = Float(CGFloat(height) / factor)
//            let expectedCellHeight = TableUtil.heightForFeaturedCell()
//            let discrepancy = fabsf(expectedCellHeight - realCellHeigt)
//            if discrepancy < Util.screenWidth() / 10 {
//                return CGFloat(realCellHeigt)
//            } else {
//                return CGFloat(expectedCellHeight)
//            }
//        }
//        return TableUtil.heightForFeaturedCell()
//    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let segueToProgramDetail = kSegueToProgramDetail
        if !isEditing {
            let cell: UITableViewCell? = tableView.cellForRow(at: indexPath)
            if shouldPerformSegue(withIdentifier: segueToProgramDetail, sender: cell) {
                performSegue(withIdentifier: segueToProgramDetail, sender: cell)
            }
        }
    }
    // MARK: - Segue delegate
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == kSegueToProgramDetail) {
            let selectedRowIndexPath: IndexPath? = tableView.indexPathForSelectedRow
            let catrobatProject = projects[selectedRowIndexPath?.row ?? 0] as? CatrobatProgram
            let programDetailViewController = segue.destination as? ProgramDetailStoreViewController
            programDetailViewController?.project = catrobatProject
        }
    }
    // MARK: - update
    func update() {
        tableView.reloadData()
    }
    // MARK: - BackButtonDelegate
    func back() {
        navigationController?.popViewController(animated: true)
    }
}
