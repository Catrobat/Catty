//
//  RecentProjectsViewController.h
//  Catty
//
//  Created by Christof Stromberger on 18.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProjectBrowserBaseClassViewController.h"

#define TIMEOUT 30.0f

@interface RecentProjectsViewController : ProjectBrowserBaseClassViewController <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *labelOutel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewOutlet;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControlOutlet;


@end
