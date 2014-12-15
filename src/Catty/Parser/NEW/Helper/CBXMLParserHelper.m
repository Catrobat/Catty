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

#import "CBXMLParserHelper.h"
#import "CBXMLValidator.h"
#import "GDataXMLNode+CustomExtensions.h"
#import "CBXMLContext.h"
#import "Formula+CBXMLHandler.h"
#import "Header+CBXMLHandler.h"
#import "Look+CBXMLHandler.h"
#import "Sound+CBXMLHandler.h"
#import "UserVariable+CBXMLHandler.h"
#import "SpriteObject+CBXMLHandler.h"
#import "CatrobatLanguageDefines.h"
#import <objc/runtime.h>

#define kCatroidXMLPrefix               @"org.catrobat.catroid.content."
#define kCatroidXMLSpriteList           @"spriteList"
#define kParserObjectTypeString         @"T@\"NSString\""
#define kParserObjectTypeNumber         @"T@\"NSNumber\""
#define kParserObjectTypeArray          @"T@\"NSArray\""
#define kParserObjectTypeMutableArray   @"T@\"NSMutableArray\""
#define kParserObjectTypeMutableDictionary @"T@\"NSMutableDictionary\""
#define kParserObjectTypeDate           @"T@\"NSDate\""

@implementation CBXMLParserHelper

+ (BOOL)validateXMLElement:(GDataXMLElement*)xmlElement forNumberOfChildNodes:(NSUInteger)numberOfChildNodes
{
  [XMLError exceptionIf:[xmlElement childCount]
              notEquals:numberOfChildNodes
                message:@"Too less or too many child nodes found... (%lu expected)", (unsigned long)numberOfChildNodes];
  return true;
}

+ (BOOL)validateXMLElement:(GDataXMLElement*)xmlElement forNumberOfChildNodes:(NSUInteger)numberOfChildNodes AndFormulaListWithTotalNumberOfFormulas:(NSUInteger)numberOfFormulas
{
  [[self class] validateXMLElement:xmlElement forNumberOfChildNodes:numberOfChildNodes];
  
  GDataXMLElement *formulaListElement = [xmlElement childWithElementName:@"formulaList"];
  [XMLError exceptionIfNil:formulaListElement message:@"No formulaList element found..."];
  [XMLError exceptionIf:[formulaListElement childCount] notEquals:numberOfFormulas message:@"Too many formulas found (%lu expected)", (unsigned long)numberOfFormulas];
  
  return true;
}

+ (Formula*)formulaInXMLElement:(GDataXMLElement*)xmlElement forCategoryName:(NSString*)categoryName
{
  GDataXMLElement *formulaListElement = [xmlElement childWithElementName:@"formulaList"];
  [XMLError exceptionIfNil:formulaListElement message:@"No formulaList element found..."];
  GDataXMLElement *formulaElement = [formulaListElement childWithElementName:@"formula"
                                                         containingAttribute:@"category"
                                                                   withValue:categoryName];
  [XMLError exceptionIfNil:formulaElement message:@"No formula with category %@ found...", categoryName];
  Formula *formula = [Formula parseFromElement:formulaElement withContext:nil];
  [XMLError exceptionIfNil:formula message:@"Unable to parse formula..."];
  return formula;
}

+ (const char*)typeStringForProperty:(objc_property_t)property
{
  const char *attrs = property_getAttributes(property);
  if (attrs == NULL) { return NULL; }
  
  static char buffer[256];
  const char *e = strchr(attrs, ',');
  if (e == NULL) { return NULL; }
  
  int len = (int)(e - attrs);
  memcpy(buffer, attrs, len);
  buffer[len] = '\0';
  return buffer;
}

+ (id)valueForHeaderPropertyNode:(GDataXMLNode*)propertyNode
{
  objc_property_t property = class_getProperty([Header class], [propertyNode.name UTF8String]);
  [XMLError exceptionIfNull:property message:@"Invalid header property %@ given", propertyNode.name];
  NSString *propertyType = [NSString stringWithUTF8String:[[self class] typeStringForProperty:property]];
  id value = nil;
  if ([propertyType isEqualToString:kParserObjectTypeString]) {
    value = [propertyNode stringValue];
  } else if ([propertyType isEqualToString:kParserObjectTypeNumber]) {
    value = [NSNumber numberWithFloat:[[propertyNode stringValue]floatValue]];
  } else if ([propertyType isEqualToString:kParserObjectTypeDate]) {
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    [dateFormatter setDateFormat:kCatrobatHeaderDateTimeFormat];
    value = [dateFormatter dateFromString:propertyNode.stringValue];
  } else {
    [XMLError exceptionWithMessage:@"Unsupported type for property %@ (of type: %@) in header", propertyNode.name, propertyType];
  }
  return value;
}

+ (id)valueForPropertyNode:(GDataXMLNode*)propertyNode
{
    // TODO: stub method => implement this!!
  [XMLError exceptionWithMessage:@"valueForPropertyNode: NOT IMPLEMENTED YET!!!"];
  return nil;
}

+ (BOOL)isReferenceElement:(GDataXMLElement*)xmlElement
{
  return ([xmlElement attributeForName:@"reference"] ? YES : NO);
}

+ (SpriteObject*)findSpriteObjectInArray:(NSArray*)spriteObjectList withName:(NSString*)spriteObjectName
{
  for (SpriteObject *spriteObject in spriteObjectList) {
    if ([spriteObject.name isEqualToString:spriteObjectName]) { // TODO: implement isEqual in SpriteObject class
      return spriteObject;
    }
  }
  return nil;
}

+ (Look*)findLookInArray:(NSArray*)lookList withName:(NSString*)lookName
{
  for (Look *look in lookList) {
    if ([look.name isEqualToString:lookName]) { // TODO: implement isEqual in SpriteObject class
      return look;
    }
  }
  return nil;
}

+ (Sound*)findSoundInArray:(NSArray*)soundList withName:(NSString*)soundName
{
  for (Sound *sound in soundList) {
    if ([sound.name isEqualToString:soundName]) { // TODO: implement isEqual in SpriteObject class
      return sound;
    }
  }
  return nil;
}

+ (UserVariable*)findUserVariableInArray:(NSArray*)userVariableList withName:(NSString*)userVariableName
{
  for (UserVariable *userVariable in userVariableList) {
    if ([userVariable.name isEqualToString:userVariableName]) { // TODO: implement isEqual in UserVariable class
      return userVariable;
    }
  }
  return nil;
}

@end

