//
//  FeaturedProjectsViewController.m
//  Catty
//
//  Created by Christof Stromberger on 24.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "FeaturedProjectsViewController.h"
#import "CatrobatInformation.h"
#import "CatrobatProject.h"
#import "Util.h"
#import "CreateView.h"
#import "CattyAppDelegate.h"
#import "StageViewController.h"
#import "LevelLoadingInfo.h"

#define SEGUE_TO_STAGE @"SEGUE_QUICK_TO_STAGE"

@interface FeaturedProjectsViewController ()

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) NSMutableArray *projects;
@property (nonatomic, strong) UIActivityIndicatorView *activity;

@end

@implementation FeaturedProjectsViewController

@synthesize connection = _connection;
@synthesize data       = _data;
@synthesize projects   = _projects;
@synthesize activity   = _activity;


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

    
    
    self.scrollView = self.scrollViewOutlet;
    self.pageNavigationOutlet = self.labelOutlet;
    self.pageControl = self.pageControlOutlet;
    
    //allocating data
    self.data = [[NSMutableData alloc] init];
    
    //setting up request url
    NSURL *url = [NSURL URLWithString:@"http://catroidtest.ist.tugraz.at/api/projects/search.json?offset=0&query=aquarium%20georg%20tally%20hear%20default"];
    
    //creating url request
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:TIMEOUT];
    
    //creating connection
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    self.connection = connection;
    
    
    
    //hiding page control
    self.pageControl.hidden = YES;
    
    
    //delegates
    self.scrollView.delegate = self;
    
    //init page array
    self.pages = [[NSMutableArray alloc] init];
    
    //creating new view for page
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"container"]];
    
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(113, 154, 25, 25)];
    activity.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    self.activity = activity;
    [activity startAnimating];
    
    [view addSubview:activity];
    
    //add item
    [self.pages addObject:view];
    
    //initiliaze page control
    [self initialized];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Visualization methods
- (void)update {
    
    UIView *loadingView = [self.pages objectAtIndex:0];
    loadingView.hidden = YES;
    loadingView = nil;
    
    [self.activity stopAnimating];
    self.activity = nil;
    
    [self.pages removeAllObjects];
    
    NSInteger index = 0;
    for (CatrobatProject *project in self.projects) {
        UIView *view = [self createView:project];
        view.tag = index++;
        [self.pages addObject:view];
    }
    
    self.pageNavigationOutlet.text = [NSString stringWithFormat:@"%d of %d", self.pageControl.currentPage+1, [self.pages count]];
    
    [self initialized];
    [self.scrollView setNeedsLayout];
}

- (UIView*)createView:(CatrobatProject*)project {
    
    
    
    
    return [CreateView createLevelStoreView:project target:self];
}


//download button has been clicked
- (void)buttonClicked:(UIButton*)button {
    
    //abort if we are currently downloading an item
    if (self.activity.isAnimating) {
        [Util alertWithText:@"You are currently downloading a level! You cannot download two at the same time"];
        return;
    }
    
    //checking if its a play button or a download button
    if (button.tag == 502) { //play button
        [self performSegueWithIdentifier:SEGUE_TO_STAGE sender:[self.projects objectAtIndex:button.superview.tag]];
        
        //abort
        return;
    }
    
    //test
    button.hidden = YES;
    
    UIView *superView = button.superview;
    UIButton *playButton = (UIButton*)[superView viewWithTag:502];
    playButton.hidden = NO;
    UIActivityIndicatorView *activity = (UIActivityIndicatorView*)[playButton viewWithTag:601];
    [activity startAnimating];
    self.activity = activity;
    
    
    //downloading level from server (downloadURL)
    CatrobatProject *level = [self.projects objectAtIndex:superView.tag];
    
    CattyAppDelegate *appDelegate = (CattyAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSURL *url = [NSURL URLWithString:level.downloadUrl];
    [appDelegate.fileManager downloadFileFromURL:url withName:level.projectName];
    appDelegate.fileManager.delegate = self;
    
    //[Util alertWithText:@"Catty is downloading your level. You can play it in the 'Play' section"];
}

- (void)downloadFinished {
    [self.activity stopAnimating];
}


#pragma mark - NSURLConnection Delegates
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (self.connection == connection) {
        NSLog(@"Received data from server");
        [self.data appendData:data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (self.connection == connection) {
        NSLog(@"Finished");
        
        //building up json string from data bytes
        //NSString *jsonString = [NSString stringWithUTF8String:[self.data bytes]];
        
        //deserializing json
        NSError *error = nil;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:self.data
                                                        options:NSJSONReadingMutableContainers
                                                          error:&error];
        //error handling
        [Util log:error];
        
        
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
            
            //allocating projects array
            self.projects = [[NSMutableArray alloc] initWithCapacity:[catrobatProjects count]];
            
            for (NSDictionary *projectDict in catrobatProjects) {
                CatrobatProject *project = [[CatrobatProject alloc] initWithDict:projectDict];
                [self.projects addObject:project];
            }
        }
        
        //freeing space
        self.data = nil;
        self.connection = nil;
        
        //reloading view
        [self update];
    }
}


- (void)viewDidUnload {
    [self setScrollViewOutlet:nil];
    [self setLabelOutlet:nil];
    [self setPageControlOutlet:nil];
    [super viewDidUnload];
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:SEGUE_TO_STAGE]) {
        if ([segue.destinationViewController isKindOfClass:[StageViewController class]]){
            StageViewController *destination = (StageViewController*)segue.destinationViewController;
            
            CatrobatProject *level = nil;
            //retrieving catrobat project info
            if ([sender isKindOfClass:[CatrobatProject class]]) {
                level = (CatrobatProject*)sender;
            }
            assert(level); //should not happen...
            
            
            //creating new level loading info
            LevelLoadingInfo *loadingInfo = [[LevelLoadingInfo alloc] init];
            loadingInfo.visibleName = level.projectName;
            
            //retrieving app delegate
            CattyAppDelegate *appDelegate = (CattyAppDelegate*)[[UIApplication sharedApplication] delegate];
            loadingInfo.basePath = [NSString stringWithFormat:@"%@/", [appDelegate.fileManager getPathForLevel:level.projectName]];
            assert(loadingInfo.basePath);
            
            destination.levelLoadingInfo = loadingInfo;
            
        }
    }
}
@end
