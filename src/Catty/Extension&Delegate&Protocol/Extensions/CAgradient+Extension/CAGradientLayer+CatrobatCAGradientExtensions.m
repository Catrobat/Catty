/**
 *  Copyright (C) 2010-2017 The Catrobat Team
 *  (http://developer.catrobat.org/credits)
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *
 *  An additional term exception under section 7 of the GNU Affero
 *  General Public License, version 3, is available at
 *  (http://developer.catrobat.org/license_additional_term)
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU Affero General Public License for more details.
 *
 *  You should have received a copy of the GNU Affero General Public License
 *  along with this program.  If not, see http://www.gnu.org/licenses/.
 */

#import "CAGradientLayer+CatrobatCAGradientExtensions.h"

@implementation CAGradientLayer (CatrobatCAGradientExtensions)

+ (CAGradientLayer*) blueGradientLayerWithFrame:(CGRect)frame
{
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = frame;
    
    gradientLayer.colors = [NSArray arrayWithObjects:
                            (id)[UIColor colorWithRed:54/255.0f green:157/255.0f blue:244/255.0f alpha:1.0f].CGColor,
                            (id)[UIColor colorWithRed:58/255.0f green:136/255.0f blue:191/255.0f alpha:1.0f].CGColor,
                            nil];
    
    gradientLayer.locations = [NSArray arrayWithObjects:
                               [NSNumber numberWithFloat:0.0f],
                               [NSNumber numberWithFloat:1.0f],
                               nil];
    
    return gradientLayer;
}

+ (CAGradientLayer*) greenGradientLayerWithFrame:(CGRect)frame
{
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = frame;
    
    gradientLayer.colors = [NSArray arrayWithObjects:
                               (id)[UIColor colorWithRed:103/255.0f green:174/255.0f blue:59/255.0f alpha:1.0f].CGColor,
                               (id)[UIColor colorWithRed:61/255.0f green:118/255.0f blue:26/255.0f alpha:1.0f].CGColor,
                               nil];
    
    gradientLayer.locations = [NSArray arrayWithObjects:
                                  [NSNumber numberWithFloat:0.0f],
                                  [NSNumber numberWithFloat:1.0f],
                                  nil];
    
    return gradientLayer;
}

+ (CAGradientLayer*) redGradientLayerWithFrame:(CGRect)frame
{
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = frame;
    
    gradientLayer.colors = [NSArray arrayWithObjects:
                            (id)[UIColor colorWithRed:204/255.0f green:26/255.0f blue:26/255.0f alpha:1.0f].CGColor,
                            (id)[UIColor colorWithRed:170/255.0f green:40/255.0f blue:45/255.0f alpha:1.0f].CGColor,
                            nil];
    
    gradientLayer.locations = [NSArray arrayWithObjects:
                               [NSNumber numberWithFloat:0.0f],
                               [NSNumber numberWithFloat:1.0f],
                               nil];
    
    return gradientLayer;
}

@end
