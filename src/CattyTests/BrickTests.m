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
#import "ComeToFrontBrick.h"
#import "SetXBrick.h"
#import "Brick.h"
#import "Script.h"
#import "Formula.h"
#import "FormulaElement.h"
#import "ProgramLoadingInfo.h"
#import "Program.h"
#import "Parser.h"
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
#import "BroadcastWaitHandler.h"
#import <SpriteKit/SpriteKit.h>
#import "SetSizeToBrick.h"

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

@end
