//
//  SetBrightnessBrick.m
//  Catty
//
//  Created by Christof Stromberger on 28.02.13.
//  Copyright (c) 2013 Graz University of Technology. All rights reserved.
//

#import "Setbrightnessbrick.h"
#import "Formula.h"

@implementation Setbrightnessbrick

-(void)performFromScript:(Script *)script
{
    double brightness = [self.brightness interpretDoubleForSprite:self.object];
    [self.object changeBrightness:brightness];
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"Set Brightness to: %f%%)", [self.brightness interpretDoubleForSprite:self.object]];
}

@end
