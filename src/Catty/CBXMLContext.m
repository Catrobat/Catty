/**
 *  Copyright (C) 2010-2014 The Catrobat Team
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

#import "CBXMLContext.h"
#import "CBXMLOpenedNestingBricksStack.h"

@interface CBXMLContext ()

@property (nonatomic, strong, readwrite) NSMutableArray *userVariableList;

@end

@implementation CBXMLContext

#pragma mark - Getters and Setters
- (NSMutableArray*)userVariableList
{
    if (! _userVariableList) {
        _userVariableList = [NSMutableArray array];
    }
    return _userVariableList;
}

#pragma mark - Initializers

- (id)initWithSpriteObjectList:(NSMutableArray*)spriteObjectList
{
    self = [super init];
    if(self) {
        self.spriteObjectList = spriteObjectList;
    }
    
    return self;
}

- (id)initWithLookList:(NSMutableArray*)lookList
{
    self = [super init];
    if(self) {
        self.lookList = lookList;
    }
    
    return self;
}

- (id)initWithSoundList:(NSMutableArray*)soundList
{
    self = [super init];
    if(self) {
        self.soundList = soundList;
    }
    
    return self;
}

- (CBXMLOpenedNestingBricksStack*)openedNestingBricksStack
{
    if(!_openedNestingBricksStack)
        _openedNestingBricksStack = [[CBXMLOpenedNestingBricksStack alloc] init];
    
    return _openedNestingBricksStack;
}

@end
