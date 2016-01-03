/**
 *  Copyright (C) 2010-2016 The Catrobat Team
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
#import "OrderedMapTable.h"
#import "SpriteObject.h"

@interface XMLParserUserVariableTests095 : XMLAbstractTest

@property (nonatomic, strong) CBXMLParserContext *parserContext;

@end

@implementation XMLParserUserVariableTests095

- (void)setUp
{
    self.parserContext = [[CBXMLParserContext alloc] initWithLanguageVersion:0.95f];
}

- (void)testValidVariables
{
    GDataXMLDocument* xmlRoot = [self getXMLDocumentForPath:[self getPathForXML:@"Airplane_with_shadow_095"]];
    XCTAssertNotNil(xmlRoot.rootElement, @"rootElement is nil");
                                    
    VariablesContainer *variablesContainer = [self.parserContext parseFromElement:xmlRoot.rootElement withClass:[VariablesContainer class]];
    XCTAssertNotNil(variablesContainer, @"VariablesContainer is nil");
    
    XCTAssertEqual(8, [variablesContainer.objectVariableList count], @"Invalid number of object variables");
    
    SpriteObject *spriteObject = [variablesContainer.objectVariableList keyAtIndex:0];
    XCTAssertTrue([spriteObject.name isEqualToString:[NSString stringWithFormat:@"Lower right tile"]], @"Invalid SpriteObject name for object variable 1");
    NSArray *variables = [variablesContainer objectVariablesForObject:spriteObject];
    XCTAssertEqual(0, [variables count], @"Invalid number of object variables for object 1");
    
    spriteObject = [variablesContainer.objectVariableList keyAtIndex:1];
    XCTAssertTrue([spriteObject.name isEqualToString:[NSString stringWithFormat:@"Lower left tile"]], @"Invalid SpriteObject name for object variable 2");
    variables = [variablesContainer objectVariablesForObject:spriteObject];
    XCTAssertEqual(0, [variables count], @"Invalid number of object variables for object 2");
    
    spriteObject = [variablesContainer.objectVariableList keyAtIndex:2];
    XCTAssertTrue([spriteObject.name isEqualToString:[NSString stringWithFormat:@"Upper left tile"]], @"Invalid SpriteObject name for object variable 3");
    variables = [variablesContainer objectVariablesForObject:spriteObject];
    XCTAssertEqual(0, [variables count], @"Invalid number of object variables for object 3");
    
    spriteObject = [variablesContainer.objectVariableList keyAtIndex:3];
    XCTAssertTrue([spriteObject.name isEqualToString:[NSString stringWithFormat:@"Airplane"]], @"Invalid SpriteObject name for object variable 4");
    variables = [variablesContainer objectVariablesForObject:spriteObject];
    XCTAssertEqual(0, [variables count], @"Invalid number of object variables for object 4");
    
    spriteObject = [variablesContainer.objectVariableList keyAtIndex:4];
    XCTAssertTrue([spriteObject.name isEqualToString:[NSString stringWithFormat:@"Upper right tile"]], @"Invalid SpriteObject name for object variable 5");
    variables = [variablesContainer objectVariablesForObject:spriteObject];
    XCTAssertEqual(0, [variables count], @"Invalid number of object variables for object 5");
    
    spriteObject = [variablesContainer.objectVariableList keyAtIndex:5];
    XCTAssertTrue([spriteObject.name isEqualToString:[NSString stringWithFormat:@"Shadow"]], @"Invalid SpriteObject name for object variable 6");
    variables = [variablesContainer objectVariablesForObject:spriteObject];
    XCTAssertEqual(0, [variables count], @"Invalid number of object variables for object 6");
    
    spriteObject = [variablesContainer.objectVariableList keyAtIndex:6];
    XCTAssertTrue([spriteObject.name isEqualToString:[NSString stringWithFormat:@"Background"]], @"Invalid SpriteObject name for object variable 7");
    variables = [variablesContainer objectVariablesForObject:spriteObject];
    XCTAssertEqual(0, [variables count], @"Invalid number of object variables for object 7");
    
    spriteObject = [variablesContainer.objectVariableList keyAtIndex:7];
    XCTAssertTrue([spriteObject.name isEqualToString:[NSString stringWithFormat:@"Pointer"]], @"Invalid SpriteObject name for object variable 8");
    variables = [variablesContainer objectVariablesForObject:spriteObject];
    XCTAssertEqual(0, [variables count], @"Invalid number of object variables for object 8");

    XCTAssertEqual(5, [variablesContainer.programVariableList count], @"Invalid number of program variables");
}

@end
