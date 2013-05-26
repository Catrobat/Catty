//
//  SetSizeToBrick.m
//  Catty
//
//  Created by Mattias Rauter on 26.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Setsizetobrick.h"
#import "Formula.h"

@implementation Setsizetobrick

@synthesize size = _sizeInPercentage;


-(id)initWithSizeInPercentage:(NSNumber*)sizeInPercentage
{
    abort();
#warning do not use any more! (NSNumber changed to Formula!)
    
    self = [super init];
    if (self)
    {
        self.size = sizeInPercentage;
    }
    return self;
}

- (void)performFromScript:(Script*)script
{
    NSLog(@"Performing: %@", self.description);
    
    double size = [self.size interpretDoubleForSprite:self.object];
    
    [self.object setSizeToPercentage:size];
    
    //    float sleepTime = ((float)self.timeToWaitInMilliseconds.intValue)/1000;
    //    NSLog(@"wating for %f seconds", sleepTime);
    //    NSLog(@"---- BEFORE SLEEP -----");
    //    [NSThread sleepForTimeInterval:sleepTime];
    //    NSLog(@"---- AFTER SLEEP ------");
    
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"SetSizeTo (%f%%)", [self.size interpretDoubleForSprite:self.object]];
}

@end
