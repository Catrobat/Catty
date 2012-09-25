//
//  FileManager.h
//  Catty
//
//  Created by Christof Stromberger on 25.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileManager : NSObject

- (void)deleteAllFillesOfDirectory:(NSString*)path;

@end
