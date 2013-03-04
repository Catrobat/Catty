//
//  ImageCache.h
//  Catty
//
//  Created by Dominik Ziegler on 3/4/13.
//  Copyright (c) 2013 Graz University of Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageCache : NSObject


+(ImageCache *)sharedImageCache;

-(UIImage*) getImageWithName:(NSString*)imageName;

-(void) addImage:(UIImage*)image withName:(NSString*) imageName;

@end
