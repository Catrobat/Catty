//
//  CatrobatProject.m
//  Catty
//
//  Created by Christof Stromberger on 17.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "CatrobatProject.h"

@implementation CatrobatProject

@synthesize author          = _author;
@synthesize description     = _description;
@synthesize downloadUrl     = _downloadUrl;
@synthesize downloads       = _downloads;
@synthesize projectName     = _projectName;
@synthesize projectUrl      = _projectUrl;
@synthesize screenshotBig   = _screenshotBig;
@synthesize screenshotSmall = _screenshotSmall;
@synthesize uploaded        = _uploaded;
@synthesize version         = _version;
@synthesize views           = _views;

- (id)initWithDict:(NSDictionary*)dict {
    self = [super init];
    if (self) {
        //assuming values
        self.author          = [dict valueForKey:@"Author"];
        self.description     = [dict valueForKey:@"Description"];
        self.downloadUrl     = [dict valueForKey:@"DownloadUrl"];
        self.downloads       = [dict valueForKey:@"Downloads"];
        self.projectName     = [dict valueForKey:@"ProjectName"];
        self.projectUrl      = [dict valueForKey:@"ProjectUrl"];
        self.screenshotBig   = [dict valueForKey:@"ScreenshotBig"];
        self.screenshotSmall = [dict valueForKey:@"ScreenshotSmall"];
        self.uploaded        = [dict valueForKey:@"Uploaded"];
        self.version         = [dict valueForKey:@"Version"];
        self.views           = [dict valueForKey:@"Views"];
        
        
//        id value = [dict valueForKey:@"Author"];
//        if ([value isKindOfClass:[NSString class]]) {
//            self.author = (NSString*)value;
//        }
    }
    
    return self;
}

@end
