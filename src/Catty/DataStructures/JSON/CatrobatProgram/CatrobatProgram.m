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

#import "CatrobatProgram.h"

@implementation CatrobatProgram

- (id)initWithDict:(NSDictionary*)dict andBaseUrl:(NSString*)baseUrl {
    self = [super init];
    if (self) {
        
        if ([baseUrl hasPrefix:@"//"]) {
            baseUrl = [NSString stringWithFormat:@"https:%@", baseUrl];
        }
        
        self.name            = [dict valueForKey:@"ProjectName"];
        self.author          = [dict valueForKey:@"Author"];
        self.projectDescription = [dict valueForKey:@"Description"];
        self.downloadUrl     = [NSString stringWithFormat:@"%@%@", baseUrl,[dict valueForKey:@"DownloadUrl"]];
        self.downloads       = [dict valueForKey:@"Downloads"];
        self.projectID       = [[dict valueForKey:@"ProjectId"] stringValue];
        self.projectName     = [dict valueForKey:@"ProjectName"];
        self.projectUrl      = [dict valueForKey:@"ProjectUrl"];
        self.screenshotBig   = [NSString stringWithFormat:@"%@%@", baseUrl,[dict valueForKey:@"ScreenshotBig"]];
        self.screenshotSmall = [NSString stringWithFormat:@"%@%@", baseUrl,[dict valueForKey:@"ScreenshotSmall"]];
        self.featuredImage   = [NSString stringWithFormat:@"%@%@", baseUrl,[dict valueForKey:@"FeaturedImage"]];
        self.uploaded        = [[dict valueForKey:@"Uploaded"] stringValue];
        self.version         = [dict valueForKey:@"Version"];
        self.views           = [dict valueForKey:@"Views"];
       
        if ([[dict valueForKey:@"FileSize"] isKindOfClass:[NSString class]]){
             self.size  = [dict valueForKey:@"FileSize"];
        } else {
            NSNumber * size = [dict valueForKey:@"FileSize"];
            self.size = [NSString stringWithFormat:@"%.*f",1,size.floatValue];
        }
        if (!self.size) {
            self.size = @"?";
        }
    }
    return self;
}

static NSDateFormatter *uploadDateFormatter = nil;
+ (NSDateFormatter*)uploadDateFormatter
{
    if (! uploadDateFormatter) {
        uploadDateFormatter = [NSDateFormatter new];
        [uploadDateFormatter setDateStyle:NSDateFormatterMediumStyle];
    }
    return uploadDateFormatter;
}

@end
