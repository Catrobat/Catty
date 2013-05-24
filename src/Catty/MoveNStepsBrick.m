//
//  MoveNStepsBrick.m
//  Catty
//
//  Created by Dominik Ziegler on 5/24/13.
//
//

#import "MoveNStepsBrick.h"
#import "Formula.h"

@implementation Movenstepsbrick

-(void)performFromScript:(Script *)script
{
    double steps = [self.steps interpretDoubleForSprite:self.object];
    [self.object moveNSteps:steps];
}


-(NSString*)description
{
    return [NSString stringWithFormat:@"MoveNStepsBrick: %f steps", [self.steps interpretDoubleForSprite:self.object] ];
}

@end
