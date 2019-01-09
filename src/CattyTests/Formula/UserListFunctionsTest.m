/**
 *  Copyright (C) 2010-2019 The Catrobat Team
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
#import "AbstractBrickTests.h"
#import "WhenScript.h"
#import "Pocket_Code-Swift.h"

@interface UserListFunctionsTest : XCTestCase
@property (nonatomic, strong) FormulaManager *formulaManager;
@property (nonatomic, strong) SpriteObject *spriteObject;
@end

@implementation UserListFunctionsTest

- (void)setUp
{
    self.formulaManager = [[FormulaManager alloc] initWithSceneSize:[Util screenSize:true]];
}

- (void)testNumberOfItems
{
    Program *program = [Program new];
    
    SpriteObject *object = [[SpriteObject alloc] init];
    object.program = program;
    
    UserVariable* var = [UserVariable new];
    var.name = @"TestList";
    var.isList = YES;
    var.value = [[NSMutableArray alloc] init];
    [var.value addObject:[NSNumber numberWithInt:0]];
    [var.value addObject:[NSNumber numberWithInt:0]];
    [var.value addObject:[NSNumber numberWithInt:0]];
    [program.variables.programListOfLists addObject:var];
    
    FormulaElement *leftChild = [[FormulaElement alloc] initWithType:@"USER_LIST" value:@"TestList" leftChild:nil rightChild:nil parent:nil];
    FormulaElement *formulaTree = [[FormulaElement alloc] initWithType:@"FUNCTION" value:@"NUMBER_OF_ITEMS" leftChild:leftChild rightChild:nil parent:nil];
    formulaTree = formulaTree;
    
    Formula *formula = [[Formula alloc] initWithFormulaElement:formulaTree];
    double numberOfItems = [self.formulaManager interpretDouble:formula forSpriteObject:object];
    
    XCTAssertEqual(numberOfItems, 3, @"Wrong number of Items");
}

- (void)testElement
{
    Program *program = [Program new];
    
    SpriteObject *object = [[SpriteObject alloc] init];
    object.program = program;
    
    UserVariable* var = [UserVariable new];
    var.name = @"TestList";
    var.isList = YES;
    var.value = [[NSMutableArray alloc] init];
    [var.value addObject:[NSNumber numberWithInt:1]];
    [var.value addObject:[NSNumber numberWithInt:4]];
    [var.value addObject:[NSNumber numberWithInt:8]];
    [program.variables.programListOfLists addObject:var];
    
    FormulaElement *leftChild = [[FormulaElement alloc] initWithType:@"NUMBER" value:@"2" leftChild:nil rightChild:nil parent:nil];
    FormulaElement *rightChild = [[FormulaElement alloc] initWithType:@"USER_LIST" value:@"TestList" leftChild:nil rightChild:nil parent:nil];
    FormulaElement *formulaTree = [[FormulaElement alloc] initWithType:@"FUNCTION" value:@"LIST_ITEM" leftChild:leftChild rightChild:rightChild parent:nil];
    Formula *formula = [[Formula alloc] initWithFormulaElement:formulaTree];
    
    double element = [self.formulaManager interpretDouble:formula forSpriteObject:object];
    XCTAssertEqual(element, 4, @"Should be Element of List but is not");
    
    leftChild = [[FormulaElement alloc] initWithType:@"NUMBER" value:@"-3" leftChild:nil rightChild:nil parent:nil];
    formulaTree = [[FormulaElement alloc] initWithType:@"FUNCTION" value:@"LIST_ITEM" leftChild:leftChild rightChild:rightChild parent:nil];
    formula = [[Formula alloc] initWithFormulaElement:formulaTree];
    
    element = [self.formulaManager interpretDouble:formula forSpriteObject:object];
    XCTAssertEqual(element, 0, @"Invalid default value");
    
    leftChild = [[FormulaElement alloc] initWithType:@"NUMBER" value:@"44" leftChild:nil rightChild:nil parent:nil];
    formulaTree = [[FormulaElement alloc] initWithType:@"FUNCTION" value:@"LIST_ITEM" leftChild:leftChild rightChild:rightChild parent:nil];
    formula = [[Formula alloc] initWithFormulaElement:formulaTree];
    
    element = [self.formulaManager interpretDouble:formula forSpriteObject:object];
    XCTAssertEqual(element, 0, @"Invalid default value");
}

- (void)testContains
{
    Program *program = [Program new];
    
    SpriteObject *object = [[SpriteObject alloc] init];
    object.program = program;
    
    UserVariable* var = [UserVariable new];
    var.name = @"TestList";
    var.isList = YES;
    var.value = [[NSMutableArray alloc] init];
    [var.value addObject:[NSNumber numberWithInt:0]];
    [var.value addObject:[NSNumber numberWithInt:4]];
    [var.value addObject:[NSNumber numberWithInt:8]];
    [program.variables.programListOfLists addObject:var];
    
    FormulaElement *rightChild = [[FormulaElement alloc] initWithType:@"NUMBER" value:@"4" leftChild:nil rightChild:nil parent:nil];
    FormulaElement *leftChild = [[FormulaElement alloc] initWithType:@"USER_LIST" value:@"TestList" leftChild:nil rightChild:nil parent:nil];
    FormulaElement *formulaTree = [[FormulaElement alloc] initWithType:@"FUNCTION" value:@"CONTAINS" leftChild:leftChild rightChild:rightChild parent:nil];
    formulaTree = formulaTree;
    
    Formula *formula = [[Formula alloc] initWithFormulaElement:formulaTree];
    BOOL contains = [self.formulaManager interpretDouble:formula forSpriteObject:object];
    
    XCTAssertEqual(contains, YES, @"Should be Element of List but is not");
}

@end
