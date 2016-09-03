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

@implementation XMLParserBrickTests093

- (void)setUp
{
    self.parserContext = [[CBXMLParserContext alloc] initWithLanguageVersion:0.93f];
}

- (void)testValidSetLookBrick
{
    GDataXMLDocument *document = [self getXMLDocumentForPath:[self getPathForXML:@"ValidProgram"]];
    GDataXMLElement *xmlElement = [document rootElement];
    
    NSArray *brickElement = [xmlElement nodesForXPath:@"//program/objectList/object[1]/scriptList/script[1]/brickList/brick[1]" error:nil];
    XCTAssertEqual([brickElement count], 1);
    
    NSArray *objectArray = [xmlElement nodesForXPath:@"//program/objectList/object[1]" error:nil];
    XCTAssertEqual([objectArray count], 1);
    GDataXMLElement *objectElement = [objectArray objectAtIndex:0];
    
    NSMutableArray *lookList = [SpriteObject parseAndCreateLooks:objectElement withContext:self.parserContext];
    GDataXMLElement *brickXMLElement = [brickElement objectAtIndex:0];
    
    self.parserContext.spriteObject = [SpriteObject new];
    self.parserContext.spriteObject.lookList = lookList;
    Brick *brick = [self.parserContext parseFromElement:brickXMLElement withClass:[SetLookBrick class]];
    
    XCTAssertTrue(brick.brickType == kSetLookBrick, @"Invalid brick type");
    XCTAssertTrue([brick isKindOfClass:[SetLookBrick class]], @"Invalid brick class");
    
    SetLookBrick *setLookBrick = (SetLookBrick*)brick;
    
    Look *look = setLookBrick.look;
    XCTAssertTrue([look.name isEqualToString:@"Background"], @"Invalid look name");
}

- (void)testValidSetVariableBrick
{
    GDataXMLDocument *document = [self getXMLDocumentForPath:[self getPathForXML:@"ValidProgram"]];
    GDataXMLElement *xmlElement = [document rootElement];
    
    NSArray *brickElement = [xmlElement nodesForXPath:@"//program/objectList/object[1]/scriptList/script[1]/brickList/brick[2]" error:nil];
    XCTAssertEqual([brickElement count], 1);
    GDataXMLElement *brickXMLElement = [brickElement objectAtIndex:0];

    Brick *brick = [self.parserContext parseFromElement:brickXMLElement withClass:[SetVariableBrick class]];
    XCTAssertTrue(brick.brickType == kSetVariableBrick, @"Invalid brick type");
    XCTAssertTrue([brick isKindOfClass:[SetVariableBrick class]], @"Invalid brick class");
    
    SetVariableBrick *setVariableBrick = (SetVariableBrick*)brick;
    
    XCTAssertTrue([setVariableBrick.userVariable.name isEqualToString:@"random from"], @"Invalid user variable name");
    
    Formula *formula = setVariableBrick.variableFormula;
    XCTAssertTrue(formula.formulaTree.type == NUMBER, @"Invalid variable type");
    XCTAssertTrue([formula.formulaTree.value isEqualToString:@"1"], @"Invalid variable value");
}

