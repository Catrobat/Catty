//
//  SetBrightnessBrick.m
//  Catty
//
//  Created by Christof Stromberger on 28.02.13.
//  Copyright (c) 2013 Graz University of Technology. All rights reserved.
//

#import "Setbrightnessbrick.h"

@implementation Setbrightnessbrick

-(void)performFromScript:(Script *)script
{
    [self.object changeBrightness:self.brightness.floatValue];
}
@end
