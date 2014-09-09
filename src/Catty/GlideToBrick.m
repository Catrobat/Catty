/**
 *  Copyright (C) 2010-2014 The Catrobat Team
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
#import "GDataXMLNode.h"

@interface GlideToBrick()

@property (nonatomic, assign) BOOL isInitialized;
@property (nonatomic, assign) CGPoint currentPoint;
@property (nonatomic, assign) CGPoint startingPoint;

@end

@implementation GlideToBrick

@synthesize durationInSeconds = _durationInSeconds;
@synthesize xDestination = _xDestination;
@synthesize yDestination = _yDestination;

- (Formula*)getFormulaForLineNumber:(NSInteger)lineNumber AndParameterNumber:(NSInteger)paramNumber
{
    if(lineNumber == 0 && paramNumber == 0)
        return self.durationInSeconds;
    else if(lineNumber == 1 && paramNumber == 0)
        return self.xDestination;
    else if(lineNumber == 1 && paramNumber == 1)
        return self.yDestination;
    
    return nil;
}

- (void)setFormula:(Formula*)formula ForLineNumber:(NSInteger)lineNumber AndParameterNumber:(NSInteger)paramNumber
{
    if(lineNumber == 0 && paramNumber == 0)
        self.durationInSeconds = formula;
    else if(lineNumber == 1 && paramNumber == 0)
        self.xDestination = formula;
    else if(lineNumber == 1 && paramNumber == 1)
        self.yDestination = formula;
}

- (id)init
{
    if(self = [super init]) {
        self.isInitialized = NO;
    }
    return self;
}

- (NSString*)brickTitle
{
    return kBrickCellMotionTitleGlideTo;
}

#pragma mark - override
- (SKAction*)action
{
    double durationInSeconds = [self.durationInSeconds interpretDoubleForSprite:self.object];
    double xDestination = [self.xDestination interpretDoubleForSprite:self.object];
    double yDestination = [self.yDestination interpretDoubleForSprite:self.object];
    self.isInitialized = NO;

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

- (GDataXMLElement*)toXMLforObject:(SpriteObject*)spriteObject
{
    GDataXMLElement *brickXMLElement = [super toXMLforObject:spriteObject];

    if (self.durationInSeconds) {
        GDataXMLElement *durationInSecondsXMLElement = [GDataXMLNode elementWithName:@"durationInSeconds"];
        [durationInSecondsXMLElement addChild:[self.durationInSeconds toXMLforObject:spriteObject]];
        [brickXMLElement addChild:durationInSecondsXMLElement];
    }

    if (self.xDestination) {
        GDataXMLElement *xDestinationXMLElement = [GDataXMLNode elementWithName:@"xDestination"];
        [xDestinationXMLElement addChild:[self.xDestination toXMLforObject:spriteObject]];
        [brickXMLElement addChild:xDestinationXMLElement];
    }

    if (self.yDestination) {
        GDataXMLElement *yDestinationXMLElement = [GDataXMLNode elementWithName:@"yDestination"];
        [yDestinationXMLElement addChild:[self.yDestination toXMLforObject:spriteObject]];
        [brickXMLElement addChild:yDestinationXMLElement];
    }

    if (! self.durationInSeconds && ! self.xDestination && ! self.yDestination) {
        // remove object reference
        [brickXMLElement removeChild:[[brickXMLElement children] firstObject]];
    }
    return brickXMLElement;
}

@end
