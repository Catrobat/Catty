//
//  GlideToBrick.m
//  Catty
//
//  Created by Mattias Rauter on 16.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "GlideToBrick.h"

// TODO: change! Need CattyViewController to get FRAMES_PER_SECOND... 
#import "CattyViewController.h"

@implementation GlideToBrick

@synthesize position = _position;
@synthesize durationInMilliSecs = _durationInMilliSecs;

#pragma mark - init methods
-(id)initWithPosition:(GLKVector3)position andDurationInMilliSecs:(int)durationInMilliSecs
{
    self = [super init];
    if (self)
    {
        self.position = position;
        self.durationInMilliSecs = durationInMilliSecs;
    }
    return self;
}

#pragma mark - override
-(void)performOnSprite:(Sprite *)sprite fromScript:(Script*)script
{
    NSLog(@"Performing: %@", self.description);

    [sprite glideToPosition:self.position withinDurationInMilliSecs:self.durationInMilliSecs fromScript:script];
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"GlideTo (Position: %f/%f; duration: %d ms)", self.position.x, self.position.y, self.durationInMilliSecs];
}

@end
