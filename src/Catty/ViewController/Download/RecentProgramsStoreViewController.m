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

#import "RecentProgramsStoreViewController.h"
#import "CatrobatInformation.h"
#import "AppDelegate.h"
#import "Util.h"
#import "TableUtil.h"
#import "CellTagDefines.h"
#import "CatrobatImageCell.h"
#import "LoadingView.h"
#import "NetworkDefines.h"
#import "SegueDefines.h"
#import "ProgramDetailStoreViewController.h"
#import "UIImage+CatrobatUIImageExtensions.h"

@interface RecentProgramsStoreViewController ()

@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSURLSessionDataTask *idTask;
@property (strong, nonatomic) NSURLSessionDataTask *infoTask;
@property (nonatomic, strong) NSMutableArray *projects;
@property (nonatomic, strong) LoadingView* loadingView;
@property (assign)            int programListOffset;
@property (nonatomic, strong) CatrobatInformation* information;
@property (nonatomic, strong) NSMutableArray* mostDownloadedProjects;
@property (nonatomic, strong) NSMutableArray* mostViewedProjects;
@property (nonatomic, strong) NSMutableArray* mostRecentProjects;
@property (nonatomic) NSInteger previousSelectedIndex;
@property (assign)            int mostDownloadedProgramListOffset;
@property (assign)            int mostViewedprogramListOffset;
@property (assign)            int mostRecentprogramListOffset;
@property (nonatomic, strong) ProgramDetailStoreViewController* controller;
@property (nonatomic) BOOL shouldShowAlert;

@end

@implementation RecentProgramsStoreViewController

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (NSURLSession *)session {
    if (!_session) {
        // Initialize Session Configuration
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        // Configure Session Configuration
        [sessionConfiguration setHTTPAdditionalHeaders:@{ @"Accept" : @"application/json" }];
        
        // Initialize Session
        _session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    }
    
    return _session;
}

- (void)viewDidLoad
{
    self.programListOffset = 0;
    
    [super viewDidLoad];
    [self loadProjectsWithIndicator:0];
    [self initTableView];
    self.view.backgroundColor = [UIColor backgroundColor];
    [self initSegmentedControl];
    [self initFooterView];
    self.previousSelectedIndex = 0;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = UIColor.globalTintColor;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.contentInset = UIEdgeInsetsMake(0., 0., CGRectGetHeight(self.tabBarController.tabBar.frame)+44, 0);
    self.shouldShowAlert = YES;
    
    self.mostDownloadedProjects = [[NSMutableArray alloc] init];
    self.mostViewedProjects = [[NSMutableArray alloc] init];
    self.mostRecentProjects = [[NSMutableArray alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    self.delegate=nil;
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.navigationController.navigationBar.translucent = YES;
    self.tabBarController.tabBar.translucent = YES;
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)dealloc
{
    [self.loadingView removeFromSuperview];
    self.loadingView = nil;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (self.downloadSegmentedControl.selectedSegmentIndex) {
        case 0:
            return self.mostDownloadedProjects.count;
            break;
        case 1:
            return self.mostViewedProjects.count;
            break;
        case 2:
            return self.mostRecentProjects.count;
            break;

        default:
            break;
    }

    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = nil;
    cell = [self cellForProjectsTableView:tableView atIndexPath:indexPath];
    return cell;
}

#pragma mark - Init
- (void)initTableView
{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.backgroundColor = [UIColor backgroundColor];
    self.tableView.scrollsToTop = YES;
}

- (void)initSegmentedControl
{
    [self.downloadSegmentedControl addTarget:self action:@selector(changeView) forControlEvents:UIControlEventValueChanged];
    [self.downloadSegmentedControl setTitle:kLocalizedMostDownloaded forSegmentAtIndex:0];
    [self.downloadSegmentedControl setTitle:kLocalizedMostViewed forSegmentAtIndex:1];
    [self.downloadSegmentedControl setTitle:kLocalizedNewest forSegmentAtIndex:2];
    if (IS_IPHONE4||IS_IPHONE5) {
        UIFont *font = [UIFont boldSystemFontOfSize:10.0f];
        NSDictionary *attributes = [NSDictionary dictionaryWithObject:font
                                                               forKey:NSFontAttributeName];
        [self.downloadSegmentedControl setTitleTextAttributes:attributes
                                                     forState:UIControlStateNormal];
    }
}

- (void)initFooterView
{
    self.footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 40.0)];
    
    UIActivityIndicatorView * actInd = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    actInd.tag = 10;
    
    actInd.frame = CGRectMake(self.tableView.frame.size.width/2-20, 10.0, 40.0, 40.0);
    
    actInd.hidesWhenStopped = YES;
    
    [self.footerView addSubview:actInd];
    
    actInd = nil;
}

