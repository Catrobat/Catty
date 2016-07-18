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

#import "MirrorRotationZoomTool.h"
#import "UIImage+Rotate.h"
#import "UndoManager.h"

#define kMaxZoomScale 5.0f
#define kMinZoomScale 0.25f

@implementation MirrorRotationZoomTool
- (id) initWithDrawViewCanvas:(PaintViewController *)canvas
{
  self = [super init];
  if(self)
  {
    self.canvas = canvas;
  }
  return self;
}

- (void)mirrorVerticalAction
{
  UIImage* flippedImage;
  if (!self.canvas.vertical) {
    flippedImage = [UIImage imageWithCGImage:self.canvas.saveView.image.CGImage
                                       scale:self.canvas.saveView.image.scale
                                 orientation:UIImageOrientationUpMirrored];
    self.canvas.vertical = YES;
  } else{
    flippedImage = [UIImage imageWithCGImage:self.canvas.saveView.image.CGImage
                                       scale:self.canvas.saveView.image.scale
                                 orientation:UIImageOrientationUp];
    self.canvas.vertical=NO;
  }
    CGSize imageSize = CGSizeMake(self.canvas.saveView.bounds.size.width, self.canvas.saveView.bounds.size.height);
    
    UIGraphicsBeginImageContext(imageSize);
    UIImage *tempImage = [flippedImage copy];
    [tempImage drawInRect:CGRectMake(0, 0, imageSize.width, imageSize.height)];
    tempImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //UNDO-Manager
    UndoManager* manager = [self.canvas getUndoManager];
    [manager setImage:self.canvas.saveView.image];
    self.canvas.saveView.image = tempImage;
  self.canvas.drawView.image = nil;
}

- (void)mirrorHorizontalAction
{
  UIImage* flippedImage;
  if (!self.canvas.horizontal) {
    flippedImage = [UIImage imageWithCGImage:self.canvas.saveView.image.CGImage
                                       scale:self.canvas.saveView.image.scale
                                 orientation:UIImageOrientationDownMirrored];
    self.canvas.horizontal = YES;
  } else{
    flippedImage = [UIImage imageWithCGImage:self.canvas.saveView.image.CGImage
                                       scale:self.canvas.saveView.image.scale
                                 orientation:UIImageOrientationUp];
    self.canvas.horizontal=NO;
  }
    
    CGSize imageSize = CGSizeMake(self.canvas.saveView.bounds.size.width, self.canvas.saveView.bounds.size.height);
    
    UIGraphicsBeginImageContext(imageSize);
    UIImage *tempImage = [flippedImage copy];
    [tempImage drawInRect:CGRectMake(0, 0, imageSize.width, imageSize.height)];
    tempImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //UNDO-Manager
    UndoManager* manager = [self.canvas getUndoManager];
    [manager setImage:self.canvas.saveView.image];
  self.canvas.saveView.image = tempImage;
  self.canvas.drawView.image = nil;
}

- (void)rotateRight
{
  self.canvas.degrees += 90;
    UIImage *image =[self.canvas.saveView.image imageRotatedByDegrees:90];
    CGFloat zoomScale = self.canvas.scrollView.zoomScale;
    self.canvas.scrollView.zoomScale = 1.0;

    self.canvas.saveView.frame =CGRectMake(0,0, (self.canvas.helper.frame.size.height), (self.canvas.helper.frame.size.width));
    self.canvas.drawView.frame =CGRectMake(0,0, (self.canvas.helper.frame.size.height), (self.canvas.helper.frame.size.width));
    self.canvas.helper.frame =CGRectMake(self.canvas.helper.frame.origin.x,self.canvas.helper.frame.origin.y, self.canvas.helper.frame.size.height, self.canvas.helper.frame.size.width);

    self.canvas.scrollView.zoomScale = zoomScale;
    
    CGSize imageSize = CGSizeMake(self.canvas.helper.frame.size.width, self.canvas.helper.frame.size.height);
    
    UIGraphicsBeginImageContext(imageSize);
    UIImage *tempImage = [image copy];
    [tempImage drawInRect:CGRectMake(0, 0, imageSize.width, imageSize.height)];
    tempImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    //UNDO-Manager
    UndoManager* manager = [self.canvas getUndoManager];
    [manager setImage:self.canvas.saveView.image];
  self.canvas.saveView.image = tempImage;
}

- (void)rotateLeft
{
  self.canvas.degrees -= 90;
  UIImage *image =[self.canvas.saveView.image imageRotatedByDegrees:-90];
  CGFloat zoomScale = self.canvas.scrollView.zoomScale;
  self.canvas.scrollView.zoomScale = 1.0;
  self.canvas.saveView.frame =CGRectMake(0,0, (self.canvas.helper.frame.size.height), (self.canvas.helper.frame.size.width));
  self.canvas.drawView.frame =CGRectMake(0,0, (self.canvas.helper.frame.size.height), (self.canvas.helper.frame.size.width));
  self.canvas.helper.frame =CGRectMake(self.canvas.helper.frame.origin.x,self.canvas.helper.frame.origin.y, self.canvas.helper.frame.size.height, self.canvas.helper.frame.size.width);
  self.canvas.scrollView.zoomScale = zoomScale;
    
    CGSize imageSize = CGSizeMake(self.canvas.helper.frame.size.width, self.canvas.helper.frame.size.height);
    
    UIGraphicsBeginImageContext(imageSize);
    UIImage *tempImage = [image copy];
    [tempImage drawInRect:CGRectMake(0, 0, imageSize.width, imageSize.height)];
    tempImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //UNDO-Manager
    UndoManager* manager = [self.canvas getUndoManager];
    [manager setImage:self.canvas.saveView.image];
  self.canvas.saveView.image = tempImage;
}

- (void)zoomIn
{
  if (self.canvas.scrollView.zoomScale * 1.1f < kMaxZoomScale) {
    self.canvas.scrollView.zoomScale = self.canvas.scrollView.zoomScale * 1.1f;
  }else{
    self.canvas.scrollView.zoomScale = kMaxZoomScale;
  }
}

- (void)zoomOut
{
    if (self.canvas.scrollView.zoomScale / 1.1f > kMinZoomScale) {
        self.canvas.scrollView.zoomScale = self.canvas.scrollView.zoomScale / 1.1f;
    } else {
        self.canvas.scrollView.zoomScale = kMinZoomScale;
    }
}

@end
