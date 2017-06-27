/**
 *  Copyright (C) 2010-2017 The Catrobat Team
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
#import "BrickTests.h"
#import "WhenScript.h"
#import "Pocket_Code-Swift.h"

@interface UserListFunctionsTest : XCTestCase

@end

@implementation UserListFunctionsTest

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
    FormulaElement *formulaTree = [[FormulaElement alloc] initWithType:@"FUNCTION" value:@"NUMBEROFITEMS" leftChild:leftChild rightChild:nil parent:nil];
    formulaTree = formulaTree;
    
    double numberOfItems = [[formulaTree interpretRecursiveForSprite:object] doubleValue];
    
    XCTAssertEqual(numberOfItems, 3, @"Wrong number of Items");
}

@end
