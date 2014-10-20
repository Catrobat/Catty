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

#import "CatrobatXMLParser.h"
#import "AppDefines.h"
#import "NSString+CatrobatNSStringExtensions.h"
#import "Program+CustomExtensions.h"
#import "GDataXMLNode.h"
#import "Header.h"
#import <objc/runtime.h>
#import <Foundation/NSObjCRuntime.h>
#import "CatrobatLanguageDefines.h"
#import "SpriteObject.h"
#import "Look.h"
#import "Sound.h"

#define kCatroidXMLPrefix               @"org.catrobat.catroid.content."
#define kCatroidXMLSpriteList           @"spriteList"
#define kParserObjectTypeString         @"T@\"NSString\""
#define kParserObjectTypeNumber         @"T@\"NSNumber\""
#define kParserObjectTypeArray          @"T@\"NSArray\""
#define kParserObjectTypeMutableArray   @"T@\"NSMutableArray\""
#define kParserObjectTypeMutableDictionary @"T@\"NSMutableDictionary\""
#define kParserObjectTypeDate           @"T@\"NSDate\""

// NEVER MOVE THESE DEFINE CONSTANTS TO ANOTHER CLASS
#define kCatrobatXMLParserMinSupportedLanguageVersion 0.0902f
#define kCatrobatXMLParserMaxSupportedLanguageVersion CGFLOAT_MAX

@interface CatrobatXMLParser()

@property (nonatomic, strong) NSString *xmlPath;

@end

@implementation CatrobatXMLParser

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

- (CGFloat)detectLanguageVersion
{
    NSError *error;
    NSString *xmlString = [NSString stringWithContentsOfFile:self.xmlPath
                                                    encoding:NSUTF8StringEncoding
                                                       error:&error];
    // sanity check
    if (error || ! xmlString) {
        return kCatrobatInvalidVersion;
    }
    // get the end of the xml header
    NSArray *xmlStringChunks = [xmlString componentsSeparatedByString:@"</header>"];
    if (! [xmlStringChunks count]) {
        return kCatrobatInvalidVersion;
    }
    // extract header
    NSString *xmlStringHeaderChunk = [xmlStringChunks firstObject];
    if (! xmlStringHeaderChunk) {
        return kCatrobatInvalidVersion;
    }

    // extract catrobatLanguageVersion field out of header
    NSString *languageVersionString = [xmlStringHeaderChunk stringBetweenString:@"<catrobatLanguageVersion>"
                                                                      andString:@"</catrobatLanguageVersion>"
                                                                    withOptions:NSCaseInsensitiveSearch];
    if (! languageVersionString) {
        return kCatrobatInvalidVersion;
    }

    // handle language versions that contain more than one dot-separator!
    // e.g. => convert 0.9.2 to 0.0902
    //      => convert 0.10.2 to 0.1002
    //      => convert 0.9.2.1 to 0.090201
    NSArray *languageVersionNumberParts = [languageVersionString componentsSeparatedByString:@"."];
    if ([languageVersionNumberParts count] > 1) {
        NSUInteger index = 0;
        NSString *majorVersionNumberString = [languageVersionNumberParts objectAtIndex:index];
        NSString *subVersionNumberString = [languageVersionNumberParts objectAtIndex:(index+1)];
        NSUInteger subVersionNumber = [subVersionNumberString integerValue];
        if (subVersionNumber < 10) {
            subVersionNumberString = [@"0" stringByAppendingString:subVersionNumberString];
        }
        NSMutableString *filteredLanguageVersionString = [NSMutableString stringWithFormat:@"%@.%@",
                                                          majorVersionNumberString,
                                                          subVersionNumberString];
        for (index = 2; index < [languageVersionNumberParts count]; ++index) {
            NSString *subSubVersionNumberString = [languageVersionNumberParts objectAtIndex:index];
            NSUInteger subSubVersionNumber = [subSubVersionNumberString integerValue];
            if (subSubVersionNumber < 10) {
                subSubVersionNumberString = [@"0" stringByAppendingString:subSubVersionNumberString];
            }
            [filteredLanguageVersionString appendString:subSubVersionNumberString];
        }
        languageVersionString = [filteredLanguageVersionString copy];
    }

    // check if string contains valid number
    if (! [languageVersionString isValidNumber]) {
        return kCatrobatInvalidVersion;
    }

    CGFloat languageVersion = (CGFloat)[languageVersionString floatValue];
    if (languageVersion < 0.0f) {
        return kCatrobatInvalidVersion;
    }
    return languageVersion;
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
    NSLog(@"!!! NEW PARSER IS NOT IMPLEMENTED YET => RETURNING NIL !!!");
    return nil;
}