- (void)testValidSetSizeToBrick
{
    GDataXMLDocument *document = [self getXMLDocumentForPath:[self getPathForXML:@"ValidProgram"]];
    GDataXMLElement *xmlElement = [document rootElement];
    
    NSArray *brickElement = [xmlElement nodesForXPath:@"//program/objectList/object[2]/scriptList/script[1]/brickList/brick[1]" error:nil];
    XCTAssertEqual([brickElement count], 1);
    
    NSArray *objectArray = [xmlElement nodesForXPath:@"//program/objectList/object[1]" error:nil];
    XCTAssertEqual([objectArray count], 1);
    GDataXMLElement *objectElement = [objectArray objectAtIndex:0];
    
    NSMutableArray *lookList = [SpriteObject parseAndCreateLooks:objectElement withContext:self.parserContext];
    GDataXMLElement *brickXMLElement = [brickElement objectAtIndex:0];

    CBXMLParserContext *context = [CBXMLParserContext new];
    context.spriteObject = [SpriteObject new];
    context.spriteObject.lookList = lookList;
    Brick *brick = [self.parserContext parseFromElement:brickXMLElement withClass:[SetSizeToBrick class]];

    XCTAssertTrue(brick.brickType == kSetSizeToBrick, @"Invalid brick type");
    XCTAssertTrue([brick isKindOfClass:[SetSizeToBrick class]], @"Invalid brick class");
    
    SetSizeToBrick *setSizeToBrick = (SetSizeToBrick*)brick;
    Formula *formula = setSizeToBrick.size;
    
    XCTAssertNotNil(formula, @"Invalid formula");
    
    XCTAssertTrue(formula.formulaTree.type == NUMBER, @"Invalid variable type");
    XCTAssertTrue([formula.formulaTree.value isEqualToString:@"30"], @"Invalid formula value");
    
    XCTAssertEqualWithAccuracy([formula interpretDoubleForSprite:nil], 30, 0.00001, @"Formula not correctly parsed");
}

- (void)testValidForeverBrickAndLoopEndlessBrick
{
    CBXMLParserContext *context = [[CBXMLParserContext alloc] init];
    GDataXMLDocument *document = [self getXMLDocumentForPath:[self getPathForXML:@"ValidProgram"]];
    GDataXMLElement *xmlElement = [document rootElement];
    
    NSArray *brickElement = [xmlElement nodesForXPath:@"//program/objectList/object[2]/scriptList/script[1]/brickList/brick[2]" error:nil];
    XCTAssertEqual([brickElement count], 1);
    
    GDataXMLElement *brickXMLElement = [brickElement objectAtIndex:0];
    
    Brick *brick = [self.parserContext parseFromElement:brickXMLElement withClass:[ForeverBrick class]];
    
    XCTAssertTrue(brick.brickType == kForeverBrick, @"Invalid brick type");
    XCTAssertTrue([brick isKindOfClass:[ForeverBrick class]], @"Invalid brick class");
    
    brickElement = [xmlElement nodesForXPath:@"//program/objectList/object[2]/scriptList/script[1]/brickList/brick[12]" error:nil];
    XCTAssertEqual([brickElement count], 1);
    
    brickXMLElement = [brickElement objectAtIndex:0];
    
    brick = [self.parserContext parseFromElement:brickXMLElement withClass:[LoopEndBrick class]];
    
    XCTAssertTrue(brick.brickType == kLoopEndBrick, @"Invalid brick type");
    XCTAssertTrue([brick isKindOfClass:[LoopEndBrick class]], @"Invalid brick class");
    
    XCTAssertTrue([context.openedNestingBricksStack isEmpty], @"Nesting bricks not closed properly");
}

- (void)testValidPlaceAtBrick
{
    GDataXMLDocument *document = [self getXMLDocumentForPath:[self getPathForXML:@"ValidProgram"]];
    GDataXMLElement *xmlElement = [document rootElement];
    
    NSArray *brickElement = [xmlElement nodesForXPath:@"//program/objectList/object[2]/scriptList/script[1]/brickList/brick[3]" error:nil];
    XCTAssertEqual([brickElement count], 1);
    
    GDataXMLElement *brickXMLElement = [brickElement objectAtIndex:0];
    
    Brick *brick = [self.parserContext parseFromElement:brickXMLElement withClass:[PlaceAtBrick class]];
    
    XCTAssertTrue(brick.brickType == kPlaceAtBrick, @"Invalid brick type");
    XCTAssertTrue([brick isKindOfClass:[PlaceAtBrick class]], @"Invalid brick class");
    
    PlaceAtBrick *placeAtBrick = (PlaceAtBrick*)brick;
    Formula *xPosition = placeAtBrick.xPosition;
    Formula *yPosition = placeAtBrick.yPosition;
    XCTAssertNotNil(xPosition, @"Invalid formula for xPosition");
    XCTAssertNotNil(yPosition, @"Invalid formula for yPosition");
    
    XCTAssertEqualWithAccuracy([xPosition interpretDoubleForSprite:nil], -170, 0.00001, @"Formula not correctly parsed");
    XCTAssertEqualWithAccuracy([yPosition interpretDoubleForSprite:nil], -115, 0.00001, @"Formula not correctly parsed");
}

