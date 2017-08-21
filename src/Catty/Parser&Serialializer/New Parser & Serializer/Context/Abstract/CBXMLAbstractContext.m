/**
 *  Copyright (C) 2010-2017 The Catrobat Team
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

#import "CBXMLAbstractContext.h"
#import "CBXMLOpenedNestingBricksStack.h"
#import "OrderedMapTable.h"

@implementation CBXMLAbstractContext

#pragma mark - Getters and Setters
- (CBXMLOpenedNestingBricksStack*)openedNestingBricksStack
{
    if(!_openedNestingBricksStack)
        _openedNestingBricksStack = [[CBXMLOpenedNestingBricksStack alloc] init];

    return _openedNestingBricksStack;
}

- (NSMutableArray*)pointedSpriteObjectList
{
    if (! _pointedSpriteObjectList) {
        _pointedSpriteObjectList = [NSMutableArray array];
    }
    return _pointedSpriteObjectList;
}

- (NSMutableArray*)spriteObjectList
{
    if (! _spriteObjectList) {
        _spriteObjectList = [NSMutableArray array];
    }
    return _spriteObjectList;
}

- (NSMutableArray*)programVariableList
{
    if (! _programVariableList) {
        _programVariableList = [NSMutableArray array];
    }
    return _programVariableList;
}

- (OrderedMapTable *)objectVariableList {
    if (! _objectVariableList) {
        _objectVariableList = [OrderedMapTable weakToStrongObjectsMapTable];
    }
    return _objectVariableList;
}

- (id)mutableCopy
{
    CBXMLAbstractContext *copiedContext = [[self class] new];
    copiedContext.openedNestingBricksStack = [self.openedNestingBricksStack mutableCopy];
    copiedContext.pointedSpriteObjectList = [self.pointedSpriteObjectList mutableCopy];
    copiedContext.spriteObjectList = [self.spriteObjectList mutableCopy];
    copiedContext.spriteObject = self.spriteObject;
    copiedContext.programVariableList = [self.programVariableList mutableCopy];
    copiedContext.objectVariableList = [self.objectVariableList mutableCopy];
    return copiedContext;
}

@end
