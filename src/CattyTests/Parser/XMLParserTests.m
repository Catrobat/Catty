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

#define CATTY_TESTS 1

#import <XCTest/XCTest.h>
#import "CBXMLParser.h"
#import "GDataXMLNode.h"
#import "UIDefines.h"
#import "Program.h"
#import "Look.h"
#import "Sound.h"
#import "Script.h"
#import "Brick.h"
#import "CatrobatLanguageDefines.h"
#import "Program+CustomExtensions.h"
#import "CBXMLValidator.h"
#import "Header+CBXMLHandler.h"
#import "SpriteObject+CBXMLHandler.h"
#import "VariablesContainer+CBXMLHandler.h"
#import "Script+CBXMLHandler.h"
#import "UserVariable+CBXMLHandler.h"
#import "Formula+CBXMLHandler.h"
#import "FormulaElement+CBXMLHandler.h"
#import "Brick+CBXMLHandler.h"
#import "SetLookBrick+CBXMLHandler.h"
#import "SetSizeToBrick+CBXMLHandler.h"
#import "CBXMLContext.h"
#import "CBXMLOpenedNestingBricksStack.h"
#import "SetLookBrick.h"
#import "SetVariableBrick.h"
#import "ForeverBrick+CBXMLHandler.h"
#import "LoopEndBrick+CBXMLHandler.h"

@interface XMLParserTests : XCTestCase

@end

@implementation XMLParserTests

- (void)testValidHeader {
    
    Header *header = [Header parseFromElement:[[self getXMLDocumentForPath:[self getPathForXML:@"ValidProgram"]] rootElement] withContext:nil];
    XCTAssertNotNil(header, @"Header is nil");
    
    XCTAssertTrue([header.applicationBuildName isEqualToString: @"applicationBuildName"], @"applicationBuildName not correctly parsed");
    XCTAssertTrue([header.applicationBuildNumber isEqualToString: @"123"], @"applicationBuildNumber not correctly parsed");
    XCTAssertTrue([header.applicationVersion isEqualToString: @"v0.9.8-260-g4bcf9a2 master"], @"applicationVersion not correctly parsed");
    XCTAssertTrue([header.catrobatLanguageVersion isEqualToString: @"0.93"], @"catrobatLanguageVersion not correctly parsed");
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:kCatrobatHeaderDateTimeFormat];
    XCTAssertTrue([[formatter stringFromDate:header.dateTimeUpload] isEqualToString: @"2014-11-0211:00:00"], @"dateTimeUpload not correctly parsed");
    
    XCTAssertTrue([header.programDescription isEqualToString: @"description"], @"description not correctly parsed");
    XCTAssertTrue([header.deviceName isEqualToString: @"Android SDK built for x86"], @"deviceName not correctly parsed");
    XCTAssertTrue([header.mediaLicense isEqualToString: @"mediaLicense"], @"mediaLicense not correctly parsed");
    XCTAssertTrue([header.platform isEqualToString: @"Android"], @"platform not correctly parsed");
    XCTAssertTrue([header.programLicense isEqualToString: @"programLicense"], @"programLicense not correctly parsed");
    XCTAssertTrue([header.programName isEqualToString: @"My first program"], @"programName not correctly parsed");
    XCTAssertTrue([header.remixOf isEqualToString: @"remixOf"], @"remixOf not correctly parsed");
    XCTAssertEqual([header.screenHeight intValue], 1184, @"screenHeight not correctly parsed");
    XCTAssertEqual([header.screenWidth intValue], 768, @"screenWidth not correctly parsed");
    XCTAssertTrue([header.tags isEqualToString: @"tags"], @"tags not correctly parsed");
    XCTAssertTrue([header.url isEqualToString: @"url"], @"url not correctly parsed");
    XCTAssertTrue([header.userHandle isEqualToString: @"userHandle"], @"userHandle not correctly parsed");
}