- (void)testValidWaitBrick
{
    GDataXMLDocument *document = [self getXMLDocumentForPath:[self getPathForXML:@"ValidProgram"]];
    GDataXMLElement *xmlElement = [document rootElement];
    
    NSArray *brickElement = [xmlElement nodesForXPath:@"//program/objectList/object[2]/scriptList/script[1]/brickList/brick[4]" error:nil];
    XCTAssertEqual([brickElement count], 1);
    
    GDataXMLElement *brickXMLElement = [brickElement objectAtIndex:0];
    
    Brick *brick = [self.parserContext parseFromElement:brickXMLElement withClass:[WaitBrick class]];
    
    XCTAssertTrue(brick.brickType == kWaitBrick, @"Invalid brick type");
    XCTAssertTrue([brick isKindOfClass:[WaitBrick class]], @"Invalid brick class");
    
    WaitBrick *waitBrick = (WaitBrick*)brick;
    Formula *timeToWaitInSeconds = waitBrick.timeToWaitInSeconds;
    XCTAssertNotNil(timeToWaitInSeconds, @"Invalid formula");
    
    // result is either 1 or 2
    XCTAssertEqualWithAccuracy([timeToWaitInSeconds interpretDoubleForSprite:nil], 1, 1, @"Formula not correctly parsed");
}

- (void)testValidShowBrick
{
    GDataXMLDocument *document = [self getXMLDocumentForPath:[self getPathForXML:@"ValidProgram"]];
    GDataXMLElement *xmlElement = [document rootElement];
    
    NSArray *brickElement = [xmlElement nodesForXPath:@"//program/objectList/object[2]/scriptList/script[1]/brickList/brick[5]" error:nil];
    XCTAssertEqual([brickElement count], 1);
    
    GDataXMLElement *brickXMLElement = [brickElement objectAtIndex:0];
    
    Brick *brick = [self.parserContext parseFromElement:brickXMLElement withClass:[ShowBrick class]];
    
    XCTAssertTrue(brick.brickType == kShowBrick, @"Invalid brick type");
    XCTAssertTrue([brick isKindOfClass:[ShowBrick class]], @"Invalid brick class");
}

- (void)testValidGlideToBrick
{
    GDataXMLDocument *document = [self getXMLDocumentForPath:[self getPathForXML:@"ValidProgram"]];
    GDataXMLElement *xmlElement = [document rootElement];
    
    NSArray *brickElement = [xmlElement nodesForXPath:@"//program/objectList/object[2]/scriptList/script[1]/brickList/brick[7]" error:nil];
    XCTAssertEqual([brickElement count], 1);
    
    GDataXMLElement *brickXMLElement = [brickElement objectAtIndex:0];
    
    Brick *brick = [self.parserContext parseFromElement:brickXMLElement withClass:[GlideToBrick class]];
    
    XCTAssertTrue(brick.brickType == kGlideToBrick, @"Invalid brick type");
    XCTAssertTrue([brick isKindOfClass:[GlideToBrick class]], @"Invalid brick class");
    
    GlideToBrick *glideToBrick = (GlideToBrick*)brick;
    
    Formula *durationInSeconds = glideToBrick.durationInSeconds;
    XCTAssertNotNil(durationInSeconds, @"Invalid formula");
    XCTAssertEqualWithAccuracy([durationInSeconds interpretDoubleForSprite:nil], 0.1, 0.00001, @"Formula not correctly parsed");
    
    Formula *xDestination = glideToBrick.xDestination;
    XCTAssertNotNil(xDestination, @"Invalid formula");
    XCTAssertEqualWithAccuracy([xDestination interpretDoubleForSprite:nil], -170, 0.00001, @"Formula not correctly parsed");

    Formula *yDestination = glideToBrick.yDestination;
    XCTAssertNotNil(yDestination, @"Invalid formula");
    XCTAssertEqualWithAccuracy([yDestination interpretDoubleForSprite:nil], -100, 0.00001, @"Formula not correctly parsed");
}

