//
//  ImageCache.m
//  Catty
//
//  Created by Dominik Ziegler on 3/4/13.
//  Copyright (c) 2013 Graz University of Technology. All rights reserved.
//

#import "ImageCache.h"

@interface ImageCache()

@property (nonatomic, strong) NSCache *imageCache;

@end

@implementation ImageCache



static ImageCache *sharedImageCache = nil;


+ (ImageCache *) sharedImageCache {
    
    @synchronized(self) {
        if (sharedImageCache == nil) {
            sharedImageCache = [[ImageCache alloc] init];
        }
    }
    return sharedImageCache;
}

-(id)init
{
    self = [super init];
    if (self) {
        self.imageCache = [[NSCache alloc] init];
    }
    
    return self;
}


- (void)dealloc {
    // Should never be called, but just here for clarity really.
    abort();
}


-(UIImage*) getImageWithName:(NSString*)imageName;
{
    return [self.imageCache objectForKey:imageName];
}

-(void)addImage:(UIImage *)image withName:(NSString *)imageName
{
    [self.imageCache setObject:image forKey:imageName];
}


@end
