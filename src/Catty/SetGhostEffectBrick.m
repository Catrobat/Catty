//
//  SetGhostEffectBrick.m
//  Catty
//
//  Created by Dominik Ziegler on 9/28/12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Setghosteffectbrick.h"
#import "Formula.h"

@implementation Setghosteffectbrick

@synthesize transparency = _transparency;


-(id)initWithTransparencyInPercent:(NSNumber*)transparency;
{
    abort();
#warning do not use any more! NSNumber changed to Formula!
    self = [super init];
    if (self) {
        self.transparency = transparency;
    }
    return self;
}

- (void)performFromScript:(Script*)script;
{
    NSDebug(@"Performing: %@", self.description);
    
    double transparency  = [self.transparency interpretDoubleForSprite:self.object];
    
    [self.object setTransparencyInPercent:transparency];
    
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"SetGhostEffect (%f%%)", [self.transparency interpretDoubleForSprite:self.object]];
}

@end


