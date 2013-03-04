//
//  SetCostumeBrick.m
//  Catty
//
//  Created by Mattias Rauter on 17.04.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "SetLookBrick.h"
#import "Sprite.h"

@implementation SetLookBrick

@synthesize indexOfCostumeInArray = _indexOfCostumeInArray;
@synthesize look = _look;

- (void)performFromScript:(Script*)script
{
    NSLog(@"Performing: %@", self.description);
    

    [self.sprite performSelectorOnMainThread:@selector(changeCostume:) withObject:self.indexOfCostumeInArray waitUntilDone:YES];
}


#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"SetCostumeBrick (CostumeIndex: %d)", self.indexOfCostumeInArray.intValue];
}

@end