#pragma mark - Helper
- (UITableViewCell*)cellForProjectsTableView:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath
{
    static NSString *CellIdentifier = kImageCell;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if ([cell conformsToProtocol:@protocol(CatrobatImageCell)]) {
        CatrobatProgram *project ;
        switch (self.downloadSegmentedControl.selectedSegmentIndex) {
            case 0:
                project = [self.mostDownloadedProjects objectAtIndex:indexPath.row];
                break;
            case 1:
                project = [self.mostViewedProjects objectAtIndex:indexPath.row];
                break;
            case 2:
                project = [self.mostRecentProjects objectAtIndex:indexPath.row];
                break;
                
            default:
                break;
        }
        
        UITableViewCell <CatrobatImageCell>* imageCell = (UITableViewCell <CatrobatImageCell>*)cell;
        imageCell.titleLabel.text = project.projectName;
        
        [self loadImage:project.screenshotSmall forCell:imageCell atIndexPath:indexPath];
    }
    return cell;
}

- (void)loadImage:(NSString*)imageURLString forCell:(UITableViewCell <CatrobatImageCell>*) imageCell atIndexPath:(NSIndexPath*)indexPath
{
    imageCell.iconImageView.image =
    [UIImage imageWithContentsOfURL:[NSURL URLWithString:imageURLString]
                   placeholderImage:[UIImage imageNamed:@"programs"]
                       onCompletion:^(UIImage *image) {
                           dispatch_async(dispatch_get_main_queue(), ^{
                               [self.tableView beginUpdates];
                               UITableViewCell <CatrobatImageCell>* cell = (UITableViewCell <CatrobatImageCell>*)[self.tableView cellForRowAtIndexPath:indexPath];
                               if(cell) {
                                   cell.iconImageView.image = image;
                               }
                               [self.tableView endUpdates];
                           });
                       }];
}

- (void)loadProjectsWithIndicator:(NSInteger)indicator
{
    NSURL *url = [NSURL alloc];
    switch (self.downloadSegmentedControl.selectedSegmentIndex) {
        case 0:
            url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@?%@%i&%@%i&%@%@", kConnectionHost, kConnectionMostDownloaded, kProgramsOffset, self.programListOffset, kProgramsLimit, kRecentProgramsMaxResults, kMaxVersion, [Util catrobatLanguageVersion]]];
            
            break;
        case 1:
            url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@?%@%i&%@%i&%@%@", kConnectionHost, kConnectionMostViewed, kProgramsOffset, self.programListOffset, kProgramsLimit, kRecentProgramsMaxResults, kMaxVersion, [Util catrobatLanguageVersion]]];
            
            break;
        case 2:
            url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@?%@%i&%@%i&%@%@", kConnectionHost, kConnectionRecent, kProgramsOffset, self.programListOffset, kProgramsLimit, kRecentProgramsMaxResults, kMaxVersion, [Util catrobatLanguageVersion]]];
            
            break;
        default:
            break;
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kConnectionTimeout];
    
    NSDebug(@"url is: %@", url);
    
    if (self.idTask) {
        [self.idTask cancel];
    }
    self.idTask = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            if ([Util isNetworkError:error]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Util defaultAlertForNetworkError];
                    [self hideLoadingView];
                    [self loadingIndicator:NO];
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDebug(@"LoadIDS");
                [self loadProjectsWith:data andResponse:response];
            });
        }
    }];
    
    if (self.idTask) {
        [self.idTask resume];
    }
    
    if (indicator==0) {
        [self showLoadingView];
    }
    [self loadingIndicator:YES];
    
    self.programListOffset += kRecentProgramsMaxResults;
}

- (void)loadProjectsWith:(NSData*)data andResponse:(NSURLResponse*)response
{
    if (data == nil) {
        if (self.shouldShowAlert) {
            self.shouldShowAlert = NO;
            [Util defaultAlertForNetworkError];
        }
        return;
    }
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                    options:NSJSONReadingMutableContainers
                                                      error:&error];
    NSDebug(@"array: %@", jsonObject);

    if ([jsonObject isKindOfClass:[NSDictionary class]]) {
        NSDictionary *catrobatInformation = [jsonObject valueForKey:@"CatrobatInformation"];

        CatrobatInformation *information = [[CatrobatInformation alloc] initWithDict:catrobatInformation];

        NSArray *catrobatProjects = [jsonObject valueForKey:@"CatrobatProjects"];

        switch (self.downloadSegmentedControl.selectedSegmentIndex) {
            case 0:
                for (NSDictionary *projectDict in catrobatProjects) {
                    CatrobatProgram *project = [[CatrobatProgram alloc] initWithDict:projectDict andBaseUrl:information.baseURL];
                    [self.mostDownloadedProjects addObject:project];
                }
                break;
            case 1:
                for (NSDictionary *projectDict in catrobatProjects) {
                    CatrobatProgram *project = [[CatrobatProgram alloc] initWithDict:projectDict andBaseUrl:information.baseURL];
                    [self.mostViewedProjects addObject:project];
                }
                break;
            case 2:
                for (NSDictionary *projectDict in catrobatProjects) {
                    CatrobatProgram *project = [[CatrobatProgram alloc] initWithDict:projectDict andBaseUrl:information.baseURL];
                    [self.mostRecentProjects addObject:project];
                }
                break;
            default:
                break;
        }
    }
    [self update];
    [self hideLoadingView];
    [self loadingIndicator:NO];
}

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

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return [TableUtil heightForImageCell];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *segueToProgramDetail = kSegueToProgramDetail;
    if (! self.editing) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if ([self shouldPerformSegueWithIdentifier:segueToProgramDetail sender:cell]) {
            [self performSegueWithIdentifier:segueToProgramDetail sender:cell];
        }
    }
}

