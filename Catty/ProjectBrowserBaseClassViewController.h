//
//  ProjectBrowserBaseClassViewController.h
//  Catty
//
//  Created by Christof Stromberger on 20.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProjectBrowserBaseClassViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UILabel *pageNavigationOutlet;

@property (nonatomic, strong) NSMutableArray *pages;

- (void)initialized;

@end
