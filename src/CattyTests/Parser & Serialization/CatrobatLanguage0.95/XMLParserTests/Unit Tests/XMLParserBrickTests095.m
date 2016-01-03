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

#import "XMLParserBrickTests093.h"
#import "CBXMLParserHelper.h"
#import "ChangeVariableBrick+CBXMLHandler.h"

@interface XMLParserBrickTests095 : XMLParserBrickTests093

@property (nonatomic, strong) CBXMLSerializerContext *serializerContext;
@end

@implementation XMLParserBrickTests095

- (void)setUp
{
    self.parserContext = [[CBXMLParserContext alloc] initWithLanguageVersion:0.95f];
    self.serializerContext = [[CBXMLSerializerContext alloc] init];
}

- (void)testInvalidSetVariableBrickWithoutFormula
{
    SetVariableBrick *setVariableBrick = [SetVariableBrick new];
    GDataXMLElement *xmlElement = [setVariableBrick xmlElementWithContext:self.serializerContext];
    
    XCTAssertThrowsSpecificNamed([SetVariableBrick parseFromElement:xmlElement withContextForLanguageVersion095:self.parserContext], NSException, NSStringFromClass([CBXMLParserHelper class]), @"SetVariableBrick has invalid number of formulas. Should throw exception.");
}

- (void)testSetVariableBrickWithoutUserVariable
{
    SetVariableBrick *setVariableBrick = [SetVariableBrick new];
    [setVariableBrick setDefaultValuesForObject:nil];
    GDataXMLElement *xmlElement = [setVariableBrick xmlElementWithContext:self.serializerContext];
    
    XCTAssertNotNil(xmlElement, @"GDataXMLElement must not be nil");
    
    GDataXMLElement *inUserBrickElement = [xmlElement childWithElementName:@"inUserBrick"];
    XCTAssertNotNil(inUserBrickElement, @"No inUserBrickElement element found");
    
    SetVariableBrick *parsedSetVariableBrick = [SetVariableBrick parseFromElement:xmlElement withContextForLanguageVersion095:self.parserContext];
    
    XCTAssertNotNil(parsedSetVariableBrick, @"Could not parse SetVariableBrick");
    XCTAssertNotNil(parsedSetVariableBrick.variableFormula, @"Formula not correctly parsed");
}

- (void)testSetVariableBrickWithoutInUserBrickElement
{
    SetVariableBrick *setVariableBrick = [SetVariableBrick new];
    [setVariableBrick setDefaultValuesForObject:nil];
    GDataXMLElement *xmlElement = [setVariableBrick xmlElementWithContext:self.serializerContext];
    
    XCTAssertNotNil(xmlElement, @"GDataXMLElement must not be nil");
    
    GDataXMLElement *inUserBrickElement = [xmlElement childWithElementName:@"inUserBrick"];
    XCTAssertNotNil(inUserBrickElement, @"No inUserBrickElement element found");
    
    [xmlElement removeChild:inUserBrickElement];
    
    XCTAssertNil([xmlElement childWithElementName:@"inUserBrick"], @"inUserBrickElement element not removed");
    
    SetVariableBrick *parsedSetVariableBrick = [SetVariableBrick parseFromElement:xmlElement withContextForLanguageVersion095:self.parserContext];
    
    XCTAssertNotNil(parsedSetVariableBrick, @"Could not parse SetVariableBrick");
    XCTAssertNotNil(parsedSetVariableBrick.variableFormula, @"Formula not correctly parsed");
}

- (void)testCompleteSetVariableBrick
{
    UserVariable *userVariable = [UserVariable new];
    userVariable.name = @"test";
    [self.serializerContext.variables.programVariableList addObject:userVariable];
    
    SetVariableBrick *setVariableBrick = [SetVariableBrick new];
    [setVariableBrick setDefaultValuesForObject:nil];
    setVariableBrick.userVariable = userVariable;
    
    GDataXMLElement *xmlElement = [setVariableBrick xmlElementWithContext:self.serializerContext];
    
    XCTAssertNotNil(xmlElement, @"GDataXMLElement must not be nil");
    
    SetVariableBrick *parsedSetVariableBrick = [SetVariableBrick parseFromElement:xmlElement withContextForLanguageVersion095:self.parserContext];
    
    XCTAssertNotNil(parsedSetVariableBrick, @"Could not parse SetVariableBrick");
    XCTAssertNotNil(parsedSetVariableBrick.variableFormula, @"Formula not correctly parsed");
    XCTAssertNotNil(parsedSetVariableBrick.userVariable, @"UserVariable not correctly parsed");
}

