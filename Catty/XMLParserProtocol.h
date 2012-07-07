//
//  XMLParserProtocol.h
//  Catty
//
//  Created by Christof Stromberger on 27.04.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Level;

@protocol XMLParserProtocol <NSObject>

- (Level*)generateObjectForLevel:(NSString*)path;

@end
