/**
 *  Copyright (C) 2010-2016 The Catrobat Team
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

#import <UIKit/UIKit.h>

@interface UIImage (CatrobatUIImageExtensions)

+ (UIImage*)imageWithColor:(UIColor*)color;

+ (UIImage*)imageWithContentsOfURL:(NSURL*)imageURL
                  placeholderImage:(UIImage*)placeholderImage
                      onCompletion:(void (^)(UIImage *image))completion;

+ (UIImage*)imageWithContentsOfURL:(NSURL*)imageURL
                  placeholderImage:(UIImage*)placeholderImage
                        errorImage:(UIImage*)errorImage
                      onCompletion:(void (^)(UIImage *image))completion;

+ (UIImage*)setImage:(UIImage*)uiImage WithBrightness:(CGFloat)brightness;
- (CGRect)cropRectForImage:(UIImage *)image;
- (CGContextRef)newARGBBitmapContextFromImage:(CGImageRef)inImage;
- (BOOL)isTransparentPixelAtPoint:(CGPoint)point;
- (BOOL)isTransparentPixelAtScenePoint:(CGPoint)point;
+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToMaxWidth:(CGFloat)width maxHeight:(CGFloat)height;
+ (UIImage*)changeImage:(UIImage*)image toColor:(UIColor*)color;

@end
