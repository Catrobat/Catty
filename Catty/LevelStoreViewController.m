//
//  LevelStoreViewController.m
//  Catty
//
//  Created by Christof Stromberger on 25.02.13.
//  Copyright (c) 2013 Graz University of Technology. All rights reserved.
//

#import "LevelStoreViewController.h"
#import "CatrobatInformation.h"
#import "CatrobatProject.h"
#import "CattyAppDelegate.h"
#import "Util.h"
#import "TableUtil.h"
#import "CellTags.h"
#import "CatrobatImageCell.h"

#define kConnectionTimeout 30
#define kConnectionHost @"http://catroid.org/api/projects"

@interface LevelStoreViewController ()

@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableArray *projects;

// search controller
@property (nonatomic, strong) NSMutableArray *searchResults;

@end

@implementation LevelStoreViewController

@synthesize data          = _data;
@synthesize connection    = _connection;
@synthesize projects      = _projects;
@synthesize searchResults = _searchResults;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.data = [[NSMutableData alloc] init];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/recent.json", kConnectionHost]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kConnectionTimeout];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    self.connection = connection;
    
    // search display controller
    self.searchDisplayController.delegate = self;
    self.tableView.delegate = self;
    
    self.searchResults = [[NSMutableArray alloc] init];
    
    [TableUtil initNavigationItem:self.navigationItem withTitle:@"Downloads" enableBackButton:YES target:self];
    
    [self initTableView];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return self.searchResults.count + 1;
    }
    else {
        return self.projects.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell* cell = nil;
    if([tableView isEqual:self.searchDisplayController.searchResultsTableView]) {
        cell = [self cellForSearchResultsTableView:tableView atIndexPath:indexPath];
    } else {
        cell = [self cellForProjectsTableView:tableView atIndexPath:indexPath];
    }
    
    return cell;
}


#pragma marks init
-(void)initTableView
{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"darkblue"]];
}




#pragma mark - Helper

-(UITableViewCell*)cellForProjectsTableView:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath {
    
    
    static NSString *CellIdentifier = kImageCell;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        NSLog(@"Should Never happen - since iOS5 Storyboard *always* instantiates our cell!");
//        abort();
    }
    

    if([cell conformsToProtocol:@protocol(CatrobatImageCell)]) {
        CatrobatProject *project = [self.projects objectAtIndex:indexPath.row];
        
        UITableViewCell <CatrobatImageCell>* imageCell = (UITableViewCell <CatrobatImageCell>*)cell;
        imageCell.titleLabel.text = project.projectName;
        
        [self loadImage:project.screenshotSmall forCell:imageCell atIndexPath:indexPath];
    }
    
  
    return cell;
}



-(UITableViewCell*)cellForSearchResultsTableView:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath {
    CatrobatProject *project = nil;
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.row == self.searchResults.count) {
        cell.textLabel.text = @"SEARCH ON SERVER...";
        return cell; // todo...
    }
    else {
        project = [self.searchResults objectAtIndex:indexPath.row];
    }

    return cell;
}


-(void)loadImage:(NSString*)imageURL forCell:(UITableViewCell <CatrobatImageCell>*) imageCell atIndexPath:(NSIndexPath*)indexPath
{
//    imageCell.imageView.image = [UIImage imageNamed:@"programs"];
#warning one should save the images so they do not have to be downloaded again! - This way the UI is very laggy!
    
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(concurrentQueue, ^{
        NSData *image = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:imageURL]];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(image) {
                imageCell.imageView.image = [UIImage imageWithData:image];
            } else {
                imageCell.imageView.image = [UIImage imageNamed:@"programs"];
            }
//            [self.tableView beginUpdates];
//            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
//            [self.tableView endUpdates];
            
        });
    });
}



