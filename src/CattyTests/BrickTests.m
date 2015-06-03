/**
 *  Copyright (C) 2010-2015 The Catrobat Team
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

#import "BrickTests.h"


@implementation BrickTests

- (NSMutableArray*) programs
{
  if (! self.programs)
    self.programs = [NSMutableArray array];
  return self.programs;
}

- (void)setUp
{
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}


- (void)testSetVariableBrick
{
//  Program* program = [[Program alloc] init];
//  
//  SpriteObject* object = [[SpriteObject alloc] init];
//  CBSpriteNode *spriteNode = [[CBSpriteNode alloc] initWithSpriteObject:object];
//  object.spriteNode = spriteNode;
//  spriteNode.position = CGPointMake(0, 0);
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


@end
