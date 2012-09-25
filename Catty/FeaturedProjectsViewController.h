//
//  FeaturedProjectsViewController.h
//  Catty
//
//  Created by Christof Stromberger on 24.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProjectBrowserBaseClassViewController.h"

@interface FeaturedProjectsViewController : ProjectBrowserBaseClassViewController <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewOutlet;
@property (weak, nonatomic) IBOutlet UILabel *labelOutlet;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControlOutlet;

@end
