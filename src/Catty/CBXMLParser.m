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
#import "CBXMLValidator.h"
#import "CBXMLContext.h"
#import "Program+CustomExtensions.h"
#import "Header+CBXMLHandler.h"
#import "VariablesContainer+CBXMLHandler.h"
#import "SpriteObject+CBXMLHandler.h"
#import "CatrobatLanguageDefines.h"

// NEVER MOVE THESE DEFINE CONSTANTS TO ANOTHER (HEADER) FILE
#define kCatrobatXMLParserMinSupportedLanguageVersion 0.93f
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
    if (error) {
        NSError(@"XML file could not be loaded!");
        return nil; }

    //NSLog(@"%@", xmlFile);
    NSData *xmlData = [xmlFile dataUsingEncoding:NSUTF8StringEncoding];

    // sanity check
    if (! xmlData) {
        NSError(@"XML file could not be loaded!");
        return nil;
    }

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

    // TODO: REMOVE THIS LOG-Entry after parser has been fully implemented
    NSLog(@"!!! NEW Catrobat XML Parser IS NOT FULLY IMPLEMENTED YET !!!");
    return program;
}

- (Program*)parseAndCreateProgramForDocument:(GDataXMLDocument*)xmlDocument
{
    GDataXMLElement *rootElement = xmlDocument.rootElement;
    [XMLError exceptionIfNode:rootElement isNilOrNodeNameNotEquals:@"program"];
    Program *program = [Program new];
    CBXMLContext *context = [CBXMLContext new];
    program.header = [self parseAndCreateHeaderFromElement:rootElement];
    program.objectList = [self parseAndCreateObjectsFromElement:rootElement withContext:context];
    context.spriteObjectList = program.objectList;
    program.variables = [self parseAndCreateVariablesFromElement:rootElement withContext:context];
    return program;
}

#pragma mark Header parsing
- (Header*)parseAndCreateHeaderFromElement:(GDataXMLElement*)programElement
{
    return [Header parseFromElement:programElement withContext:nil];
}

#pragma mark Object parsing
- (NSMutableArray*)parseAndCreateObjectsFromElement:(GDataXMLElement*)programElement
                                        withContext:(CBXMLContext*)context
{
    NSArray *objectListElements = [programElement elementsForName:@"objectList"];
    [XMLError exceptionIf:[objectListElements count] notEquals:1 message:@"No objectList given!"];
    NSArray *objectElements = [[objectListElements firstObject] children];
    [XMLError exceptionIf:[objectListElements count] equals:0
                  message:@"No objects in objectList, but there must exist at least 1 object (background)!!"];
    NSLog(@"<objectList>");
    NSMutableArray *objectList = [NSMutableArray arrayWithCapacity:[objectElements count]];
    for (GDataXMLElement *objectElement in objectElements) {
        SpriteObject *spriteObject = [SpriteObject parseFromElement:objectElement withContext:context];
        if (spriteObject != nil)
            [objectList addObject:spriteObject];
    }
    // sanity check => check if all objects from context are in objectList
    for (SpriteObject *pointedObjectInContext in context.pointedSpriteObjectList) {
        BOOL found = NO;
        for(SpriteObject *spriteObject in objectList) {
            if([pointedObjectInContext.name isEqualToString:spriteObject.name])
                found = YES;
        }
        [XMLError exceptionIf:found equals:NO message:@"Pointed object with name %@ not found in object list!", pointedObjectInContext.name];
    }
    NSLog(@"</objectList>");
    return objectList;
}

#pragma mark Variable parsing
- (VariablesContainer*)parseAndCreateVariablesFromElement:(GDataXMLElement*)programElement
                                              withContext:(CBXMLContext*)context
{
    return [VariablesContainer parseFromElement:programElement withContext:context];
}

@end
