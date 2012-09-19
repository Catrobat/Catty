//
//  RecentProjectsViewController.m
//  Catty
//
//  Created by Christof Stromberger on 18.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "RecentProjectsViewController.h"

@interface RecentProjectsViewController ()

@property (nonatomic, strong) NSMutableArray *pages;

@end

@implementation RecentProjectsViewController

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
    
    //delegates
    self.scrollView.delegate = self;
    
    //init page array
    self.pages = [[NSMutableArray alloc] init];

    //creating new view for page
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor redColor];
    
    //add item
    [self.pages addObject:view];
    
    
    view = [[UIView alloc] init];
    view.backgroundColor = [UIColor greenColor];
    [self.pages addObject:view];

    view = [[UIView alloc] init];
    view.backgroundColor = [UIColor blueColor];
    [self.pages addObject:view];
    
    view = [[UIView alloc] init];
    view.backgroundColor = [UIColor yellowColor];
    [self.pages addObject:view];
    
    view = [[UIView alloc] init];
    view.backgroundColor = [UIColor orangeColor];
    [self.pages addObject:view];
    
    
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
        frame.origin.x = 25 + self.scrollView.frame.size.width * counter++;
        frame.origin.y = 15;
        frame.size.height = 350.0;
        frame.size.width = 270.0;
        
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



@end
