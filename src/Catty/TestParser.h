/**
 *  Copyright (C) 2010-2013 The Catrobat Team
 *  (http://developer.catrobat.org/credits)
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *
 *  An additional term exception under section 7 of the GNU Affero
 *  General Public License, version 3, is available at
 *  (http://developer.catrobat.org/license_additional_term)
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU Affero General Public License for more details.
 *
 *  You should have received a copy of the GNU Affero General Public License
 *  along with this program.  If not, see http://www.gnu.org/licenses/.
 */

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
-(Program*)generateDebugProject_goNStepsBack;
-(Program*)generateDebugProject_changeSizeByN;
-(Program*)generateDebugProject_parallelScripts;
-(Program*)generateDebugProject_loops;
-(Program*)generateDebugProject_pointToDirection;
-(Program*)generateDebugProject_setBrightness;
-(Program*)generateDebugProject_rotate;
-(Program*)generateDebugProject_rotateFullCircle;
-(Program*)generateDebugProject_rotateAndMove;
-(Program*)generateDebugProject_transparency;

@end