- (void)testValidHideBrick
{
    GDataXMLDocument *document = [self getXMLDocumentForPath:[self getPathForXML:@"ValidProgram"]];
    GDataXMLElement *xmlElement = [document rootElement];
    
    NSArray *brickElement = [xmlElement nodesForXPath:@"//program/objectList/object[2]/scriptList/script[1]/brickList/brick[10]" error:nil];
    XCTAssertEqual([brickElement count], 1);
    
    GDataXMLElement *brickXMLElement = [brickElement objectAtIndex:0];
    
    Brick *brick = [self.parserContext parseFromElement:brickXMLElement withClass:[HideBrick class]];
    
    XCTAssertTrue(brick.brickType == kHideBrick, @"Invalid brick type");
    XCTAssertTrue([brick isKindOfClass:[HideBrick class]], @"Invalid brick class");
}

- (void)testValidPlaySoundBrick
{
    GDataXMLDocument *document = [self getXMLDocumentForPath:[self getPathForXML:@"ValidProgram"]];
    GDataXMLElement *xmlElement = [document rootElement];
    
    NSArray *brickElement = [xmlElement nodesForXPath:@"//program/objectList/object[2]/scriptList/script[2]/brickList/brick[1]" error:nil];
    XCTAssertEqual([brickElement count], 1);
    
    NSArray *objectArray = [xmlElement nodesForXPath:@"//program/objectList/object[2]" error:nil];
    XCTAssertEqual([objectArray count], 1);
    GDataXMLElement *objectElement = [objectArray objectAtIndex:0];
    
    NSMutableArray *soundList = [SpriteObject parseAndCreateSounds:objectElement withContext:self.parserContext];
    GDataXMLElement *brickXMLElement = [brickElement objectAtIndex:0];

    self.parserContext.spriteObject = [SpriteObject new];
    self.parserContext.spriteObject.soundList = soundList;
    Brick *brick = [self.parserContext parseFromElement:brickXMLElement withClass:[PlaySoundBrick class]];

    XCTAssertTrue(brick.brickType == kPlaySoundBrick, @"Invalid brick type");
    XCTAssertTrue([brick isKindOfClass:[PlaySoundBrick class]], @"Invalid brick class");
    
    PlaySoundBrick *playSoundBrick = (PlaySoundBrick*)brick;
    Sound *sound = playSoundBrick.sound;
    
    XCTAssertNotNil(sound, @"Invalid sound");
    XCTAssertTrue([sound.name isEqualToString:@"Hit"], @"Invalid sound name");
}

- (void)testValidSetXBrick
{
    GDataXMLDocument *document = [self getXMLDocumentForPath:[self getPathForXML:@"ValidProgramAllBricks"]];
    GDataXMLElement *xmlElement = [document rootElement];
    
    NSArray *brickElement = [xmlElement nodesForXPath:@"//program/objectList/object[1]/scriptList/script[1]/brickList/brick[2]" error:nil];
    XCTAssertEqual([brickElement count], 1);
    
    GDataXMLElement *brickXMLElement = [brickElement objectAtIndex:0];
    
    Brick *brick = [self.parserContext parseFromElement:brickXMLElement withClass:[SetXBrick class]];
    
    XCTAssertTrue(brick.brickType == kSetXBrick, @"Invalid brick type");
    XCTAssertTrue([brick isKindOfClass:[SetXBrick class]], @"Invalid brick class");
    
    SetXBrick *setXBrick = (SetXBrick*)brick;
    Formula *formula = setXBrick.xPosition;
    
    XCTAssertNotNil(formula, @"Invalid formula");
    XCTAssertTrue(formula.formulaTree.type == USER_VARIABLE, @"Invalid variable type");
    XCTAssertTrue([formula.formulaTree.value isEqualToString:@"lokal"], @"Invalid formula value");
}

