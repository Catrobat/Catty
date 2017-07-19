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


@class SpriteObject;
@class UserVariable;
@class OrderedMapTable;

@interface VariablesContainer : NSObject

// Map<Sprite, List<UserVariable>
@property (nonatomic, strong) OrderedMapTable *objectVariableList;
@property (nonatomic, strong) OrderedMapTable *objectListOfLists;

// List<UserVariable>
@property (nonatomic, strong) NSMutableArray *programVariableList;
@property (nonatomic, strong) NSMutableArray *programListOfLists;

- (UserVariable*)getUserVariableNamed:(NSString*)name forSpriteObject:(SpriteObject*)sprite;
- (UserVariable*)getUserListNamed:(NSString*)name forSpriteObject:(SpriteObject*)sprite;


- (BOOL)removeUserVariableNamed:(NSString*)name forSpriteObject:(SpriteObject*)sprite;
- (BOOL)removeUserListNamed:(NSString*)name forSpriteObject:(SpriteObject*)sprite;


- (void)setUserVariable:(UserVariable*)userVariable toValue:(id)value;

- (void)changeVariable:(UserVariable*)userVariable byValue:(double)value;

- (void)addToUserList:(UserVariable*)userList value:(id)value;

- (void)insertToUserList:(UserVariable*)userList value:(id)value atIndex:(id)position;

- (void)replaceItemInUserList:(UserVariable*)userList value:(id)value atIndex:(id)position;

// Array of UserVariable
- (NSArray*)allVariablesForObject:(SpriteObject*)spriteObject;
- (NSArray*)allListsForObject:(SpriteObject*)spriteObject;

// Array of Variables
- (NSMutableArray*)allVariables;
// Array of Lists
- (NSMutableArray*)allLists;
// Array of Variables and Lists
- (NSMutableArray*)allVariablesAndLists;

// Array of UserVariable
- (NSArray*)objectVariablesForObject:(SpriteObject*)spriteObject;
- (NSArray*)objectListsForObject:(SpriteObject*)spriteObject;

- (SpriteObject*)spriteObjectForObjectVariable:(UserVariable*)userVariable;

- (BOOL)isVariableOfSpriteObject:(SpriteObject*)spriteObject userVariable:(UserVariable*)userVariable;

- (BOOL)isProgramVariableOrList:(UserVariable*)userVariable;

- (void)removeObjectVariablesForSpriteObject:(SpriteObject*)object;
- (void)removeObjectListsForSpriteObject:(SpriteObject*)object;

- (BOOL)isEqualToVariablesContainer:(VariablesContainer*)variablesContainer;

- (id)mutableCopy;

@end
