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

#import "CBXMLParser.h"
#import "GDataXMLNode.h"
#import "Program+CustomExtensions.h"
#import "Header.h"
#import <Foundation/NSObjCRuntime.h>
#import "CatrobatLanguageDefines.h"
#import "SpriteObjectCBXMLNodeParser.h"
#import "CBXMLValidator.h"
#import "HeaderCBXMLNodeParser.h"
#import "VariablesContainer.h"

#define kCatroidXMLPrefix               @"org.catrobat.catroid.content."
#define kCatroidXMLSpriteList           @"spriteList"
#define kParserObjectTypeString         @"T@\"NSString\""
#define kParserObjectTypeNumber         @"T@\"NSNumber\""
#define kParserObjectTypeArray          @"T@\"NSArray\""
#define kParserObjectTypeMutableArray   @"T@\"NSMutableArray\""
#define kParserObjectTypeMutableDictionary @"T@\"NSMutableDictionary\""
#define kParserObjectTypeDate           @"T@\"NSDate\""

// NEVER MOVE THESE DEFINE CONSTANTS TO ANOTHER (HEADER) FILE
#define kCatrobatXMLParserMinSupportedLanguageVersion 0.0902f
#define kCatrobatXMLParserMaxSupportedLanguageVersion CGFLOAT_MAX

@interface CBXMLParser()

@property (nonatomic, strong) NSString *xmlPath;

@end

@implementation CBXMLParser

#pragma mark - Initialization
- (id)initWithPath:(NSString*)path
{
    if (self = [super init]) {
        // sanity check
        if (! path || [path isEqualToString:@""]) {
            NSLog(@"Path (%@) is NOT valid!", path);
            return nil;
        }
        self.xmlPath = path;
    }
    return self;
}

#pragma mark - Supported versions
- (BOOL)isSupportedLanguageVersion:(CGFloat)languageVersion
{
    return ((languageVersion >= kCatrobatXMLParserMinSupportedLanguageVersion)
            && (languageVersion <= kCatrobatXMLParserMaxSupportedLanguageVersion));
}

#pragma mark - Program parsing
- (Program*)parseAndCreateProgram
{
    NSError *error;
    NSString *xmlFile = [NSString stringWithContentsOfFile:self.xmlPath
                                                  encoding:NSUTF8StringEncoding
                                                     error:&error];
    // sanity check
    if (error) { return nil; }

    NSLog(@"%@", xmlFile);
    NSData *xmlData = [xmlFile dataUsingEncoding:NSUTF8StringEncoding];

    // sanity check
    if (!xmlData) { return nil; }

    error = nil;
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];

    // sanity check
    if (error || (! document)) { return nil; }

    Program *program = nil;
    @try {
        NSInfo(@"Loading Project...");
        program = [self parseAndCreateProgramForDocument:document];
        NSInfo(@"Loading done...");
    } @catch(NSException *exception) {
        NSError(@"Program could not be loaded! %@", [exception description]);
    }
    [program updateReferences];
    program.XMLdocument = document;

//    return program;
    // FIXME: REMOVE THIS LOG-Entry after parser has been fully implemented
    NSLog(@"!!! NEW Catrobat XML Parser IS NOT FULLY IMPLEMENTED YET => RETURNING NIL !!!");
    return nil;
}

- (Program*)parseAndCreateProgramForDocument:(GDataXMLDocument*)xmlDocument
{
    GDataXMLElement *rootElement = xmlDocument.rootElement;
    [XMLError exceptionIfString:rootElement.name isNotEqualToString:@"program"
                        message:@"The name of the rootElement is %@ but should be 'program'",rootElement.name];
    Program *program = [[Program alloc] init];
    program.header = [self parseAndCreateHeaderFromElement:rootElement];
    program.objectList = [self parseAndCreateObjectsFromElement:rootElement];
    program.variables = [self parseAndCreateVariablesFromElement:rootElement];
    return program;
}

#pragma mark Header parsing
- (Header*)parseAndCreateHeaderFromElement:(GDataXMLElement*)programElement
{
    HeaderCBXMLNodeParser *headerParser = [[HeaderCBXMLNodeParser alloc] init];
    return [headerParser parseFromElement:programElement];
}

#pragma mark Object parsing
- (NSMutableArray*)parseAndCreateObjectsFromElement:(GDataXMLElement*)programElement
{
    NSArray *objectListElements = [programElement elementsForName:@"objectList"];
    [XMLError exceptionIf:[objectListElements count] notEquals:1 message:@"No objectList given!"];
    NSArray *objectElements = [[objectListElements firstObject] children];
    [XMLError exceptionIf:[objectListElements count] equals:0
                  message:@"No objects in objectList, but there must exit at least 1 object (background)!!"];
    NSLog(@"<objectList>");
    NSMutableArray *objectList = [NSMutableArray arrayWithCapacity:[objectElements count]];
    SpriteObjectCBXMLNodeParser *spriteParser = [SpriteObjectCBXMLNodeParser new];
    for (GDataXMLElement *objectElement in objectElements) {
        [objectList addObject:[spriteParser parseFromElement:objectElement]];
    }
    NSLog(@"</objectList>");
    return objectList;
}

#pragma mark Variable parsing
- (VariablesContainer*)parseAndCreateVariablesFromElement:(GDataXMLElement*)programElement
{
    // TODO: stub method => implement this!!
    [XMLError exceptionWithMessage:@"parseAndCreateVariablesFromElement: NOT IMPLEMENTED YET!!!"];
    return nil;//[[VariablesContainer alloc] init];
}

#pragma mark - Helpers
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
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
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

@end
