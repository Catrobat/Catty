/**
 *  Copyright (C) 2010-2018 The Catrobat Team
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

#import <XCTest/XCTest.h>
#import "Program.h"
#import "SpriteObject.h"
#import "Script.h"
#import "Brick.h"
#import "NoteBrick.h"
#import "Parser.h"

@interface XMLParserTests : XCTestCase

@end

@implementation XMLParserTests

- (NSString*)getPathForXML:(NSString*)xmlFile
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:xmlFile ofType:@"xml"];
    return path;
}

- (void)testConvertUnsupportedBrickToNoteBrick {
    Parser *parser092 = [[Parser alloc] init];
    Program *program = [parser092 generateObjectForProgramWithPath:[self getPathForXML:@"LegoNxtMotorActionBrick"]];
    XCTAssertNotNil(program, @"Program should not be nil");
    
    for(SpriteObject *spriteObject in program.objectList) {
        XCTAssertNotNil(spriteObject, @"SpriteObject should not be nil");
        for(Script *script in spriteObject.scriptList) {
            for(Brick *brick in script.brickList) {
                XCTAssertNotNil(brick, @"Brick should not be nil");
            }
        }
    }
    
    XCTAssertEqual(6, [program.objectList count], @"Invalid number of SpriteObjects");
    SpriteObject *spriteObject = [program.objectList objectAtIndex:1];
    XCTAssertEqual(1, [spriteObject.scriptList count], @"Invalid number of Scripts");
    Script *script = [spriteObject.scriptList objectAtIndex:0];
    XCTAssertEqual(1, [script.brickList count], @"Invalid number of Bricks");
    Brick *brick = [script.brickList objectAtIndex:0];
    XCTAssertTrue([brick isKindOfClass:[NoteBrick class]], @"Invalid Brick type: Brick should be of type %@", [NoteBrick class]);
}

@end
