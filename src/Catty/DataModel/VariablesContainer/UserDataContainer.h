/**
 *  Copyright (C) 2010-2020 The Catrobat Team
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
@class UserList;
@class OrderedMapTable;
@protocol UserDataProtocol;

@interface UserDataContainer : NSObject

// Map<Sprite, List<UserVariable>
@property (nonatomic, strong) OrderedMapTable *objectListOfLists;
@property (nonatomic, strong) OrderedMapTable *objectVariableList;

// List<UserVariable>
@property (nonatomic, strong) NSMutableArray<UserVariable*> *programVariableList;
@property (nonatomic, strong) NSMutableArray<UserList*> *programListOfLists;

- (UserVariable*)getUserVariableNamed:(NSString*)name forSpriteObject:(SpriteObject*)sprite;
- (UserList*)getUserListNamed:(NSString*)name forSpriteObject:(SpriteObject*)sprite;


- (BOOL)removeUserVariableNamed:(NSString*)name forSpriteObject:(SpriteObject*)sprite;
- (BOOL)removeUserListNamed:(NSString*)name forSpriteObject:(SpriteObject*)sprite;


- (void)setUserVariable:(UserVariable*)userVariable toValue:(id)value;

- (void)changeVariable:(UserVariable*)userVariable byValue:(double)value;

// Array of UserVariable
- (NSArray<UserVariable*>*)allVariablesForObject:(SpriteObject*)spriteObject;
- (NSArray<UserList*>*)allListsForObject:(SpriteObject*)spriteObject;

// Array of Variables
- (NSArray<UserVariable*>*)allVariables;
// Array of Lists
- (NSArray<UserList*>*)allLists;

// Array of UserVariable
- (NSArray<UserVariable*>*)objectVariablesForObject:(SpriteObject*)spriteObject;
- (NSArray<UserList*>*)objectListsForObject:(SpriteObject*)spriteObject;

- (BOOL)addObjectVariable:(UserVariable*)userVariable forObject:(SpriteObject*)spriteObject;
- (BOOL)addObjectList:(UserList*)userList forObject:(SpriteObject*)spriteObject;

- (BOOL)isProjectList: (UserList*)userList;
- (BOOL)isProjectVariable: (UserVariable*)userVariable;

- (void)removeObjectVariablesForSpriteObject:(SpriteObject*)object;
- (void)removeObjectListsForSpriteObject:(SpriteObject*)object;

- (BOOL)isEqualToUserDataContainer:(UserDataContainer*)userDataContainer;

- (id)mutableCopy;

@end
