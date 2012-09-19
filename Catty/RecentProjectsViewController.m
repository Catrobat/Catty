//
//  RecentProjectsViewController.m
//  Catty
//
//  Created by Christof Stromberger on 18.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "RecentProjectsViewController.h"
#import "Util.h"
#import "CatrobatInformation.h"
#import "CatrobatProject.h"


@interface RecentProjectsViewController ()

@property (nonatomic, strong) NSMutableArray *pages;

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) NSMutableArray *projects;
@property (nonatomic, strong) UIActivityIndicatorView *activity;

@end

@implementation RecentProjectsViewController

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
    
    //background image
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"background"]];
    self.view.backgroundColor = background;
    
    
    
    //allocating data
    self.data = [[NSMutableData alloc] init];
    
    //setting up request url
    NSURL *url = [NSURL URLWithString:@"http://catroidtest.ist.tugraz.at/api/projects/recent.json"];
    
    //creating url request
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:TIMEOUT];
    
    //creating connection
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    self.connection = connection;
    
    
    
    
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
    
//    
//    view = [[UIView alloc] init];
//    view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"container"]];
//    [self.pages addObject:view];
//
//    view = [[UIView alloc] init];
//    view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"container"]];
//    [self.pages addObject:view];
//    
//    view = [[UIView alloc] init];
//    view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"container"]];
//    [self.pages addObject:view];
//    
//    view = [[UIView alloc] init];
//    view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"container"]];
//    [self.pages addObject:view];
//    
    
    //initiliaze page control
    [self initialized];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setScrollView:nil];
    [self setPageControl:nil];
    [super viewDidUnload];
}


#pragma mark - PageControl methods
- (void)initialized {
    NSInteger counter = 0;
    for (UIView *view in self.pages ) {
        CGRect frame;
        frame.origin.x = 35 + self.scrollView.frame.size.width * counter++;
        frame.origin.y = 15;
        frame.size.height = 330.0;
        frame.size.width = 250.0;
        
//        UIImageView *imageview = [[UIImageView alloc] initWithFrame:frame];
//        imageview.image = image;
        
        view.frame = frame;
        
        [self.scrollView addSubview:view];
    }
    
//    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * self.pages.count, self.scrollView.frame.size.height);

    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * self.pages.count, 380);

    
    self.pageControl.numberOfPages = self.pages.count;

}

#pragma mark - scroll view delegate
- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
}

#pragma mark - Visualization methods
- (void)update {
    
    UIView *loadingView = [self.pages objectAtIndex:0];
    loadingView.hidden = YES;
    loadingView = nil;
    
    [self.pages removeAllObjects];
    
    for (CatrobatProject *project in self.projects) {
        UIView *view = [self createView:project];
        [self.pages addObject:view];
    }
    
    [self initialized];
    [self.scrollView setNeedsLayout];
}

- (UIView*)createView:(CatrobatProject*)project {
    //creating new view for page
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"container"]];
    
    
    //adding project name
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 10, 150, 30)];
    nameLabel.text = project.projectName;
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.font = [UIFont boldSystemFontOfSize:16];
    nameLabel.textColor = [UIColor colorWithRed:61.0/255.0 green:61.0/255.0 blue:61.0/255.0 alpha:1.0];
    nameLabel.layer.shadowColor = [[UIColor whiteColor] CGColor];
    nameLabel.layer.shadowOffset = CGSizeMake(0.0, 0.0);

    //just 4 debug
    nameLabel.layer.borderColor = [UIColor greenColor].CGColor;
    nameLabel.layer.borderWidth = 1.0;
    
    [view addSubview:nameLabel];
    
    return view;
}


#pragma mark - NSURLConnection Delegates
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (self.connection == connection)
    {
        NSLog(@"Received data from server");
        [self.data appendData:data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (self.connection == connection)
    {
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




@end
