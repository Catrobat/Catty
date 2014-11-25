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

#import "CBParserProtocol.h"
#import <objc/runtime.h>

@class GDataXMLDocument;
@class GDataXMLNode;
@class GDataXMLElement;
@class SpriteObject;
@class Look;
@class Sound;
@class UserVariable;

@interface CBXMLParser : NSObject <CBParserProtocol>

- (id)initWithPath:(NSString*)path;
- (BOOL)isSupportedLanguageVersion:(CGFloat)languageVersion;
- (Program*)parseAndCreateProgram;

// helpers (used by the sub-parsing system)
+ (id)valueForHeaderPropertyNode:(GDataXMLNode*)propertyNode;
+ (id)valueForPropertyNode:(GDataXMLNode*)propertyNode;
+ (BOOL)isReferenceElement:(GDataXMLElement*)xmlElement;
+ (SpriteObject*)findSpriteObjectInArray:(NSArray*)spriteObjectList withName:(NSString*)spriteObjectName;
+ (Look*)findLookInArray:(NSArray*)lookList withName:(NSString*)lookName;
+ (Sound*)findSoundInArray:(NSArray*)soundList withName:(NSString*)soundName;
+ (UserVariable*)findUserVariableInArray:(NSArray*)userVariableList withName:(NSString*)userVariableName;

@end
