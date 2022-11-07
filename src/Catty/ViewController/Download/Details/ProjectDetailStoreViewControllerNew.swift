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

// TODO: #selector are not working correctly
// TODO: var project and projectView are not initialized correctly

class ProjectDetailStoreViewController: UIViewController {
    var project: CatrobatProject
    @IBOutlet weak var scrollViewOutlet: UIScrollView!
    var storeProjectDownloader = StoreProjectDownloader(session: StoreProjectDownloader.defaultSession(), fileManager: CBFileManager.shared())
    var projectManager = ProjectManager.shared
    var projectView: UIView
    
    /* ProjectDetailStoreViewController.h
     @class CatrobatProject;
     @class StoreProjectDownloader;
     @class ProjectManager;

     @interface ProjectDetailStoreViewController : UIViewController<ProjectStoreDelegate, UIScrollViewDelegate, NSURLConnectionDataDelegate, UIGestureRecognizerDelegate>

     @property (nonatomic, strong) CatrobatProject *project;
     @property (nonatomic, weak) IBOutlet UIScrollView *scrollViewOutlet;
     @property (nonatomic, strong) StoreProjectDownloader *storeProjectDownloader;
     @property (nonatomic, strong) ProjectManager *projectManager;
     @property (nonatomic, strong) UIView *projectView;
    */
    
    private var loadingView = LoadingView()
    //never used
    //private var session: URLSession
    //private var dataTask: URLSessionDataTask
    
    /* ProjectDetailStoreViewController
    @interface ProjectDetailStoreViewController ()

    @property (nonatomic, strong) LoadingView *loadingView;
    @property (strong, nonatomic) NSURLSession *session;
    @property (strong, nonatomic) NSURLSessionDataTask *dataTask;
    */
    
    // MARK: original init of projectManager and storedownloader
    
    /*
    - (ProjectManager*)projectManager
    {
      if (! _projectManager) {
          _projectManager = [ProjectManager shared];
      }
      return _projectManager;
    }

    - (StoreProjectDownloader*)storeProjectDownloader
    {
      if (_storeProjectDownloader == nil) {
          _storeProjectDownloader = [[StoreProjectDownloader alloc] initWithSession:[StoreProjectDownloader defaultSession] fileManager:[CBFileManager sharedManager]];
      }
      return _storeProjectDownloader;
    }
    */

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        view.addSubview(loadingView)
        /* original
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
        NotificationCenter.default.removeObserver(self)
        
        /*
         [super viewWillDisappear:animated];
         self.hidesBottomBarWhenPushed = NO;
         [[NSNotificationCenter defaultCenter] removeObserver:self];
         */
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard self.navigationController != nil else {
            return
        }
        self.navigationController!.setToolbarHidden(true, animated: animated)
        
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
        guard self.navigationController != nil else {
            return
        }
        self.navigationController!.popViewController(animated: true)
        
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
    
    func openButtonPressed(_ sender: Any?){
        openButtonPressed()
     
        /*
         - (void)openButtonPressed:(id)sender
         {
             [self openButtonPressed];
         }
         */
    }

    

    func downloadButtonPressed(_ sender: Any?) {
        downloadButtonPressed()
        
        /*
         - (void)downloadButtonPressed:(id)sender
         {
             [self downloadButtonPressed];
         }
         */
    }
    
    func downloadButtonPressed() {
        let button = projectView.viewWithTag(Int(kStopLoadingTag)) as? EVCircularProgressView
        projectView.viewWithTag(Int(kDownloadButtonTag))?.isHidden = true
        button?.isHidden = false
        button?.progress = 0
        if let duplicateName = Util.uniqueName(project.name, existingNames: Project.allProjectNames()) {
            download(name: duplicateName)
        }
        /*
         NSDebug(@"Download Button!");
         EVCircularProgressView* button = (EVCircularProgressView*)[self.projectView viewWithTag:kStopLoadingTag];
         [self.projectView viewWithTag:kDownloadButtonTag].hidden = YES;
         button.hidden = NO;
         button.progress = 0;
         NSString* duplicateName = [Util uniqueName:self.project.name existingNames:[Project allProjectNames]];
         [self downloadWithName:duplicateName];
         */
        
    }

    func downloadAgain(_ sender: Any?) {
        
        let button = projectView.viewWithTag(Int(kStopLoadingTag)) as? EVCircularProgressView
        projectView.viewWithTag(Int(kOpenButtonTag))?.isHidden = true
        
        let downloadAgainButton = projectView.viewWithTag(Int(kDownloadAgainButtonTag)) as? UIButton
        downloadAgainButton?.isEnabled = false
        button?.isHidden = false
        button?.progress = 0
        
        if let duplicateName = Util.uniqueName(project.name, existingNames: Project.allProjectNames()) {
            download(name: duplicateName)
        }
       
        /*
         -(void)downloadAgain:(id)sender
         {
             EVCircularProgressView* button = (EVCircularProgressView*)[self.projectView viewWithTag:kStopLoadingTag];
             [self.projectView viewWithTag:kOpenButtonTag].hidden = YES;
             UIButton* downloadAgainButton = (UIButton*)[self.projectView viewWithTag:kDownloadAgainButtonTag];
             downloadAgainButton.enabled = NO;
             button.hidden = NO;
             button.progress = 0;
             NSString* duplicateName = [Util uniqueName:self.project.name existingNames:[Project allProjectNames]];
             NSDebug(@"%@",[Project allProjectNames]);
             [self downloadWithName:duplicateName];
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
