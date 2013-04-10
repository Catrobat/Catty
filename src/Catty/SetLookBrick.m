//
//  SetCostumeBrick.m
//  Catty
//
//  Created by Mattias Rauter on 17.04.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Setlookbrick.h"
#import "SpriteObject.h"

@implementation Setlookbrick

//@synthesize indexOfCostumeInArray = _indexOfCostumeInArray;
@synthesize look = _look;

- (void)performFromScript:(Script*)script
{
    NSLog(@"Performing: %@", self.description);
    
    [self.object performSelectorOnMainThread:@selector(changeLook:) withObject:self.look waitUntilDone:YES];
}


#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"SetLookBrick (Look: %@)", self.look];
}

@end
