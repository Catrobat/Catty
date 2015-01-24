/**
 *  Copyright (C) 2010-2015 The Catrobat Team
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

#import "GDataXMLElement+CustomExtensions.h"
#import "GDataXMLNode+CustomExtensions.h"
#import "CBXMLContext.h"
#import "CBXMLValidator.h"
#import "CBXMLPositionStack.h"
#import "NSString+CatrobatNSStringExtensions.h"

@implementation GDataXMLElement (CustomExtensions)

- (NSString *)XMLStringPrettyPrinted:(BOOL)isPrettyPrinted
{
  NSString *str = nil;

  if (xmlNode_ != NULL) {

    xmlBufferPtr buff = xmlBufferCreate();
    if (buff) {

      xmlDocPtr doc = NULL;
      int level = 0;

      // NOTE: Yes, strange but true. It's exactly the same code as in the XMLString-method, but this local
      // format-variable is set to fixed value 0.
      int format = (isPrettyPrinted ? 1 : 0);

      int result = xmlNodeDump(buff, doc, xmlNode_, level, format);

      if (result > -1) {
        str = [[NSString alloc] initWithBytes:(xmlBufferContent(buff))
                                        length:(xmlBufferLength(buff))
                                      encoding:NSUTF8StringEncoding];
      }
      xmlBufferFree(buff);
    }
  }

  // remove leading and trailing whitespace
  NSCharacterSet *ws = [NSCharacterSet whitespaceAndNewlineCharacterSet];
  NSString *trimmed = [str stringByTrimmingCharactersInSet:ws];
  return trimmed;
}

- (NSString*)XMLRootElementAsString
{
    NSString *attributesStr = [[NSString alloc] init];
    if ([self isKindOfClass:[GDataXMLElement class]]) {
        GDataXMLElement *element = (GDataXMLElement*)self;
        NSArray *attributesArr = [element attributes];
        for(GDataXMLNode *attribute in attributesArr) {
            attributesStr = [NSString stringWithFormat:@"%@ %@", attributesStr, [attribute XMLString]];
        }
    }
    return [NSString stringWithFormat:@"<%@%@>", [self name], attributesStr];
}

- (GDataXMLElement*)childWithElementName:(NSString*)elementName
{
    NSArray *childElements = [self children];
    for (GDataXMLElement *childElement in childElements) {
        if ([[childElement name] isEqualToString:elementName]) {
            return childElement;
        }
    }
    return nil;
}

- (GDataXMLElement*)childWithElementName:(NSString*)elementName
                     containingAttribute:(NSString*)attributeName
                               withValue:(NSString*)attributeValue
{
    NSArray *childElements = [self children];
    for (GDataXMLElement *childElement in childElements) {
        if (! [[childElement name] isEqualToString:elementName]) {
            continue;
        }
        GDataXMLNode *attributeNode = [childElement attributeForName:attributeName];
        if ((! attributeName) || ! [[attributeNode stringValue] isEqualToString:attributeValue]) {
            continue;
        }
        return childElement;
    }
    return nil;
}

- (GDataXMLElement*)singleNodeForCatrobatXPath:(NSString*)catrobatXPath
{
    NSArray *pathComponents = [catrobatXPath componentsSeparatedByString:@"/"];
    NSMutableString *xPath = [NSMutableString stringWithCapacity:[catrobatXPath length]];
    NSUInteger index = 0;
    NSUInteger numberOfComponents = [pathComponents count];
    for (NSString *pathComponent in pathComponents) {
        if (! pathComponent || (! [pathComponent length])) {
            if (index < (numberOfComponents - 1)) {
                [xPath appendString:@"/"];
            }
            ++index;
            continue;
        }
        [xPath appendString:pathComponent];
        if ([pathComponent isEqualToString:@".."]) {
            if (index < (numberOfComponents - 1)) {
                [xPath appendString:@"/"];
            }
            ++index;
            continue;
        }
        NSUInteger location = [pathComponent rangeOfString:@"]"].location;
        if ((location == NSNotFound) || (location != ([pathComponent length] - 1))) {
            [xPath appendString:@"[1]"];
        }
        if (index < (numberOfComponents - 1)) {
            [xPath appendString:@"/"];
        }
        ++index;
    }

    NSError *error = nil;
    NSArray *nodes = [self nodesForXPath:xPath error:&error];
    if (error || ([nodes count] != 1)) {
        return nil;
    }
    return [nodes firstObject];
}

+ (void)pushToStackElementName:(NSString*)name xPathIndex:(NSUInteger)xPathIndex context:(CBXMLContext*)context
{
    [XMLError exceptionIfNil:name message:@"Given param xmlElement MUST NOT be nil!!"];
    if (context.currentPositionStack) {
        if (xPathIndex > 1) {
            name = [name stringByAppendingFormat:@"[%lu]", xPathIndex];
        }
        [context.currentPositionStack pushXmlElementName:name];
        NSLog(@"+ [%@] added to stack", name);
    }
}

+ (GDataXMLElement*)elementWithName:(NSString*)name context:(CBXMLContext*)context
{
    return [self elementWithName:name xPathIndex:0 context:context];
}

+ (GDataXMLElement*)elementWithName:(NSString*)name xPathIndex:(NSUInteger)xPathIndex
                            context:(CBXMLContext*)context
{
    [[self class] pushToStackElementName:name xPathIndex:xPathIndex context:context];
    return [[self class] elementWithName:name];
}

+ (GDataXMLElement*)elementWithName:(NSString*)name stringValue:(NSString*)value context:(CBXMLContext*)context
{
    return [self elementWithName:name xPathIndex:0 stringValue:value context:context];
}

+ (GDataXMLElement*)elementWithName:(NSString*)name xPathIndex:(NSUInteger)xPathIndex
                        stringValue:(NSString*)value context:(CBXMLContext*)context
{
    [[self class] pushToStackElementName:name xPathIndex:xPathIndex context:context];
    if (value && [value length]) {
        return [[self class] elementWithName:name
                                 stringValue:[value stringByEscapingForXMLValues]];
    }
    return [[self class] elementWithName:name];
}

+ (id)attributeWithName:(NSString*)name escapedStringValue:(NSString*)value
{
    return [[self class] attributeWithName:name stringValue:[value stringByEscapingForXMLValues]];
}

- (void)addChild:(GDataXMLNode*)child context:(CBXMLContext*)context
{
    [XMLError exceptionIf:[context.currentPositionStack isEmpty] equals:YES
                  message:@"Can't pop xml element from stack. Stack is empty!!"];
    NSString *xmlElementName = [context.currentPositionStack popXmlElementName];
    if (context.currentPositionStack) {
        NSLog(@"- [%@] removed from stack", xmlElementName);
    }
    [self addChild:child];
}

- (BOOL)isEqualToElement:(GDataXMLElement*)node
{
    if(![self.decodedName isEqualToString:node.decodedName]) {
        NSDebug(@"GDataXMLElements not equal: tag names not equal (%@ != %@)!", self.name, node.name);
    }
    
    NSUInteger attributesCount = [self.attributes count];
    if(attributesCount != [node.attributes count]) {
        NSDebug(@"GDataXMLElements not equal: different number of attributes!");
        return false;
    }
    for(int i = 0; i < attributesCount; i++) {
        GDataXMLNode *firstAttribute = [self.attributes objectAtIndex:i];
        GDataXMLNode *secondAttribute = [node.attributes objectAtIndex:i];
        if(![firstAttribute isEqualToNode:secondAttribute])
            return false;
    }
    
    NSArray *children = [self childrenWithoutComments];
    NSArray *nodeChildren = [node childrenWithoutComments];
    NSUInteger childrenCount = [children count];
    if(childrenCount != [nodeChildren count]) {
        NSDebug(@"GDataXMLElements not equal: different number of children for element with name %@!", self.name);
        return false;
    }
    for(int i = 0; i < childrenCount; i++) {
        if([[children objectAtIndex:i] isKindOfClass:[GDataXMLElement class]]) {
            GDataXMLElement *firstChild = [children objectAtIndex:i];
            GDataXMLElement *secondChild = [nodeChildren objectAtIndex:i];
            if(![firstChild isEqualToElement:secondChild])
                return false;
        } else if([[children objectAtIndex:i] isKindOfClass:[GDataXMLNode class]]) {
            GDataXMLNode *firstChild = [children objectAtIndex:i];
            GDataXMLElement *secondChild = [nodeChildren objectAtIndex:i];
            if(![firstChild isEqualToNode:secondChild])
                return false;
        } else {
            NSDebug(@"GDataXMLElements not equal: invalid class name %@!", [[self.children objectAtIndex:i] class]);
            return false;
        }
    }
    if(childrenCount == 0) {
        if(![(GDataXMLNode*)self isEqualToNode:(GDataXMLNode*)node])
            return false;
    }
    
    return true;
}

@end
