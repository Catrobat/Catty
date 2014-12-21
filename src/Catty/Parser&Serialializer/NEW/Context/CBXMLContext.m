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

- (NSMutableArray*)lookList
{
    if (! _lookList) {
        _lookList = [NSMutableArray array];
    }
    return _lookList;
}

- (NSMutableArray*)soundList
{
    if (! _soundList) {
        _soundList = [NSMutableArray array];
    }
    return _soundList;
}

- (NSMutableArray*)brickList
{
    if (! _brickList) {
        _brickList = [NSMutableArray array];
    }
    return _brickList;
}

- (VariablesContainer*)variables
{
    if (! _variables) {
        _variables = [VariablesContainer new];
    }
    return _variables;
}


- (instancetype)shallowCopy
{
    CBXMLContext *copiedContext = [CBXMLContext new];
    copiedContext.openedNestingBricksStack = [self.openedNestingBricksStack shallowCopy];
    copiedContext.currentPositionStack = [self.currentPositionStack shallowCopy];
    copiedContext.spriteObjectNamePositions = [self.spriteObjectNamePositions mutableCopy];
    copiedContext.programUserVariableNamePositions = [self.programUserVariableNamePositions mutableCopy];
    copiedContext.pointedSpriteObjectList = [self.pointedSpriteObjectList mutableCopy];
    copiedContext.spriteObjectList = [self.spriteObjectList mutableCopy];
    copiedContext.lookList = [self.lookList mutableCopy];
    copiedContext.soundList = [self.soundList mutableCopy];
    copiedContext.brickList = [self.brickList mutableCopy];
    copiedContext.variables = [self.variables shallowCopy];
    return copiedContext;
}

@end
