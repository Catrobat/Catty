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

#import "SearchStoreViewController.h"
#import "CatrobatProgram.h"
#import "CatrobatInformation.h"
#import "NetworkDefines.h"
#import "TableUtil.h"
#import "CellTagDefines.h"
#import "CatrobatImageCell.h"
#import "UIImage+CatrobatUIImageExtensions.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "SegueDefines.h"
#import "ProgramDetailStoreViewController.h"
#import "Util.h"
#import "LanguageTranslationDefines.h"

@interface SearchStoreViewController ()

@property (nonatomic, strong) NSMutableArray *searchResults;
@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSURLSessionDataTask *dataTask;
@property (nonatomic, strong) UILabel *noSearchResultsLabel;
@property (nonatomic, strong) UISearchController* searchController;

@end

@implementation SearchStoreViewController

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
    [super viewDidLoad];
    [self initSearchView];
    [self initTableView];
    [self initNoSearchResultsLabel];
    
    self.searchController = [[UISearchController alloc] init];
    self.searchController.searchBar.backgroundColor = [UIColor backgroundColor];
    [self.searchController setActive:YES ];
    [self.searchBar becomeFirstResponder];
    self.searchController.searchBar.delegate = self;
    self.searchController.searchBar.barTintColor = UIColor.navBarColor;
    self.searchController.searchBar.barStyle = UISearchBarStyleMinimal;
    self.searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x, self.searchController.searchBar.frame.origin.y,[Util screenWidth],self.searchController.searchBar.frame.size.height);
//    self.searchBar.frame = CGRectMake(self.searchBar.frame.origin.x, self.searchBar.frame.origin.y,[Util screenWidth],self.searchBar.frame.size.height);

    self.tableView.backgroundColor = [UIColor backgroundColor];
    self.checkSearch = YES;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = UIColor.globalTintColor;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    [tap setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tap];
    tap.delegate = self;


    self.view.backgroundColor = [UIColor backgroundColor];
// [iOS9] DO NOT REMOVE!!!
//    [[UITextField appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTextColor:[UIColor lightTextTintColor]];
// [iOS9] DO NOT REMOVE!!!
// [iOS8] DO NOT REMOVE!!!
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor textTintColor]];
// [iOS8] DO NOT REMOVE!!!
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.tableView.contentInset = UIEdgeInsetsMake(0., 0., CGRectGetHeight(self.tabBarController.tabBar.frame)+44, 0);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.translucent = YES;
    self.navigationController.navigationBar.translucent =YES;
    //    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchBar.tintColor = [UIColor globalTintColor];
    self.searchBar.translucent = YES;
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self loadingIndicator:NO];
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    ///Hack for translucency
    //    CGRect frame = self.tableView.frame;
    //    frame.origin.y = self.navigationController.navigationBar.frame.size.height;
    //    frame.size.height = (frame.size.height - frame.origin.y);
    //    self.tableView.frame = frame;
    //    self.searchDisplayController.displaysSearchBarInNavigationBar = NO;
    //    self.searchDisplayController.searchBar.frame = CGRectMake(0,65,self.searchDisplayController.searchBar.frame.size.width,self.searchDisplayController.searchBar.frame.size.height);
    //    self.navigationController.navigationBar.translucent = YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer*)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
    ///Hack for translucency
    //    if (!self.checkSearch) {
    //        CGRect frame = self.tableView.frame;
    //        frame.origin.y = 65;
    //        frame.size.height = (frame.size.height - frame.origin.y);
    //        self.tableView.frame = frame;
    //        self.searchDisplayController.displaysSearchBarInNavigationBar = NO;
    //        self.searchDisplayController.searchBar.frame = CGRectMake(0,65,self.searchDisplayController.searchBar.frame.size.width,self.searchDisplayController.searchBar.frame.size.height);
    //        self.checkSearch=YES;
    //        self.navigationController.navigationBar.translucent = YES;
    //
    //    }
    
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
    //return MAX(1, self.searchResults.count);
    return self.searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (self.searchResults.count == 0) {
        static NSString *loadingCellIdentifier = @"loadingCell";
        cell = [tableView dequeueReusableCellWithIdentifier:loadingCellIdentifier forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:loadingCellIdentifier];
            cell.textLabel.textColor = [UIColor buttonTintColor];
            cell.textLabel.text = @"";
        }
    }
    else if([tableView isEqual:self.tableView]) {
        cell = [self cellForProjectsTableView:tableView atIndexPath:indexPath];
    }
    //  else if([tableView isEqual:self.searchDisplayController.searchResultsTableView]) {
    //    cell = [self cellForSearchResultsTableView:tableView atIndexPath:indexPath];
    //  }
    if (! cell) {
        NSError(@"Why?! Should not happen!");
        abort();
    }
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CatrobatProgram *catrobatProject = [self.searchResults objectAtIndex:indexPath.row];
    static NSString *segueToProgramDetail = kSegueToProgramDetail;
    if (! self.editing) {
        if ([self shouldPerformSegueWithIdentifier:segueToProgramDetail sender:catrobatProject]) {
            [self performSegueWithIdentifier:segueToProgramDetail sender:catrobatProject];
        }
    }
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if ([tableView isEqual:self.tableView]) {
        return [TableUtil heightForImageCell];
    }
    return self.tableView.rowHeight;
}



- (void)loadingIndicator:(BOOL)value
{
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = value;
}

