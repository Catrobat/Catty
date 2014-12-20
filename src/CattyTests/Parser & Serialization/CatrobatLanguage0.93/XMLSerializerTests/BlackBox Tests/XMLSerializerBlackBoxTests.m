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

#import <XCTest/XCTest.h>
#import "XMLSerializerAbstractTest.h"
#import "CBXMLSerializer.h"
#import "Program.h"

@interface XMLSerializerBlackBoxTests : XMLSerializerAbstractTest

@end

@implementation XMLSerializerBlackBoxTests

- (void)testPythagoreanTheorem
{
    Program *program093 = [self getProgramForXML:@"Pythagorean-Theorem-093"];
    [self saveProgram:program093]; // TODO: mustn't use saveToDisk! never throws exceptions => test always succeeds...
}

- (void)testValidProgramAllBricks
{
    Program *program093 = [self getProgramForXML:@"ValidProgramAllBricks"];
    [self saveProgram:program093]; // TODO: mustn't use saveToDisk! never throws exceptions => test always succeeds...
}

- (void)saveProgram:(Program*)program
{
    // TODO: find correct serializer class dynamically
    NSString *xmlPath = [NSString stringWithFormat:@"%@%@", [program projectPath], kProgramCodeFileName];
    id<CBSerializerProtocol> serializer = [[CBXMLSerializer alloc] initWithPath:xmlPath];
    [serializer serializeProgram:program];
}

@end