- (void)testValidObjectList {
    
    GDataXMLDocument *document = [self getXMLDocumentForPath:[self getPathForXML:@"ValidProgram"]];
    GDataXMLElement *xmlElement = [document rootElement];
    
    NSArray *objectListElements = [xmlElement elementsForName:@"objectList"];
    XCTAssertEqual([objectListElements count], 1);
    
    NSArray *objectElements = [[objectListElements firstObject] children];
    NSMutableArray *objectList = [NSMutableArray arrayWithCapacity:[objectElements count]];
    
    for (GDataXMLElement *objectElement in objectElements) {
        SpriteObject *spriteObject = [SpriteObject parseFromElement:objectElement withContext:nil];
        [objectList addObject:spriteObject];
    }
    
    XCTAssertEqual([objectList count], 5);
    
    SpriteObject *background = [objectList objectAtIndex:0];
    XCTAssertTrue([background.name isEqualToString: @"Background"], @"SpriteObject[0]: Name not correctly parsed");
    XCTAssertEqual([background.lookList count], 1, @"SpriteObject[0]: lookList not correctly parsed");
    
    Look *look = [background.lookList objectAtIndex:0];
    XCTAssertTrue([look.name isEqualToString: @"Background"], @"SpriteObject[0]: Look name not correctly parsed");
    XCTAssertTrue([look.fileName isEqualToString: @"1f363a1435a9497852285dbfa82b74e4_Background.png"], @"SpriteObject[0]: Look fileName not correctly parsed");
    
    XCTAssertEqual([background.soundList count], 0, @"SpriteObject[0]: soundList not correctly parsed");
    XCTAssertEqual([background.scriptList count], 1, @"SpriteObject[0]: scriptList not correctly parsed");
    
    SpriteObject *mole = [objectList objectAtIndex:1];
    XCTAssertTrue([mole.name isEqualToString: @"Mole 1"], @"SpriteObject[1]: Name not correctly parsed");
    XCTAssertEqual([mole.lookList count], 3, @"SpriteObject[1]: lookList not correctly parsed");
    look = [mole.lookList objectAtIndex:1];
    XCTAssertTrue([look.name isEqualToString: @"Mole"], @"SpriteObject[1]: Look name not correctly parsed");
    XCTAssertTrue([look.fileName isEqualToString: @"dfcefc77af918afcbb71009c12ca5378_Mole.png"], @"SpriteObject[1]: Look fileName not correctly parsed");
    
    XCTAssertEqual([mole.soundList count], 1, @"SpriteObject[1]: soundList not correctly parsed");
    Sound *sound = [mole.soundList objectAtIndex:0];
    XCTAssertTrue([sound.name isEqualToString: @"Hit"], @"SpriteObject[1]: Sound name not correctly parsed");
    XCTAssertTrue([sound.fileName isEqualToString: @"6f231e6406d3554d691f3c9ffb37c043_Hit1.m4a"], @"SpriteObject[1]: Sound fileName not correctly parsed");
}

- (void)testValidSetLookBrick {
    
    GDataXMLDocument *document = [self getXMLDocumentForPath:[self getPathForXML:@"ValidProgram"]];
    GDataXMLElement *xmlElement = [document rootElement];
    
    NSArray *brickElement = [xmlElement nodesForXPath:@"//program/objectList/object[1]/scriptList/script[1]/brickList/brick[1]" error:nil];
    XCTAssertEqual([brickElement count], 1);
    
    NSArray *objectArray = [xmlElement nodesForXPath:@"//program/objectList/object[1]" error:nil];
    XCTAssertEqual([objectArray count], 1);
    GDataXMLElement *objectElement = [objectArray objectAtIndex:0];
    
    NSMutableArray *lookList = [SpriteObject parseAndCreateLooks:objectElement];
    GDataXMLElement *brickXMLElement = [brickElement objectAtIndex:0];
    
    Brick *brick = [Brick parseFromElement:brickXMLElement withContext:[[CBXMLContext alloc] initWithLookList:lookList]];
    
    XCTAssertTrue(brick.brickType == kSetLookBrick, @"Invalid brick type");
    XCTAssertTrue([brick isKindOfClass:[SetLookBrick class]], @"Invalid brick class");
    
    SetLookBrick *setLookBrick = (SetLookBrick*)brick;
    
    Look *look = setLookBrick.look;
    XCTAssertTrue([look.name isEqualToString:@"Background"], @"Invalid look name");
}

