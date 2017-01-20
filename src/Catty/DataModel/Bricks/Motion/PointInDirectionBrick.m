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

#import "PointInDirectionBrick.h"
#import "Formula.h"
#import "Util.h"
#import "Script.h"

@implementation PointInDirectionBrick

- (Formula*)formulaForLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    return self.degrees;
}

- (void)setFormula:(Formula*)formula forLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    self.degrees = formula;
}

- (NSArray*)getFormulas
{
    return @[self.degrees];
}

- (BOOL)allowsStringFormula
{
    return NO;
}

- (void)setDefaultValuesForObject:(SpriteObject*)spriteObject
{
    self.degrees = [[Formula alloc] initWithInteger:90];
}

- (NSString*)brickTitle
{
    return kLocalizedPointInDirection;
}

#pragma mark - Description
- (NSString*)description
{
    double deg = [self.degrees interpretDoubleForSprite:self.script.object];
    return [NSString stringWithFormat:@"PointInDirection: %f", deg];
}

#pragma mark - Resources
- (NSInteger)getRequiredResources
{
    return [self.degrees getRequiredResources];
}

@end