- (void)testInvalidChangeVariableBrickWithoutFormula
{
    ChangeVariableBrick *changeVariableBrick = [ChangeVariableBrick new];
    GDataXMLElement *xmlElement = [changeVariableBrick xmlElementWithContext:self.serializerContext];
    
    XCTAssertThrowsSpecificNamed([ChangeVariableBrick parseFromElement:xmlElement withContextForLanguageVersion095:self.parserContext], NSException, NSStringFromClass([CBXMLParserHelper class]), @"ChangeVariableBrick has invalid number of formulas. Should throw exception.");
}

- (void)testChangeVariableBrickWithoutUserVariable
{
    ChangeVariableBrick *changeVariableBrick = [ChangeVariableBrick new];
    [changeVariableBrick setDefaultValuesForObject:nil];
    GDataXMLElement *xmlElement = [changeVariableBrick xmlElementWithContext:self.serializerContext];
    
    XCTAssertNotNil(xmlElement, @"GDataXMLElement must not be nil");
    
    GDataXMLElement *inUserBrickElement = [xmlElement childWithElementName:@"inUserBrick"];
    XCTAssertNotNil(inUserBrickElement, @"No inUserBrickElement element found");
    
    ChangeVariableBrick *parsedChangeVariableBrick = [ChangeVariableBrick parseFromElement:xmlElement withContextForLanguageVersion095:self.parserContext];
    
    XCTAssertNotNil(parsedChangeVariableBrick, @"Could not parse ChangeVariableBrick");
    XCTAssertNotNil(parsedChangeVariableBrick.variableFormula, @"Formula not correctly parsed");
}

- (void)testChangeVariableBrickWithoutInUserBrickElement
{
    ChangeVariableBrick *changeVariableBrick = [ChangeVariableBrick new];
    [changeVariableBrick setDefaultValuesForObject:nil];
    GDataXMLElement *xmlElement = [changeVariableBrick xmlElementWithContext:self.serializerContext];
    
    XCTAssertNotNil(xmlElement, @"GDataXMLElement must not be nil");
    
    GDataXMLElement *inUserBrickElement = [xmlElement childWithElementName:@"inUserBrick"];
    XCTAssertNotNil(inUserBrickElement, @"No inUserBrickElement element found");
    
    [xmlElement removeChild:inUserBrickElement];
    
    XCTAssertNil([xmlElement childWithElementName:@"inUserBrick"], @"inUserBrickElement element not removed");
    
    ChangeVariableBrick *parsedChangeVariableBrick = [ChangeVariableBrick parseFromElement:xmlElement withContextForLanguageVersion095:self.parserContext];
    
    XCTAssertNotNil(parsedChangeVariableBrick, @"Could not parse ChangeVariableBrick");
    XCTAssertNotNil(parsedChangeVariableBrick.variableFormula, @"Formula not correctly parsed");
}

- (void)testCompleteChangeVariableBrick
{
    UserVariable *userVariable = [UserVariable new];
    userVariable.name = @"test";
    [self.serializerContext.variables.programVariableList addObject:userVariable];
    
    ChangeVariableBrick *changeVariableBrick = [ChangeVariableBrick new];
    [changeVariableBrick setDefaultValuesForObject:nil];
    changeVariableBrick.userVariable = userVariable;
    
    GDataXMLElement *xmlElement = [changeVariableBrick xmlElementWithContext:self.serializerContext];
    
    XCTAssertNotNil(xmlElement, @"GDataXMLElement must not be nil");
    
    ChangeVariableBrick *parsedChangeVariableBrick = [ChangeVariableBrick parseFromElement:xmlElement withContextForLanguageVersion095:self.parserContext];
    
    XCTAssertNotNil(parsedChangeVariableBrick, @"Could not parse ChangeVariableBrick");
    XCTAssertNotNil(parsedChangeVariableBrick.variableFormula, @"Formula not correctly parsed");
    XCTAssertNotNil(parsedChangeVariableBrick.userVariable, @"UserVariable not correctly parsed");
}

@end