- (void)testValidSetVariableBrick {
    
    GDataXMLDocument *document = [self getXMLDocumentForPath:[self getPathForXML:@"ValidProgram"]];
    GDataXMLElement *xmlElement = [document rootElement];
    
    NSArray *brickElement = [xmlElement nodesForXPath:@"//program/objectList/object[1]/scriptList/script[1]/brickList/brick[2]" error:nil];
    XCTAssertEqual([brickElement count], 1);
    
    NSArray *objectArray = [xmlElement nodesForXPath:@"//program/objectList/object[1]" error:nil];
    XCTAssertEqual([objectArray count], 1);
    GDataXMLElement *objectElement = [objectArray objectAtIndex:0];
    
    NSMutableArray *lookList = [SpriteObject parseAndCreateLooks:objectElement];
    GDataXMLElement *brickXMLElement = [brickElement objectAtIndex:0];
    
    Brick *brick = [Brick parseFromElement:brickXMLElement withContext:[[CBXMLContext alloc] initWithLookList:lookList]];
    
    XCTAssertTrue(brick.brickType == kSetVariableBrick, @"Invalid brick type");
    XCTAssertTrue([brick isKindOfClass:[SetVariableBrick class]], @"Invalid brick class");
    
    SetVariableBrick *setVariableBrick = (SetVariableBrick*)brick;
    
    XCTAssertTrue([setVariableBrick.userVariable.name isEqualToString:@"random from"], @"Invalid user variable name");
    
    Formula *formula = setVariableBrick.variableFormula;
    XCTAssertTrue(formula.formulaTree.type == NUMBER, @"Invalid variable type");
    XCTAssertTrue([formula.formulaTree.value isEqualToString:@"1"], @"Invalid variable value");
}

- (void)testValidSetSizeToBrick {
    
    GDataXMLDocument *document = [self getXMLDocumentForPath:[self getPathForXML:@"ValidProgram"]];
    GDataXMLElement *xmlElement = [document rootElement];
    
    NSArray *brickElement = [xmlElement nodesForXPath:@"//program/objectList/object[2]/scriptList/script[1]/brickList/brick[1]" error:nil];
    XCTAssertEqual([brickElement count], 1);
    
    NSArray *objectArray = [xmlElement nodesForXPath:@"//program/objectList/object[1]" error:nil];
    XCTAssertEqual([objectArray count], 1);
    GDataXMLElement *objectElement = [objectArray objectAtIndex:0];
    
    NSMutableArray *lookList = [SpriteObject parseAndCreateLooks:objectElement];
    GDataXMLElement *brickXMLElement = [brickElement objectAtIndex:0];
    
    Brick *brick = [Brick parseFromElement:brickXMLElement withContext:[[CBXMLContext alloc] initWithLookList:lookList]];
    
    XCTAssertTrue(brick.brickType == kSetSizeToBrick, @"Invalid brick type");
    XCTAssertTrue([brick isKindOfClass:[SetSizeToBrick class]], @"Invalid brick class");
    
    SetSizeToBrick *setSizeToBrick = (SetSizeToBrick*)brick;
    Formula *formula = setSizeToBrick.size;
    
    XCTAssertNotNil(formula, @"Invalid formula");
    
    XCTAssertTrue(formula.formulaTree.type == NUMBER, @"Invalid variable type");
    XCTAssertTrue([formula.formulaTree.value isEqualToString:@"30"], @"Invalid formula value");
    
    XCTAssertEqualWithAccuracy([formula interpretDoubleForSprite:nil], 30, 0.00001, @"Formula not correctly parsed");

}

