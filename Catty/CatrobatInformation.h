//
//  CatrobatInformation.h
//  Catty
//
//  Created by Christof Stromberger on 17.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CatrobatInformation : NSObject

- (id)initWithDict:(NSDictionary*)dict;

@property (nonatomic, strong) NSString *apiVersion;
@property (nonatomic, strong) NSString *baseURL;
@property (nonatomic, strong) NSString *projectsExtension;
@property (nonatomic, assign) NSNumber *totalProjects;

@end
