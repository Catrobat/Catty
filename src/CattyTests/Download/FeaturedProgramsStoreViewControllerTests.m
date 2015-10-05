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
#import "FeaturedProgramsStoreViewControllerTests.h"
#import "CatrobatProgram.h"
#import "LanguageTranslationDefines.h"

#define CONNECTION_TIMEOUT 10

@implementation TestFeaturedProgramsStoreViewController
- (id)initWithExpectation:(XCTestExpectation*) expectation
{
    self = [super init];
    self.downloadFinished = expectation;
    return self;
}
- (void)loadIDsWith:(NSData*)data andResponse:(NSURLResponse*)response
{
    [super loadIDsWith:data andResponse:response];
    [self.downloadFinished fulfill];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
}
@end

@implementation FeaturedProgramsStoreViewControllerTests

- (void)setUp
{
    [super setUp];
    XCTestExpectation *expectation = [self expectationWithDescription:@"downloadFinished"];
    self.featuredProgramsStoreViewController = [[TestFeaturedProgramsStoreViewController alloc] initWithExpectation:expectation];
}

- (void)tearDown
{
    self.featuredProgramsStoreViewController = nil;
    [super tearDown];
}

/*- (void)testFeatured
{
    [self.featuredProgramsStoreViewController loadFeaturedProjects];
    
    [self waitForExpectationsWithTimeout:CONNECTION_TIMEOUT handler:^(NSError *error) {
        XCTAssertNil(error, "Expectation Failed with error: %@", error);
    }];
    
    XCTAssertTrue([self.featuredProgramsStoreViewController.projects count] > 0, @"No featured programs loaded!");
    
    for(CatrobatProgram *catrobatProject in self.featuredProgramsStoreViewController.projects) {
        XCTAssertTrue([catrobatProject.author length] > 0, @"Invalid author");
        XCTAssertTrue([catrobatProject.downloadUrl length] > 0, @"Invalid downloadUrl");
        XCTAssertTrue([catrobatProject.size length] > 0, @"Invalid fileSize");
        XCTAssertTrue([catrobatProject.projectName length] > 0, @"Invalid projectName");
        XCTAssertTrue(catrobatProject.projectID > 0, @"Invalid projectID");
        XCTAssertTrue([catrobatProject.featuredImage length] > 0, @"Invalid featuredImage");
    }
}*/

@end
