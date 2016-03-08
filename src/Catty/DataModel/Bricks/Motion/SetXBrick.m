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


#import "SetXBrick.h"
#import "Formula.h"
#import "Logger.h"
#import "Script.h"

@implementation SetXBrick

- (Formula*)formulaForLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    return self.xPosition;
}

- (void)setFormula:(Formula*)formula forLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    self.xPosition = formula;
}

- (NSArray*)getFormulas
{
    return @[self.xPosition];
}

- (BOOL)allowsStringFormula
{
    return NO;
}

- (void)setDefaultValuesForObject:(SpriteObject*)spriteObject
{
    self.xPosition = [[Formula alloc] initWithInteger:100];
}

- (NSString*)brickTitle
{
    return kLocalizedSetX;
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"SetXBrick (x-Pos:%f)", [self.xPosition interpretDoubleForSprite:self.script.object]];
}

#pragma mark - Resources
- (NSInteger)getRequiredResources
{
    return [self.xPosition getRequiredResources];
}
@end
