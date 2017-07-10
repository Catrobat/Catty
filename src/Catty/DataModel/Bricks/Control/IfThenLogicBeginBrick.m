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

#import "IfThenLogicBeginBrick.h"
#import "IfThenLogicEndBrick.h"
#import "Util.h"
#import "Script.h"

@implementation IfThenLogicBeginBrick

- (BOOL)isAnimateable
{
    return YES;
}

- (BOOL)isIfLogicBrick
{
    return YES;
}

- (Formula*)formulaForLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    return self.ifCondition;
}

- (NSArray*)conditions
{
    return [self getFormulas];
}

- (NSArray*)getFormulas
{
    return @[self.ifCondition];
}

- (void)setFormula:(Formula*)formula forLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    self.ifCondition = formula;
}

- (BOOL)allowsStringFormula
{
    return NO;
}

- (void)setDefaultValuesForObject:(SpriteObject*)spriteObject
{
    self.ifCondition = [[Formula alloc] initWithInteger:1];
}

- (NSString*)brickTitle
{
    return [kLocalizedIfBegin stringByAppendingString:[@"%@ " stringByAppendingString:kLocalizedIfBeginSecondPart]];
}

- (BOOL)checkCondition
{
    NSDebug(@"Performing: %@", self.description);
    return [self.ifCondition interpretBOOLForSprite:self.script.object];
}

- (void)resetCondition
{
    // nothing to do
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"If Then Logic Begin Brick"];
}

- (BOOL)isEqualToBrick:(Brick*)brick
{
    if(![Util isEqual:self.ifEndBrick.brickTitle toObject:((IfThenLogicBeginBrick*)brick).ifEndBrick.brickTitle])
        return NO;
    if(![self.ifCondition isEqualToFormula:((IfThenLogicBeginBrick*)brick).ifCondition])
        return NO;
    return YES;
}

#pragma mark - Resources
- (NSInteger)getRequiredResources
{
    return [self.ifCondition getRequiredResources];
}
@end