- (void)testValidSetXBrickEqual
{
    GDataXMLDocument *document = [self getXMLDocumentForPath:[self getPathForXML:@"ValidProgramAllBricks"]];
    GDataXMLElement *xmlElement = [document rootElement];
    
    NSArray *brickElement = [xmlElement nodesForXPath:@"//program/objectList/object[1]/scriptList/script[1]/brickList/brick[2]" error:nil];
    XCTAssertEqual([brickElement count], 1);
    
    GDataXMLElement *brickXMLElement = [brickElement objectAtIndex:0];
    
    Brick *brick = [self.parserContext parseFromElement:brickXMLElement withClass:[SetXBrick class]];
    
    XCTAssertTrue(brick.brickType == kSetXBrick, @"Invalid brick type");
    XCTAssertTrue([brick isKindOfClass:[SetXBrick class]], @"Invalid brick class");
    
    SetXBrick *setXBrick = (SetXBrick*)brick;
    Formula *formula = setXBrick.xPosition;
    
    XCTAssertNotNil(formula, @"Invalid formula");
    XCTAssertTrue(formula.formulaTree.type == USER_VARIABLE, @"Invalid variable type");
    XCTAssertTrue([formula.formulaTree.value isEqualToString:@"lokal"], @"Invalid formula value");
    
    SetXBrick *secondBrick = [SetXBrick new];
    Formula *secondFormula = [Formula new];
    FormulaElement *formulaTree = [FormulaElement new];
    formulaTree.type = USER_VARIABLE;
    formulaTree.value = @"lokal";
    secondFormula.formulaTree = formulaTree;
    secondBrick.xPosition = secondFormula;
    
    XCTAssertTrue([secondFormula isEqualToFormula:formula], @"Formulas not equal");
    XCTAssertTrue([secondBrick isEqualToBrick:setXBrick], @"SetXBricks not equal");
}

- (void)testValidSetYBrick
{
    GDataXMLDocument *document = [self getXMLDocumentForPath:[self getPathForXML:@"ValidProgramAllBricks"]];
    GDataXMLElement *xmlElement = [document rootElement];
    
    NSArray *brickElement = [xmlElement nodesForXPath:@"//program/objectList/object[1]/scriptList/script[1]/brickList/brick[3]" error:nil];
    XCTAssertEqual([brickElement count], 1);
    
    GDataXMLElement *brickXMLElement = [brickElement objectAtIndex:0];
    
    Brick *brick = [self.parserContext parseFromElement:brickXMLElement withClass:[SetYBrick class]];
    
    XCTAssertTrue(brick.brickType == kSetYBrick, @"Invalid brick type");
    XCTAssertTrue([brick isKindOfClass:[SetYBrick class]], @"Invalid brick class");
    
    SetYBrick *setYBrick = (SetYBrick*)brick;
    Formula *formula = setYBrick.yPosition;
    
    XCTAssertNotNil(formula, @"Invalid formula");
    XCTAssertTrue(formula.formulaTree.type == USER_VARIABLE, @"Invalid variable type");
    XCTAssertTrue([formula.formulaTree.value isEqualToString:@"global"], @"Invalid formula value");
}

- (void)testValidChangeXByNBrick
{
    GDataXMLDocument *document = [self getXMLDocumentForPath:[self getPathForXML:@"ValidProgramAllBricks"]];
    GDataXMLElement *xmlElement = [document rootElement];
    
    NSArray *brickElement = [xmlElement nodesForXPath:@"//program/objectList/object[1]/scriptList/script[1]/brickList/brick[4]" error:nil];
    XCTAssertEqual([brickElement count], 1);
    
    GDataXMLElement *brickXMLElement = [brickElement objectAtIndex:0];
    
    Brick *brick = [self.parserContext parseFromElement:brickXMLElement withClass:[ChangeXByNBrick class]];
    
    XCTAssertTrue(brick.brickType == kChangeXByNBrick, @"Invalid brick type");
    XCTAssertTrue([brick isKindOfClass:[ChangeXByNBrick class]], @"Invalid brick class");
    
    ChangeXByNBrick *changeXByNBrick = (ChangeXByNBrick*)brick;
    Formula *formula = changeXByNBrick.xMovement;
    
    XCTAssertNotNil(formula, @"Invalid formula");
    XCTAssertTrue(formula.formulaTree.type == SENSOR, @"Invalid variable type");
    XCTAssertTrue([formula.formulaTree.value isEqualToString:@"OBJECT_BRIGHTNESS"], @"Invalid formula value");
}

