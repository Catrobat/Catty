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

#import <Foundation/Foundation.h>
#import "CBXMLAbstractContext.h"

@class CBXMLOpenedNestingBricksStack;
@class CBXMLPositionStack;
@class SpriteObject;
@class VariablesContainer;

@interface CBXMLSerializerContext : CBXMLAbstractContext

//------------------------------------------------------------------------------------------------------------
// navigational, nesting and recursion depth data used while traversing the tree
//------------------------------------------------------------------------------------------------------------
@property (nonatomic, strong) CBXMLPositionStack *currentPositionStack; // stack to keep track of current position (used for serialization only)

// contains SpriteObject names as the dictionary's keys and their current position on the stack (pointer to
// a CBXMLPositionStack instance) as the dictionary's values (used for serialization only)
@property (nonatomic, strong) NSMutableDictionary *spriteObjectNamePositions;

// contains SpriteObject names as the dictionary's keys and NSMutableArrays containing their current position
// on the stack (pointer to a CBXMLPositionStack instance) as the dictionary's values (used for
// serialization only)
@property (nonatomic, strong) NSMutableDictionary *spriteObjectNameUserVariableListPositions;

// contains UserVariable names as the dictionary's keys and their current position on the stack (pointer to
// a CBXMLPositionStack instance) as the dictionary's values (used for serialization only)
@property (nonatomic, strong) NSMutableDictionary *programUserVariableNamePositions;

//------------------------------------------------------------------------------------------------------------
// ressources data used while traversing the tree
//------------------------------------------------------------------------------------------------------------
// TODO: refactor this later: remove brickList here and dynamically find brick in scriptList. maybe scripts should be referenced in bricks as well!!
@property (nonatomic, strong) NSMutableArray *brickList; // contains all bricks (used only by serializer)

- (id)mutableCopy;

@end
