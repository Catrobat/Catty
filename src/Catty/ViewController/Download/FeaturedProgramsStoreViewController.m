/**
 *  Copyright (C) 2010-2016 The Catrobat Team
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

#import "FeaturedProgramsStoreViewController.h"
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
#import "DarkBlueGradientFeaturedCell.h"

#import "UIImage+CatrobatUIImageExtensions.h"
#import "LanguageTranslationDefines.h"

#define kFeaturedProgramsMaxResults 10

@interface FeaturedProgramsStoreViewController ()

@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSURLSessionDataTask *dataTask;
@property (nonatomic, strong) NSMutableArray *projects;
@property (nonatomic, strong) NSArray *featuredSize;
@property (nonatomic, strong) LoadingView* loadingView;
@property (nonatomic) BOOL shouldShowAlert;
@property (nonatomic) BOOL shouldHideLoadingView;

@end

@implementation FeaturedProgramsStoreViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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
    [super viewDidLoad];
    [self loadFeaturedProjects];
    self.navigationItem.title = kLocalizedFeaturedPrograms;
    //  CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
    //  self.tableView.contentInset = UIEdgeInsetsMake(navigationBarHeight, 0, 0, 0);
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.shouldShowAlert = YES;
    self.shouldHideLoadingView = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.translucent = YES;
    self.navigationController.navigationBar.translucent =YES;
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
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.projects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell* cell = nil;
    cell = [self cellForProjectsTableView:tableView atIndexPath:indexPath];
    return cell;
}

#pragma mark - Helper
- (UITableViewCell*)cellForProjectsTableView:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath
{
    static NSString *CellIdentifier = kFeaturedCell;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        NSLog(@"Should Never happen - since iOS5 Storyboard *always* instantiates our cell!");
        abort();
    }

    if([cell isKindOfClass:[DarkBlueGradientFeaturedCell class]]) {
        CatrobatProgram *project = [self.projects objectAtIndex:indexPath.row];
        
        DarkBlueGradientFeaturedCell *imageCell = (DarkBlueGradientFeaturedCell *)cell;
        [self loadImage:project.featuredImage forCell:imageCell atIndexPath:indexPath];
        if (![imageCell.featuredImage.image isEqual:[UIImage imageNamed:@"programs"]]) {
            imageCell.featuredImage.frame = cell.frame;
            imageCell.featuredImage.frame = CGRectMake(0, 0, imageCell.featuredImage.frame.size.width, imageCell.featuredImage.frame.size.height);
            [self loadingIndicator:NO];
        }
    }
    
    return cell;
}



- (void)loadImage:(NSString*)imageURLString forCell:(DarkBlueGradientFeaturedCell *) imageCell atIndexPath:(NSIndexPath*)indexPath
{
    
    [self loadingIndicator:YES];
    UIImage* image = [UIImage imageWithContentsOfURL:[NSURL URLWithString:imageURLString]
                                    placeholderImage:[UIImage imageNamed:@"programs"]
                                        onCompletion:^(UIImage *img) {
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                [self.tableView beginUpdates];
                                                DarkBlueGradientFeaturedCell *cell = (DarkBlueGradientFeaturedCell*)[self.tableView cellForRowAtIndexPath:indexPath];
                                                if(cell) {
                                                    cell.featuredImage.image = img;
                                                    cell.featuredImage.frame = cell.frame;
                                                    cell.featuredImage.frame = CGRectMake(30, 0, self.view.frame.size.width, cell.featuredImage.frame.size.height);
                                                    self.featuredSize = @[[NSNumber numberWithFloat:img.size.width],[NSNumber numberWithFloat:img.size.height]];
                                                    NSDebug(@"%f",img.size.height/(img.size.width / [Util screenWidth]));
//                                                    CGFloat factor = img.size.width / [Util screenWidth];
//                                                    NSDebug(@"%f",img.size.height/factor);
                                                    [self loadingIndicator:NO];
                                                    cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, cell.featuredImage.frame.size.height);
                                                }
                                                [self.tableView endUpdates];
                                                [self.tableView reloadData];
                                            });
                                        }];
    imageCell.featuredImage.image = image;
    self.featuredSize = @[[NSNumber numberWithFloat:image.size.width],[NSNumber numberWithFloat:image.size.height]];
    imageCell.featuredImage.contentMode = UIViewContentModeScaleAspectFit;
}


- (void)loadFeaturedProjects
{
    //self.data = [[NSMutableData alloc] init];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@?%@%i", kConnectionHost, kConnectionFeatured, kProgramsLimit, kFeaturedProgramsMaxResults]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kConnectionTimeout];

    self.dataTask = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            if ([Util isNetworkError:error]) {
                [Util defaultAlertForNetworkError];
                self.shouldHideLoadingView = YES;
                [self hideLoadingView];
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self loadIDsWith:data andResponse:response];
            });
            
        }
    }];
    
    if (self.dataTask) {
        [self.dataTask resume];
        [self showLoadingView];
    }
}

- (void)loadIDsWith:(NSData*)data andResponse:(NSURLResponse*)response
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
        
        if (catrobatProjects) {
            self.projects = [[NSMutableArray alloc] initWithCapacity:[catrobatProjects count]];
            
            for (NSDictionary *projectDict in catrobatProjects) {
                CatrobatProgram *project = [[CatrobatProgram alloc] initWithDict:projectDict andBaseUrl:information.baseURL];
                [self.projects addObject:project];
            }
        } else {
            [Util defaultAlertForUnknownError];
            self.shouldHideLoadingView = YES;
            [self hideLoadingView];
            return;
        }
    }
    [self update];
    
    for (CatrobatProgram* project in self.projects) {
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@?id=%@", kConnectionHost, kConnectionIDQuery,project.projectID]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kConnectionTimeout];

        NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error) {
                if (error.code != kCFURLErrorCancelled) {
                    NSLog(@"%@", error);
                }
                
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                        [self loadInfosWith:data andResponse:response];
                });
                
            }
        }];
        
        if (task) {
            [task resume];
            [self showLoadingView];
        }
    }
    [self showLoadingView];
  
}
- (void)loadInfosWith:(NSData*)data andResponse:(NSURLResponse*)response
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
        
        if (catrobatProjects) {
            NSInteger counter=0;
            CatrobatProgram *loadedProject;
            NSDictionary *projectDict = [catrobatProjects objectAtIndex:[catrobatProjects count]-1];
            loadedProject = [[CatrobatProgram alloc] initWithDict:projectDict andBaseUrl:information.baseURL];
            
            for (CatrobatProgram* project in self.projects) {
                if ([project.projectID isEqualToString:loadedProject.projectID ]) {
                    @synchronized(self.projects){
                        loadedProject.featuredImage = [NSString stringWithString:project.featuredImage];
                        [self.projects removeObject:project];
                        [self.projects insertObject:loadedProject atIndex:counter];
                    }
                    break;
                }
                counter++;
            }
        } else {
            [Util defaultAlertForUnknownError];
        }
    }
    [self update];
    self.shouldHideLoadingView = YES;
    [self hideLoadingView];
   
}

- (void)showLoadingView
{
    if(!self.loadingView) {
        self.loadingView = [[LoadingView alloc] init];
//        [self.loadingView setBackgroundColor:[UIColor globalTintColor]];
        [self.view addSubview:self.loadingView];
    }
    [self.loadingView show];
    [self loadingIndicator:YES];
}

- (void)hideLoadingView
{
    if(self.shouldHideLoadingView) {
        [self.loadingView hide];
        [self loadingIndicator:NO];
        self.shouldHideLoadingView = NO;
    }
}

- (void)loadingIndicator:(BOOL)value
{
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = value;
}


#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.featuredSize) {
        NSNumber* width = self.featuredSize[0];
        NSNumber* height = self.featuredSize[1];
        
        CGFloat factor = width.floatValue / [Util screenWidth];
        float realCellHeigt = height.floatValue/factor;
        float expectedCellHeight = [TableUtil heightForFeaturedCell];
        
        float discrepancy = fabsf(expectedCellHeight - realCellHeigt);
        if (discrepancy < [Util screenWidth]/10)
        {
            return realCellHeigt;
        }
        else
        {
            return expectedCellHeight;
        }
    }
    return [TableUtil heightForFeaturedCell];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *segueToProgramDetail = kSegueToProgramDetail;
    if (!self.editing) {
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
//
//- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
//
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
//            CatrobatInformation *information = [[CatrobatInformation alloc] initWithDict:catrobatInformation];
//
//            NSArray *catrobatProjects = [jsonObject valueForKey:@"CatrobatProjects"];
//
//            self.projects = [[NSMutableArray alloc] initWithCapacity:[catrobatProjects count]];
//
//            for (NSDictionary *projectDict in catrobatProjects) {
//                CatrobatProject *project = [[CatrobatProject alloc] initWithDict:projectDict andBaseUrl:information.baseURL];
//                [self.projects addObject:project];
//            }
//        }
//
//        self.data = nil;
//        self.connection = nil;
//
//        [self update];
//    }
//}

# pragma mark - Segue delegate
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:kSegueToProgramDetail]) {
        NSIndexPath *selectedRowIndexPath = self.tableView.indexPathForSelectedRow;
        CatrobatProgram *catrobatProject = [self.projects objectAtIndex:selectedRowIndexPath.row];
        ProgramDetailStoreViewController* programDetailViewController = (ProgramDetailStoreViewController*)[segue destinationViewController];
        programDetailViewController.project = catrobatProject;
        
    }
}

#pragma mark - update
- (void)update {
    [self.tableView reloadData];
}

#pragma mark - BackButtonDelegate
- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}


@end
