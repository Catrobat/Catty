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

@synthesize durationInMilliSeconds = _durationInMilliSecs;
@synthesize xDestination = _xDestination;
@synthesize yDestination = _yDestination;

#pragma mark - init methods
-(id)initWithXPosition:(NSNumber*)xPosition yPosition:(NSNumber*)yPosition andDurationInMilliSecs:(NSNumber*)durationInMilliSecs
{
    self = [super init];
    if (self)
    {
        self.xDestination = xPosition;
        self.yDestination = yPosition;
        self.durationInMilliSeconds = durationInMilliSecs;
    }
    return self;
}

#pragma mark - override
-(void)performFromScript:(Script*)script
{
    NSLog(@"Performing: %@", self.description);

        
    GLKVector3 position = GLKVector3Make(self.xDestination.floatValue, self.yDestination.floatValue, 0.0f);
    
    [self.sprite glideToPosition:position withinDurationInMilliSecs:self.durationInMilliSeconds fromScript:script];
    [NSThread sleepForTimeInterval:self.durationInMilliSeconds.floatValue/1000.0f];
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"GlideTo (Position: %f/%f; duration: %f ms)", self.xDestination.floatValue, self.yDestination.floatValue, self.durationInMilliSeconds.floatValue
            ];
}

@end
