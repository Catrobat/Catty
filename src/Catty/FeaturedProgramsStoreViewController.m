/**
 *  Copyright (C) 2010-2013 The Catrobat Team
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
#import "CatrobatProject.h"
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

@interface FeaturedProgramsStoreViewController ()

@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableArray *projects;
@property (nonatomic, strong) LoadingView* loadingView;

@end

@implementation FeaturedProgramsStoreViewController

@synthesize data          = _data;
@synthesize connection    = _connection;
@synthesize projects      = _projects;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadFeaturedProjects];
    self.navigationItem.title = kUIViewControllerTitleFeaturedPrograms;
    //  CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
    //  self.tableView.contentInset = UIEdgeInsetsMake(navigationBarHeight, 0, 0, 0);
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
    static NSString *CellIdentifier = kImageCell;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        NSLog(@"Should Never happen - since iOS5 Storyboard *always* instantiates our cell!");
        abort();
    }

    if([cell conformsToProtocol:@protocol(CatrobatImageCell)]) {
        CatrobatProject *project = [self.projects objectAtIndex:indexPath.row];
        
        UITableViewCell <CatrobatImageCell>* imageCell = (UITableViewCell <CatrobatImageCell>*)cell;
        imageCell.titleLabel.text = project.projectName;
        
        [self loadImage:project.featuredImage forCell:imageCell atIndexPath:indexPath];
    }
    
    return cell;
}


-(void)loadImage:(NSString*)imageURLString forCell:(UITableViewCell <CatrobatImageCell>*) imageCell atIndexPath:(NSIndexPath*)indexPath
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
    
    
    
    imageCell.iconImageView.contentMode = UIViewContentModeScaleAspectFit;
}


- (void)loadFeaturedProjects
{
    //self.data = [[NSMutableData alloc] init];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kConnectionHost, kConnectionFeatured]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kConnectionTimeout];
    
    //    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    //    self.connection = connection;
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               [self loadIDsWith:data andResponse:response];}];
    
    [self showLoadingView];
}

-(void)loadIDsWith:(NSData*)data andResponse:(NSURLResponse*)response
{
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                    options:NSJSONReadingMutableContainers
                                                      error:&error];
    NSDebug(@"array: %@", jsonObject);
    
    
    if ([jsonObject isKindOfClass:[NSDictionary class]]) {
        NSDictionary *catrobatInformation = [jsonObject valueForKey:@"CatrobatInformation"];
        
        CatrobatInformation *information = [[CatrobatInformation alloc] initWithDict:catrobatInformation];
        
        NSArray *catrobatProjects = [jsonObject valueForKey:@"CatrobatProjects"];
        
        self.projects = [[NSMutableArray alloc] initWithCapacity:[catrobatProjects count]];
        
        for (NSDictionary *projectDict in catrobatProjects) {
            CatrobatProject *project = [[CatrobatProject alloc] initWithDict:projectDict andBaseUrl:information.baseURL];
            [self.projects addObject:project];
        }
    }
    [self update];
    
    for (CatrobatProject* project in self.projects) {
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@?id=%@", kConnectionHost, kConnectionIDQuery,project.projectID]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kConnectionTimeout];
        
        //    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        //    self.connection = connection;
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   [self loadInfosWith:data andResponse:response];}];
    }
    [self showLoadingView];
  
}
-(void)loadInfosWith:(NSData*)data andResponse:(NSURLResponse*)response
{
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
        CatrobatProject *loadedProject;
        NSDictionary *projectDict = [catrobatProjects objectAtIndex:[catrobatProjects count]-1];
        loadedProject = [[CatrobatProject alloc] initWithDict:projectDict andBaseUrl:information.baseURL];
        
        for (CatrobatProject* project in self.projects) {
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
    }
    [self update];
    [self hideLoadingView];
   
}

- (void)showLoadingView
{
    if(!self.loadingView) {
        self.loadingView = [[LoadingView alloc] init];
        [self.view addSubview:self.loadingView];
    }
    [self.loadingView show];
    [self loadingIndicator:YES];
}

- (void) hideLoadingView
{
    [self.loadingView hide];
    [self loadingIndicator:NO];
}

-(void)loadingIndicator:(BOOL)value
{
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = value;
}


#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [TableUtil getHeightForImageCell];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
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
//        NSLog(@"Received data from server");
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
        CatrobatProject *catrobatProject = [self.projects objectAtIndex:selectedRowIndexPath.row];
        ProgramDetailStoreViewController* programDetailViewController = (ProgramDetailStoreViewController*)[segue destinationViewController];
        programDetailViewController.project = catrobatProject;
        
    }
}

#pragma mark - update
- (void)update {
    [self.tableView reloadData];
    [self.searchDisplayController setActive:NO animated:YES];
}


#pragma mark - BackButtonDelegate
-(void)back {
    [self.navigationController popViewControllerAnimated:YES];
}


@end