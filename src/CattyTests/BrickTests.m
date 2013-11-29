/**
 *  Copyright (C) 2010-2013 The Catrobat Team
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
#import "SpriteObject.h"
#import "Scene.h"
#import "Script.h"
#import "Formula.h"
#import "FormulaElement.h"
#import "ProgramLoadingInfo.h"
#import "Program.h"
#import "Parser.h"
#import "Look.h"
#import "BroadcastWaitHandler.h"
#import <SpriteKit/SpriteKit.h>
#import "UserVariable.h"
#import "VariablesContainer.h"
#import "Util.h"

//BrickImports
#import "Brick+UnitTestingExtensions.h"
#import "ComeToFrontBrick.h"
#import "SetXBrick.h"
#import "SetYBrick.h"
#import "Brick.h"
#import "LoopBeginBrick.h"
#import "LoopEndBrick.h"
#import "LoopBeginBrick.h"
#import "LoopEndBrick.h"
#import "BroadcastWaitBrick.h"
#import "IfLogicBeginBrick.h"
#import "IfLogicElseBrick.h"
#import "IfLogicEndBrick.h"
#import "NoteBrick.h"
#import "ForeverBrick.h"
#import "SetSizeToBrick.h"
#import "ShowBrick.h"
#import "SetVariableBrick.h"
#import "SetGhostEffectBrick.h"
#import "ChangeGhostEffectByNBrick.h"
#import "PointInDirectionBrick.h"
#import "PlaceAtBrick.h"
#import "HideBrick.h"
#import "ChangeYByNBrick.h"
#import "ChangeXByNBrick.h"
#import "ChangeSizeByNBrick.h"
#import "TurnLeftBrick.h"
#import "TurnRightBrick.h"
#import "GoNStepsBackBrick.h"
#import "SetBrightnessBrick.h"
#import "MoveNStepsBrick.h"
#import "ClearGraphicEffectBrick.h"

@interface BrickTests : XCTestCase

@property (strong, nonatomic) NSMutableArray* programs;
@property (strong, nonatomic) SKView *skView;
@property (strong, nonatomic) SKScene *scene;

@end

@implementation BrickTests

- (NSMutableArray*) programs
{
  if (! _programs)
    _programs = [NSMutableArray array];
  return _programs;
}

- (void)setUp
{
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

-(void)testSetSizeToBrickAction
{
    ComeToFrontBrick* brick = [[ComeToFrontBrick alloc] init];
    SKAction* action = [brick action];
    
    XCTAssertNotNil(action, @"Returned action is nil");
}

-(void)testSetSizeToBrickPositiv
{
    
    SpriteObject* object = [[SpriteObject alloc] init];
    
    SetSizeToBrick* brick = [[SetSizeToBrick alloc] init];
    brick.object = object;
    
    Formula* size = [[Formula alloc] init];
    FormulaElement* formulaTree = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"130";
    size.formulaTree = formulaTree;
    brick.size = size;
    
    dispatch_block_t action = [brick actionBlock];
    
    action();
    
    XCTAssertEqual([object scaleX], 130.0f, @"X - Scale not correct");
    XCTAssertEqual([object scaleY], 130.0f, @"Y - Scale not correct");
    
    
}

-(void)testSetSizeToBrickNegativ
{
    
    SpriteObject* object = [[SpriteObject alloc] init];
    
    SetSizeToBrick* brick = [[SetSizeToBrick alloc] init];
    brick.object = object;
    
    Formula* size = [[Formula alloc] init];
    FormulaElement* formulaTree = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"-130";
    size.formulaTree = formulaTree;
    brick.size = size;
    
    dispatch_block_t action = [brick actionBlock];
    
    action();
    
    XCTAssertEqual([object scaleX], -130.0f, @"X - Scale not correct");
    XCTAssertEqual([object scaleY], -130.0f, @"Y - Scale not correct");
    
    
}

-(void)testSetSizeToBrickWrongInput
{
    
    SpriteObject* object = [[SpriteObject alloc] init];
    
    SetSizeToBrick* brick = [[SetSizeToBrick alloc] init];
    brick.object = object;
    
    Formula* size = [[Formula alloc] init];
    FormulaElement* formulaTree = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"a";
    size.formulaTree = formulaTree;
    brick.size = size;
    
    dispatch_block_t action = [brick actionBlock];
    
    action();
    
    XCTAssertEqual([object scaleX], 0.0f, @"X - Scale not correct");
    XCTAssertEqual([object scaleY], 0.0f, @"Y - Scale not correct");
    
    
}

-(void)testComeToFrontBrick
{
    
    Program* program = [[Program alloc] init];
    
    SpriteObject* object1 = [[SpriteObject alloc] init];
    object1.program = program;
    object1.zPosition = 1;
    object1.numberOfObjectsWithoutBackground = 2;
    
    SpriteObject* object2 = [[SpriteObject alloc] init];
    object2.zPosition = 2;
    
    [program.objectList addObject:object1];
    [program.objectList addObject:object2];
    
    
    ComeToFrontBrick* brick = [[ComeToFrontBrick alloc] init];
    brick.object = object1;
    
    dispatch_block_t action = [brick actionBlock];
    action();
    
    XCTAssertEqual(object1.zPosition, (CGFloat)2.0, @"ComeToFront is not correctly calculated");
    XCTAssertEqual(object2.zPosition, (CGFloat)1.0, @"ComeToFront is not correctly calculated");

}

-(void)testSetXBrickPositiv
{
        
    SpriteObject* object = [[SpriteObject alloc] init];
    object.position = CGPointMake(0, 0);

    Scene* scene = [[Scene alloc] init];
    [scene addChild:object];
  
    Formula* xPosition =[[Formula alloc] init];
    FormulaElement* formulaTree  = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"20";
    xPosition.formulaTree = formulaTree;
    
    
    SetXBrick* brick = [[SetXBrick alloc]init];
    brick.object = object;
    brick.xPosition = xPosition;
    
    dispatch_block_t action = [brick actionBlock];
    action();
    
    
    XCTAssertEqual(object.xPosition, (CGFloat)20, @"SetxBrick is not correctly calculated");
}

-(void)testSetXBrickNegativ
{
    
    SpriteObject* object = [[SpriteObject alloc] init];
    object.position = CGPointMake(0, 0);
    
    Scene* scene = [[Scene alloc] init];
    [scene addChild:object];
    
    Formula* xPosition =[[Formula alloc] init];
    FormulaElement* formulaTree  = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"-20";
    xPosition.formulaTree = formulaTree;
    
    
    SetXBrick* brick = [[SetXBrick alloc]init];
    brick.object = object;
    brick.xPosition = xPosition;
    
    dispatch_block_t action = [brick actionBlock];
    action();
    
    
    XCTAssertEqual(object.xPosition, (CGFloat)-20, @"SetxBrick is not correctly calculated");
}

-(void)testSetXBrickOutOfRange
{
    
    SpriteObject* object = [[SpriteObject alloc] init];
    object.position = CGPointMake(0, 0);
    
    Scene* scene = [[Scene alloc] init];
    [scene addChild:object];
    
    Formula* xPosition =[[Formula alloc] init];
    FormulaElement* formulaTree  = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"50000";
    xPosition.formulaTree = formulaTree;
    
    
    SetXBrick* brick = [[SetXBrick alloc]init];
    brick.object = object;
    brick.xPosition = xPosition;
    
    dispatch_block_t action = [brick actionBlock];
    action();
    
    
    XCTAssertEqual(object.xPosition, (CGFloat)50000, @"SetxBrick is not correctly calculated");
}

-(void)testSetXBrickWrongInput
{
    
    SpriteObject* object = [[SpriteObject alloc] init];
    object.position = CGPointMake(0, 0);
    
    Scene* scene = [[Scene alloc] init];
    [scene addChild:object];
    
    Formula* xPosition =[[Formula alloc] init];
    FormulaElement* formulaTree  = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"a";
    xPosition.formulaTree = formulaTree;
    
    
    SetXBrick* brick = [[SetXBrick alloc]init];
    brick.object = object;
    brick.xPosition = xPosition;
    
    dispatch_block_t action = [brick actionBlock];
    action();
    
    
    XCTAssertEqual(object.xPosition, (CGFloat)0, @"SetxBrick is not correctly calculated");
}

-(void)testSetYBrickPositiv
{
  
  SpriteObject* object = [[SpriteObject alloc] init];
  object.position = CGPointMake(0, 0);
  
  Scene* scene = [[Scene alloc] init];
  [scene addChild:object];
  
  Formula* yPosition =[[Formula alloc] init];
  FormulaElement* formulaTree  = [[FormulaElement alloc] init];
  formulaTree.type = NUMBER;
  formulaTree.value = @"20";
  yPosition.formulaTree = formulaTree;
  
  
  SetYBrick* brick = [[SetYBrick alloc]init];
  brick.object = object;
  brick.yPosition = yPosition;
  
  dispatch_block_t action = [brick actionBlock];
  action();
  
  
  XCTAssertEqual(object.yPosition, (CGFloat)20, @"SetyBrick is not correctly calculated");
}

-(void)testSetYBrickNegativ
{
    
    SpriteObject* object = [[SpriteObject alloc] init];
    object.position = CGPointMake(0, 0);
    
    Scene* scene = [[Scene alloc] init];
    [scene addChild:object];
    
    Formula* yPosition =[[Formula alloc] init];
    FormulaElement* formulaTree  = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"-20";
    yPosition.formulaTree = formulaTree;
    
    
    SetYBrick* brick = [[SetYBrick alloc]init];
    brick.object = object;
    brick.yPosition = yPosition;
    
    dispatch_block_t action = [brick actionBlock];
    action();
    
    
    XCTAssertEqual(object.yPosition, (CGFloat)-20, @"SetyBrick is not correctly calculated");
}

-(void)testSetYBrickOutOfRange
{
    
    SpriteObject* object = [[SpriteObject alloc] init];
    object.position = CGPointMake(0, 0);
    
    Scene* scene = [[Scene alloc] init];
    [scene addChild:object];
    
    Formula* yPosition =[[Formula alloc] init];
    FormulaElement* formulaTree  = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"50000";
    yPosition.formulaTree = formulaTree;
    
    
    SetYBrick* brick = [[SetYBrick alloc]init];
    brick.object = object;
    brick.yPosition = yPosition;
    
    dispatch_block_t action = [brick actionBlock];
    action();
    
    
    XCTAssertEqual(object.yPosition, (CGFloat)50000, @"SetyBrick is not correctly calculated");
}

-(void)testSetYBrickWrongInput
{
    
    SpriteObject* object = [[SpriteObject alloc] init];
    object.position = CGPointMake(0, 0);
    
    Scene* scene = [[Scene alloc] init];
    [scene addChild:object];
    
    Formula* yPosition =[[Formula alloc] init];
    FormulaElement* formulaTree  = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"a";
    yPosition.formulaTree = formulaTree;
    
    
    SetYBrick* brick = [[SetYBrick alloc]init];
    brick.object = object;
    brick.yPosition = yPosition;
    
    dispatch_block_t action = [brick actionBlock];
    action();
    
    
    XCTAssertEqual(object.yPosition, (CGFloat)0, @"SetyBrick is not correctly calculated");
}



-(void)testShowBrick
{
  
  SpriteObject* object = [[SpriteObject alloc] init];
  object.position = CGPointMake(0, 0);
  
  Scene* scene = [[Scene alloc] init];
  [scene addChild:object];
  
  ShowBrick* brick = [[ShowBrick alloc]init];
  brick.object = object;
  
  dispatch_block_t action = [brick actionBlock];
  action();
  
  
  XCTAssertEqual(object.hidden, NO, @"ShowBrick is not correctly calculated");
}

-(void)testHideBrick
{
    
    SpriteObject* object = [[SpriteObject alloc] init];
    object.position = CGPointMake(0, 0);
    
    Scene* scene = [[Scene alloc] init];
    [scene addChild:object];
    
    HideBrick* brick = [[HideBrick alloc]init];
    brick.object = object;
    
    dispatch_block_t action = [brick actionBlock];
    action();
    
    
    XCTAssertEqual(object.hidden, YES, @"HideBrick is not correctly calculated");
}

-(void)testSetVariableBrick
{
//  Program* program = [[Program alloc] init];
//  
//  SpriteObject* object = [[SpriteObject alloc] init];
//  object.position = CGPointMake(0, 0);
//  
//  object.program = program;
//
//  [program.objectList addObject:object];
//  Scene* scene = [[Scene alloc] init];
//  [scene addChild:object];
//  
//  Formula* formula =[[Formula alloc] init];
//  FormulaElement* formulaTree  = [[FormulaElement alloc] init];
//  formulaTree.type = NUMBER;
//  formulaTree.value = @"20";
//  formula.formulaTree = formulaTree;
//  
//  UserVariable *variable = [[UserVariable alloc] init];
//  variable.name = @"Test";
//  variable.value = @20;
//  
//  
//  SetVariableBrick* brick = [[SetVariableBrick alloc]init];
//  brick.object = object;
//  brick.userVariable = variable;
//  brick.variableFormula = formula;
//
//  
//  dispatch_block_t action = [brick actionBlock];
//  action();
//  
//  
//  
//  XCTAssertEqual([program.variables getUserVariableNamed:@"Test" forSpriteObject:object].value , @20, @"SetVariableBrick is not correctly calculated");
}

-(void)testSetGhostEffectBrickPositv
{
  SpriteObject* object = [[SpriteObject alloc] init];
  object.position = CGPointMake(0, 0);
  
  Scene* scene = [[Scene alloc] init];
  [scene addChild:object];
  
  Formula* transparency =[[Formula alloc] init];
  FormulaElement* formulaTree  = [[FormulaElement alloc] init];
  formulaTree.type = NUMBER;
  formulaTree.value = @"20";
  transparency.formulaTree = formulaTree;
  
  SetGhostEffectBrick* brick = [[SetGhostEffectBrick alloc]init];
  brick.object = object;
  brick.transparency = transparency;
  
  dispatch_block_t action = [brick actionBlock];
  action();
  
  
  XCTAssertEqual(object.alpha, 0.8f, @"ShowBrick is not correctly calculated");
}

-(void)testSetGhostEffectBrickNegativ
{
    SpriteObject* object = [[SpriteObject alloc] init];
    object.position = CGPointMake(0, 0);
    
    Scene* scene = [[Scene alloc] init];
    [scene addChild:object];
    
    Formula* transparency =[[Formula alloc] init];
    FormulaElement* formulaTree  = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"-20";
    transparency.formulaTree = formulaTree;
    
    SetGhostEffectBrick* brick = [[SetGhostEffectBrick alloc]init];
    brick.object = object;
    brick.transparency = transparency;
    
    dispatch_block_t action = [brick actionBlock];
    action();
    
    
    XCTAssertEqual(object.alpha, 1.0f, @"ShowBrick is not correctly calculated");
}

-(void)testSetGhostEffectBrickWronginput
{
    SpriteObject* object = [[SpriteObject alloc] init];
    object.position = CGPointMake(0, 0);
    object.alpha = 1.0f;
    
    Scene* scene = [[Scene alloc] init];
    [scene addChild:object];
    
    Formula* transparency =[[Formula alloc] init];
    FormulaElement* formulaTree  = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"a";
    transparency.formulaTree = formulaTree;
    
    SetGhostEffectBrick* brick = [[SetGhostEffectBrick alloc]init];
    brick.object = object;
    brick.transparency = transparency;
    
    dispatch_block_t action = [brick actionBlock];
    action();
    
    
    XCTAssertEqual(object.alpha, 1.0f, @"ShowBrick is not correctly calculated");
}

-(void)testChangeGhostEffectByNBrickPositiv
{
  
  SpriteObject* object = [[SpriteObject alloc] init];
  object.position = CGPointMake(0, 0);
  
  Scene* scene = [[Scene alloc] init];
  [scene addChild:object];
  
  Formula* transparency =[[Formula alloc] init];
  FormulaElement* formulaTree  = [[FormulaElement alloc] init];
  formulaTree.type = NUMBER;
  formulaTree.value = @"20";
  transparency.formulaTree = formulaTree;
  
  ChangeGhostEffectByNBrick* brick = [[ChangeGhostEffectByNBrick alloc]init];
  brick.object = object;
  brick.changeGhostEffect = transparency;
  
  dispatch_block_t action = [brick actionBlock];
  action();
  
  
  XCTAssertEqual(object.alpha, 0.8f, @"ChangeGhostEffectBrick is not correctly calculated");
}


-(void)testChangeGhostEffectByNBrickNegativ
{
    
    SpriteObject* object = [[SpriteObject alloc] init];
    object.position = CGPointMake(0, 0);
    object.alpha = 0.4;
    
    Scene* scene = [[Scene alloc] init];
    [scene addChild:object];
    
    Formula* transparency =[[Formula alloc] init];
    FormulaElement* formulaTree  = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"-20";
    transparency.formulaTree = formulaTree;
    
    ChangeGhostEffectByNBrick* brick = [[ChangeGhostEffectByNBrick alloc]init];
    brick.object = object;
    brick.changeGhostEffect = transparency;
    
    dispatch_block_t action = [brick actionBlock];
    action();
    
    
    XCTAssertEqual(object.alpha, 0.6f, @"ChangeGhostEffectBrick is not correctly calculated");
}


-(void)testChangeGhostEffectByNBrickOutOfRange
{
 
    SpriteObject* object = [[SpriteObject alloc] init];
    object.position = CGPointMake(0, 0);
    object.alpha = 0.4;
    
    Scene* scene = [[Scene alloc] init];
    [scene addChild:object];
    
    Formula* transparency =[[Formula alloc] init];
    FormulaElement* formulaTree  = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"150";
    transparency.formulaTree = formulaTree;
    
    ChangeGhostEffectByNBrick* brick = [[ChangeGhostEffectByNBrick alloc]init];
    brick.object = object;
    brick.changeGhostEffect = transparency;
    
    dispatch_block_t action = [brick actionBlock];
    action();
    
    
    XCTAssertEqual(object.alpha, 0.0f, @"ChangeGhostEffectBrick is not correctly calculated");
}

-(void)testChangeGhostEffectByNBrickWrongInput
{
 
    SpriteObject* object = [[SpriteObject alloc] init];
    object.position = CGPointMake(0, 0);
    
    Scene* scene = [[Scene alloc] init];
    [scene addChild:object];
    
    Formula* transparency =[[Formula alloc] init];
    FormulaElement* formulaTree  = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"a";
    transparency.formulaTree = formulaTree;
    
    ChangeGhostEffectByNBrick* brick = [[ChangeGhostEffectByNBrick alloc]init];
    brick.object = object;
    brick.changeGhostEffect = transparency;
    
    dispatch_block_t action = [brick actionBlock];
    action();
    
    
    XCTAssertEqual(object.alpha, 1.0f, @"ChangeGhostEffectBrick is not correctly calculated");
}

-(void)testPointInDirectionBrick
{
  SpriteObject* object = [[SpriteObject alloc] init];
  object.position = CGPointMake(0, 0);
  
  Scene* scene = [[Scene alloc] init];
  [scene addChild:object];
  
  Formula* degrees =[[Formula alloc] init];
  FormulaElement* formulaTree  = [[FormulaElement alloc] init];
  formulaTree.type = NUMBER;
  formulaTree.value = @"20";
  degrees.formulaTree = formulaTree;
  
  PointInDirectionBrick* brick = [[PointInDirectionBrick alloc]init];
  brick.object = object;
  brick.degrees = degrees;
  
  dispatch_block_t action = [brick actionBlock];
  action();

  
  XCTAssertEqual(object.zRotation, (float)((360-(-70))*M_PI/180), @"PointInDirectionBrick is not correctly calculated");
}


-(void)testPlaceAtBrickPositiv
{
  
  SpriteObject* object = [[SpriteObject alloc] init];
  object.position = CGPointMake(0, 0);
  
  Scene* scene = [[Scene alloc] init];
  [scene addChild:object];
  
  Formula* yPosition =[[Formula alloc] init];
  FormulaElement* formulaTree  = [[FormulaElement alloc] init];
  formulaTree.type = NUMBER;
  formulaTree.value = @"20";
  yPosition.formulaTree = formulaTree;
  
  Formula* xPosition =[[Formula alloc] init];
  FormulaElement* formulaTree1  = [[FormulaElement alloc] init];
  formulaTree1.type = NUMBER;
  formulaTree1.value = @"20";
  xPosition.formulaTree = formulaTree1;
  
  
  PlaceAtBrick* brick = [[PlaceAtBrick alloc]init];
  brick.object = object;
  brick.yPosition = yPosition;
  brick.xPosition = xPosition;
  
  dispatch_block_t action = [brick actionBlock];
  action();
  
  CGPoint testPoint = CGPointMake(20, 20);
  XCTAssertEqual(object.position, testPoint, @"PlaceAtBrick is not correctly calculated");
}

-(void)testPlaceAtBrickNegativ
{
    
    SpriteObject* object = [[SpriteObject alloc] init];
    object.position = CGPointMake(0, 0);
    
    Scene* scene = [[Scene alloc] init];
    [scene addChild:object];
    
    Formula* yPosition =[[Formula alloc] init];
    FormulaElement* formulaTree  = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"-20";
    yPosition.formulaTree = formulaTree;
    
    Formula* xPosition =[[Formula alloc] init];
    FormulaElement* formulaTree1  = [[FormulaElement alloc] init];
    formulaTree1.type = NUMBER;
    formulaTree1.value = @"-20";
    xPosition.formulaTree = formulaTree1;
    
    
    PlaceAtBrick* brick = [[PlaceAtBrick alloc]init];
    brick.object = object;
    brick.yPosition = yPosition;
    brick.xPosition = xPosition;
    
    dispatch_block_t action = [brick actionBlock];
    action();
    
    CGPoint testPoint = CGPointMake(-20, -20);
    XCTAssertEqual(object.position, testPoint, @"PlaceAtBrick is not correctly calculated");
}

-(void)testPlaceAtBrickOutOfRange
{
    
    SpriteObject* object = [[SpriteObject alloc] init];
    object.position = CGPointMake(0, 0);
    
    Scene* scene = [[Scene alloc] init];
    [scene addChild:object];
    
    Formula* yPosition =[[Formula alloc] init];
    FormulaElement* formulaTree  = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"-20000";
    yPosition.formulaTree = formulaTree;
    
    Formula* xPosition =[[Formula alloc] init];
    FormulaElement* formulaTree1  = [[FormulaElement alloc] init];
    formulaTree1.type = NUMBER;
    formulaTree1.value = @"-20000";
    xPosition.formulaTree = formulaTree1;
    
    
    PlaceAtBrick* brick = [[PlaceAtBrick alloc]init];
    brick.object = object;
    brick.yPosition = yPosition;
    brick.xPosition = xPosition;
    
    dispatch_block_t action = [brick actionBlock];
    action();
    
    CGPoint testPoint = CGPointMake(-20000, -20000);
    XCTAssertEqual(object.position, testPoint, @"PlaceAtBrick is not correctly calculated");
}

-(void)testPlaceAtBrickWrongInput
{
    
    SpriteObject* object = [[SpriteObject alloc] init];
    object.position = CGPointMake(0, 0);
    
    Scene* scene = [[Scene alloc] init];
    [scene addChild:object];
    
    Formula* yPosition =[[Formula alloc] init];
    FormulaElement* formulaTree  = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"a";
    yPosition.formulaTree = formulaTree;
    
    Formula* xPosition =[[Formula alloc] init];
    FormulaElement* formulaTree1  = [[FormulaElement alloc] init];
    formulaTree1.type = NUMBER;
    formulaTree1.value = @"a";
    xPosition.formulaTree = formulaTree1;
    
    
    PlaceAtBrick* brick = [[PlaceAtBrick alloc]init];
    brick.object = object;
    brick.yPosition = yPosition;
    brick.xPosition = xPosition;
    
    dispatch_block_t action = [brick actionBlock];
    action();
    
    CGPoint testPoint = CGPointMake(0, 0);
    XCTAssertEqual(object.position, testPoint, @"PlaceAtBrick is not correctly calculated");
}

-(void)testChangeSizeByNBrickPositiv
{
    
    SpriteObject* object = [[SpriteObject alloc] init];
    object.xScale = 10;
    object.yScale = 10;
    
    ChangeSizeByNBrick* brick = [[ChangeSizeByNBrick alloc] init];
    brick.object = object;
    
    Formula* size = [[Formula alloc] init];
    FormulaElement* formulaTree = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"30";
    size.formulaTree = formulaTree;
    brick.size = size;
    
    dispatch_block_t action = [brick actionBlock];
    
    action();
    
    XCTAssertEqual([object scaleX], 1030.0f, @"X - Scale not correct");
    XCTAssertEqual([object scaleY], 1030.0f, @"Y - Scale not correct");

    
}


-(void)testChangeSizeByNBrickNegativ
{
    
    SpriteObject* object = [[SpriteObject alloc] init];
    object.xScale = 10;
    object.yScale = 10;
    
    ChangeSizeByNBrick* brick = [[ChangeSizeByNBrick alloc] init];
    brick.object = object;
    
    Formula* size = [[Formula alloc] init];
    FormulaElement* formulaTree = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"-30";
    size.formulaTree = formulaTree;
    brick.size = size;
    
    dispatch_block_t action = [brick actionBlock];
    
    action();
    
    XCTAssertEqual([object scaleX], 970.0f, @"X - Scale not correct");
    XCTAssertEqual([object scaleY], 970.0f, @"Y - Scale not correct");
    
    
}
-(void)testChangeSizeByNBrickWrongInput
{
    
    SpriteObject* object = [[SpriteObject alloc] init];
    object.xScale = 10;
    object.yScale = 10;
    
    ChangeSizeByNBrick* brick = [[ChangeSizeByNBrick alloc] init];
    brick.object = object;
    
    Formula* size = [[Formula alloc] init];
    FormulaElement* formulaTree = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"a";
    size.formulaTree = formulaTree;
    brick.size = size;
    
    dispatch_block_t action = [brick actionBlock];
    
    action();
    
    XCTAssertEqual([object scaleX], 1000.0f, @"X - Scale not correct");
    XCTAssertEqual([object scaleY], 1000.0f, @"Y - Scale not correct");
    
    
}
-(void)testTurnLeftBrick
{
    SpriteObject* object = [[SpriteObject alloc] init];
    object.zRotation = 0;
    
    TurnLeftBrick* brick = [[TurnLeftBrick alloc] init];
    brick.object = object;
    
    Formula* degrees = [[Formula alloc] init];
    FormulaElement* formulaTree = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"60";
    degrees.formulaTree = formulaTree;
    brick.degrees = degrees;
    
    dispatch_block_t action = [brick actionBlock];
    
    action();
    
    XCTAssertEqual([object rotation], (float)60, @"TurnLeftBrick not correct");
}

-(void)testTurnLeftBrickOver360
{
    SpriteObject* object = [[SpriteObject alloc] init];
    object.zRotation = 0;
    
    TurnLeftBrick* brick = [[TurnLeftBrick alloc] init];
    brick.object = object;
    
    Formula* degrees = [[Formula alloc] init];
    FormulaElement* formulaTree = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"400";
    degrees.formulaTree = formulaTree;
    brick.degrees = degrees;
    
    dispatch_block_t action = [brick actionBlock];
    
    action();
    
    XCTAssertEqual([object rotation], (float)40, @"TurnLeftBrick not correct");
}

-(void)testTurnLeftBrickNegativ
{
    SpriteObject* object = [[SpriteObject alloc] init];
    object.zRotation = 0;
    
    TurnLeftBrick* brick = [[TurnLeftBrick alloc] init];
    brick.object = object;
    
    Formula* degrees = [[Formula alloc] init];
    FormulaElement* formulaTree = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"-60";
    degrees.formulaTree = formulaTree;
    brick.degrees = degrees;
    
    dispatch_block_t action = [brick actionBlock];
    
    action();
    
    XCTAssertEqual([object rotation], (float)-60, @"TurnLeftBrick not correct");
}

-(void)testTurnLeftBrickNegativOver360
{
    SpriteObject* object = [[SpriteObject alloc] init];
    object.zRotation = 0;
    
    TurnLeftBrick* brick = [[TurnLeftBrick alloc] init];
    brick.object = object;
    
    Formula* degrees = [[Formula alloc] init];
    FormulaElement* formulaTree = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"-400";
    degrees.formulaTree = formulaTree;
    brick.degrees = degrees;
    
    dispatch_block_t action = [brick actionBlock];
    
    action();
    
    XCTAssertEqual([object rotation], (float)-40, @"TurnLeftBrick not correct");
}


-(void)testTurnrightBrick
{
    SpriteObject* object = [[SpriteObject alloc] init];
    object.zRotation = 0;
    
    TurnRightBrick* brick = [[TurnRightBrick alloc] init];
    brick.object = object;
    
    Formula* degrees = [[Formula alloc] init];
    FormulaElement* formulaTree = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"20";
    degrees.formulaTree = formulaTree;
    brick.degrees = degrees;
    
    dispatch_block_t action = [brick actionBlock];
    
    action();
    NSLog(@"Rotation: %f",[object rotation]);
    
    XCTAssertEqual([object rotation], (float)-20, @"TurnRightBrick not correct");
}

-(void)testTurnrightBrickOver360
{
    SpriteObject* object = [[SpriteObject alloc] init];
    object.zRotation = 0;
    
    TurnRightBrick* brick = [[TurnRightBrick alloc] init];
    brick.object = object;
    
    Formula* degrees = [[Formula alloc] init];
    FormulaElement* formulaTree = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"400";
    degrees.formulaTree = formulaTree;
    brick.degrees = degrees;
    
    dispatch_block_t action = [brick actionBlock];
    
    action();
    NSLog(@"Rotation: %f",[object rotation]);
    
    XCTAssertEqual([object rotation], (float)-40, @"TurnRightBrick not correct");
}


-(void)testTurnrightBrickNegativ
{
    SpriteObject* object = [[SpriteObject alloc] init];
    object.zRotation = 0;
    
    TurnRightBrick* brick = [[TurnRightBrick alloc] init];
    brick.object = object;
    
    Formula* degrees = [[Formula alloc] init];
    FormulaElement* formulaTree = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"-20";
    degrees.formulaTree = formulaTree;
    brick.degrees = degrees;
    
    dispatch_block_t action = [brick actionBlock];
    
    action();
    NSLog(@"Rotation: %f",[object rotation]);
    
    XCTAssertEqual([object rotation], (float)20, @"TurnRightBrick not correct");
}

-(void)testTurnrightBrickNegativOver360
{
    SpriteObject* object = [[SpriteObject alloc] init];
    object.zRotation = 0;
    
    TurnRightBrick* brick = [[TurnRightBrick alloc] init];
    brick.object = object;
    
    Formula* degrees = [[Formula alloc] init];
    FormulaElement* formulaTree = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"-400";
    degrees.formulaTree = formulaTree;
    brick.degrees = degrees;
    
    dispatch_block_t action = [brick actionBlock];
    
    action();
    NSLog(@"Rotation: %f",[object rotation]);
    
    XCTAssertEqual([object rotation], (float)40, @"TurnRightBrick not correct");
}

-(void)testTurnrightBrickWrongInput
{
    SpriteObject* object = [[SpriteObject alloc] init];
    object.zRotation = 0;
    
    TurnRightBrick* brick = [[TurnRightBrick alloc] init];
    brick.object = object;
    
    Formula* degrees = [[Formula alloc] init];
    FormulaElement* formulaTree = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"a";
    degrees.formulaTree = formulaTree;
    brick.degrees = degrees;
    
    dispatch_block_t action = [brick actionBlock];
    
    action();
    NSLog(@"Rotation: %f",[object rotation]);
    
    XCTAssertEqual([object rotation], (float)0, @"TurnRightBrick not correct");
}

-(void)testGoNStepsBackBrickSingle
{
    Program* program = [[Program alloc] init];
    
    SpriteObject* object1 = [[SpriteObject alloc] init];
    object1.program = program;
    object1.zPosition = 5;
    object1.numberOfObjectsWithoutBackground = 2;
    
    SpriteObject* object2 = [[SpriteObject alloc] init];
    object2.zPosition = 3;
    
    [program.objectList addObject:object1];
    [program.objectList addObject:object2];
    
    
    GoNStepsBackBrick* brick = [[GoNStepsBackBrick alloc] init];
    brick.object = object1;
    
    Formula* steps = [[Formula alloc] init];
    FormulaElement* formulaTree = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"1";
    steps.formulaTree = formulaTree;
    brick.steps = steps;
    
    dispatch_block_t action = [brick actionBlock];
    action();
    
    XCTAssertEqual(object1.zPosition, (CGFloat)4.0, @"GoNStepsBack is not correctly calculated");
    XCTAssertEqual(object2.zPosition, (CGFloat)3.0, @"GoNStepsBack is not correctly calculated");
    
}

-(void)testGoNStepsBackBrickComeToSameLayer
{
    Program* program = [[Program alloc] init];
    
    SpriteObject* object1 = [[SpriteObject alloc] init];
    object1.program = program;
    object1.zPosition = 5;
    object1.numberOfObjectsWithoutBackground = 2;
    
    SpriteObject* object2 = [[SpriteObject alloc] init];
    object2.zPosition = 3;
    
    [program.objectList addObject:object1];
    [program.objectList addObject:object2];
    
    
    GoNStepsBackBrick* brick = [[GoNStepsBackBrick alloc] init];
    brick.object = object1;
    
    Formula* steps = [[Formula alloc] init];
    FormulaElement* formulaTree = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"2";
    steps.formulaTree = formulaTree;
    brick.steps = steps;
    
    dispatch_block_t action = [brick actionBlock];
    action();
    
    XCTAssertEqual(object1.zPosition, (CGFloat)3.0, @"GoNStepsBack is not correctly calculated");
    XCTAssertEqual(object2.zPosition, (CGFloat)4.0, @"GoNStepsBack is not correctly calculated");
    
}

-(void)testGoNStepsBackBrickOutOfRange
{
    Program* program = [[Program alloc] init];
    
    SpriteObject* object1 = [[SpriteObject alloc] init];
    object1.program = program;
    object1.zPosition = 5;
    object1.numberOfObjectsWithoutBackground = 2;
    
    SpriteObject* object2 = [[SpriteObject alloc] init];
    object2.zPosition = 3;
    
    [program.objectList addObject:object1];
    [program.objectList addObject:object2];
    
    
    GoNStepsBackBrick* brick = [[GoNStepsBackBrick alloc] init];
    brick.object = object1;
    
    Formula* steps = [[Formula alloc] init];
    FormulaElement* formulaTree = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"10";
    steps.formulaTree = formulaTree;
    brick.steps = steps;
    
    dispatch_block_t action = [brick actionBlock];
    action();
    
    XCTAssertEqual(object1.zPosition, (CGFloat)1.0, @"GoNStepsBack is not correctly calculated");
    XCTAssertEqual(object2.zPosition, (CGFloat)4.0, @"GoNStepsBack is not correctly calculated");
    
}

-(void)testGoNStepsBackBrickWronginput
{
    Program* program = [[Program alloc] init];
    
    SpriteObject* object1 = [[SpriteObject alloc] init];
    object1.program = program;
    object1.zPosition = 5;
    object1.numberOfObjectsWithoutBackground = 2;
    
    SpriteObject* object2 = [[SpriteObject alloc] init];
    object2.zPosition = 3;
    
    [program.objectList addObject:object1];
    [program.objectList addObject:object2];
    
    
    GoNStepsBackBrick* brick = [[GoNStepsBackBrick alloc] init];
    brick.object = object1;
    
    Formula* steps = [[Formula alloc] init];
    FormulaElement* formulaTree = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"a";
    steps.formulaTree = formulaTree;
    brick.steps = steps;
    
    dispatch_block_t action = [brick actionBlock];
    action();
    
    XCTAssertEqual(object1.zPosition, (CGFloat)5.0, @"GoNStepsBack is not correctly calculated");
    XCTAssertEqual(object2.zPosition, (CGFloat)3.0, @"GoNStepsBack is not correctly calculated");
    
}

-(void)testSetBrightnessBrickDarker
{
#warning Problem with texture -> don't have a image to test
//    SpriteObject* object = [[SpriteObject alloc] init];
//    
//    SetBrightnessBrick* brick = [[SetBrightnessBrick alloc] init];
//    brick.object = object;
//    object.texture = [SKTexture textureWithImageNamed:@"icon.png"];
//
//    
//    Formula* brightness = [[Formula alloc] init];
//    FormulaElement* formulaTree = [[FormulaElement alloc] init];
//    formulaTree.type = NUMBER;
//    formulaTree.value = @"30";
//    brightness.formulaTree = formulaTree;
//    brick.brightness = brightness;
//    
//    dispatch_block_t action = [brick actionBlock];
//    
//    action();
//    
//    XCTAssertEqual([object currentLookBrightness], -0.7f, @"SetBrightnessBrick - Brightness not correct");
}

-(void)testSetBrightnessBrickBrighter
{

//    SpriteObject* object = [[SpriteObject alloc] init];
//
//
//    SetBrightnessBrick* brick = [[SetBrightnessBrick alloc] init];
//    brick.object = object;
//
//    Formula* brightness = [[Formula alloc] init];
//    FormulaElement* formulaTree = [[FormulaElement alloc] init];
//    formulaTree.type = NUMBER;
//    formulaTree.value = @"130";
//    brightness.formulaTree = formulaTree;
//    brick.brightness = brightness;
//
//    dispatch_block_t action = [brick actionBlock];
//
//    action();
//
//    XCTAssertEqual([object currentLookBrightness], 1.3f, @"SetBrightnessBrick - Brightness not correct");
}
-(void)testSetBrightnessBrickTooBright
{

//        SpriteObject* object = [[SpriteObject alloc] init];
//
//        SetBrightnessBrick* brick = [[SetBrightnessBrick alloc] init];
//        brick.object = object;
//
//        Formula* brightness = [[Formula alloc] init];
//        FormulaElement* formulaTree = [[FormulaElement alloc] init];
//        formulaTree.type = NUMBER;
//        formulaTree.value = @"-80";
//        brightness.formulaTree = formulaTree;
//        brick.brightness = brightness;
//
//    dispatch_block_t action = [brick actionBlock];
//
//    action();
//    XCTAssertEqual([object currentLookBrightness], -1.0f, @"SetBrightnessBrick - Brightness not correct");
}
-(void)testSetBrightnessBrickTooDark
{

//    SpriteObject* object = [[SpriteObject alloc] init];
//
//
//    SetBrightnessBrick* brick = [[SetBrightnessBrick alloc] init];
//    brick.object = object;
//
//    Formula* brightness = [[Formula alloc] init];
//    FormulaElement* formulaTree = [[FormulaElement alloc] init];
//    formulaTree.type = NUMBER;
//    formulaTree.value = @"300";
//    brightness.formulaTree = formulaTree;
//    brick.brightness = brightness;
//
//    dispatch_block_t action = [brick actionBlock];
//
//    action();
//
//    XCTAssertEqual([object currentLookBrightness], 1.0f, @"SetBrightnessBrick - Brightness not correct");
}
-(void)testSetBrightnessBrickWrongInput
{

//    SpriteObject* object = [[SpriteObject alloc] init];
//
//
//    SetBrightnessBrick* brick = [[SetBrightnessBrick alloc] init];
//    brick.object = object;
//
//    Formula* brightness = [[Formula alloc] init];
//    FormulaElement* formulaTree = [[FormulaElement alloc] init];
//    formulaTree.type = NUMBER;
//    formulaTree.value = @"a";
//    brightness.formulaTree = formulaTree;
//    brick.brightness = brightness;
//
//    dispatch_block_t action = [brick actionBlock];
//
//    action();
//
//    XCTAssertEqual([object currentLookBrightness], 0.0f, @"SetBrightnessBrick - Brightness not correct");
}



-(void)testMoveNStepsBrick
{
//    Program* program = [[Program alloc] init];
//    
//    SpriteObject* object1 = [[SpriteObject alloc] init];
//    object1.program = program;
//    
//    [program.objectList addObject:object1];
//    //[object1 setPosition:CGPointMake(20, 20)];
//    
//    MoveNStepsBrick* brick = [[MoveNStepsBrick alloc] init];
//    brick.object = object1;
//    
//    Formula* steps = [[Formula alloc] init];
//    FormulaElement* formulaTree = [[FormulaElement alloc] init];
//    formulaTree.type = NUMBER;
//    formulaTree.value = @"10";
//    steps.formulaTree = formulaTree;
//    brick.steps = steps;
//    
//    dispatch_block_t action = [brick actionBlock];
//    action();
//    
//    CGPoint checkPoint = CGPointMake(30, 20);
//    
//    XCTAssertEqual(object1.position.x, checkPoint.x, @"MoveNSteps Brick is not correctly calculated");
//    XCTAssertEqual(object1.position.y, checkPoint.y, @"MoveNSteps Brick is not correctly calculated");
}

-(void)testClearGraphicEffectBrick
{
//    SpriteObject* object = [[SpriteObject alloc] init];
//    object.position = CGPointMake(0, 0);
//    object.currentLook = [[Look alloc] initWithPath:[NSString stringWithFormat:@"%@/screenshot.png",[Util applicationDocumentsDirectory]]];
//    Scene* scene = [[Scene alloc] init];
//    [scene addChild:object];
//    
//    Formula* transparency =[[Formula alloc] init];
//    FormulaElement* formulaTree  = [[FormulaElement alloc] init];
//    formulaTree.type = NUMBER;
//    formulaTree.value = @"20";
//    transparency.formulaTree = formulaTree;
//    
//    SetGhostEffectBrick* brick = [[SetGhostEffectBrick alloc]init];
//    brick.object = object;
//    brick.transparency = transparency;
//    
//    dispatch_block_t action = [brick actionBlock];
//    action();
//    
//    ClearGraphicEffectBrick* clearBrick = [[ClearGraphicEffectBrick alloc]init];
//    clearBrick.object = object;
//    
//    action = [clearBrick actionBlock];
//    action();
//    
//    
//    XCTAssertEqual(object.alpha, 1.0f, @"ClearGraphic is not correctly calculated");
}

@end
