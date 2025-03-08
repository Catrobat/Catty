/**
 *  Copyright (C) 2010-2024 The Catrobat Team
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

#import "ChooseCameraBrick.h"

@implementation ChooseCameraBrick

- (NSArray<NSNumber *> *)category
{
    return @[@(kLookBrick)];
}

- (id)initWithChoice:(int)choice
{
    self = [super init];
    if (self)
    {
        self.cameraPosition = choice;
    }
    return self;
}

- (void)setDefaultValuesForObject:(SpriteObject*)spriteObject
{
    self.cameraPosition = 1;
}

- (void)setChoice:(NSString*)choice forLineNumber:(NSInteger)lineNumber
andParameterNumber:(NSInteger)paramNumber
{
    if ([choice isEqualToString:kLocalizedCameraBack]) {
        self.cameraPosition = 0;
    } else {
        self.cameraPosition = 1;
    }
}

- (NSString*)choiceForLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    NSArray *choices = [self possibleChoicesForLineNumber:1 andParameterNumber:0];
    return choices[self.cameraPosition];
}

- (NSArray<NSString *>*)possibleChoicesForLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    NSArray<NSString *> *choices = [NSArray arrayWithObjects: kLocalizedCameraBack, kLocalizedCameraFront, nil];
    return choices;
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"camera position (%i)", self.cameraPosition];
}

#pragma mark - Resources
- (NSInteger)getRequiredResources
{
    return kNoResources;
}

@end
