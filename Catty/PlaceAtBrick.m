//
//  PlaceAtBrick.m
//  Catty
//
//  Created by Mattias Rauter on 13.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "PlaceAtBrick.h"

@implementation PlaceAtBrick

@synthesize position = _position;

#pragma mark - init methods
-(id)initWithPosition:(GLKVector3)position
{
    self = [super init];
    if (self)
    {
        self.position = position;
    }
    return self;
}

#pragma mark - override
-(void)performOnSprite:(Sprite *)sprite fromScript:(Script*)script
{
  /*  NSLog(@"SPRITE: %@     SCRIPT: %@", sprite.name, script);
    NSLog(@"Set position of sprite %@ to %f / % f / %f", sprite.name, self.position.x, self.position.y, self.position.z);
    self.position.x = self.xPosition.integerValue;
    self.position.y = self.yPosition.floatValue;
    
    */
    
    [sprite placeAt:/*self.position*/GLKVector3Make(self.xPosition.floatValue, self.yPosition.floatValue, 0)];
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"PlaceAt (Position: %f/%f)", self.xPosition.floatValue, self.yPosition.floatValue];
}

@end
