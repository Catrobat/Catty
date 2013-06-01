//
//  GlideToBrick.m
//  Catty
//
//  Created by Mattias Rauter on 16.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Glidetobrick.h"
#import "Script.h"
#import "Formula.h"

@implementation Glidetobrick

@synthesize durationInSeconds = _durationInSeconds;
@synthesize xDestination = _xDestination;
@synthesize yDestination = _yDestination;


#pragma mark - override
-(void)performFromScript:(Script*)script
{
    NSDebug(@"Performing: %@", self.description);

        
    //GLKVector3 position = GLKVector3Make(self.xDestination.floatValue, self.yDestination.floatValue, 0.0f);
    
    double xDestination = [self.xDestination interpretDoubleForSprite:self.object];
    double yDestination = [self.yDestination interpretDoubleForSprite:self.object];
    double durationInSeconds = [self.durationInSeconds interpretDoubleForSprite:self.object];
    
    CGPoint position = CGPointMake(xDestination, yDestination);
    
    [self.object glideToPosition:position withDurationInSeconds:durationInSeconds fromScript:script];
    [NSThread sleepForTimeInterval:durationInSeconds];
}

#pragma mark - Description
- (NSString*)description
{
    
    double xDestination = [self.xDestination interpretDoubleForSprite:self.object];
    double yDestination = [self.yDestination interpretDoubleForSprite:self.object];
    double durationInSeconds = [self.durationInSeconds interpretDoubleForSprite:self.object];
    
    return [NSString stringWithFormat:@"GlideTo (Position: %f/%f; duration: %f s)", xDestination, yDestination, durationInSeconds];
}

@end
