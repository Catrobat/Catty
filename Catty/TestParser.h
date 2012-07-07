//
//  TestParser.h
//  Catty
//
//  Created by Christof Stromberger on 27.04.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMLParserProtocol.h"
#import <GLKit/GLKit.h>

@interface TestParser : NSObject <XMLParserProtocol>

@property (strong, nonatomic) GLKBaseEffect *effect;

@end
