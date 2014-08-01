/**
 *  Copyright (C) 2010-2013 The Catrobat Team
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



#import <Foundation/Foundation.h>

@interface CatrobatProject : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *downloadUrl;
@property (nonatomic, strong) NSNumber *downloads;
@property (nonatomic, strong) NSString *projectID;
@property (nonatomic, strong) NSString *projectName;
@property (nonatomic, strong) NSString *projectUrl;
@property (nonatomic, strong) NSString *screenshotBig;
@property (nonatomic, strong) NSString *screenshotSmall;
@property (nonatomic, strong) NSString *featuredImage;
@property (nonatomic, strong) NSString *uploaded;
@property (nonatomic, strong) NSString *version;
@property (nonatomic, strong) NSNumber *views;
@property (nonatomic, strong) NSString *size;
@property (nonatomic) BOOL isdownloading;

- (id)initWithDict:(NSDictionary*)dict andBaseUrl:(NSString*)baseUrl;


@end
