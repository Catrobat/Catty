/**
 *  Copyright (C) 2010-2018 The Catrobat Team
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
#import "RecentProgramsStoreViewControllerTests.h"
#import "CatrobatInformation.h"
#import "CatrobatProgram.h"
#import "LanguageTranslationDefines.h"
#import "Util.h"

#define CONNECTION_TIMEOUT 10

@implementation TestRecentProgramsStoreViewController
- (id)initWithExpectation:(XCTestExpectation*) expectation
{
    self = [super init];
    self.downloadFinished = expectation;
    return self;
}
- (void)loadIDForArray:(NSMutableArray*)projects andInformation:(CatrobatInformation*) information andProjects:(NSArray*)catrobatProjects
{
    [super loadIDForArray:projects andInformation:information andProjects:catrobatProjects];
    [self.downloadFinished fulfill];
}
- (UISegmentedControl*)downloadSegmentedControl
{
    static UISegmentedControl *segmentControl;
    if(segmentControl == nil)
        segmentControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:kLocalizedMostDownloaded, kLocalizedMostViewed, kLocalizedNewest, nil]];
    return segmentControl;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
}
@end

@implementation RecentProgramsStoreViewControllerTests

- (void)setUp
{
    [super setUp];
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"recentDownloadFinished"];
    self.recentProgramsStoreViewController = [[TestRecentProgramsStoreViewController alloc] initWithExpectation:expectation];
}

- (void)tearDown
{
    self.recentProgramsStoreViewController = nil;
    [super tearDown];
}

- (void)testMostDownloaded
{
    UISegmentedControl *segmentedControl = self.recentProgramsStoreViewController.downloadSegmentedControl;
    segmentedControl.selectedSegmentIndex = 0;
    [self.recentProgramsStoreViewController loadProjectsWithIndicator:0];
    
    [self waitForExpectationsWithTimeout:CONNECTION_TIMEOUT handler:^(NSError *error) {
        XCTAssertNil(error, "Expectation Failed with error: %@", error);
    }];
    
    XCTAssertEqual([self.recentProgramsStoreViewController.mostDownloadedProjects count], kRecentProgramsMaxResults, @"Recent programs not received completely!");
    
    for(CatrobatProgram *catrobatProject in self.recentProgramsStoreViewController.mostDownloadedProjects) {
        XCTAssertTrue([catrobatProject.author length] > 0, @"Invalid author");
        XCTAssertTrue([catrobatProject.downloadUrl length] > 0, @"Invalid downloadUrl");
        XCTAssertTrue([catrobatProject.size length] > 0, @"Invalid fileSize");
        XCTAssertTrue([catrobatProject.projectName length] > 0, @"Invalid projectName");
        XCTAssertTrue(catrobatProject.projectID > 0, @"Invalid projectID");
        XCTAssertTrue([catrobatProject.version length] > 0, @"Invalid version");
        XCTAssertTrue(catrobatProject.uploaded > 0, @"Invalid uploaded date");
        XCTAssertTrue([catrobatProject.version floatValue] <= [[Util catrobatLanguageVersion] floatValue], @"Version not supported yet");
    }
}

- (void)testMostViewed
{
    UISegmentedControl *segmentedControl = self.recentProgramsStoreViewController.downloadSegmentedControl;
    segmentedControl.selectedSegmentIndex = 1;
    [self.recentProgramsStoreViewController loadProjectsWithIndicator:0];
    
    [self waitForExpectationsWithTimeout:CONNECTION_TIMEOUT handler:^(NSError *error) {
        XCTAssertNil(error, "Expectation Failed with error: %@", error);
    }];;
    
    XCTAssertEqual([self.recentProgramsStoreViewController.mostViewedProjects count], kRecentProgramsMaxResults, @"Recent programs not received completely!");
    
    for(CatrobatProgram *catrobatProject in self.recentProgramsStoreViewController.mostViewedProjects) {
        XCTAssertTrue([catrobatProject.projectName length] > 0, @"Invalid projectName");
        XCTAssertTrue(catrobatProject.projectID > 0, @"Invalid projectID");
        XCTAssertTrue([catrobatProject.version floatValue] <= [[Util catrobatLanguageVersion] floatValue], @"Version not supported yet");
    }
}

- (void)testMostRecent
{
    UISegmentedControl *segmentedControl = self.recentProgramsStoreViewController.downloadSegmentedControl;
    segmentedControl.selectedSegmentIndex = 2;
    [self.recentProgramsStoreViewController loadProjectsWithIndicator:0];
    
    [self waitForExpectationsWithTimeout:CONNECTION_TIMEOUT handler:^(NSError *error) {
        XCTAssertNil(error, "Expectation Failed with error: %@", error);
    }];
    
    XCTAssertEqual([self.recentProgramsStoreViewController.mostRecentProjects count], kRecentProgramsMaxResults, @"Newest programs not received completely!");
    
    for(CatrobatProgram *catrobatProject in self.recentProgramsStoreViewController.mostRecentProjects) {
        XCTAssertTrue([catrobatProject.projectName length] > 0, @"Invalid projectName");
        XCTAssertTrue(catrobatProject.projectID > 0, @"Invalid projectID");
        XCTAssertTrue([catrobatProject.version floatValue] <= [[Util catrobatLanguageVersion] floatValue], @"Version not supported yet");
    }
}

@end
