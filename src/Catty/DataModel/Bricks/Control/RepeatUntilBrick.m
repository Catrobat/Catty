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

#import "RepeatUntilBrick.h"
#import "Script.h"

@interface RepeatUntilBrick()
@property (nonatomic, assign) int loopCount;
@end

@implementation RepeatUntilBrick

- (BOOL)isAnimateable
{
    return YES;
}

- (Formula*)formulaForLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    return self.repeatCondition;
}

- (void)setFormula:(Formula*)formula forLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    self.repeatCondition = formula;
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
    return @[self.repeatCondition];
}

- (void)setDefaultValuesForObject:(SpriteObject*)spriteObject
{
    self.repeatCondition = [[Formula alloc] initWithInteger:1];
}

- (NSString*)brickTitle
{
    int repeatFor = [self.repeatCondition interpretIntegerForSprite:self.script.object andUseCache:NO];
    NSString* repeatForStr;
    if ([self.repeatCondition isSingleNumberFormula] && repeatFor == 1.0) {
        repeatForStr = kLocalizedTime;
    }
    else {
        repeatForStr = kLocalizedTimes;
    }
    return [kLocalizedRepeatUntil stringByAppendingString:[@"%@ " stringByAppendingString:repeatForStr]];
}

- (BOOL)checkCondition
{
    NSDebug(@"Loop Count: %d", self.loopCount);
    return [self.repeatCondition interpretBOOLForSprite:self.script.object];
}

//- (void)resetCondition
//{
//    self.loopCount = 0;
//}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"RepeatLoop with %d iterations", [self.repeatCondition interpretIntegerForSprite:self.script.object]];
}

#pragma mark - Copy
- (id)mutableCopyWithContext:(CBMutableCopyContext*)context
{
    RepeatUntilBrick *brick = [self mutableCopyWithContext:context AndErrorReporting:NO];
    brick.loopCount = self.loopCount;
    return brick;
}

#pragma mark - Resources
- (NSInteger)getRequiredResources
{
    return [self.repeatCondition getRequiredResources];
}

@end
