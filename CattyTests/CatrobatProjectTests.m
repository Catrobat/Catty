//
//  CatrobatProjectTests.m
//  Catty
//
//  Created by Christof Stromberger on 21.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "CatrobatProjectTests.h"
#import "CatrobatProject.h"

#define SAMPLE_AUTHOR @"TestAuthor"
#define SAMPLE_DESCRIPTION @"TestDescription"
#define SAMPLE_DOWNLOAD_URL @"http://www.catrobat.org/test/"
#define SAMPLE_DOWNLOADS @"3"
#define SAMPLE_PROJECT_NAME @"TestProject"
#define SAMPLE_PROJECT_URL @"http://catrobat.org/myproject/"
#define SAMPLE_PROJECT_SCREENSHOT_BIG @"http://catrobat.org/samplescreenshot"
#define SAMPLE_PROJECT_SCREENSHOT_SMALL @"http://catrobat.org/samplescreenshotsmall"
#define SAMPLE_UPLOADED @"21.9.2012"
#define SAMPLE_VERSION @"0.1.1"
#define SAMPLE_VIEWS @"100"


@implementation CatrobatProjectTests

#pragma mark - tear up & down
- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
    
}

- (NSDictionary*)createSampleDict {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:SAMPLE_AUTHOR forKey:@"Author"];
    [dict setValue:SAMPLE_DESCRIPTION forKey:@"Description"];
    [dict setValue:SAMPLE_DOWNLOAD_URL forKey:@"DownloadUrl"];
    [dict setValue:SAMPLE_DOWNLOADS forKey:@"Downloads"];
    [dict setValue:SAMPLE_PROJECT_NAME forKey:@"ProjectName"];
    [dict setValue:SAMPLE_PROJECT_URL forKey:@"ProjectUrl"];
    [dict setValue:SAMPLE_PROJECT_SCREENSHOT_BIG forKey:@"ScreenshotBig"];
    [dict setValue:SAMPLE_PROJECT_SCREENSHOT_SMALL forKey:@"ScreenshotSmall"];
    [dict setValue:SAMPLE_UPLOADED forKey:@"Uploaded"];
    [dict setValue:SAMPLE_VERSION forKey:@"Version"];
    [dict setValue:SAMPLE_VIEWS forKey:@"Views"];
    
    return dict;
}

- (void)test001_testCatrobatProjectClass {
    CatrobatProject *project = [[CatrobatProject alloc] initWithDict:[self createSampleDict]];
    STAssertEquals(project.author, SAMPLE_AUTHOR, @"checking author");
    STAssertEquals(project.description, SAMPLE_DESCRIPTION, @"checking description");
    STAssertEquals(project.downloadUrl, SAMPLE_DOWNLOAD_URL, @"checking download url");
    STAssertEquals(project.downloads, SAMPLE_DOWNLOADS, @"checking downloads");
    STAssertEquals(project.projectName, SAMPLE_PROJECT_NAME, @"checking project name");
    STAssertEquals(project.projectUrl, SAMPLE_PROJECT_URL, @"checking project url");
    STAssertEquals(project.screenshotBig, SAMPLE_PROJECT_SCREENSHOT_BIG, @"checking big screenshot");
    STAssertEquals(project.screenshotSmall, SAMPLE_PROJECT_SCREENSHOT_SMALL, @"checking small screenshot");
    STAssertEquals(project.uploaded, SAMPLE_UPLOADED, @"checking uploaded");
    STAssertEquals(project.version, SAMPLE_VERSION, @"checking version");
    STAssertEquals(project.views, SAMPLE_VIEWS, @"checking views");
}


- (void)test002_testWrongCatrobatClass {
    CatrobatProject *project = [[CatrobatProject alloc] init];
    
    //inited with nil
    STAssertNil(project.author, @"checking author");
    STAssertNil(project.downloadUrl, @"checking download url");
    STAssertNil(project.downloads, @"checking downloads");
    STAssertNil(project.projectName, @"checking project name");
    STAssertNil(project.projectUrl, @"checking project url");
    STAssertNil(project.screenshotBig, @"checking big screenshot");
    STAssertNil(project.screenshotSmall, @"checking small screenshot");
    STAssertNil(project.uploaded, @"checking uploaded");
    STAssertNil(project.version, @"checking version");
    STAssertNil(project.views, @"checking views");
    
}


@end
