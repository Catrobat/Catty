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

import Foundation

// TODO: header properties are not working correctly

class ProjectDetailStoreViewController2: UIViewController {
    var project: CatrobatProject
    @IBOutlet weak var scrollViewOutlet: UIScrollView!
    //var storeProjectDownloader: StoreProjectDownloader
    var storeProjectDownloader = StoreProjectDownloader(session: StoreProjectDownloader.defaultSession(), fileManager: CBFileManager.shared())
    //var projectManager: ProjectManager
    var projectManager = ProjectManager.shared
    var projectView: UIView?
    /*
    @property (nonatomic, strong) CatrobatProject *project;
    @property (nonatomic, weak) IBOutlet UIScrollView *scrollViewOutlet;
    @property (nonatomic, strong) StoreProjectDownloader *storeProjectDownloader;
    @property (nonatomic, strong) ProjectManager *projectManager;
    @property (nonatomic, strong) UIView *projectView;
    */
    
    //private var loadingView: LoadingView
    private var loadingView = LoadingView()
    //private var session: URLSession
    //private var dataTask: URLSessionDataTask
    
    /*
     @property (nonatomic, strong) LoadingView *loadingView;
     @property (strong, nonatomic) NSURLSession *session;
     @property (strong, nonatomic) NSURLSessionDataTask *dataTask;
     */
  /*
    func projectManager() -> ProjectManager {
        if !projectManager {
            projectManager = ProjectManager.shared()
        }
        return projectManager
        /*
         - (ProjectManager*)projectManager
         {
             if (! _projectManager) {
                 _projectManager = [ProjectManager shared];
             }
             return _projectManager;
         }
         */
    }
    
    
    func storeProjectDownloader() -> StoreProjectDownloader? {
        if storeProjectDownloader == nil {
            storeProjectDownloader = StoreProjectDownloader(session: StoreProjectDownloader.defaultSession(), fileManager: CBFileManager.shared())
        }
        return storeProjectDownloader
        
        /*
         - (StoreProjectDownloader*)storeProjectDownloader
         {
             if (_storeProjectDownloader == nil) {
                 _storeProjectDownloader = [[StoreProjectDownloader alloc] initWithSession:[StoreProjectDownloader defaultSession] fileManager:[CBFileManager sharedManager]];
             }
             return _storeProjectDownloader;
         }
         */
    }*/

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        //project = CatrobatProject()
        //projectView = UIView()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        //projectManager = ProjectManager.shared
        
        //loadingView = LoadingView()
        view.addSubview(loadingView)
        
        //storeProjectDownloader = StoreProjectDownloader(session: StoreProjectDownloader.defaultSession(), fileManager: CBFileManager.shared())
        /*
         - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
         {
             self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
             if (self) {
                 // Custom initialization
             }
             return self;
         }
         */
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationBar()
        self.hidesBottomBarWhenPushed = true
        self.view.backgroundColor = UIColor.background
        loadProject(project)
        
        /*
         [super viewDidLoad];
         [self initNavigationBar];
         self.hidesBottomBarWhenPushed = YES;
         self.view.backgroundColor = UIColor.background;
         NSDebug(@"%@",self.project.author);
         [self loadProject:self.project];
         */
    }
    
    
    func initNavigationBar() {
        navigationItem.title = kLocalizedDetails
        title = kLocalizedDetails
        /*
        - (void)initNavigationBar
        {
            self.title = self.navigationItem.title = kLocalizedDetails;
        }*/
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.hidesBottomBarWhenPushed = false
        
        /*
         [super viewWillDisappear:animated];
         self.hidesBottomBarWhenPushed = NO;
         [[NSNotificationCenter defaultCenter] removeObserver:self];
         */
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(true, animated: animated)
        /*
         [super viewWillAppear:animated];
         [self.navigationController setToolbarHidden:YES];
         */
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //[super viewDidAppear:animated];
    }

    func back() {
        self.navigationController?.popViewController(animated: true)
        // [self.navigationController popViewControllerAnimated:YES];
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        DispatchQueue.main.async(execute: { [self] in
            loadProject(project)
            view.setNeedsDisplay()
        })
        
        /*
         -(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self loadProject:self.project];
                 [self.view setNeedsDisplay];
             });
         }
         */
    }

    deinit {
        scrollViewOutlet.removeFromSuperview()
        /*
        - (void)dealloc
        {
            [self setScrollViewOutlet:nil];
        }
         */
    }

    //MARK: Delegates
    
    func openButtonPressed(sender: String){
        openButtonPressed()
     
        /*
         - (void)openButtonPressed:(id)sender
         {
             [self openButtonPressed];
         }
         */
    }

    

    func downloadButtonPressed(sender: String) {
        downloadButtonPressed()
        /*
         - (void)downloadButtonPressed:(id)sender
         {
             [self downloadButtonPressed];
         }
         */
    }

    func reportProject(_ sender: Any?) {
        reportProject()
        /*
         - (void)reportProject:(id)sender;
         {
             [self reportProject];
         }
         */
    }

    //MARK: Loading View

    func showLoadingView() {
       
        /*if loadingView == nil {
            loadingView = LoadingView()
            view.addSubview(loadingView)
        }*/
        loadingView.show()
        
        /*
         if(!self.loadingView) {
            self.loadingView = [[LoadingView alloc] init];
            [self.view addSubview:self.loadingView];
        }
        [self.loadingView show];
         */
    }
    
    func hideLoadingView() {
        loadingView.isHidden = true
        // [self.loadingView hide];
    }
    
    private func addLoadingButton(to view: UIView, openButton: UIButton, withTarget target: Any?) {
        let button = EVCircularProgressView()
        button.tag = Int(kStopLoadingTag)
        button.tintColor = UIColor.buttonTint
        button.frame = self.createLoadingButtonFrame(view: view, openButton: openButton)
        button.isHidden = true
        button.addTarget(target, action: #selector(URLProtocol.stopLoading), for: .touchUpInside)
        view.addSubview(button)
    }

    //MARK: Actions
    
    func stopLoading() {
        storeProjectDownloader.cancelDownload(for: project.projectID)
        
        let button = view.viewWithTag(Int(kStopLoadingTag)) as? EVCircularProgressView
        button?.isHidden = true
        button?.progress = 0
        
        if let downloadAgainButton = view.viewWithTag(Int(kDownloadAgainButtonTag)) as? UIButton {
            if downloadAgainButton.isEnabled {
                view.viewWithTag(Int(kDownloadAgainButtonTag))?.isHidden = false
            } else{
                view.viewWithTag(Int(kOpenButtonTag))?.isHidden = false
                downloadAgainButton.isEnabled = true
            }
        }
        
        Util.setNetworkActivityIndicator(false)
        
        /*
        [self.storeProjectDownloader cancelDownloadForProjectWithId:self.project.projectID];

        EVCircularProgressView* button = (EVCircularProgressView*)[self.view viewWithTag:kStopLoadingTag];
        button.hidden = YES;
        button.progress = 0;

        UIButton* downloadAgainButton = (UIButton*)[self.projectView viewWithTag:kDownloadAgainButtonTag];
        if(downloadAgainButton.enabled) {
            [self.view viewWithTag:kDownloadButtonTag].hidden = NO;
        } else {
            [self.view viewWithTag:kOpenButtonTag].hidden = NO;
            downloadAgainButton.enabled = YES;
        }
        [[Util class] setNetworkActivityIndicator:NO];
         */
    }
}
