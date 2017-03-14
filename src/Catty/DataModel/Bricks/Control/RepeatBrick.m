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

#import "Repeatbrick.h"
#import "Formula.h"
#import "Script.h"

@interface RepeatBrick()
@property (nonatomic, assign) int loopCount;
@end

@implementation RepeatBrick

- (BOOL)isAnimateable
{
    return YES;
}

- (Formula*)formulaForLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    return self.timesToRepeat;
}

- (void)setFormula:(Formula*)formula forLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    self.timesToRepeat = formula;
}

- (BOOL)allowsStringFormula
{
    return NO;
}

- (NSArray*)conditions
{
    return [self getFormulas];
}

- (NSArray*)getFormulas
{
    return @[self.timesToRepeat];
}

- (void)setDefaultValuesForObject:(SpriteObject*)spriteObject
{
    self.timesToRepeat = [[Formula alloc] initWithInteger:10];
}

- (NSString*)brickTitle
{
    int repeatFor = [self.timesToRepeat interpretIntegerForSprite:self.script.object];
    NSString* repeatForStr;
    if (repeatFor == 1.0) {
        repeatForStr = kLocalizedTime;
    }
    else {
        repeatForStr = kLocalizedTimes;
    }
    return [kLocalizedRepeat stringByAppendingString:[@"%@ " stringByAppendingString:repeatForStr]];
}

- (BOOL)checkCondition
{
    NSDebug(@"Loop Count: %d", self.loopCount);
    int timesToRepeat = [self.timesToRepeat interpretIntegerForSprite:self.script.object];
    return (self.loopCount++ < timesToRepeat) ? YES : NO;
}

- (void)resetCondition
{
    self.loopCount = 0;
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"RepeatLoop with %d iterations", [self.timesToRepeat interpretIntegerForSprite:self.script.object]];
}

#pragma mark - Copy
- (id)mutableCopyWithContext:(CBMutableCopyContext*)context
{
    RepeatBrick *brick = [self mutableCopyWithContext:context AndErrorReporting:NO];
    brick.loopCount = self.loopCount;
    return brick;
}

#pragma mark - Resources
- (NSInteger)getRequiredResources
{
    return [self.timesToRepeat getRequiredResources];
}

@end
