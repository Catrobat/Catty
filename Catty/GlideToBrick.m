//
//  GlideToBrick.m
//  Catty
//
//  Created by Mattias Rauter on 16.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "GlideToBrick.h"
#import "Script.h"

// TODO: change! Need CattyViewController to get FRAMES_PER_SECOND... 
#import "CattyViewController.h"

@implementation GlideToBrick

@synthesize position = _position;
@synthesize durationInMilliSeconds = _durationInMilliSecs;

#pragma mark - init methods
-(id)initWithPosition:(GLKVector3)position andDurationInMilliSecs:(int)durationInMilliSecs
{
    self = [super init];
    if (self)
    {
        self.position = position;
        self.durationInMilliSeconds = durationInMilliSecs;
    }
    return self;
}

#pragma mark - override
-(void)performOnSprite:(Sprite *)sprite fromScript:(Script*)script
{
    NSLog(@"Performing: %@", self.description);

    
//    [script glideWithSprite:sprite toPosition:self.position withinMilliSecs:self.durationInMilliSecs];
    
    [sprite glideToPosition:self.position withinDurationInMilliSecs:self.durationInMilliSeconds fromScript:script];
    [NSThread sleepForTimeInterval:self.durationInMilliSeconds/1000.0f];
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"GlideTo (Position: %f/%f; duration: %d ms)", self.position.x, self.position.y, self.durationInMilliSeconds];
}

@end
