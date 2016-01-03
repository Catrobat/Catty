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

#import "FillTool.h"
#import "UIImage+FloodFill.h"
#import "UndoManager.h"

@implementation FillTool
- (id) initWithDrawViewCanvas:(PaintViewController *)canvas
{
  self = [super init];
  if(self)
  {
    self.canvas = canvas;
  }
  return self;
}

- (UIImage *)fillImage:(UIImage*)image startingPoint:(CGPoint)point andColor:(UIColor*)color
{
  UIImage *newImage = [image floodFillFromPoint:point withColor:color andTolerance:50];
  return newImage;
}

- (void)fillAction:(UITapGestureRecognizer*)recognizer
{
  CGPoint lastPoint = [recognizer locationOfTouch:0 inView:self.canvas.drawView];
  if (!self.canvas.saveView.image) {
    UIGraphicsBeginImageContextWithOptions(self.canvas.saveView.frame.size, NO, 0.0);
    UIImage *blank = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.canvas.saveView.image = blank;
  }
  
//  NSDebug(@"%@",self.canvas.saveView.image);
    UIImage *image = self.canvas.saveView.image;
    //UNDO-Manager
    UndoManager* manager = [self.canvas getUndoManager];
    [manager setImage:self.canvas.saveView.image];
    image = [self fillImage:image startingPoint:lastPoint andColor:[UIColor colorWithRed:self.canvas.red green:self.canvas.green blue:self.canvas.blue alpha:self.canvas.opacity]];
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    self.canvas.saveView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}
@end
