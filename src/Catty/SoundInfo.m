//
//  SoundInfo.m
//  Catty
//
//  Created by Christof Stromberger on 28.02.13.
//  Copyright (c) 2013 Graz University of Technology. All rights reserved.
//

#import "SoundInfo.h"

@implementation SoundInfo

-(id)init {
    self = [super init];
    if(self) {
#warning just to test if soundInfo really is necessary!
        [NSException raise:@"Apparently it is needed!" format:nil];
    }
    return self;
}

@end
