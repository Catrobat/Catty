//
//  LevelParser.h
//  Catty
//
//  Created by Christof Stromberger on 19.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Level;

@interface LevelParser : NSObject

- (Level*)loadLevel:(NSData*)xmlData;

@end
