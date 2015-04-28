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

#import "VariablePickerData.h"

@implementation VariablePickerData

- (instancetype)initWithTitle:(NSString*)title
{
    self = [super init];
    if(self) {
        self.title = title;
        self.isProgramVariable = NO;
        self.userVariable = nil;
    }
    return self;
}

- (instancetype)initWithTitle:(NSString*)title andVariable:(UserVariable*)userVariable
{
    self = [self initWithTitle:title];
    if(self) {
        self.userVariable = userVariable;
    }
    return self;
}

- (BOOL)isLabel
{
    return self.userVariable == nil;
}

@end
