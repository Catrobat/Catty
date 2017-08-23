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

#import "XMLAbstractTest.h"
#import "GDataXMLElement+CustomExtensions.h"
#import "CBXMLParser.h"
#import "CBXMLSerializer.h"
#import "Program+CBXMLHandler.h"
#import "Util.h"
#import "Scene.h"
#import "NSArray+CustomExtension.h"
#import "ProgramLoadingInfo.h"

@implementation XMLAbstractTest

- (void)setUp
{
    [super setUp];
    [Util activateTestMode:YES];
}

- (NSString*)getPathForXML:(NSString*)xmlFile
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:xmlFile ofType:@"xml"];
    return path;
}

- (GDataXMLDocument*)getXMLDocumentForPath:(NSString*)xmlPath
{
    NSError *error;
    NSString *xmlFile = [NSString stringWithContentsOfFile:xmlPath
                                                  encoding:NSUTF8StringEncoding
                                                     error:&error];
    NSData *xmlData = [xmlFile dataUsingEncoding:NSUTF8StringEncoding];
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];
    return document;
}

- (Program*)getProgramForXML:(NSString*)xmlFile
{
    NSString *xmlPath = [self getPathForXML:xmlFile];
    CGFloat languageVersion = [Util detectCBLanguageVersionFromXMLWithPath:xmlPath];
    // detect right parser for correct catrobat language version
    CBXMLParser *catrobatParser = [[CBXMLParser alloc] initWithPath:xmlPath];
    if (! [catrobatParser isSupportedLanguageVersion:languageVersion]) {
        NSAssert(false, @"Unsupported language version");
    } else {
        return [catrobatParser parseAndCreateProgram];
    }
    
    return nil;
}

- (void)compareProgram:(NSString*)firstProgramName withProgram:(NSString*)secondProgramName
{
    Program *firstProgram = [self getProgramForXML:firstProgramName];
    Program *secondProgram = [self getProgramForXML:secondProgramName];
    
    {
        // XXX: HACK => assign same header to both versions => this forces to ignore header
        firstProgram = [[Program alloc] initWithHeader:secondProgram.header
                                                scenes:firstProgram.scenes
                                   programVariableList:firstProgram.programVariableList];
        // XXX: HACK => for background objects always replace german name "Hintergrund" with "Background"
        [firstProgram.scenes cb_foreachUsingBlock:^(Scene *scene) {
            SpriteObject *bgObject = scene.objectList[0];
            bgObject.name = [bgObject.name stringByReplacingOccurrencesOfString:@"Hintergrund"
                                                                     withString:@"Background"];
        }];
        [secondProgram.scenes cb_foreachUsingBlock:^(Scene *scene) {
            SpriteObject *bgObject = scene.objectList[0];
            bgObject.name = [bgObject.name stringByReplacingOccurrencesOfString:@"Hintergrund"
                                                                     withString:@"Background"];
        }];
    }
    
    XCTAssertTrue([firstProgram isEqualToProgram:secondProgram], @"Programs are not equal");
}

- (BOOL)isXMLElement:(GDataXMLElement*)xmlElement equalToXMLElementForXPath:(NSString*)xPath inProgramForXML:(NSString*)program
{
    GDataXMLDocument *document = [self getXMLDocumentForPath:[self getPathForXML:program]];
    GDataXMLElement *xml = [document rootElement];
    
    NSArray *array = [xml nodesForXPath:xPath error:nil];
    XCTAssertEqual([array count], 1);
    
    GDataXMLElement *xmlElementFromFile = [array objectAtIndex:0];
    return [xmlElement isEqualToElement:xmlElementFromFile];
}

- (BOOL)isProgram:(Program*)firstProgram equalToXML:(NSString*)secondProgram
{
    GDataXMLDocument *firstDocument = [CBXMLSerializer xmlDocumentForProgram:firstProgram];
    GDataXMLDocument *secondDocument = [self getXMLDocumentForPath:[self getPathForXML:secondProgram]];
    return [firstDocument.rootElement isEqualToElement:secondDocument.rootElement];
}

- (void)saveProgram:(Program*)program
{
    NSString *projectPath = [ProgramLoadingInfo programLoadingInfoForProgram:program].basePath;
    NSString *xmlPath = [NSString stringWithFormat:@"%@%@", projectPath, kProgramCodeFileName];
    id<CBSerializerProtocol> serializer = [[CBXMLSerializer alloc] initWithPath:xmlPath];
    [serializer serializeProgram:program];
}

- (void)testParseXMLAndSerializeProgramAndCompareXML:(NSString*)xmlFile
{
    Program *program = [self getProgramForXML:xmlFile];
    BOOL equal = [self isProgram:program equalToXML:xmlFile];
    XCTAssertTrue(equal, @"Serialized program and XML are not equal (%@)", xmlFile);
}

@end
