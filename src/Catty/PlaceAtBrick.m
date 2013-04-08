//
//  PlaceAtBrick.m
//  Catty
//
//  Created by Mattias Rauter on 13.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Placeatbrick.h"

@implementation Placeatbrick

@synthesize xPosition = _xPosition;
@synthesize yPosition = _yPosition;

#pragma mark - init methods
-(id)initWithXPosition:(NSNumber*)xPosition yPosition:(NSNumber*)yPosition
{
    self = [super init];
    if (self)
    {
        self.xPosition = xPosition;
        self.yPosition = yPosition;
    }
    return self;
}

#pragma mark - override
-(void)performFromScript:(Script*)script
{
  /*  NSLog(@"SPRITE: %@     SCRIPT: %@", sprite.name, script);
    NSLog(@"Set position of sprite %@ to %f / % f / %f", sprite.name, self.position.x, self.position.y, self.position.z);
    self.position.x = self.xPosition.integerValue;
    self.position.y = self.yPosition.floatValue;
    
    */
    
    CGPoint position = CGPointMake(self.xPosition.floatValue, self.yPosition.floatValue);
    
    [self.object glideToPosition:position withDurationInSeconds:0 fromScript:script];
    //[NSThread sleepForTimeInterval:self.durationInSeconds.floatValue];

    
    //[self.object placeAt:GLKVector3Make(self.xPosition.floatValue, self.yPosition.floatValue, 0.0f)];
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"PlaceAt (Position: %f/%f)", self.xPosition.floatValue, self.yPosition.floatValue];
}

@end