- (void)testValidChangeYByNBrick
{
    GDataXMLDocument *document = [self getXMLDocumentForPath:[self getPathForXML:@"ValidProgramAllBricks"]];
    GDataXMLElement *xmlElement = [document rootElement];
    
    NSArray *brickElement = [xmlElement nodesForXPath:@"//program/objectList/object[1]/scriptList/script[1]/brickList/brick[5]" error:nil];
    XCTAssertEqual([brickElement count], 1);
    
    GDataXMLElement *brickXMLElement = [brickElement objectAtIndex:0];
    
    Brick *brick = [self.parserContext parseFromElement:brickXMLElement withClass:[ChangeYByNBrick class]];
    
    XCTAssertTrue(brick.brickType == kChangeYByNBrick, @"Invalid brick type");
    XCTAssertTrue([brick isKindOfClass:[ChangeYByNBrick class]], @"Invalid brick class");
    
    ChangeYByNBrick *changeYByNBrick = (ChangeYByNBrick*)brick;
    Formula *formula = changeYByNBrick.yMovement;
    
    XCTAssertNotNil(formula, @"Invalid formula");
    XCTAssertEqualWithAccuracy([formula interpretDoubleForSprite:nil], 10, 0.00001, @"Formula not correctly parsed");
}

- (void)testValidMoveNStepsBrick
{
    GDataXMLDocument *document = [self getXMLDocumentForPath:[self getPathForXML:@"ValidProgramAllBricks"]];
    GDataXMLElement *xmlElement = [document rootElement];
    
    NSArray *brickElement = [xmlElement nodesForXPath:@"//program/objectList/object[1]/scriptList/script[1]/brickList/brick[6]" error:nil];
    XCTAssertEqual([brickElement count], 1);
    
    GDataXMLElement *brickXMLElement = [brickElement objectAtIndex:0];
    
    Brick *brick = [self.parserContext parseFromElement:brickXMLElement withClass:[MoveNStepsBrick class]];
    
    XCTAssertTrue(brick.brickType == kMoveNStepsBrick, @"Invalid brick type");
    XCTAssertTrue([brick isKindOfClass:[MoveNStepsBrick class]], @"Invalid brick class");
    
    MoveNStepsBrick *moveNStepsBrick = (MoveNStepsBrick*)brick;
    Formula *formula = moveNStepsBrick.steps;
    
    XCTAssertNotNil(formula, @"Invalid formula");
    XCTAssertEqualWithAccuracy([formula interpretDoubleForSprite:nil], log10f(sqrt(5)) / log10f(10), 0.00001, @"Formula not correctly parsed");
}

- (void)testValidTurnLeftBrick
{
    GDataXMLDocument *document = [self getXMLDocumentForPath:[self getPathForXML:@"ValidProgramAllBricks"]];
    GDataXMLElement *xmlElement = [document rootElement];
    
    NSArray *brickElement = [xmlElement nodesForXPath:@"//program/objectList/object[1]/scriptList/script[1]/brickList/brick[7]" error:nil];
    XCTAssertEqual([brickElement count], 1);
    
    GDataXMLElement *brickXMLElement = [brickElement objectAtIndex:0];
    
    Brick *brick = [self.parserContext parseFromElement:brickXMLElement withClass:[TurnLeftBrick class]];
    
    XCTAssertTrue(brick.brickType == kTurnLeftBrick, @"Invalid brick type");
    XCTAssertTrue([brick isKindOfClass:[TurnLeftBrick class]], @"Invalid brick class");
    
    TurnLeftBrick *turnLeftBrick = (TurnLeftBrick*)brick;
    Formula *formula = turnLeftBrick.degrees;
    
    XCTAssertNotNil(formula, @"Invalid formula");
    XCTAssertEqualWithAccuracy([formula interpretDoubleForSprite:nil], 15, 0.00001, @"Formula not correctly parsed");
}

