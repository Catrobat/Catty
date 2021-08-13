/**
 *  Copyright (C) 2010-2021 The Catrobat Team
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

#import "ProjectDetailStoreViewController.h"
#import "CBFileManager.h"
#import "ButtonTags.h"
#import "SegueDefines.h"
#import "SceneTableViewController.h"
#import "Util.h"
#import "EVCircularProgressView.h"
#import "KeychainUserDefaultsDefines.h"
#import "Pocket_Code-Swift.h"
#import "EVCircularProgressView.h"
#import "RoundBorderedButton.h"

@interface ProjectDetailStoreViewController ()

@property (nonatomic, strong) LoadingView *loadingView;
@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSURLSessionDataTask *dataTask;

@end

@implementation ProjectDetailStoreViewController

#pragma mark - getters and setters
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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initNavigationBar];
    self.hidesBottomBarWhenPushed = YES;
    self.view.backgroundColor = UIColor.background;
    NSDebug(@"%@",self.project.author);
    [self loadProject:self.project];
}

- (void)initNavigationBar
{
    self.title = self.navigationItem.title = kLocalizedDetails;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.hidesBottomBarWhenPushed = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc
{
    [self setScrollViewOutlet:nil];
}

#pragma mark - ProjectStore Delegate

- (void)openButtonPressed:(id)sender
{
    [self openButtonPressed];
}

- (void)downloadButtonPressed
{
    NSDebug(@"Download Button!");
    EVCircularProgressView* button = (EVCircularProgressView*)[self.projectView viewWithTag:kStopLoadingTag];
    [self.projectView viewWithTag:kDownloadButtonTag].hidden = YES;
    button.hidden = NO;
    button.progress = 0;
    NSString* duplicateName = [Util uniqueName:self.project.name existingNames:[Project allProjectNames]];
    [self downloadWithName:duplicateName];
}

- (void)downloadButtonPressed:(id)sender
{
    [self downloadButtonPressed];
}

- (void) reportProject:(id)sender;
{
    [self reportProject];
}

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

#pragma mark - loading view
- (void)showLoadingView
{
    if(!self.loadingView) {
        self.loadingView = [[LoadingView alloc] init];
        [self.view addSubview:self.loadingView];
    }
    [self.loadingView show];
}

- (void) hideLoadingView
{
    [self.loadingView hide];
}

#pragma mark - actions
- (void)stopLoading
{
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
}

#pragma mark Rotation
-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self loadProject:self.project];
        [self.view setNeedsDisplay];
    });
}

@end
