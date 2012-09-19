//
//  RecentProjectsViewController.h
//  Catty
//
//  Created by Christof Stromberger on 18.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TIMEOUT 30.0f

@interface RecentProjectsViewController : UIViewController <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@end
