/**
 *  Copyright (C) 2010-2014 The Catrobat Team
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
#import "ExternInternRepresentationMapping.h"

@interface ExternInternRepresentationMappingTest : XCTestCase

@end

static int MAPPING_NOT_FOUND = INT_MIN;

@implementation ExternInternRepresentationMappingTest



- (void)testGetExternTokenStartIndex
{
    ExternInternRepresentationMapping *externInternRepresentationMapping = [[ExternInternRepresentationMapping alloc]init];
    
    int externTokenStringStartIndex = 1;
    int externTokenStringEndIndex = 3;
    int internTokenListIndex = 0;
    
    [externInternRepresentationMapping putMappingWithStart:externTokenStringStartIndex andEnd:externTokenStringEndIndex andInternListIndex:internTokenListIndex];
    
    XCTAssertEqual(externTokenStringStartIndex,
                   [externInternRepresentationMapping getExternTokenStartIndex:internTokenListIndex],
                   @"getExternTokenStartIndex returns wrong value");
    
    XCTAssertEqual(externTokenStringEndIndex,
                   [externInternRepresentationMapping getExternTokenEndIndex:internTokenListIndex],
                   @"getExternTokenEndIndex returns wrong value");
    
    XCTAssertEqual(MAPPING_NOT_FOUND,
                   [externInternRepresentationMapping getExternTokenStartIndex:1],
                   @"Mapping should not exist");
    
    XCTAssertEqual(MAPPING_NOT_FOUND,
                   [externInternRepresentationMapping getExternTokenEndIndex:1],
                   @"Mapping should not exist");
}

@end
