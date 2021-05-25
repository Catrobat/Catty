/**
 *  Copyright (C) 2010-2021 The Catrobat Team
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

@class GDataXMLElement;
@class GDataXMLNode;
@class Formula;
@class Look;
@class Sound;
@class UserVariable;
@class SpriteObject;
@class OrderedMapTable;
@class CBXMLParserContext;
@class UserList;

@interface CBXMLParserHelper : NSObject

+ (BOOL)validateXMLElement:(GDataXMLElement*)xmlElement forNumberOfChildNodes:(NSUInteger)numberOfChildNodes;
+ (BOOL)validateXMLElement:(GDataXMLElement*)xmlElement forNumberOfChildNodes:(NSUInteger)numberOfChildNodes AndFormulaListWithTotalNumberOfFormulas:(NSUInteger)numberOfFormulas;
+ (BOOL)validateXMLElement:(GDataXMLElement*)xmlElement forFormulaListWithTotalNumberOfFormulas:(NSUInteger)numberOfFormulas;
+ (Formula*)formulaInXMLElement:(GDataXMLElement*)xmlElement forCategoryName:(NSString*)categoryName withContext:(CBXMLParserContext*)context;

+ (id)valueForHeaderProperty:(NSString*)headerPropertyName andXMLNode:(GDataXMLNode*)propertyNode;
+ (BOOL)isReferenceElement:(GDataXMLElement*)xmlElement;
+ (SpriteObject*)findSpriteObjectInArray:(NSArray*)spriteObjectList withName:(NSString*)spriteObjectName;
+ (Look*)findLookInArray:(NSArray*)lookList withName:(NSString*)lookName;
+ (Sound*)findSoundInArray:(NSArray*)soundList withName:(NSString*)soundName;
+ (UserVariable*)findUserVariableInArray:(NSArray<UserVariable *>*)userVariableList withName:(NSString*)userVariableName;
+ (UserList*)findUserListInArray:(NSArray<UserList*>*)userLists withName:(NSString*)userVariableName;

@end
