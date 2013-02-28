//
//  LevelParser.h
//  Catty
//
//  Created by Christof Stromberger on 19.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Project;

@interface ProjectParser : NSObject

- (Project*)loadLevel:(NSData*)xmlData;

@end
