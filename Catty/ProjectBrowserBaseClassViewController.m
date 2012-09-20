//
//  ProjectBrowserBaseClassViewController.m
//  Catty
//
//  Created by Christof Stromberger on 20.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "ProjectBrowserBaseClassViewController.h"

@interface ProjectBrowserBaseClassViewController ()

@end

@implementation ProjectBrowserBaseClassViewController

@synthesize scrollView           = _scrollView;
@synthesize pageControl          = _pageControl;
@synthesize pageNavigationOutlet = _pageNavigationOutlet;
@synthesize pages                = _pages;

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
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)dealloc {
    [self setScrollView:nil];
    [self setPageControl:nil];
    [self setPageNavigationOutlet:nil];
    [self setPages:nil];
}

- (void)didReceiveMemoryWarning
{ [super didReceiveMemoryWarning]; }



#pragma mark - scroll view delegate
- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
    
    self.pageNavigationOutlet.text = [NSString stringWithFormat:@"%d of %d", page+1, self.pageControl.numberOfPages];
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


@end
