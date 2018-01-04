/**
 *  Copyright (C) 2010-2018 The Catrobat Team
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

#import "ChangeVolumeByNBrick.h"
#import "Script.h"

@implementation ChangeVolumeByNBrick

@synthesize volume  = _volume;

- (Formula*)formulaForLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    return self.volume;
}

- (void)setFormula:(Formula*)formula forLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    self.volume = formula;
}

- (BOOL)allowsStringFormula
{
    return NO;
}

- (NSArray*)getFormulas
{
    return @[self.volume];
}

- (void)setDefaultValuesForObject:(SpriteObject*)spriteObject
{
    self.volume = [[Formula alloc] initWithInteger:-10];
}

- (NSString*)brickTitle
{
    return [kLocalizedChangeVolumeByN stringByAppendingString:@"%@"];
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"Change Volume by: %f%%)", [self.volume interpretDoubleForSprite:self.script.object]/100.0f];
}

#pragma mark - Resources
- (NSInteger)getRequiredResources
{
    return [self.volume getRequiredResources];
}

@end
