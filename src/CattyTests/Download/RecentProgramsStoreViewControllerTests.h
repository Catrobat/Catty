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

#import "RecentProgramsStoreViewController.h"

@class CatrobatInformation;

@interface RecentProgramsStoreViewController (Test)
- (void)loadProjectsWithIndicator:(NSInteger)indicator;
- (void)loadIDForArray:(NSMutableArray*)projects andInformation:(CatrobatInformation*) information andProjects:(NSArray*)catrobatProjects;
- (void)initSegmentedControl;
@end

@interface TestRecentProgramsStoreViewController : RecentProgramsStoreViewController
@property (nonatomic, strong) NSMutableArray* mostDownloadedProjects;
@property (nonatomic, strong) NSMutableArray* mostViewedProjects;
@property (nonatomic, strong) NSMutableArray* mostRecentProjects;
@property (nonatomic, weak) XCTestExpectation *downloadFinished;
- (id)initWithExpectation:(XCTestExpectation*) expectation;
@end

@interface RecentProgramsStoreViewControllerTests : XCTestCase
@property (nonatomic, strong) TestRecentProgramsStoreViewController *recentProgramsStoreViewController;
@end
