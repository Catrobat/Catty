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


#import "Stage.h" 
#import "Program.h"
#import "SPStage.h"
#import "SpriteObject.h"


@interface Stage ()


@property (nonatomic, strong) SPImage *tmpImage;
@property BOOL pausedFirstTime;


@end



@implementation Stage
{
    SPSprite *_contents;
}

- (id)init
{
    if ((self = [super init])) {
//        [self addEventListener:@selector(onEnterFrame:) atObject:self
//                       forType:SP_EVENT_TYPE_ENTER_FRAME];
    }
    return self;
}

- (void)dealloc
{
}



-(void)start
{
    self.paused = NO;
    
    for (SpriteObject *obj in self.program.objectList) {
        [obj addEventListener:@selector(onImageTouched:) atObject:obj forType:SP_EVENT_TYPE_TOUCH];
        [self addChild:obj];
        NSDebug(@"####### %@", obj.name);
    }
    
    for (SpriteObject *obj in self.program.objectList) {
        [obj start];
    }
}


//- (void)onEnterFrame:(SPEnterFrameEvent *)event
//{
//    double passedTime = event.passedTime;
//    
//    if (!self.paused) {
//        for (SpriteObject *obj in self.program.objectList) {
//            [obj advanceTime:passedTime];
//        }
//    }
//    else if(self.pausedFirstTime) {
//        for (SpriteObject *obj in self.program.objectList) {
//            [obj pause];
//        }
//        self.pausedFirstTime = NO;
//    }
//}





@end