- (void)testValidForeverBrickAndLoopEndlessBrick {
    
    CBXMLContext *context = [[CBXMLContext alloc] init];
    GDataXMLDocument *document = [self getXMLDocumentForPath:[self getPathForXML:@"ValidProgram"]];
    GDataXMLElement *xmlElement = [document rootElement];
    
    NSArray *brickElement = [xmlElement nodesForXPath:@"//program/objectList/object[2]/scriptList/script[1]/brickList/brick[2]" error:nil];
    XCTAssertEqual([brickElement count], 1);
    
    GDataXMLElement *brickXMLElement = [brickElement objectAtIndex:0];
    
    Brick *brick = [Brick parseFromElement:brickXMLElement withContext:context];
    
    XCTAssertTrue(brick.brickType == kForeverBrick, @"Invalid brick type");
    XCTAssertTrue([brick isKindOfClass:[ForeverBrick class]], @"Invalid brick class");
    
    brickElement = [xmlElement nodesForXPath:@"//program/objectList/object[2]/scriptList/script[1]/brickList/brick[12]" error:nil];
    XCTAssertEqual([brickElement count], 1);
    
    brickXMLElement = [brickElement objectAtIndex:0];
    
    brick = [Brick parseFromElement:brickXMLElement withContext:context];
    
    XCTAssertTrue(brick.brickType == kLoopEndBrick, @"Invalid brick type");
    XCTAssertTrue([brick isKindOfClass:[LoopEndBrick class]], @"Invalid brick class");
    
    XCTAssertTrue([context.openedNestingBricksStack isEmpty], @"Nesting bricks not closed properly");
}

- (void)testValidFormulaList {
    
    GDataXMLDocument *document = [self getXMLDocumentForPath:[self getPathForXML:@"ValidFormulaList"]];
    GDataXMLElement *xmlElement = [document rootElement];
    
    NSArray *brickElement = [xmlElement nodesForXPath:@"//program/objectList/object[1]/scriptList/script[1]/brickList/brick[2]" error:nil];
    XCTAssertEqual([brickElement count], 1);
    
    NSArray *objectArray = [xmlElement nodesForXPath:@"//program/objectList/object[1]" error:nil];
    XCTAssertEqual([objectArray count], 1);
    GDataXMLElement *objectElement = [objectArray objectAtIndex:0];
    
    NSMutableArray *lookList = [SpriteObject parseAndCreateLooks:objectElement];
    GDataXMLElement *brickXMLElement = [brickElement objectAtIndex:0];
    
    Brick *brick = [Brick parseFromElement:brickXMLElement withContext:[[CBXMLContext alloc] initWithLookList:lookList]];
    
    XCTAssertTrue(brick.brickType == kSetVariableBrick, @"Invalid brick type");
    XCTAssertTrue([brick isKindOfClass:[SetVariableBrick class]], @"Invalid brick class");
    
    SetVariableBrick *setVariableBrick = (SetVariableBrick*)brick;
    
    XCTAssertTrue([setVariableBrick.userVariable.name isEqualToString:@"random from"], @"Invalid user variable name");
    
    Formula *formula = setVariableBrick.variableFormula;
    // formula value should be: (1 * (-2)) + (3 / 4) = -1,25
    XCTAssertEqualWithAccuracy([formula interpretDoubleForSprite:nil], -1.25, 0.00001, @"Formula not correctly parsed");
}

- (NSString*)getPathForXML: (NSString*)xmlFile {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:xmlFile ofType:@"xml"];
    return path;
}

- (GDataXMLDocument*)getXMLDocumentForPath: (NSString*)xmlPath {
    NSError *error;
    NSString *xmlFile = [NSString stringWithContentsOfFile:xmlPath
                                                  encoding:NSUTF8StringEncoding
                                                     error:&error];
    NSData *xmlData = [xmlFile dataUsingEncoding:NSUTF8StringEncoding];
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];
    return document;
}


@end
