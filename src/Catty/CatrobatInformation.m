//
//  CatrobatInformation.m
//  Catty
//
//  Created by Christof Stromberger on 17.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "CatrobatInformation.h"

@implementation CatrobatInformation

@synthesize apiVersion        = _apiVersion;
@synthesize baseURL           = _baseURL;
@synthesize projectsExtension = _projectsExtension;
@synthesize totalProjects     = _totalProjects;

//custom init method
- (id)initWithDict:(NSDictionary*)dict {
    self = [super init];
    if (self) {
        
        //assuming values from json dict
        self.apiVersion = [dict valueForKey:@"ApiVersion"];
        self.baseURL = [dict valueForKey:@"BaseUrl"];
        self.projectsExtension = [dict valueForKey:@"ProjectExtension"];
        self.totalProjects = [dict valueForKey:@"TotalProjects"];
    }
    return self;
}

@end
