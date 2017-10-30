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

#import "UserVariable.h"
#import "Util.h"
#import "CBMutableCopyContext.h"

@implementation UserVariable

- (NSString*)description
{
    return [NSString stringWithFormat:@"UserVariable: Name: %@, Value: %@", self.name, self.value ];
}

- (BOOL)isEqualToUserVariable:(UserVariable*)userVariable
{
    if ([self.name isEqualToString:userVariable.name] && [Util isEqual:self.value toObject:userVariable.value] &&
        (self.isList == userVariable.isList))
        return YES;
    return NO;
}

#pragma mark - Copy
- (id)mutableCopyWithContext:(CBMutableCopyContext*)context
{
    return self;
}

@end
