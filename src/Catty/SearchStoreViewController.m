/**
 *  Copyright (C) 2010-2014 The Catrobat Team
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
#import "CatrobatProject.h"
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
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) UILabel *noSearchResultsLabel;

@end

@implementation SearchStoreViewController

- (id)init
{
  self = [super init];
  if (self) {
  }
  return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initSearchView];
    [self initTableView];
    [self initNoSearchResultsLabel];

    self.searchDisplayController.displaysSearchBarInNavigationBar = NO;
    self.searchDisplayController.searchBar.backgroundColor = [UIColor darkBlueColor];
    self.tableView.backgroundColor = [UIColor darkBlueColor];
    [self.searchDisplayController setActive:YES animated:YES];
    [self.searchDisplayController.searchBar becomeFirstResponder];
    self.searchDisplayController.searchBar.delegate = self;
    self.checkSearch = YES;
    self.searchDisplayController.searchBar.barTintColor = UIColor.navBarColor;
    self.searchDisplayController.searchBar.barStyle = UISearchBarStyleMinimal;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = UIColor.skyBlueColor;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    [self.searchBar becomeFirstResponder];
    self.view.backgroundColor = [UIColor darkBlueColor];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor lightOrangeColor]];
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
    self.searchBar.tintColor = [UIColor lightOrangeColor];
    self.searchBar.translucent = YES;

}

- (void)viewWillDisappear:(BOOL)animated
{
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
      cell.textLabel.textColor = [UIColor blueGrayColor];
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
    NSLog(@"Why?! Should not happen!");
    abort();
  }
  return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CatrobatProject *catrobatProject = [self.searchResults objectAtIndex:indexPath.row];
    static NSString *segueToProgramDetail = kSegueToProgramDetail;
    if (! self.editing) {
        if ([self shouldPerformSegueWithIdentifier:segueToProgramDetail sender:catrobatProject]) {
            [self performSegueWithIdentifier:segueToProgramDetail sender:catrobatProject];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  if([tableView isEqual:self.tableView]) {
    return [TableUtil getHeightForImageCell];
  }
  return self.tableView.rowHeight;
}

#pragma mark - NSURLConnection Delegates
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
  if (self.connection == connection) {
    [self.data appendData:data];
  }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
  if (self.connection == connection) {
    NSDebug(@"Finished");

    self.searchResults = nil;
    self.searchResults = [[NSMutableArray alloc] init];

    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:self.data
                                                    options:NSJSONReadingMutableContainers
                                                      error:&error];

    NSDebug(@"array: %@", jsonObject);

    if ([jsonObject isKindOfClass:[NSDictionary class]]) {
      NSDictionary *catrobatInformation = [jsonObject valueForKey:@"CatrobatInformation"];
      
      CatrobatInformation *information = [[CatrobatInformation alloc] initWithDict:catrobatInformation];
      
      NSArray *catrobatProjects = [jsonObject valueForKey:@"CatrobatProjects"];
      
      self.searchResults = [[NSMutableArray alloc] initWithCapacity:[catrobatProjects count]];
      
      for (NSDictionary *projectDict in catrobatProjects) {
        CatrobatProject *project = [[CatrobatProject alloc] initWithDict:projectDict andBaseUrl:information.baseURL];
        [self.searchResults addObject:project];
      }
    }
    self.data = nil;
    self.connection = nil;
    [self update];
    [self loadingIndicator:NO];
  }
}

-(void)loadingIndicator:(BOOL)value
{
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = value;
}

#pragma mark - Search display delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if (! [searchText isEqualToString:@""]) {
        [self performSelector:@selector(queryServerForSearchString:) withObject:searchText afterDelay:0.2];
    }
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar*)searchBar
{
    self.searchBar.showsCancelButton = YES;
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    self.searchBar.showsCancelButton = NO;
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self queryServerForSearchString:searchBar.text];
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
    self.tableView.backgroundColor = [UIColor darkBlueColor];
}

- (void)initNoSearchResultsLabel
{
    self.noSearchResultsLabel = [[UILabel alloc] init];
    self.noSearchResultsLabel.text = kLocalizedNoSearchResults;
    self.noSearchResultsLabel.textAlignment = NSTextAlignmentCenter;
    self.noSearchResultsLabel.textColor = [UIColor lightOrangeColor];
    self.noSearchResultsLabel.tintColor = [UIColor lightOrangeColor];
    self.noSearchResultsLabel.frame = self.view.frame;
    self.noSearchResultsLabel.hidden = YES;
    [self.view addSubview:self.noSearchResultsLabel];
}

-(void)initSearchView
{
  self.searchResults = [[NSMutableArray alloc] init];

  for (UIView *subView in self.searchDisplayController.searchBar.subviews) {
    if([subView isKindOfClass: [UITextField class]]) {
      [(UITextField *)subView setKeyboardAppearance: UIKeyboardAppearanceAlert];
    }
  }

}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  [self.searchDisplayController setActive:NO animated:YES];
  [self update];
  if([[segue identifier] isEqualToString:kSegueToProgramDetail]) {
    if([sender isKindOfClass:[CatrobatProject class]]) {
      ProgramDetailStoreViewController* programDetailViewController = (ProgramDetailStoreViewController*)[segue destinationViewController];
      programDetailViewController.project = sender;
        programDetailViewController.searchStoreController = self;
    }
  }
}

#pragma mark - Helper
-(void)queryServerForSearchString:(NSString*)searchString
{
  NSDebug(@"Begin custom query to server");
  // reset data
  self.data = nil; // cleanup
  self.data = [[NSMutableData alloc] init];
  
  NSString *queryString = [NSString stringWithFormat:@"%@/%@?offset=0&query=%@", kConnectionHost, kConnectionSearch, searchString];
  NSDebug(@"Query string: %@", queryString);
  
  NSURL *url = [NSURL URLWithString:queryString];
  
  NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kConnectionTimeout];
  
  NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
  self.connection = connection;
  
  NSDebug(@"Finished custom query to server");
}

- (void)update
{
//  [self.searchDisplayController.searchResultsTableView reloadData];
    
    self.noSearchResultsLabel.hidden = [self.searchResults count] == 0 ? NO : YES;
    [self.tableView reloadData];
}

- (UITableViewCell*)cellForProjectsTableView:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath
{
  static NSString *CellIdentifier = kImageCell;
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

  if (!cell) {
    NSLog(@"Should Never happen - since iOS5 Storyboard *always* instantiates our cell!");
    abort();
  }

  if ([cell conformsToProtocol:@protocol(CatrobatImageCell)]) {
    CatrobatProject *project = [self.searchResults objectAtIndex:indexPath.row];
    
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
