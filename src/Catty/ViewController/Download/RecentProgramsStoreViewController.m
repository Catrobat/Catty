/**
 *  Copyright (C) 2010-2015 The Catrobat Team
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
#import "CatrobatProgram.h"
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
#import "UIColor+CatrobatUIColorExtensions.h"
#import "LanguageTranslationDefines.h"

@interface RecentProgramsStoreViewController ()

@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableArray *projects;
@property (nonatomic, strong) LoadingView* loadingView;
@property (assign)            int programListOffset;
@property (assign)            int programListLimit;
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

- (void)viewDidLoad
{
    self.programListLimit = 20;
    self.programListOffset = 0;

    [super viewDidLoad];
    [self loadProjectsWithIndicator:0];
    [self initTableView];
    self.view.backgroundColor = [UIColor darkBlueColor];
    [self initSegmentedControl];
    [self initFooterView];
    self.previousSelectedIndex = 0;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = UIColor.skyBlueColor;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.shouldShowAlert = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    self.delegate=nil;
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
    self.tableView.backgroundColor = [UIColor darkBlueColor];
    CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat segmentedcontrolHeight = self.segmentedControlView.frame.size.height;
    self.tableView.frame = CGRectMake(0, navigationBarHeight+segmentedcontrolHeight+[UIApplication sharedApplication].statusBarFrame.size.height, self.tableView.frame.size.width, [Util screenHeight] - (navigationBarHeight + segmentedcontrolHeight));
    self.tableView.scrollsToTop = YES;
}

- (void)initSegmentedControl
{
    [self.downloadSegmentedControl addTarget:self action:@selector(changeView) forControlEvents:UIControlEventValueChanged];
    [self.downloadSegmentedControl setTitle:kLocalizedMostDownloaded forSegmentAtIndex:0];
    [self.downloadSegmentedControl setTitle:kLocalizedMostViewed forSegmentAtIndex:1];
    [self.downloadSegmentedControl setTitle:kLocalizedNewest forSegmentAtIndex:2];
    

    CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
    self.downloadSegmentedControl.backgroundColor = [UIColor darkBlueColor];
    self.downloadSegmentedControl.tintColor = [UIColor lightOrangeColor];
    self.segmentedControlView.frame = CGRectMake(0, navigationBarHeight+[UIApplication sharedApplication].statusBarFrame.size.height, self.view.frame.size.width, self.segmentedControlView.frame.size.height);
    self.segmentedControlView.backgroundColor = [UIColor darkBlueColor];
    self.downloadSegmentedControl.frame = CGRectMake(9, 9, self.view.frame.size.width - 18, self.downloadSegmentedControl.frame.size.height);

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
        //        if(indexPath.row == [self.projects count]-1){
        //            UITableViewCell <CatrobatImageCell>* imageCell = (UITableViewCell <CatrobatImageCell>*)cell;
        //            imageCell.titleLabel.text = nil;
        //            imageCell.imageView.image = nil;
        //            UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        //
        //            imageCell.accessoryView = activityIndicator;
        //            [activityIndicator startAnimating];
        //            NSDebug(@"LoadingCell");
        //            imageCell.iconImageView.image = nil;
        //
        //        }
        //        else{
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
        NSDebug(@"Normal Cell");
        //        }
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
    self.data = [[NSMutableData alloc] init];
    NSURL *url = [NSURL alloc];
    switch (self.downloadSegmentedControl.selectedSegmentIndex) {
        case 0:
            url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@?%@%i&%@%i", kConnectionHost, kConnectionMostDownloadedFull, kProgramsOffset, self.programListOffset, kProgramsLimit, self.programListLimit]];
            
            break;
        case 1:
            url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@?%@%i&%@%i", kConnectionHost, kConnectionMostViewed, kProgramsOffset, self.programListOffset, kProgramsLimit, self.programListLimit]];
            
            break;
        case 2:
            url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@?%@%i&%@%i", kConnectionHost, kConnectionRecent, kProgramsOffset, self.programListOffset, kProgramsLimit, self.programListLimit]];
            
            break;
            
        default:
            break;
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kConnectionTimeout];
    
    NSDebug(@"url is: %@", url);
    //    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    //    self.connection = connection;
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               [self loadIDsWith:data andResponse:response];}];
    if (indicator==0) {
        [self showLoadingView];
    }
    [self loadingIndicator:YES];
    
    self.programListOffset += self.programListLimit;
}

- (void)loadIDsWith:(NSData*)data andResponse:(NSURLResponse*)response
{
    if (data == nil) {
        if (self.shouldShowAlert) {
            self.shouldShowAlert = NO;
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:kLocalizedPocketCode
                                                                message:kLocalizedSlowInternetConnection
                                                               delegate:self.navigationController.visibleViewController
                                                      cancelButtonTitle:kLocalizedOK
                                                      otherButtonTitles:nil];
            [alertView show];
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
                
                if (!self.mostDownloadedProjects) {
                    self.mostDownloadedProjects = [[NSMutableArray alloc] initWithCapacity:[catrobatProjects count]];
                }
                else {
                    //preallocate due to performance reasons
                    NSMutableArray *tmpResizedArray = [[NSMutableArray alloc] initWithCapacity:([self.mostDownloadedProjects count] + [catrobatProjects count])];
                    for (CatrobatProgram *catrobatProject in self.mostDownloadedProjects) {
                        [tmpResizedArray addObject:catrobatProject];
                    }
                    self.mostDownloadedProjects = nil;
                    self.mostDownloadedProjects = tmpResizedArray;
                }
                
                
                [self loadIDForArray:self.mostDownloadedProjects andInformation:information andProjects:catrobatProjects];
                break;
            case 1:
                if (!self.mostViewedProjects) {
                    self.mostViewedProjects = [[NSMutableArray alloc] initWithCapacity:[catrobatProjects count]];
                }
                else {
                    //preallocate due to performance reasons
                    NSMutableArray *tmpResizedArray = [[NSMutableArray alloc] initWithCapacity:([self.mostViewedProjects count] + [catrobatProjects count])];
                    for (CatrobatProgram *catrobatProject in self.mostViewedProjects) {
                        [tmpResizedArray addObject:catrobatProject];
                    }
                    self.mostViewedProjects = nil;
                    self.mostViewedProjects = tmpResizedArray;
                }
                
                [self loadIDForArray:self.mostViewedProjects andInformation:information andProjects:catrobatProjects];
                break;
            case 2:
                if (!self.mostRecentProjects) {
                    self.mostRecentProjects = [[NSMutableArray alloc] initWithCapacity:[catrobatProjects count]];
                }
                else {
                    //preallocate due to performance reasons
                    NSMutableArray *tmpResizedArray = [[NSMutableArray alloc] initWithCapacity:([self.mostRecentProjects count] + [catrobatProjects count])];
                    for (CatrobatProgram *catrobatProject in self.mostRecentProjects) {
                        [tmpResizedArray addObject:catrobatProject];
                    }
                    self.mostRecentProjects = nil;
                    self.mostRecentProjects = tmpResizedArray;
                }
                [self loadIDForArray:self.mostRecentProjects andInformation:information andProjects:catrobatProjects];
                break;
                
            default:
                break;
        }
        
    }
    
    
    
    [self update];
    
}

- (void)loadIDForArray:(NSMutableArray*)projects andInformation:(CatrobatInformation*) information andProjects:(NSArray*)catrobatProjects
{
    
    for (NSDictionary *projectDict in catrobatProjects) {
        CatrobatProgram *project = [[CatrobatProgram alloc] initWithDict:projectDict andBaseUrl:information.baseURL];
        [projects addObject:project];
    }
    [self update];
    for (CatrobatProgram* project in projects) {
        //if ([project.author isEqualToString:@""]) {
        if (!project.author) {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@?id=%@", kConnectionHost, kConnectionIDQuery,project.projectID]];
            NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kConnectionTimeout];
            
            //    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            //    self.connection = connection;
            
            [NSURLConnection sendAsynchronousRequest:request
                                               queue:[NSOperationQueue mainQueue]
                                   completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                       [self loadInfosWith:data andResponse:response];}];
//            [self showLoadingView];
        }
        else
        {
            [self hideLoadingView];
            [self loadingIndicator:NO];
        }
        
        // }
    }
    
    
}


- (void)loadInfosWith:(NSData*)data andResponse:(NSURLResponse*)response
{
    if (data == nil) {
        if (self.shouldShowAlert) {
            self.shouldShowAlert = NO;
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:kLocalizedPocketCode
                                                                message:kLocalizedSlowInternetConnection
                                                               delegate:self.navigationController.visibleViewController
                                                      cancelButtonTitle:kLocalizedOK
                                                      otherButtonTitles:nil];
            [alertView show];
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
        
        NSInteger counter=0;
        CatrobatProgram *loadedProject;
        NSDictionary *projectDict = [catrobatProjects objectAtIndex:[catrobatProjects count]-1];
        loadedProject = [[CatrobatProgram alloc] initWithDict:projectDict andBaseUrl:information.baseURL];
        switch (self.downloadSegmentedControl.selectedSegmentIndex) {
            case 0:
                for (CatrobatProgram* project in self.mostDownloadedProjects) {
                    if ([project.projectID isEqualToString:loadedProject.projectID ]) {
                        
                        [self.mostDownloadedProjects removeObject:project];
                        [self.mostDownloadedProjects insertObject:loadedProject atIndex:counter];
                        
                        if ([self.delegate respondsToSelector:@selector(reloadWithProject:)] && [self.controller.project.projectID isEqualToString:loadedProject.projectID]){
                            
                            [self.delegate reloadWithProject:loadedProject];
                        }
                        break;
                    }
                    counter++;
                }
                
                break;
            case 1:
                for (CatrobatProgram* project in self.mostViewedProjects) {
                    if ([project.projectID isEqualToString:loadedProject.projectID ]) {
                        
                        [self.mostViewedProjects removeObject:project];
                        [self.mostViewedProjects insertObject:loadedProject atIndex:counter];
                        if ([self.delegate respondsToSelector:@selector(reloadWithProject:)] && [self.controller.project.projectID isEqualToString:loadedProject.projectID]){
                            [self.delegate reloadWithProject:loadedProject];
                        }
                        break;
                    }
                    counter++;
                }
                
                break;
            case 2:
                for (CatrobatProgram* project in self.mostRecentProjects) {
                    if ([project.projectID isEqualToString:loadedProject.projectID ]) {
                        
                        [self.mostRecentProjects removeObject:project];
                        [self.mostRecentProjects insertObject:loadedProject atIndex:counter];
                        
                        if ([self.delegate respondsToSelector:@selector(reloadWithProject:)] && [self.controller.project.projectID isEqualToString:loadedProject.projectID]){
                            [self.delegate reloadWithProject:loadedProject];
                        }
                        break;
                    }
                    counter++;
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

#pragma mark - NSURLConnection Delegates
//- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
//    if (self.connection == connection) {
//        NSDebug(@"Received data from server");
//        [self.data appendData:data];
//    }
//}

//-(void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
//{
//    if (self.connection == connection)
//    {
//        NSDebug(@"Received response");
//        NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *) response;
//        NSInteger errorCode = httpResponse.statusCode;
//        NSDebug(@"CODE: %li",(long)errorCode);
//        if (self.information.totalProjects.integerValue <= self.projects.count) {
//            NSDebug(@"stop loading");
//        }
//    }
//}

//- (void)connectionDidFinishLoading:(NSURLConnection *)connection
//{
//    if (self.connection == connection) {
//
//        [self.loadingView hide];
//
//        NSError *error = nil;
//        id jsonObject = [NSJSONSerialization JSONObjectWithData:self.data
//                                                        options:NSJSONReadingMutableContainers
//                                                          error:&error];
//        NSDebug(@"array: %@", jsonObject);
//
//
//        if ([jsonObject isKindOfClass:[NSDictionary class]]) {
//            NSDictionary *catrobatInformation = [jsonObject valueForKey:@"CatrobatInformation"];
//
//            self.information = [[CatrobatInformation alloc] initWithDict:catrobatInformation];
//
//            NSArray *catrobatProjects = [jsonObject valueForKey:@"CatrobatProjects"];
//
//            if (!self.projects) {
//                self.projects = [[NSMutableArray alloc] initWithCapacity:[catrobatProjects count]];
//            }
//            else {
//                //preallocate due to performance reasons
//                NSMutableArray *tmpResizedArray = [[NSMutableArray alloc] initWithCapacity:([self.projects count] + [catrobatProjects count])];
//                for (CatrobatProject *catrobatProject in self.projects) {
//                    [tmpResizedArray addObject:catrobatProject];
//                }
//                self.projects = nil;
//                self.projects = tmpResizedArray;
//            }
//
//
//            for (NSDictionary *projectDict in catrobatProjects) {
//                CatrobatProject *project = [[CatrobatProject alloc] initWithDict:projectDict andBaseUrl:self.information.baseURL];
//                [self.projects addObject:project];
//            }
//        }
//
//        self.data = nil;
//        self.connection = nil;
//
//
//        [self update];
//    }
//}


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
- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - scrollView
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.tableView.tableFooterView = self.footerView;
    
    [(UIActivityIndicatorView *)[self.footerView viewWithTag:10] startAnimating];
}

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
            if (currentViewBottomEdge >= checkPoint && [self.mostViewedProjects count] >= self.programListOffset) {
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
    NSDebug(@"test %li", (long)self.downloadSegmentedControl.selectedSegmentIndex);
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

    // TODO: Add Support that tableView will scroll to the top after changing
    //self.tableView.contentOffset = CGPointMake(0, 0);
}

- (void)loadingIndicator:(BOOL)value
{
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = value;
}

@end
