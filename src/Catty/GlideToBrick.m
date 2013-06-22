/**
 *  Copyright (C) 2010-2013 The Catrobat Team
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

#import "Glidetobrick.h"
#import "Script.h"
#import "Formula.h"

@interface GlideToBrick()

@property (nonatomic, assign) BOOL isInitialized;
@property (nonatomic, assign) CGPoint currentPoint;
@property (nonatomic, assign) CGPoint startingPoint;

@end


@implementation GlideToBrick

@synthesize durationInSeconds = _durationInSeconds;
@synthesize xDestination = _xDestination;
@synthesize yDestination = _yDestination;


-(id)init
{
    if(self = [super init]) {
        self.isInitialized = NO;
    }
    return self;
}



#pragma mark - override

-(SKAction*)action
{
    
    double durationInSeconds = [self.durationInSeconds interpretDoubleForSprite:self.object];
    double xDestination = [self.xDestination interpretDoubleForSprite:self.object];
    double yDestination = [self.yDestination interpretDoubleForSprite:self.object];
    CGPoint position = CGPointMake(xDestination, yDestination);
    
    return [SKAction customActionWithDuration:durationInSeconds actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        NSDebug(@"Performing: %@", self.description);
        
        if(!self.isInitialized) {
            self.isInitialized = YES;
            self.currentPoint = self.object.position;
            self.startingPoint = self.currentPoint;
        }
        
        // TODO: handle extreme movemenets and set currentPoint accordingly
        CGFloat percent = elapsedTime / durationInSeconds;
        
        CGFloat xPoint = self.startingPoint.x + (xDestination - self.startingPoint.x) * percent;
        CGFloat yPoint = self.startingPoint.y + (yDestination - self.startingPoint.y) * percent;
        
        self.object.position = self.currentPoint = CGPointMake(xPoint, yPoint);


    }];
}

#pragma mark - Description
- (NSString*)description
{
    
    double xDestination = [self.xDestination interpretDoubleForSprite:self.object];
    double yDestination = [self.yDestination interpretDoubleForSprite:self.object];
    double durationInSeconds = [self.durationInSeconds interpretDoubleForSprite:self.object];
    
    return [NSString stringWithFormat:@"GlideTo (Position: %f/%f; duration: %f s)", xDestination, yDestination, durationInSeconds];
}

@end