#pragma mark - Table view delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [TableUtil getHeightForImageCell];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView) { // SEARCH DISPLAY TABLE VIEW
        if (indexPath.row == self.searchResults.count) { // = SEARCH ON SERVER row
            // reload results from server
            // ACTUALLY: BUSY WAIT! not so good...
            
            // -------
            NSLog(@"Begin custom query to server");
            // reset data
            self.data = nil; // cleanup
            self.data = [[NSMutableData alloc] init];

            NSString *queryString = [NSString stringWithFormat:@"%@/search.json?offset=0&query=%@", kConnectionHost, self.searchDisplayController.searchBar.text];
            NSLog(@"   Query string: %@", queryString);
            NSURL *url = [NSURL URLWithString:queryString];
            
            NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kConnectionTimeout];
            
            NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            self.connection = connection;
            
            NSLog(@"Finished custom query to server");
            // -------
            //[self searchDisplayController:self.searchDisplayController shouldReloadTableForSearchString:self.searchDisplayController.searchBar.text];
        }
        else {
            CatrobatProject *level = [self.projects objectAtIndex:indexPath.row];
            
            CattyAppDelegate *appDelegate = (CattyAppDelegate*)[[UIApplication sharedApplication] delegate];
            NSURL *url = [NSURL URLWithString:level.downloadUrl];
            [appDelegate.fileManager downloadFileFromURL:url withName:level.projectName];
            appDelegate.fileManager.delegate = self;
            
            [Util alertWithText:@"Catty is downloading your level. You can open it in the 'Play' section"];
        }
    }
    else { // REGULAR TABLE VIEW
        //downloading level from server (downloadURL)
        CatrobatProject *level = [self.projects objectAtIndex:indexPath.row];
        
        CattyAppDelegate *appDelegate = (CattyAppDelegate*)[[UIApplication sharedApplication] delegate];
        NSURL *url = [NSURL URLWithString:level.downloadUrl];
        [appDelegate.fileManager downloadFileFromURL:url withName:level.projectName];
        appDelegate.fileManager.delegate = self;
        
        [Util alertWithText:@"Catty is downloading your level. You can open it in the 'Play' section"];
    }

    // deselect current row
    // change this in future when the detail view is implement !!!
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - NSURLConnection Delegates
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (self.connection == connection) {
        NSLog(@"Received data from server");
        [self.data appendData:data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (self.connection == connection) {
        NSLog(@"Finished");
        self.searchResults = nil;
        self.searchResults = [[NSMutableArray alloc] init];
        
        //deserializing json
        NSError *error = nil;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:self.data
                                                        options:NSJSONReadingMutableContainers
                                                          error:&error];
        
        
        //debug
        NSLog(@"array: %@", jsonObject);
        
        
        if ([jsonObject isKindOfClass:[NSArray class]]) {
            NSLog(@"array");
        }
        else if ([jsonObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *catrobatInformation = [jsonObject valueForKey:@"CatrobatInformation"];
            
            CatrobatInformation *information = [[CatrobatInformation alloc] initWithDict:catrobatInformation];
            NSLog(@"api version: %@", information.apiVersion);
            
            NSArray *catrobatProjects = [jsonObject valueForKey:@"CatrobatProjects"];
            
            self.projects = [[NSMutableArray alloc] initWithCapacity:[catrobatProjects count]];
            
            for (NSDictionary *projectDict in catrobatProjects) {
                CatrobatProject *project = [[CatrobatProject alloc] initWithDict:projectDict];
                [self.projects addObject:project];
            }
        }
        
        //freeing space
        self.data = nil;
        self.connection = nil;
        

        [self update];
    }
}


#pragma mark - update
- (void)update {
    [self.tableView reloadData];
    [self.searchDisplayController setActive:NO animated:YES];
}

#pragma mark - UISearchDisplayController Delegate Methods
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
	NSLog(@"Previous Search Results were removed.");
	[self.searchResults removeAllObjects];
    
    for (CatrobatProject *project in self.projects) {
        if ([project.projectName isEqualToString:scope] || [scope isEqualToString:@"All"])
        {
            NSComparisonResult result = [project.projectName compare:searchText
                                                             options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)
                                                               range:NSMakeRange(0, [searchText length])];
            
            if (result == NSOrderedSame) {
                [self.searchResults addObject:project];
            }
        }
    }
    
    NSLog(@"New results: %d", self.searchResults.count);
    
}



- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:@"All"];
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:@"All"];
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.tableView reloadData];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    //CustomSearchbar *sBar = (CustomSearchbar *)searchBar;
    //[sBar setShowsCancelButton:YES];
    //[sBar setCloseButtonTitle:@"Done" forState:UIControlStateNormal];
}

#pragma mark - BackButtonDelegate
-(void)back {
    [self.navigationController popViewControllerAnimated:YES];
}


@end
