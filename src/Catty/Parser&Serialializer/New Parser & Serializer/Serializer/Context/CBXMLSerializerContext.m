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

#import "CBXMLSerializerContext.h"
#import "CBXMLPositionStack.h"

@implementation CBXMLSerializerContext

#pragma mark - Getters and Setters
- (CBXMLPositionStack*)currentPositionStack
{
    if(! _currentPositionStack)
        _currentPositionStack = [[CBXMLPositionStack alloc] init];

    return _currentPositionStack;
}

- (NSMutableDictionary*)spriteObjectNamePositions
{
    if(! _spriteObjectNamePositions)
        _spriteObjectNamePositions = [NSMutableDictionary dictionary];

    return _spriteObjectNamePositions;
}

- (NSMutableDictionary*)spriteObjectNameUserVariableListPositions
{
    if(! _spriteObjectNameUserVariableListPositions)
        _spriteObjectNameUserVariableListPositions = [NSMutableDictionary dictionary];
    
    return _spriteObjectNameUserVariableListPositions;
}

- (NSMutableDictionary*)programUserVariableNamePositions
{
    if(! _programUserVariableNamePositions)
        _programUserVariableNamePositions = [NSMutableDictionary dictionary];

    return _programUserVariableNamePositions;
}

- (NSMutableDictionary*)spriteObjectNameUserListOfListsPositions
{
    if(! _spriteObjectNameUserListOfListsPositions)
        _spriteObjectNameUserListOfListsPositions = [NSMutableDictionary dictionary];
    
    return _spriteObjectNameUserListOfListsPositions;
}

- (NSMutableDictionary*)programUserListNamePositions
{
    if(! _programUserListNamePositions)
        _programUserListNamePositions = [NSMutableDictionary dictionary];
    
    return _programUserListNamePositions;
}

- (NSMutableArray*)brickList
{
    if (! _brickList) {
        _brickList = [NSMutableArray array];
    }
    return _brickList;
}

- (id)mutableCopy
{
    CBXMLSerializerContext *copiedContext = [super mutableCopy];
    copiedContext.currentPositionStack = [self.currentPositionStack mutableCopy];
    copiedContext.spriteObjectNamePositions = [self.spriteObjectNamePositions mutableCopy];
    copiedContext.programUserVariableNamePositions = [self.programUserVariableNamePositions mutableCopy];
    copiedContext.programUserListNamePositions = [self.programUserListNamePositions mutableCopy];
    copiedContext.spriteObjectNameUserVariableListPositions = [self.spriteObjectNameUserVariableListPositions mutableCopy];
    copiedContext.spriteObjectNameUserListOfListsPositions = [self.spriteObjectNameUserListOfListsPositions mutableCopy];
    copiedContext.brickList = [self.brickList mutableCopy];
    return copiedContext;
}

@end
