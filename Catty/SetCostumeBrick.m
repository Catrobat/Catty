//
//  SetCostumeBrick.m
//  Catty
//
//  Created by Mattias Rauter on 17.04.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "SetCostumeBrick.h"

@implementation SetCostumeBrick

@synthesize indexOfCostumeInArray = _indexOfCostumeInArray;


- (void)performOnSprite:(Sprite *)sprite
{
    NSLog(@"Performing: %@", self.description);
    
    [sprite performSelectorOnMainThread:@selector(setIndexOfCurrentCostumeInArray:) withObject:self.indexOfCostumeInArray waitUntilDone:YES];
}


#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"SetCostumeBrick (CostumeIndex: %d)", self.indexOfCostumeInArray.intValue];
}

@end
