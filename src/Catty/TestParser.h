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
-(Program*)generateDebugProject_GlideTo;
-(Program*)generateDebugProject_nextCostume;
-(Program*)generateDebugProject_HideShow;
-(Program*)generateDebugProject_SetXY;
-(Program*)generateDebugProject_broadcast;
-(Program*)generateDebugProject_broadcastWait;
-(Program*)generateDebugProject_comeToFront;
-(Program*)generateDebugProject_changeSizeByN;
-(Program*)generateDebugProject_parallelScripts;
-(Program*)generateDebugProject_loops;
-(Program*)generateDebugProject_rotate;
-(Program*)generateDebugProject_rotateFullCircle;
-(Program*)generateDebugProject_rotateAndMove;

@end
