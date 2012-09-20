//
//  CreateView.h
//  Catty
//
//  Created by Christof Stromberger on 20.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <Foundation/Foundation.h>


@class CatrobatProject;

@interface CreateView : NSObject

+ (UIView*)createLevelStoreView:(CatrobatProject*)project target:(id)target;
@end
