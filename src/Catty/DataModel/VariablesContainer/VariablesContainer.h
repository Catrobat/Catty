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

- (UserVariable*)getUserVariableNamed:(NSString*)name forSpriteObject:(SpriteObject*)sprite isList:(BOOL)isList;

- (BOOL)removeUserVariableNamed:(NSString*)name forSpriteObject:(SpriteObject*)sprite;

- (void)setUserVariable:(UserVariable*)userVariable toValue:(id)value;

- (void)changeVariable:(UserVariable*)userVariable byValue:(double)value;

// Array of UserVariable
- (NSArray*)allVariablesForObject:(SpriteObject*)spriteObject;

// Array of Variables
- (NSMutableArray*)allVariables;
// Array of Lists
- (NSMutableArray*)allLists;
// Array of Variables and Lists
- (NSMutableArray*)allVariablesAndLists;

// Array of UserVariable
- (NSArray*)objectVariablesForObject:(SpriteObject*)spriteObject;

- (SpriteObject*)spriteObjectForObjectVariable:(UserVariable*)userVariable;

- (BOOL)isVariableOfSpriteObject:(SpriteObject*)spriteObject userVariable:(UserVariable*)userVariable;

- (BOOL)isProgramVariable:(UserVariable*)userVariable;

- (void)removeObjectVariablesForSpriteObject:(SpriteObject*)object;

- (BOOL)isEqualToVariablesContainer:(VariablesContainer*)variablesContainer;

- (id)mutableCopy;

@end
