/**
 *  Copyright (C) 2010-2014 The Catrobat Team
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

#define kMaxZoomScale 5.0f
#define kMinZoomScale 0.25f

@implementation MirrorRotationZoomTool
-(id) initWithDrawViewCanvas:(PaintViewController *)canvas
{
  self = [super init];
  if(self)
  {
    self.canvas = canvas;
  }
  return self;
}

-(void)mirrorVerticalAction
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
  //UNDO-Manager
  [[self.canvas getUndoManager] setImage:self.canvas.saveView.image];
  self.canvas.saveView.image = flippedImage;
  self.canvas.drawView.image = nil;
}

-(void)mirrorHorizontalAction
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
  //UNDO-Manager
  [[self.canvas getUndoManager] setImage:self.canvas.saveView.image];
  self.canvas.saveView.image = flippedImage;
  self.canvas.drawView.image = nil;
}

-(void)rotateRight
{
  self.canvas.degrees += 90;
  self.canvas.saveView.frame =CGRectMake(self.canvas.saveView.frame.origin.x,self.canvas.saveView.frame.origin.y, (self.canvas.helper.frame.size.height/self.canvas.scrollView.zoomScale), (self.canvas.helper.frame.size.width/self.canvas.scrollView.zoomScale));
  self.canvas.drawView.frame =CGRectMake(self.canvas.drawView.frame.origin.x,self.canvas.drawView.frame.origin.y, (self.canvas.helper.frame.size.height/self.canvas.scrollView.zoomScale), (self.canvas.helper.frame.size.width/self.canvas.scrollView.zoomScale));
  self.canvas.helper.frame =CGRectMake(self.canvas.helper.frame.origin.x, self.canvas.helper.frame.origin.y, self.canvas.helper.frame.size.height/self.canvas.scrollView.zoomScale, self.canvas.helper.frame.size.width/self.canvas.scrollView.zoomScale);
  UIImage *image =[self.canvas.saveView.image imageRotatedByDegrees:90];
  [self.canvas.scrollView zoomToRect:self.canvas.saveView.frame animated:NO];
  //UNDO-Manager
  [[self.canvas getUndoManager] setImage:self.canvas.saveView.image];
  self.canvas.saveView.image = image;
}

-(void)rotateLeft
{
  self.canvas.degrees -= 90;
  self.canvas.saveView.frame =CGRectMake(self.canvas.saveView.frame.origin.x,self.canvas.saveView.frame.origin.y, (self.canvas.helper.frame.size.height/self.canvas.scrollView.zoomScale), (self.canvas.helper.frame.size.width/self.canvas.scrollView.zoomScale));
  self.canvas.drawView.frame =CGRectMake(self.canvas.drawView.frame.origin.x,self.canvas.drawView.frame.origin.y, (self.canvas.helper.frame.size.height/self.canvas.scrollView.zoomScale), (self.canvas.helper.frame.size.width/self.canvas.scrollView.zoomScale));
  self.canvas.helper.frame =CGRectMake(self.canvas.helper.frame.origin.x, self.canvas.helper.frame.origin.y, self.canvas.helper.frame.size.height/self.canvas.scrollView.zoomScale, self.canvas.helper.frame.size.width/self.canvas.scrollView.zoomScale);
  UIImage *image = [self.canvas.saveView.image imageRotatedByDegrees:-90];
  [self.canvas.scrollView zoomToRect:self.canvas.saveView.frame animated:NO];
  //UNDO-Manager
  [[self.canvas getUndoManager] setImage:self.canvas.saveView.image];
  self.canvas.saveView.image = image;
}

-(void)zoomIn
{
  if (self.canvas.scrollView.zoomScale * 1.1f < kMaxZoomScale) {
    self.canvas.scrollView.zoomScale = self.canvas.scrollView.zoomScale * 1.1f;
  }else{
    self.canvas.scrollView.zoomScale = kMaxZoomScale;
  }
}

-(void)zoomOut
{
  if (self.canvas.scrollView.zoomScale / 1.1f > kMinZoomScale) {
    self.canvas.scrollView.zoomScale = self.canvas.scrollView.zoomScale / 1.1f;
  }else{
    self.canvas.scrollView.zoomScale =kMinZoomScale;
  }
  
}

@end