- (Program*)parseAndCreateProgramForDocument:(GDataXMLDocument*)xmlDocument
{
    GDataXMLElement *rootElement = xmlDocument.rootElement;
    if (! [rootElement.name isEqualToString:@"program"]) {
        [NSException raise:@"WrongRootElementNameException"
                    format:@"The name of the rootElement is %@ but should be 'program'", rootElement.name];
    }

    // TODO: add annotation parsing and annotations to all data model classes' properties
    //       + determine which properties should be hooked up
    Program *program = [[Program alloc] init];
    program.header = [self parseAndCreateHeader:rootElement];
    program.objectList = [self parseAndCreateObjects:rootElement];
//    TODO: continue...
    return program;
}

#pragma mark Header parsing
- (Header*)parseAndCreateHeader:(GDataXMLElement*)programElement
{
    // TODO: create InvalidHeaderException class
    Header *header = [Header defaultHeader];
    NSArray *headerNodes = [programElement elementsForName:@"header"];
    if ([headerNodes count] != 1) {
        [NSException raise:@"InvalidHeaderException" format:@"Invalid header given!"];
    }
    NSArray *headerPropertyNodes = [[headerNodes firstObject] children];
    if (! [headerPropertyNodes count]) {
        [NSException raise:@"InvalidHeaderException" format:@"No parsed properties found in header!"];
    }

    NSLog(@"<header>");

    // Note: WEAK (!) properties are not yet supported!!
    for (GDataXMLNode *headerPropertyNode in headerPropertyNodes) {
        if (! headerPropertyNode) {
            [NSException raise:@"InvalidHeaderException" format:@"Parsed an empty header entry!"];
        }
        id value = [self valueForHeaderPropertyNode:headerPropertyNode];
        NSLog(@"<%@>%@</%@>", headerPropertyNode.name, value, headerPropertyNode.name);
        NSString *headerPropertyName = headerPropertyNode.name;

        // consider special case: name of property description in header is programDescription
        if ([headerPropertyNode.name isEqualToString:@"description"]) {
            headerPropertyName = @"programDescription";
        }
        [header setValue:value forKey:headerPropertyName];
    }
    NSLog(@"</header>");
    return header;
}

#pragma mark Object parsing
- (NSMutableArray*)parseAndCreateObjects:(GDataXMLElement*)programElement
{
    // TODO: create InvalidObjectException class
    NSArray *objectListElements = [programElement elementsForName:@"objectList"];
    if ([objectListElements count] != 1) {
        [NSException raise:@"InvalidObjectException" format:@"No objectList given!"];
    }
    NSArray *objectElements = [[objectListElements firstObject] children];
    if (! [objectElements count]) {
        [NSException raise:@"InvalidObjectException"
                    format:@"No objects found in objectList, but there must be at least 1 object => background object!!"];
    }

    NSLog(@"<objectList>");

    NSMutableArray *objectList = [NSMutableArray arrayWithCapacity:[objectElements count]];

    // TODO: support for WEAK (!) properties required here!!
    for (GDataXMLElement *objectElement in objectElements) {
        if (! objectElement) {
            [NSException raise:@"InvalidObjectException" format:@"Parsed an empty object entry!"];
        }

        NSArray *attributes = [objectElement attributes];
        if ([attributes count] != 1) {
            [NSException raise:@"InvalidObjectException"
                        format:@"Parsed name-attribute of object is invalid or empty!"];
        }

        SpriteObject *spriteObject = [[SpriteObject alloc] init];
        GDataXMLNode *attribute = [attributes firstObject];
        GDataXMLElement *pointedObjectElement = nil;
        // check if normal or pointed object
        if ([attribute.name isEqualToString:@"name"]) {
            spriteObject.name = [attribute stringValue];
        } else if ([attribute.name isEqualToString:@"reference"]) {
            NSString *xPath = [attribute stringValue];
            NSArray *queriedObjects = [objectElement nodesForXPath:xPath error:nil];
            if ([queriedObjects count] != 1) {
                [NSException raise:@"InvalidObjectException"
                            format:@"Invalid reference in object. No or too many pointed objects found!"];
            }
            pointedObjectElement = [queriedObjects firstObject];
            GDataXMLNode *nameAttribute = [pointedObjectElement attributeForName:@"name"];
            if (! nameAttribute) {
                [NSException raise:@"InvalidObjectException"
                            format:@"PointedObject must contain a name attribute"];
            }
            spriteObject.name = [nameAttribute stringValue];
        } else {
            [NSException raise:@"InvalidObjectException" format:@"Unsupported attribute: %@!", attribute.name];
        }
        NSLog(@"<object name=\"%@\">", spriteObject.name);

        spriteObject.lookList = [self parseAndCreateLooks:(pointedObjectElement ? pointedObjectElement : objectElement)];
        spriteObject.soundList = [self parseAndCreateSounds:(pointedObjectElement ? pointedObjectElement : objectElement)];
// TODO: implement this...
//        spriteObject.scriptList = [self parseAndCreateSounds:(pointedObjectElement ? pointedObjectElement : objectElement)];
        [objectList addObject:spriteObject];
    }
    NSLog(@"</objectList>");
    return objectList;
}

