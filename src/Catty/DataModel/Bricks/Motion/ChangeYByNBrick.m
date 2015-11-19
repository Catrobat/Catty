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

#import "ChangeYByNBrick.h"
#import "Formula.h"
#import "Script.h"
#import "Pocket_Code-Swift.h"

@implementation ChangeYByNBrick

- (Formula*)formulaForLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    return self.yMovement;
}

- (void)setFormula:(Formula*)formula forLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    self.yMovement = formula;
}

- (NSArray*)getFormulas
{
    return @[self.yMovement];
}

- (void)setDefaultValuesForObject:(SpriteObject*)spriteObject
{
    self.yMovement = [[Formula alloc] initWithInteger:10];
}

- (NSString*)brickTitle
{
    return kLocalizedChangeY;
}

#pragma mark - Description
- (NSString*)description
{
    double yMov = [self.yMovement interpretDoubleForSprite:self.script.object];
    return [NSString stringWithFormat:@"ChangeYBy (%f)", yMov];
}
#pragma mark - Resources
- (NSInteger)getRequiredResources
{
    return [self.yMovement getRequiredResources];
}
@end
