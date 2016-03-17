/**
 *  Copyright (C) 2010-2016 The Catrobat Team
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

#import "ChangeXByNBrick.h"
#import "Formula.h"
#import "Script.h"
#import "Pocket_Code-Swift.h"

@implementation ChangeXByNBrick

- (Formula*)formulaForLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    return self.xMovement;
}

- (void)setFormula:(Formula*)formula forLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    self.xMovement = formula;
}

- (NSArray*)getFormulas
{
    return @[self.xMovement];
}

- (BOOL)allowsStringFormula
{
    return NO;
}

- (void)setDefaultValuesForObject:(SpriteObject*)spriteObject
{
    self.xMovement = [[Formula alloc] initWithInteger:10];
}

- (NSString*)brickTitle
{
    return kLocalizedChangeX;
}

#pragma mark - Description
- (NSString*)description
{
    double xMov = [self.xMovement interpretDoubleForSprite:self.script.object];
    return [NSString stringWithFormat:@"ChangeXBy (%f)", xMov];
}

#pragma mark - Resources
- (NSInteger)getRequiredResources
{
    return [self.xMovement getRequiredResources];
}
@end
