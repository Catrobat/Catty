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


@interface BrickTests : XCTestCase

@end

@implementation BrickTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testExample
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}



-(void)test_ComeToFrontBrick
{
    SpriteObject *sprite1 =[[SpriteObject alloc] init];
    SpriteObject *sprite2 =[[SpriteObject alloc] init];

    
    Program *program = [[Program alloc]init];
    [program.objectList addObject:sprite2];
    [program.objectList addObject:sprite1];
    Script *script = [[Script alloc]init];

    sprite2.zPosition=1;
    sprite1.zPosition=2;
    sprite2.program=program;
    sprite1.program=program;
    ComeToFrontBrick *comeToFrontBrick = [[ComeToFrontBrick alloc]init];
    [script.brickList addObject:comeToFrontBrick];
    sprite2.numberOfObjects = 2;
    sprite1.numberOfObjects = 2;
    
 
    script.object = sprite2;

    CGFloat test = 2;
//IMPLEMENTATION COMETOFRONT-BRICK//////////////////////////////////
    CGFloat zValue = script.object.zPosition;
    NSInteger maxValue = script.object.numberOfObjects;
    
    for(SpriteObject *obj in script.object.program.objectList){
        
        if (obj.zPosition > zValue && obj.zPosition > 1) {
            obj.zPosition = obj.zPosition - 1;
        }

        
    }
    
    script.object.zPosition = maxValue;
///////////////////////////////////////

    XCTAssertEqual(test, sprite2.zPosition, @"ComeToFront is not correctly calculated");
    
    
}

-(void)test_SetXBrick
{
//    CGPoint checkPoint = CGPointMake(200, 0);
//    SpriteObject *sprite1 =[[SpriteObject alloc] init];
//    Script *script = [[Script alloc]init];
//    SetXBrick *setXBrick =[[SetXBrick alloc]init];
//    Formula * formula = [[Formula alloc] init];
//    FormulaElement * fElement = [[FormulaElement alloc]initWithType:@"NUMBER" value:@"200" leftChild:nil rightChild:nil parent:nil];
//    
//    formula.formulaTree = fElement;
//    setXBrick.xPosition = formula;
//    
//    script.object = sprite1;
//    
//    
//    
////IMPLEMENTATION SETXBRICK//////////////////////////////////////
//    double xPosition = [setXBrick.xPosition interpretDoubleForSprite:script.object];
//    
//    script.object.position = CGPointMake(xPosition, 0);
//    
//    
////////////////////////////////////////////////
//    
//        XCTAssertEqual(checkPoint, script.object.position ,@"SetXBrick is not correctly calculated");
}




@end
