/**
 *  Copyright (C) 2010-2015 The Catrobat Team
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

#import "GlideToBrick.h"
#import "Script.h"
#import "Formula.h"
#import "CBMutableCopyContext.h"
#import "Pocket_Code-Swift.h"

@interface GlideToBrick()

@property (nonatomic, assign) BOOL isInitialized;
@property (nonatomic, assign) CGPoint currentPoint;
@property (nonatomic, assign) CGPoint startingPoint;

@end

@implementation GlideToBrick

@synthesize durationInSeconds = _durationInSeconds;
@synthesize xDestination = _xDestination;
@synthesize yDestination = _yDestination;

- (Formula*)formulaForLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    if(lineNumber == 0 && paramNumber == 0)
        return self.durationInSeconds;
    else if(lineNumber == 1 && paramNumber == 0)
        return self.xDestination;
    else if(lineNumber == 1 && paramNumber == 1)
        return self.yDestination;
    
    return nil;
}

- (void)setFormula:(Formula*)formula forLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    if(lineNumber == 0 && paramNumber == 0)
        self.durationInSeconds = formula;
    else if(lineNumber == 1 && paramNumber == 0)
        self.xDestination = formula;
    else if(lineNumber == 1 && paramNumber == 1)
        self.yDestination = formula;
}

- (void)setDefaultValuesForObject:(SpriteObject*)spriteObject
{
    self.durationInSeconds = [[Formula alloc] initWithInteger:1];
    self.xDestination = [[Formula alloc] initWithInteger:100];
    self.yDestination = [[Formula alloc] initWithInteger:200];
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
    return kLocalizedGlideTo;
}

#pragma mark - override
- (SKAction*)action
{
    double durationInSeconds = [self.durationInSeconds interpretDoubleForSprite:self.script.object];
    double xDestination = [self.xDestination interpretDoubleForSprite:self.script.object];
    double yDestination = [self.yDestination interpretDoubleForSprite:self.script.object];
    self.isInitialized = NO;

    return [SKAction customActionWithDuration:durationInSeconds actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        NSDebug(@"Performing: %@", self.description);
        
        if(!self.isInitialized) {
            self.isInitialized = YES;
            self.currentPoint = self.script.object.spriteNode.scenePosition;
            self.startingPoint = self.currentPoint;
        }
        // TODO: handle extreme movemenets and set currentPoint accordingly
        CGFloat percent = (CGFloat)(elapsedTime / durationInSeconds);
        CGFloat xPoint = (CGFloat)(self.startingPoint.x + (xDestination - self.startingPoint.x) * percent);
        CGFloat yPoint = (CGFloat)(self.startingPoint.y + (yDestination - self.startingPoint.y) * percent);
        self.script.object.spriteNode.scenePosition = self.currentPoint = CGPointMake(xPoint, yPoint);
    }];
}

#pragma mark - Description
- (NSString*)description
{
    double xDestination = [self.xDestination interpretDoubleForSprite:self.script.object];
    double yDestination = [self.yDestination interpretDoubleForSprite:self.script.object];
    double durationInSeconds = [self.durationInSeconds interpretDoubleForSprite:self.script.object];
    return [NSString stringWithFormat:@"GlideTo (Position: %f/%f; duration: %f s)", xDestination, yDestination, durationInSeconds];
}

- (BOOL)isEqualToBrick:(Brick*)brick
{
    if(![self.durationInSeconds isEqualToFormula:((GlideToBrick*)brick).durationInSeconds])
        return NO;
    if(![self.xDestination isEqualToFormula:((GlideToBrick*)brick).xDestination])
        return NO;
    if(![self.yDestination isEqualToFormula:((GlideToBrick*)brick).yDestination])
        return NO;
    return YES;
}

#pragma mark - Copy
- (id)mutableCopyWithContext:(CBMutableCopyContext*)context
{
    return [self mutableCopyWithContext:context AndErrorReporting:NO];
    
}

@end
