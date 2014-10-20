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

#import "DrawTool.h"

@implementation DrawTool

-(id) initWithDrawViewCanvas:(PaintViewController *)canvas
{
  self = [super init];
  if(self)
  {
    self.canvas = canvas;
  }
  return self;
}

-(void)draw:(UIPanGestureRecognizer *)recognizer
{
  if (recognizer.state == UIGestureRecognizerStateBegan){
    
//    if (enabled) {
      fingerSwiped = NO;
      lastPoint = [recognizer locationOfTouch:0 inView:self.canvas.drawView];
    UIGraphicsBeginImageContext(self.canvas.drawView.frame.size);
    [self.canvas.drawView.image drawInRect:CGRectMake(self.canvas.drawView.frame.origin.x,self.canvas.drawView.frame.origin.y, self.canvas.drawView.frame.size.width, self.canvas.drawView.frame.size.height)];
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
    switch (self.canvas.ending) {
      case Round:
        CGContextSetLineCap(UIGraphicsGetCurrentContext(),kCGLineCapRound);
        break;
      case Square:
        CGContextSetLineCap(UIGraphicsGetCurrentContext(),kCGLineCapSquare);
        break;
      default:
        break;
    }
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), self.canvas.thickness );
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), self.canvas.red, self.canvas.green, self.canvas.blue, 1.0);
    if (self.canvas.isEraser) {
      CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeClear);
    } else {
      CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
    }
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.canvas.drawView.image = UIGraphicsGetImageFromCurrentImageContext();
    [self.canvas.drawView setAlpha:self.canvas.opacity];
    UIGraphicsEndImageContext();
//    }
    
  }else if (recognizer.state == UIGestureRecognizerStateChanged){
//    if (enabled) {
      fingerSwiped = YES;
      CGPoint currentPoint = [recognizer locationOfTouch:0 inView:self.canvas.drawView];
      UIGraphicsBeginImageContext(self.canvas.drawView.frame.size);
      [self.canvas.drawView.image drawInRect:CGRectMake(self.canvas.drawView.frame.origin.x,self.canvas.drawView.frame.origin.y, self.canvas.drawView.frame.size.width, self.canvas.drawView.frame.size.height)];
      CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
      CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
      switch (self.canvas.ending) {
        case Round:
          CGContextSetLineCap(UIGraphicsGetCurrentContext(),kCGLineCapRound);
          break;
        case Square:
          CGContextSetLineCap(UIGraphicsGetCurrentContext(),kCGLineCapSquare);
          break;
        default:
          break;
      }
      CGContextSetLineWidth(UIGraphicsGetCurrentContext(), self.canvas.thickness );
      CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), self.canvas.red, self.canvas.green, self.canvas.blue, 1.0);
      if (self.canvas.isEraser) {
        CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeClear);
      } else {
        CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
      }
      CGContextStrokePath(UIGraphicsGetCurrentContext());
      self.canvas.drawView.image = UIGraphicsGetImageFromCurrentImageContext();
      [self.canvas.drawView setAlpha:self.canvas.opacity];
      UIGraphicsEndImageContext();
      
      lastPoint = currentPoint;
//    }
    
  }else if (recognizer.state == UIGestureRecognizerStateEnded){
//    if (enabled) {
      if (self.canvas.isEraser) {
        if(!fingerSwiped) {
          UIGraphicsBeginImageContext(self.canvas.drawView.frame.size);
          [self.canvas.drawView.image drawInRect:CGRectMake(self.canvas.drawView.frame.origin.x,self.canvas.drawView.frame.origin.y, self.canvas.drawView.frame.size.width, self.canvas.drawView.frame.size.height)];
          switch (self.canvas.ending) {
            case Round:
              CGContextSetLineCap(UIGraphicsGetCurrentContext(),kCGLineCapRound);
              break;
            case Square:
              CGContextSetLineCap(UIGraphicsGetCurrentContext(),kCGLineCapSquare);
              break;
            default:
              break;
          }
          CGContextSetLineWidth(UIGraphicsGetCurrentContext(), self.canvas.thickness);
          CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), self.canvas.red, self.canvas.green, self.canvas.blue, 1);
          CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
          CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
          CGContextStrokePath(UIGraphicsGetCurrentContext());
          CGContextFlush(UIGraphicsGetCurrentContext());
          self.canvas.drawView.image = UIGraphicsGetImageFromCurrentImageContext();
          
          UIImage *image = [[UIImage alloc] init];
          
          [image drawInRect:CGRectMake(0, 0, self.canvas.drawView.frame.size.width, self.canvas.drawView.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
          [self.canvas.drawView.image drawInRect:CGRectMake(self.canvas.drawView.frame.origin.x,self.canvas.drawView.frame.origin.y, self.canvas.drawView.frame.size.width, self.canvas.drawView.frame.size.height) blendMode:kCGBlendModeClear alpha:1];
          image = UIGraphicsGetImageFromCurrentImageContext();
          self.canvas.drawView.image = nil;
          CGContextFlush(UIGraphicsGetCurrentContext());
          UIGraphicsEndImageContext();
          
          self.canvas.saveView.image = image;
          self.canvas.drawView.hidden = YES;
        }else {
          self.canvas.saveView.image = self.canvas.drawView.image;
        }
        
      }
      else {
        if(!fingerSwiped) {
          UIGraphicsBeginImageContext(self.canvas.drawView.frame.size);
          [self.canvas.drawView.image drawInRect:CGRectMake(self.canvas.drawView.frame.origin.x,self.canvas.drawView.frame.origin.y, self.canvas.drawView.frame.size.width, self.canvas.drawView.frame.size.height)];
          switch (self.canvas.ending) {
            case Round:
              CGContextSetLineCap(UIGraphicsGetCurrentContext(),kCGLineCapRound);
              break;
            case Square:
              CGContextSetLineCap(UIGraphicsGetCurrentContext(),kCGLineCapSquare);
              break;
            default:
              break;
          }
          CGContextSetLineWidth(UIGraphicsGetCurrentContext(), self.canvas.thickness);
          CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), self.canvas.red, self.canvas.green, self.canvas.blue, self.canvas.opacity);
          CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
          CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
          CGContextStrokePath(UIGraphicsGetCurrentContext());
          CGContextFlush(UIGraphicsGetCurrentContext());
          self.canvas.drawView.image = UIGraphicsGetImageFromCurrentImageContext();
          
          UIGraphicsEndImageContext();
        }
        UIGraphicsBeginImageContext(self.canvas.saveView.frame.size);
        [self.canvas.saveView.image drawInRect:CGRectMake(self.canvas.saveView.frame.origin.x,self.canvas.saveView.frame.origin.y, self.canvas.saveView.frame.size.width, self.canvas.saveView.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
        [self.canvas.drawView.image drawInRect:CGRectMake(self.canvas.drawView.frame.origin.x,self.canvas.drawView.frame.origin.y, self.canvas.drawView.frame.size.width, self.canvas.drawView.frame.size.height) blendMode:kCGBlendModeNormal alpha:self.canvas.opacity];
        //UNDO-Manager
        [[self.canvas getUndoManager] setImage:self.canvas.saveView.image];
        
        self.canvas.saveView.image = UIGraphicsGetImageFromCurrentImageContext();
        self.canvas.drawView.image = nil;
        UIGraphicsEndImageContext();
      }
    }
  
}
@end
