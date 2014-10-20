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
//    program.objectList = [self parseAndCreateObjects];
//    TODO: continue...
    return program;
}

#pragma mark Header parsing
- (Header*)parseAndCreateHeader:(GDataXMLElement*)programElement
{
    // TODO: create InvalidHeaderException class
    Header *header = [Header defaultHeader];
    NSArray *headerElement = [programElement elementsForName:@"header"];
    if ((! headerElement) || ([headerElement count] != 1)) {
        [NSException raise:@"InvalidHeaderException" format:@"Invalid header given!"];
    }
    NSArray *headerPropertyElements = [[headerElement firstObject] children];
    if (! [headerPropertyElements count]) {
        [NSException raise:@"InvalidHeaderException" format:@"No parsed properties found in header!"];
    }

    NSLog(@"<header>");

    // Note: WEAK (!) properties are not yet supported!!
    for (GDataXMLElement *headerPropertyElement in headerPropertyElements) {
        if (! headerPropertyElement) {
            [NSException raise:@"InvalidHeaderException" format:@"Parsed an empty header entry from xml!"];
        }
        id value = [self valueForHeaderPropertyElement:headerPropertyElement];
        NSLog(@"<%@>%@</%@>", headerPropertyElement.name, value, headerPropertyElement.name);
        NSString *headerPropertyName = headerPropertyElement.name;

        // consider special case: name of property description in header is programDescription
        if ([headerPropertyElement.name isEqualToString:@"description"]) {
            headerPropertyName = @"programDescription";
        }
        [header setValue:value forKey:headerPropertyName];
    }
    NSLog(@"</header>");
    return header;
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

- (id)valueForHeaderPropertyElement:(GDataXMLElement*)propertyElement
{
    objc_property_t property = class_getProperty([Header class], [propertyElement.name UTF8String]);
    if (! property) {
        [NSException raise:@"InvalidHeaderException"
                    format:@"Invalid header property %@ given", propertyElement.name];
    }

    NSString *propertyType = [NSString stringWithUTF8String:[self typeStringForProperty:property]];
    id value = nil;
    if ([propertyType isEqualToString:kParserObjectTypeString]) {
        value = [propertyElement stringValue];
    } else if ([propertyType isEqualToString:kParserObjectTypeNumber]) {
        value = [NSNumber numberWithFloat:[[propertyElement stringValue]floatValue]];
    } else if ([propertyType isEqualToString:kParserObjectTypeDate]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        [dateFormatter setDateFormat:kCatrobatHeaderDateTimeFormat];
        value = [dateFormatter dateFromString:propertyElement.stringValue];
    } else {
        [NSException raise:@"InvalidHeaderException"
                    format:@"Unsupported type for property %@ (of type: %@) in header",
                           propertyElement.name, propertyType];
    }
    return value;
}

@end