- (void)testValidTurnRightBrick
{
    GDataXMLDocument *document = [self getXMLDocumentForPath:[self getPathForXML:@"ValidProgramAllBricks"]];
    GDataXMLElement *xmlElement = [document rootElement];
    
    NSArray *brickElement = [xmlElement nodesForXPath:@"//program/objectList/object[1]/scriptList/script[1]/brickList/brick[8]" error:nil];
    XCTAssertEqual([brickElement count], 1);
    
    GDataXMLElement *brickXMLElement = [brickElement objectAtIndex:0];
    
    Brick *brick = [self.parserContext parseFromElement:brickXMLElement withClass:[TurnRightBrick class]];
    
    XCTAssertTrue(brick.brickType == kTurnRightBrick, @"Invalid brick type");
    XCTAssertTrue([brick isKindOfClass:[TurnRightBrick class]], @"Invalid brick class");
    
    TurnRightBrick *turnRightBrick = (TurnRightBrick*)brick;
    Formula *formula = turnRightBrick.degrees;
    
    XCTAssertNotNil(formula, @"Invalid formula");
    XCTAssertEqualWithAccuracy([formula interpretDoubleForSprite:nil], 15, 0.00001, @"Formula not correctly parsed");
}

- (void)testValidPointInDirectionBrick
{
    GDataXMLDocument *document = [self getXMLDocumentForPath:[self getPathForXML:@"ValidProgramAllBricks"]];
    GDataXMLElement *xmlElement = [document rootElement];
    
    NSArray *brickElement = [xmlElement nodesForXPath:@"//program/objectList/object[1]/scriptList/script[1]/brickList/brick[9]" error:nil];
    XCTAssertEqual([brickElement count], 1);
    
    GDataXMLElement *brickXMLElement = [brickElement objectAtIndex:0];
    
    Brick *brick = [self.parserContext parseFromElement:brickXMLElement withClass:[PointInDirectionBrick class]];
    
    XCTAssertTrue(brick.brickType == kPointInDirectionBrick, @"Invalid brick type");
    XCTAssertTrue([brick isKindOfClass:[PointInDirectionBrick class]], @"Invalid brick class");
    
    PointInDirectionBrick *pointInDirectionBrick = (PointInDirectionBrick*)brick;
    Formula *formula = pointInDirectionBrick.degrees;
    
    XCTAssertNotNil(formula, @"Invalid formula");
    XCTAssertEqualWithAccuracy([formula interpretDoubleForSprite:nil], 90, 0.00001, @"Formula not correctly parsed");
}

- (void)testValidStopAllSoundBrick
{
    GDataXMLDocument *document = [self getXMLDocumentForPath:[self getPathForXML:@"ValidProgramAllBricks"]];
    GDataXMLElement *xmlElement = [document rootElement];
    
    NSArray *brickElement = [xmlElement nodesForXPath:@"//program/objectList/object[1]/scriptList/script[1]/brickList/brick[10]/pointedObject[1]/scriptList/script[1]/brickList/brick[2]" error:nil];
    XCTAssertEqual([brickElement count], 1);
    
    GDataXMLElement *brickXMLElement = [brickElement objectAtIndex:0];
    
    Brick *brick = [self.parserContext parseFromElement:brickXMLElement withClass:[StopAllSoundsBrick class]];
    
    XCTAssertTrue(brick.brickType == kStopAllSoundsBrick, @"Invalid brick type");
    XCTAssertTrue([brick isKindOfClass:[StopAllSoundsBrick class]], @"Invalid brick class");
}

