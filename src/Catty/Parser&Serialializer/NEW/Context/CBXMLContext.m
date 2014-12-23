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
#import "CBXMLPositionStack.h"
#import "VariablesContainer.h"

@implementation CBXMLContext

#pragma mark - Getters and Setters
- (CBXMLOpenedNestingBricksStack*)openedNestingBricksStack
{
    if(!_openedNestingBricksStack)
        _openedNestingBricksStack = [[CBXMLOpenedNestingBricksStack alloc] init];

    return _openedNestingBricksStack;
}

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

- (NSMutableDictionary*)programUserVariableNamePositions
{
    if(! _programUserVariableNamePositions)
        _programUserVariableNamePositions = [NSMutableDictionary dictionary];

    return _programUserVariableNamePositions;
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

- (NSMutableArray*)brickList
{
    if (! _brickList) {
        _brickList = [NSMutableArray array];
    }
    return _brickList;
}

- (NSMutableArray*)programVariableList
{
    if (! _programVariableList) {
        _programVariableList = [NSMutableArray array];
    }
    return _programVariableList;
}

- (NSMutableDictionary*)spriteObjectNameVariableList
{
    if (! _spriteObjectNameVariableList) {
        _spriteObjectNameVariableList = [NSMutableDictionary dictionary];
    }
    return _spriteObjectNameVariableList;
}

- (VariablesContainer*)variables
{
    if (! _variables) {
        _variables = [VariablesContainer new];
    }
    return _variables;
}

- (id)mutableCopy
{
    CBXMLContext *copiedContext = [CBXMLContext new];
    copiedContext.openedNestingBricksStack = [self.openedNestingBricksStack mutableCopy];
    copiedContext.currentPositionStack = [self.currentPositionStack mutableCopy];
    copiedContext.spriteObjectNamePositions = [self.spriteObjectNamePositions mutableCopy];
    copiedContext.programUserVariableNamePositions = [self.programUserVariableNamePositions mutableCopy];
    copiedContext.pointedSpriteObjectList = [self.pointedSpriteObjectList mutableCopy];
    copiedContext.spriteObjectList = [self.spriteObjectList mutableCopy];
    copiedContext.spriteObject = self.spriteObject;
    copiedContext.brickList = [self.brickList mutableCopy];
    copiedContext.programVariableList = [self.programVariableList mutableCopy];
    copiedContext.spriteObjectNameVariableList = [self.spriteObjectNameVariableList mutableCopy];
    copiedContext.variables = [self.variables mutableCopy];
    return copiedContext;
}

@end