#pragma mark - Search display delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if (!searchText) return;
    
    if (searchText.length <= 2) {
        [self resetSearch];
        
    } else {
        if (! [searchText isEqualToString:@""]) {
        [self performSearch];
        }
    }

}

- (void)resetSearch {
        // Update Data Source
    [self.searchResults removeAllObjects];
    
        // Update Table View
    [self update];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar*)searchBar
{
    BOOL smallIPhone = IS_IPHONE4 || IS_IPHONE5;
    if(!smallIPhone)
        self.searchBar.showsCancelButton = YES;
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    BOOL smallIPhone = IS_IPHONE4 || IS_IPHONE5;
    if(!smallIPhone)
        self.searchBar.showsCancelButton = NO;
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self performSearch];
    self.tabBarController.tabBar.translucent = YES;
    [self update];
    [self loadingIndicator:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self update];
    self.searchBar.showsCancelButton = NO;
    [searchBar resignFirstResponder];
}


- (void)initTableView
{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.backgroundColor = [UIColor backgroundColor];
}

- (void)initNoSearchResultsLabel
{
    self.noSearchResultsLabel = [[UILabel alloc] initWithFrame:self.view.frame];
    [self.noSearchResultsLabel setText:kLocalizedNoSearchResults];
    self.noSearchResultsLabel.textAlignment = NSTextAlignmentCenter;
    self.noSearchResultsLabel.textColor = [UIColor globalTintColor];
    self.noSearchResultsLabel.tintColor = [UIColor globalTintColor];
    self.noSearchResultsLabel.hidden = YES;
    [self.view addSubview:self.noSearchResultsLabel];
}

- (void)initSearchView
{
    self.searchResults = [[NSMutableArray alloc] init];
    for (UIView *subView in self.searchBar.subviews) {
        if([subView isKindOfClass: [UITextField class]]) {
            [(UITextField *)subView setKeyboardAppearance: UIKeyboardAppearanceAlert];
        }
    }
}

-(void)dismissKeyboard {
    [self.searchBar resignFirstResponder];
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self.searchController setActive:NO];
    [self update];
    if ([[segue identifier] isEqualToString:kSegueToProgramDetail]) {
        if ([sender isKindOfClass:[CatrobatProgram class]]) {
            ProgramDetailStoreViewController* programDetailViewController = (ProgramDetailStoreViewController*)[segue destinationViewController];
            programDetailViewController.project = sender;
            programDetailViewController.searchStoreController = self;
        }
    }
}

#pragma mark - Helper


- (void)performSearch {
    NSString *searchString = self.searchBar.text;
    
    if (self.dataTask) {
        [self.dataTask cancel];
    }
    NSString *queryString = [NSString stringWithFormat:@"%@/%@?q=%@&%@%i&%@%i", kConnectionHost, kConnectionSearch, [searchString stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet], kProgramsLimit, kSearchStoreMaxResults, kProgramsOffset, 0];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:queryString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kConnectionTimeout];
    
    self.dataTask = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            if ([Util isNetworkError:error]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Util defaultAlertForNetworkError];
                });
            }
        } else {
            NSMutableArray *results;
            id jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                            options:NSJSONReadingMutableContainers
                                                              error:&error];
            
            NSDebug(@"array: %@", jsonObject);
            
            if ([jsonObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *catrobatInformation = [jsonObject valueForKey:@"CatrobatInformation"];
                
                CatrobatInformation *information = [[CatrobatInformation alloc] initWithDict:catrobatInformation];
                
                NSArray *catrobatProjects = [jsonObject valueForKey:@"CatrobatProjects"];
                
                results = [[NSMutableArray alloc] initWithCapacity:[catrobatProjects count]];
                
                for (NSDictionary *projectDict in catrobatProjects) {
                    CatrobatProgram *project = [[CatrobatProgram alloc] initWithDict:projectDict andBaseUrl:information.baseURL];
                    [results addObject:project];
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (results) {
                    [self processResults:results];
                }
            });
        }
    }];
    
    if (self.dataTask) {
        [self.dataTask resume];
    }
}

- (NSURL *)urlForQuery:(NSString *)query {
    NSString *queryString = [NSString stringWithFormat:@"%@/%@?q=%@&%@%i&%@%i", kConnectionHost, kConnectionSearch, [query stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet], kProgramsLimit, kSearchStoreMaxResults, kProgramsOffset, 0];
    NSDebug(@"Query string: %@", queryString);
    return [NSURL URLWithString:queryString];
}

- (void)processResults:(NSArray *)results {
    if (!self.searchResults) {
        self.searchResults = [NSMutableArray array];
    }
    
        // Update Data Source
    [self.searchResults removeAllObjects];
    [self.searchResults addObjectsFromArray:results];
    
        // Update Table View
    [self update];
}

- (void)update
{
    self.noSearchResultsLabel.hidden = [self.searchResults count] == 0 ? NO : YES;
    [self.tableView reloadData];
}

- (UITableViewCell*)cellForProjectsTableView:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath
{
    static NSString *CellIdentifier = kImageCell;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    if (!cell) {
        NSError(@"Should Never happen - since iOS5 Storyboard *always* instantiates our cell!");
        abort();
    }

    if ([cell conformsToProtocol:@protocol(CatrobatImageCell)]) {
        CatrobatProgram *project = [self.searchResults objectAtIndex:indexPath.row];
        
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

@end
