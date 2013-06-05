/**
 *  Copyright (C) 2010-2013 The Catrobat Team
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


#import "Look.h"

@interface Look ()


@end

@implementation Look

@synthesize fileName = _costumeFileName;
@synthesize name = _costumeName;

#pragma mark - init methods
- (id)initWithPath:(NSString*)filePath
{
    self = [super init];
    if (self) 
    {
        self.name = nil;
        if (filePath == nil || [filePath length] == 0)
        {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:@"You cannot instantiate a costume without a file path"
                                         userInfo:nil];
            return nil;
        }
        else 
        {
            self.fileName = filePath;
        }
    }
    return self;
}


- (id)initWithName:(NSString*)name andPath:(NSString*)filePath
{
    self = [super init];
    if (self) 
    {
        self.name = name;
        if (filePath == nil || [filePath length] == 0)
        {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:@"You cannot instantiate a costume without a file path"
                                         userInfo:nil];
            return nil;
        }
        else 
        {
            self.fileName = filePath;
        }
    }
    return self;
}


#pragma mark - description
- (NSString*)description {
    return [NSString stringWithFormat:@"Name: %@\rPath: %@\r", self.name, self.fileName];
}

@end