# pragma mark - Segue delegate
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:kSegueToProgramDetail]) {
        NSIndexPath *selectedRowIndexPath = self.tableView.indexPathForSelectedRow;
        CatrobatProgram *catrobatProject;
        switch (self.downloadSegmentedControl.selectedSegmentIndex) {
            case 0:
                catrobatProject = [self.mostDownloadedProjects objectAtIndex:selectedRowIndexPath.row];
                break;
            case 1:
                catrobatProject = [self.mostViewedProjects objectAtIndex:selectedRowIndexPath.row];
                break;
            case 2:
                catrobatProject = [self.mostRecentProjects objectAtIndex:selectedRowIndexPath.row];
                break;
            default:
                break;
        }
        self.controller = (ProgramDetailStoreViewController*)[segue destinationViewController];
        self.controller.project = catrobatProject;
        self.delegate = self.controller;
    }
}

#pragma mark - update
- (void)update
{
    [self.tableView reloadData];
#if __IPHONE_OS_VERSION_MAX_ALLOWED < 80000
    // iOS7 specific stuff
    [self.searchDisplayController setActive:NO animated:YES];
#endif
}

#pragma mark - BackButtonDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    float checkPoint = scrollView.contentSize.height * 0.7f;
    float currentViewBottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    switch (self.downloadSegmentedControl.selectedSegmentIndex) {
        case 0:
            if (currentViewBottomEdge >= checkPoint && [self.mostDownloadedProjects count] >= self.programListOffset) {
                NSDebug(@"Reached scroll-checkpoint for loading further projects");
                [self loadProjectsWithIndicator:1];
            }
            else{
                self.tableView.tableFooterView = nil;
            }
            
            break;
        case 1:
            if (currentViewBottomEdge >= checkPoint && [self.mostViewedProjects count] >= self.programListOffset) {
                NSDebug(@"Reached scroll-checkpoint for loading further projects");
                [self loadProjectsWithIndicator:1];
            }
            else{
                self.tableView.tableFooterView = nil;
            }
            
            break;
        case 2:
            if (currentViewBottomEdge >= checkPoint && [self.mostRecentProjects count] >= self.programListOffset) {
                NSDebug(@"Reached scroll-checkpoint for loading further projects");
                [self loadProjectsWithIndicator:1];
            }
            else{
                self.tableView.tableFooterView = nil;
            }
            
            break;
        default:
            break;
    }
}

- (void)changeView
{
    switch (self.previousSelectedIndex) {
        case 0:
            self.mostDownloadedProgramListOffset = self.programListOffset;
            break;
        case 1:
            self.mostViewedprogramListOffset = self.programListOffset;
            break;
        case 2:
            self.mostRecentprogramListOffset = self.programListOffset;
            break;
        default:
            break;
    }
    switch (self.downloadSegmentedControl.selectedSegmentIndex) {
        case 0:
            self.programListOffset = self.mostDownloadedProgramListOffset;
            if (self.mostDownloadedProjects.count == 0) {
                [self loadProjectsWithIndicator:0];
            }
            break;
        case 1:
            self.programListOffset = self.mostViewedprogramListOffset;
            if (self.mostViewedProjects.count == 0) {
                [self loadProjectsWithIndicator:0];
            }
            break;
        case 2:
            self.programListOffset =  self.mostRecentprogramListOffset;
            if (self.mostRecentProjects.count == 0) {
                [self loadProjectsWithIndicator:0];
            }
            break;
        default:
            break;
    }
    self.previousSelectedIndex = self.downloadSegmentedControl.selectedSegmentIndex;
    [self update];
}

- (void)loadingIndicator:(BOOL)value
{
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = value;
}

@end
