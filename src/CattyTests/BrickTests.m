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
#import "BroadcastWaitHandler.h"
#import <SpriteKit/SpriteKit.h>
#import "UserVariable.h"
#import "VariablesContainer.h"
#import "Util.h"

//BrickImports
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

-(void)testSetSizeToBrick
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


-(void)testComeToFrontBrick
{
    
    Program* program = [[Program alloc] init];
    
    SpriteObject* object1 = [[SpriteObject alloc] init];
    object1.program = program;
    object1.zPosition = 1;
    
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

-(void)testSetXBrick
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

-(void)testSetYBrick
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
////  formulaTree.type = NUMBER;
////  formulaTree.value = @"20";
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

-(void)testSetGhostEffectBrick
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

-(void)testChangeGhostEffectByNBrick
{
  // TODO: Check Brick if there really a - ???
  
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


-(void)testPlaceAtBrick
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

@end
