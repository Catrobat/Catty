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
#import "CBStack.h"

@interface CBStackTests : XCTestCase
@end

@implementation CBStackTests

#define kNumberOfRoundsToTest 100
#define kMinNumberOfStackElements 1000
#define kMaxNumberOfStackElements 100000

- (void)testNumberOfElementsAfterPushing
{
    CBAssert(kMinNumberOfStackElements < kMaxNumberOfStackElements);
    CBStack *stack = [CBStack new];
    for (NSUInteger round = 0; round < kNumberOfRoundsToTest; ++round) {
        NSUInteger numberOfElementsToPush = (arc4random()
                                          % (kMaxNumberOfStackElements - kMinNumberOfStackElements + 1))
                                          + kMinNumberOfStackElements;
        for (NSUInteger elementNumber = 0; elementNumber < numberOfElementsToPush; ++elementNumber) {
            [stack pushElement:@(elementNumber)];
        }
        XCTAssertEqual(stack.numberOfElements, numberOfElementsToPush,
                       @"Number of elements on CBStack is %lu but should be %lu",
                       (unsigned long)stack.numberOfElements, (unsigned long)numberOfElementsToPush);
        [stack popAllElements];
    }
}

- (void)testNumberOfElementsAfterPopping
{
    CBAssert(kMinNumberOfStackElements < kMaxNumberOfStackElements);
    CBStack *stack = [CBStack new];
    for (NSUInteger round = 0; round < kNumberOfRoundsToTest; ++round) {
        for (NSUInteger elementNumber = 0; elementNumber < kMaxNumberOfStackElements; ++elementNumber) {
            [stack pushElement:@(elementNumber)];
        }
        NSUInteger numberOfElementsToPop = (arc4random()
                                         % (kMaxNumberOfStackElements - kMinNumberOfStackElements + 1))
                                         + kMinNumberOfStackElements;
        NSNumber *lastPoppedNumber = nil;
        for (NSUInteger elementNumber = 0; elementNumber < numberOfElementsToPop; ++elementNumber) {
            lastPoppedNumber = [stack popElement];
        }
        XCTAssertEqual(stack.numberOfElements, (kMaxNumberOfStackElements - numberOfElementsToPop),
                       @"Number of remaining elements on CBStack is %lu but should be %lu",
                       (unsigned long)stack.numberOfElements,
                       (unsigned long)(kMaxNumberOfStackElements - numberOfElementsToPop));
        [stack popAllElements];
    }
}

@end
