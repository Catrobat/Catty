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
@property (nonatomic, assign) float zIndex;


// just4debugging (and testing!!!!!)
-(Level*)generateDebugLevel_GlideTo;
-(Level*)generateDebugLevel_nextCostume;
-(Level*)generateDebugLevel_HideShow;
-(Level*)generateDebugLevel_SetXY;
-(Level*)generateDebugLevel_broadcast;
-(Level*)generateDebugLevel_comeToFront;
@end
