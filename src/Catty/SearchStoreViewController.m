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

@interface SearchStoreViewController ()

@property (nonatomic, strong) NSMutableArray *searchResults;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) NSURLConnection *connection;

@end

@implementation SearchStoreViewController

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
  
    [self initTableView];
    [self initSearchView];
    
    self.searchDisplayController.displaysSearchBarInNavigationBar = NO;
    self.searchDisplayController.searchBar.backgroundColor = [UIColor darkBlueColor];
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageWithColor:[UIColor darkBlueColor]]];
    [self.searchDisplayController setActive:YES animated:YES];
    [self.searchDisplayController.searchBar becomeFirstResponder];
    self.searchDisplayController.searchBar.delegate = self;
    self.searchDisplayController.searchBar.frame = CGRectMake(0,44,self.searchDisplayController.searchBar.frame.size.width,self.searchDisplayController.searchBar.frame.size.height);
    self.checkSearch = YES;
    self.searchDisplayController.searchBar.barTintColor = [UIColor darkBlueColor];
    self.searchDisplayController.searchBar.barStyle = UISearchBarStyleMinimal;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.translucent = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    CGRect frame = self.tableView.frame;
    frame.origin.y = 44;
    frame.size.height = (frame.size.height - frame.origin.y);
    self.tableView.frame = frame;
    self.searchDisplayController.displaysSearchBarInNavigationBar = NO;
    self.searchDisplayController.searchBar.frame = CGRectMake(0,44,self.searchDisplayController.searchBar.frame.size.width,self.searchDisplayController.searchBar.frame.size.height);
    self.navigationController.navigationBar.translucent = YES;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
//    float checkPoint = 44;
//    float currentViewBottomEdge = scrollView.contentOffset.y+44;
    if (!self.checkSearch) {
        CGRect frame = self.tableView.frame;
        frame.origin.y = 44;
        frame.size.height = (frame.size.height - frame.origin.y);
        self.tableView.frame = frame;
        self.searchDisplayController.displaysSearchBarInNavigationBar = NO;
        self.searchDisplayController.searchBar.frame = CGRectMake(0,44,self.searchDisplayController.searchBar.frame.size.width,self.searchDisplayController.searchBar.frame.size.height);
        self.checkSearch=YES;
        self.navigationController.navigationBar.translucent = YES;
        
    }
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
    cell = [tableView dequeueReusableCellWithIdentifier:loadingCellIdentifier];
    if (cell == nil) {
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:loadingCellIdentifier];
      cell.textLabel.textColor = [UIColor blueGrayColor];
      cell.textLabel.text = @"";
    }
  }
  else if([tableView isEqual:self.tableView]) {
    cell = [self cellForProjectsTableView:tableView atIndexPath:indexPath];
  }
  else if([tableView isEqual:self.searchDisplayController.searchResultsTableView]) {
    cell = [self cellForSearchResultsTableView:tableView atIndexPath:indexPath];
  }
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
  [self performSegueWithIdentifier:kSegueToProgramDetail sender:catrobatProject];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
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
  }
}

#pragma mark - Init
- (void)initTableView
{
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
  self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"darkblue"]];
}

#pragma mark - Search display delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
  [NSObject cancelPreviousPerformRequestsWithTarget:self];
  if(![searchText isEqualToString:@""]) {
    [self performSelector:@selector(queryServerForSearchString:) withObject:searchText afterDelay:0.2];
  }
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
//    CGRect frame = self.tableView.frame;
//    frame.origin.y = self.navigationController.navigationBar.frame.size.height;
//    frame.size.height = (frame.size.height - frame.origin.y);
//    self.tableView.frame = frame;
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSDebug(@"%@", searchBar.text);
    [self queryServerForSearchString:searchBar.text];
    [self.searchDisplayController setActive:NO animated:YES];
    [self update];
    self.searchDisplayController.searchBar.text = searchBar.text;
    self.tabBarController.tabBar.translucent = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
  [self update];
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
  [controller.searchResultsTableView setDelegate:self];
  UIImageView *anImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"darkblue"]];
  controller.searchResultsTableView.backgroundView = anImage;
  controller.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  controller.searchResultsTableView.backgroundColor = [UIColor clearColor];
    
  
}

-(void)initSearchView
{
  self.searchResults = [[NSMutableArray alloc] init];
  self.searchDisplayController.searchBar.clipsToBounds = YES;
  self.searchDisplayController.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
  //self.searchDisplayController.searchBar.translucent = YES;

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
  [self.searchDisplayController.searchResultsTableView reloadData];
  [self.tableView reloadData];
}

- (UITableViewCell*)cellForProjectsTableView:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath
{
  static NSString *CellIdentifier = kImageCell;
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

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

-(UITableViewCell*)cellForSearchResultsTableView:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath
{
  static NSString *searchCellIdentifier = kSearchCell;
  UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:searchCellIdentifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:searchCellIdentifier];
    cell.textLabel.textColor = [UIColor blueGrayColor];
    cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"darkblue"]];
  }

  CatrobatProject *project = [self.searchResults objectAtIndex:indexPath.row];
  cell.textLabel.text = project.projectName;
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
}

@end
