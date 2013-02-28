//
//  BackgroundLayer.m
//  Catty
//
//  Created by Dominik Ziegler on 2/28/13.
//  Copyright (c) 2013 Graz University of Technology. All rights reserved.
//

#import "BackgroundLayer.h"

@implementation BackgroundLayer


+ (CAGradientLayer*) darkBlueGradient {
    
    UIColor *colorOne = [UIColor colorWithRed:0.0f green:71.0f/255.0f blue:94.0f/255 alpha:1.0];
    UIColor *colorTwo = [UIColor colorWithRed:0.0f green:63.0f/255 blue:84.0f/255 alpha:1.0f];

    NSArray *colors =  [NSArray arrayWithObjects:(id)colorOne.CGColor, colorTwo.CGColor, nil];
    CAGradientLayer *headerLayer = [CAGradientLayer layer];
    headerLayer.colors = colors;
    
    return headerLayer;
}


@end
