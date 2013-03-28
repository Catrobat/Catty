//
//  GlideToBrick.m
//  Catty
//
//  Created by Mattias Rauter on 16.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Glidetobrick.h"
#import "Script.h"

// TODO: change! Need CattyViewController to get FRAMES_PER_SECOND... 
#import "CattyViewController.h"

@implementation Glidetobrick

@synthesize durationInSeconds = _durationInSeconds;
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
        self.durationInSeconds = durationInMilliSecs;
    }
    return self;
}

#pragma mark - override
-(void)performFromScript:(Script*)script
{
    NSLog(@"Performing: %@", self.description);

        
    GLKVector3 position = GLKVector3Make(self.xDestination.floatValue, self.yDestination.floatValue, 0.0f);
    
    [self.object glideToPosition:position withinDurationInMilliSecs:self.durationInSeconds.intValue fromScript:script];
    [NSThread sleepForTimeInterval:self.durationInSeconds.floatValue/1000.0f];
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"GlideTo (Position: %f/%f; duration: %f ms)", self.xDestination.floatValue, self.yDestination.floatValue, self.durationInSeconds.floatValue
            ];
}

@end
