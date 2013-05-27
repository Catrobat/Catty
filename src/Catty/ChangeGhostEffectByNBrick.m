//
//  ChangeGhostEffectBrick.m
//  Catty
//
//  Created by Dominik Ziegler on 9/28/12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Changeghosteffectbynbrick.h"
#import "Formula.h"

@implementation Changeghosteffectbynbrick

@synthesize changeGhostEffect = _changeGhostEffect;


-(id)initWithValueForGhostEffectChange:(NSNumber*)value;
{
    abort();
#warning do not use! NSNumber changed to Formula
    self = [super init];
    if (self)
    {
        self.changeGhostEffect = value;
    }
    return self;
}

- (void)performFromScript:(Script*)script;
{
    NSLog(@"Performing: %@", self.description);
    
    double transparency = [self.changeGhostEffect interpretDoubleForSprite:self.object];
    
    [self.object changeTransparencyInPercent:transparency];
    
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"ChangeGhostEffect by (%f)", [self.changeGhostEffect interpretDoubleForSprite:self.object]];
}

@end
