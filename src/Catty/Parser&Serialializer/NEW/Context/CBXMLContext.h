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

#import <Foundation/Foundation.h>

@class CBXMLOpenedNestingBricksStack;
@class GDataXMLElement;
@class CBXMLPositionStack;

@interface CBXMLContext : NSObject

@property (nonatomic, strong) CBXMLOpenedNestingBricksStack *openedNestingBricksStack;
@property (nonatomic, strong, readonly) NSMutableArray *userVariableList; // contains all already parsed UserVariables
@property (nonatomic, strong, readonly) NSMutableArray *pointedSpriteObjectList; // contains all already parsed pointed (!!) SpriteObjects
@property (nonatomic, strong) NSMutableArray *spriteObjectList; // contains all known SpriteObjects
@property (nonatomic, strong) NSMutableArray *lookList; // contains all looks of currently parsed/serialized SpriteObject
@property (nonatomic, strong) NSMutableArray *soundList; // contains all sounds of currently parsed/serialized SpriteObject

@property (nonatomic, strong) CBXMLPositionStack *currentPositionStack; // program xml element

- (id)initWithSpriteObjectList:(NSArray*)spriteObjectList;
- (id)initWithLookList:(NSArray*)lookList;
- (id)initWithSoundList:(NSArray*)soundList;

@end
