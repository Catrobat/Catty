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

#import <XCTest/XCTest.h>
#import "PlaceAtBrick.h"
#import "WaitBrick.h"
#import "CBMutableCopyContext.h"

@interface BrickMutableCopyTests : XCTestCase

@end

@implementation BrickMutableCopyTests

- (void)testMutableCopy {
    PlaceAtBrick *brick = [PlaceAtBrick new];
    brick.xPosition = [[Formula alloc] initWithInteger:111];
    brick.yPosition = [[Formula alloc] initWithInteger:999];
    PlaceAtBrick *copiedBrick = [brick mutableCopyWithContext:[CBMutableCopyContext new] AndErrorReporting:YES];
    
    XCTAssertTrue([brick isEqualToBrick:copiedBrick], @"Bricks are not equal");
    XCTAssertFalse([brick.xPosition isEqualToFormula:brick.yPosition], @"Formulas for xPosition and xPosition are equal");
    XCTAssertTrue([brick.xPosition isEqualToFormula:copiedBrick.xPosition], @"Formulas for xPosition are not equal");
    XCTAssertTrue([brick.yPosition isEqualToFormula:copiedBrick.yPosition], @"Formulas for xPosition are not equal");
}

- (void)testMutableCopyForBool {
    WaitBrick *brick = [WaitBrick new];
    brick.timeToWaitInSeconds = [[Formula alloc] initWithInteger:1];
    brick.animate = YES;
    brick.animateInsertBrick = NO;
    WaitBrick *copiedBrick = [brick mutableCopyWithContext:[CBMutableCopyContext new] AndErrorReporting:YES];
    
    XCTAssertTrue([brick isEqualToBrick:copiedBrick], @"Bricks are not equal");
    XCTAssertEqual(brick.animate, copiedBrick.animate, @"BOOL animate is not equal");
    XCTAssertEqual(brick.animateInsertBrick, copiedBrick.animateInsertBrick, @"BOOL animateInsertBrick are not equal");
    
    brick.animateInsertBrick = YES;
    XCTAssertNotEqual(brick.animateInsertBrick, copiedBrick.animateInsertBrick, @"BOOL animateInsertBrick should not be equal");
}

@end
