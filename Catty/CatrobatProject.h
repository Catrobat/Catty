//
//  CatrobatProject.h
//  Catty
//
//  Created by Christof Stromberger on 17.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//


/* sample: 
{
 Author = testUser1347674544856;
 Description = "";
 DownloadUrl = "http://catroidtest.ist.tugraz.at/catroid/download/2753.catrobat";
 Downloads = 1;
 ProjectName = "\U3053\U308c\U306f\U4f8b\U306e\U8aac\U660e\U3067\U3059\U3002";
 ProjectUrl = "http://catroidtest.ist.tugraz.at/catroid/details/2753";
 ScreenshotBig = "http://catroidtest.ist.tugraz.at/resources/thumbnails/2753_large.png";
 ScreenshotSmall = "http://catroidtest.ist.tugraz.at/resources/thumbnails/2753_small.png";
 Uploaded = "1347673398.29324";
 Version = "0.6.0beta";
 Views = 0;
}
 */


#import <Foundation/Foundation.h>

@interface CatrobatProject : NSObject

@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *downloadUrl;
@property (nonatomic, strong) NSNumber *downloads;
@property (nonatomic, strong) NSString *projectName;
@property (nonatomic, strong) NSString *projectUrl;
@property (nonatomic, strong) NSString *screenshotBig;
@property (nonatomic, strong) NSString *screenshotSmall;
@property (nonatomic, strong) NSString *uploaded;
@property (nonatomic, strong) NSString *version;
@property (nonatomic, strong) NSNumber *views;

- (id)initWithDict:(NSDictionary*)dict;


@end
