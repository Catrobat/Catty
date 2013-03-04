//
//  ImageCache.m
//  Catty
//
//  Created by Dominik Ziegler on 3/4/13.
//  Copyright (c) 2013 Graz University of Technology. All rights reserved.
//

#import "ImageCache.h"

@implementation ImageCache

static ImageCache *sharedInstance = nil;


+ (ImageCache *) sharedInstance {
    
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [[ImageCache alloc] init];
        }
    }
    return sharedInstance;
}


- (void)dealloc {
    // Should never be called, but just here for clarity really.
    abort();
}

@end