- (void)testValidPointToBrick
{
    GDataXMLDocument *document = [self getXMLDocumentForPath:[self getPathForXML:@"ValidProgramAllBricks"]];
    GDataXMLElement *xmlElement = [document rootElement];
    
    NSArray *brickElement = [xmlElement nodesForXPath:@"//program/objectList/object[1]/scriptList/script[1]/brickList/brick[10]" error:nil];
    XCTAssertEqual([brickElement count], 1);
    
    GDataXMLElement *brickXMLElement = [brickElement objectAtIndex:0];
    
    Brick *brick = [self.parserContext parseFromElement:brickXMLElement withClass:[PointToBrick class]];
    
    XCTAssertTrue(brick.brickType == kPointToBrick, @"Invalid brick type");
    XCTAssertTrue([brick isKindOfClass:[PointToBrick class]], @"Invalid brick class");
    
    PointToBrick *pointToBrick = (PointToBrick*)brick;
    SpriteObject *spriteObject = pointToBrick.pointedObject;
    XCTAssertNotNil(spriteObject, @"Invalid SpriteObject");
    XCTAssertTrue([spriteObject.name isEqualToString:@"stickers"], @"Invalid object name");
}

- (void)testValidPointToBrickWithoutSpriteObject
{
    Program *program = [self getProgramForXML:@"PointToBrickWithoutSpriteObject"];
    XCTAssertNotNil(program, @"Program must not be nil!");
    
    SpriteObject *moleTwo = [program.objectList objectAtIndex:1];
    XCTAssertNotNil(moleTwo, @"SpriteObject must not be nil!");
    XCTAssertTrue([moleTwo.name isEqualToString:@"Mole 2"], @"Invalid object name!");
    
    Script *script = [moleTwo.scriptList objectAtIndex:0];
    XCTAssertNotNil(script, @"Script must not be nil!");

    PointToBrick *pointToBrick = (PointToBrick*)[script.brickList objectAtIndex:7];
    XCTAssertNotNil(pointToBrick, @"PointToBrick must not be nil!");
    
    SpriteObject *pointedObject = pointToBrick.pointedObject;
    XCTAssertNotNil(pointedObject, @"pointedObject must not be nil!");
    XCTAssertTrue([pointedObject.name isEqualToString:@"Mole 2"], @"Invalid object name!");
}

- (void)testValidSetColorToBrick
{
    GDataXMLDocument *document = [self getXMLDocumentForPath:[self getPathForXML:@"ValidProgramAllBricks"]];
    GDataXMLElement *xmlElement = [document rootElement];
    
    NSArray *brickElement = [xmlElement nodesForXPath:@"//program/objectList/object[1]/scriptList/script[1]/brickList/brick[15]" error:nil];
    XCTAssertEqual([brickElement count], 1);
    
    GDataXMLElement *brickXMLElement = [brickElement objectAtIndex:0];
    
    Brick *brick = [self.parserContext parseFromElement:brickXMLElement withClass:[SetColorToBrick class]];
    
    XCTAssertTrue(brick.brickType == kSetColorToBrick, @"Invalid brick type");
    XCTAssertTrue([brick isKindOfClass:[SetColorToBrick class]], @"Invalid brick class");
    
    SetColorToBrick *setColorToBrick = (SetColorToBrick*)brick;
    XCTAssertEqual(1, [setColorToBrick.color interpretIntegerForSprite:nil], @"Invalid formula");
}

- (void)testValidChangeColorByNBrick
{
    GDataXMLDocument *document = [self getXMLDocumentForPath:[self getPathForXML:@"ValidProgramAllBricks"]];
    GDataXMLElement *xmlElement = [document rootElement];
    
    NSArray *brickElement = [xmlElement nodesForXPath:@"//program/objectList/object[1]/scriptList/script[1]/brickList/brick[16]" error:nil];
    XCTAssertEqual([brickElement count], 1);
    
    GDataXMLElement *brickXMLElement = [brickElement objectAtIndex:0];
    
    Brick *brick = [self.parserContext parseFromElement:brickXMLElement withClass:[ChangeColorByNBrick class]];
    
    XCTAssertTrue(brick.brickType == kChangeColorByNBrick, @"Invalid brick type");
    XCTAssertTrue([brick isKindOfClass:[ChangeColorByNBrick class]], @"Invalid brick class");
    
    ChangeColorByNBrick *changeColorByNBrick = (ChangeColorByNBrick*)brick;
    XCTAssertEqual(2, [changeColorByNBrick.changeColor interpretIntegerForSprite:nil], @"Invalid formula");
}

@end
