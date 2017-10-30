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

#import "FlashBrick.h"

@implementation FlashBrick

- (NSString*)brickTitle
{
    return [kLocalizedFlash stringByAppendingString:@"\n%@"];
}

- (id)initWithChoice:(int)choice
{
    self = [super init];
    if (self)
    {
        self.flashChoice = choice;
    }
    return self;
}

- (void)setDefaultValuesForObject:(SpriteObject*)spriteObject
{
    self.flashChoice = 0;
}

- (void)setChoice:(NSString*)choice forLineNumber:(NSInteger)lineNumber
andParameterNumber:(NSInteger)paramNumber
{
    if ([choice isEqualToString:kLocalizedOff]) {
        self.flashChoice = 0;
    } else {
        self.flashChoice = 1;
    }
}

- (NSString*)choiceForLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    NSArray *choices = [self possibleChoicesForLineNumber:1 andParameterNumber:0];
    return choices[self.flashChoice];
}

- (NSArray<NSString *>*)possibleChoicesForLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    NSArray<NSString *> *choices = [NSArray arrayWithObjects: kLocalizedOff, kLocalizedOn, nil];
    return choices;
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"flash choice (%i)", self.flashChoice];
}

#pragma mark - Resources
- (NSInteger)getRequiredResources
{
    return kNoResources;
}

@end