- (NSMutableArray*)parseAndCreateLooks:(GDataXMLElement*)objectElement
{
    NSArray *lookListElements = [objectElement elementsForName:@"lookList"];
    if ([lookListElements count] != 1) {
        [NSException raise:@"InvalidObjectException" format:@"No lookList given!"];
    }

    NSArray *lookElements = [[lookListElements firstObject] children];
    if (! [lookElements count]) {
        return nil;
    }

    NSMutableArray *lookList = [NSMutableArray arrayWithCapacity:[lookElements count]];
    for (GDataXMLElement *lookElement in lookElements) {
        Look *look = [[Look alloc] init];
        GDataXMLNode *nameAttribute = [lookElement attributeForName:@"name"];
        if (! nameAttribute) {
            [NSException raise:@"InvalidObjectException"
                        format:@"Look must contain a name attribute"];
        }
        look.name = [nameAttribute stringValue];
        NSArray *lookChildElements = [lookElement children];
        if ([lookChildElements count] != 1) {
            [NSException raise:@"InvalidObjectException"
                        format:@"Look must contain a filename child node"];
        }
        GDataXMLNode *fileNameElement = [lookChildElements firstObject];
        if (! [fileNameElement.name isEqualToString:@"fileName"]) {
            [NSException raise:@"InvalidObjectException"
                        format:@"Look contains wrong child node"];
        }
        look.fileName = [fileNameElement stringValue];
    }
    return lookList;
}

- (NSMutableArray*)parseAndCreateSounds:(GDataXMLElement*)objectElement
{
    NSArray *soundListElements = [objectElement elementsForName:@"soundList"];
    // TODO: increase readability, use macros for such sanity checks...
    if ([soundListElements count] != 1) {
        [NSException raise:@"InvalidObjectException" format:@"No soundList given!"];
    }

    NSArray *soundElements = [[soundListElements firstObject] children];
    if (! [soundElements count]) {
        return nil;
    }

    NSMutableArray *soundList = [NSMutableArray arrayWithCapacity:[soundElements count]];
    for (GDataXMLElement *soundElement in soundElements) {
        Sound *sound = [[Sound alloc] init];
        NSArray *soundChildElements = [soundElement children];
        if ([soundChildElements count] != 2) {
            [NSException raise:@"InvalidObjectException"
                        format:@"Sound must contain two child nodes"];
        }

        GDataXMLNode *nameChildNode = [soundChildElements firstObject];
        GDataXMLNode *fileNameChildNode = [soundChildElements lastObject];

        // swap values (if needed)
        if ([fileNameChildNode.name isEqualToString:@"name"] && [nameChildNode.name isEqualToString:@"fileName"]) {
            nameChildNode = fileNameChildNode;
            fileNameChildNode = nameChildNode;
        }

        if ((! [nameChildNode.name isEqualToString:@"name"]) || (! [fileNameChildNode.name isEqualToString:@"fileName"])) {
            [NSException raise:@"InvalidObjectException"
                        format:@"Sound must contains wrong child node(s)"];
        }
        sound.name = [nameChildNode stringValue];
        sound.fileName = [fileNameChildNode stringValue];
    }
    return soundList;
}

#pragma mark - Helpers
- (const char*)typeStringForProperty:(objc_property_t)property
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

- (id)valueForHeaderPropertyNode:(GDataXMLNode*)propertyNode
{
    objc_property_t property = class_getProperty([Header class], [propertyNode.name UTF8String]);
    if (! property) {
        [NSException raise:@"InvalidHeaderException"
                    format:@"Invalid header property %@ given", propertyNode.name];
    }

    NSString *propertyType = [NSString stringWithUTF8String:[self typeStringForProperty:property]];
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
        [NSException raise:@"InvalidHeaderException"
                    format:@"Unsupported type for property %@ (of type: %@) in header",
                           propertyNode.name, propertyType];
    }
    return value;
}

@end
