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

#import "SaveToProjectActivity.h"
#import "LanguageTranslationDefines.h"
#import "RuntimeImageCache.h"

@implementation SaveToProjectActivity

- (id)initWithImagePath:(NSString *)path
{
    self = [super init];
    if (self)
    {
        self.path = path;
    }
    return self;
}

- (NSString *)activityType {
    return @"SaveToProjectActivity";
}

- (NSString *)activityTitle {
    return kLocalizedSetAsPreviewImage;
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"activity"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    return YES;
}

- (UIViewController *)performWithActivityItems:(NSArray *)activityItems
{
    return nil;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    self.image = activityItems[0];
    //self.path = activityItems[1];
}


- (void)performActivity
{
    NSString *fileName = @"manual_screenshot.png";
    NSString *pngFilePath = [NSString stringWithFormat:@"%@%@",self.path, fileName];
    NSData *data = [NSData dataWithData:UIImagePNGRepresentation(self.image)];
    [data writeToFile:pngFilePath atomically:YES];
    [[RuntimeImageCache sharedImageCache] overwriteThumbnailImageFromDiskWithThumbnailPath:[NSString stringWithFormat:@"%@%@%@",self.path, kScreenshotThumbnailPrefix, fileName] image:self.image thumbnailFrameSize:CGSizeMake(kPreviewImageWidth, kPreviewImageHeight)];
    
    [self activityDidFinish:YES];
}

@end
