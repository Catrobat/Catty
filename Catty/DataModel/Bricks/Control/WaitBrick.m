/**
 *  Copyright (C) 2010-2019 The Catrobat Team
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


#import "WaitBrick.h"
#import "Script.h"

@implementation WaitBrick

- (Formula*)formulaForLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    return self.timeToWaitInSeconds;
}

- (void)setFormula:(Formula*)formula forLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    self.timeToWaitInSeconds = formula;
}

- (NSArray*)getFormulas
{
    return @[self.timeToWaitInSeconds];
}

- (BOOL)allowsStringFormula
{
    return NO;
}

- (void)setDefaultValuesForObject:(SpriteObject*)spriteObject
{
    self.timeToWaitInSeconds = [[Formula alloc] initWithInteger:1];
}

- (NSString*)brickTitle
{
    NSString* timeToWaitStr = [self.timeToWaitInSeconds isSingularNumber] ? kLocalizedSecond : kLocalizedSeconds;
    return [kLocalizedWait stringByAppendingString:[@" %@ " stringByAppendingString:timeToWaitStr]];
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"WaitBrick"];
}

#pragma mark - Resources
- (NSInteger)getRequiredResources
{
    return [self.timeToWaitInSeconds getRequiredResources];
}
@end
