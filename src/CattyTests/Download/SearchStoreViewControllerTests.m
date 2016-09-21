/**
 *  Copyright (C) 2010-2016 The Catrobat Team
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

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "SearchStoreViewControllerTests.h"
#import "CatrobatProgram.h"

#define CONNECTION_TIMEOUT 10

@implementation TestSearchStoreViewController
- (id)initWithExpectation:(XCTestExpectation*) expectation
{
    self = [super init];
    self.downloadFinished = expectation;
    return self;
}
- (void)processResults:(NSArray *)results
{
    [super processResults:results];
    [self.downloadFinished fulfill];
}
@end

@implementation SearchStoreViewControllerTests

- (void)setUp
{
    [super setUp];
    XCTestExpectation *expectation = [self expectationWithDescription:@"downloadFinished"];
    self.searchStoreViewController = [[TestSearchStoreViewController alloc] initWithExpectation: expectation];
}

- (void)tearDown
{
    self.searchStoreViewController = nil;
    [super tearDown];
}

- (void)testSearchStore
{
    UISearchBar *searchBar = [UISearchBar new];
    self.searchStoreViewController.searchBar = searchBar;
    self.searchStoreViewController.searchBar.text = @" ";
    [self.searchStoreViewController performSearch];
    
    [self waitForExpectationsWithTimeout:CONNECTION_TIMEOUT handler:^(NSError *error) {
        XCTAssertNil(error, "Expectation Failed with error: %@", error);
    }];
    
    XCTAssertEqual([self.searchStoreViewController.searchResults count], kSearchStoreMaxResults, @"Search results not received completely!");
    
    for(CatrobatProgram *catrobatProject in self.searchStoreViewController.searchResults) {
        XCTAssertTrue([catrobatProject.author length] > 0, @"Invalid author");
        XCTAssertTrue([catrobatProject.downloadUrl length] > 0, @"Invalid downloadUrl");
        XCTAssertTrue([catrobatProject.size length] > 0, @"Invalid fileSize");
        XCTAssertTrue([catrobatProject.projectName length] > 0, @"Invalid projectName");
        XCTAssertTrue(catrobatProject.projectID > 0, @"Invalid projectID");
        XCTAssertTrue([catrobatProject.version length] > 0, @"Invalid version");
        XCTAssertTrue(catrobatProject.uploaded > 0, @"Invalid uploaded date");
    }
}

@end
