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

#import "DrawTool.h"
#import "UndoManager.h"

@implementation DrawTool 

- (id) initWithDrawViewCanvas:(PaintViewController *)canvas
{
  self = [super init];
  if(self)
  {
    self.canvas = canvas;
  }
  return self;
}

- (void)draw:(UIGestureRecognizer *)recognizer
{

  if (recognizer.state == UIGestureRecognizerStateBegan){
      if (self.canvas.isEraser) {
          self.canvas.saveView.hidden = YES;
          self.canvas.drawView.image = self.canvas.saveView.image;
      }
//    if (enabled) {
      fingerSwiped = NO;
      lastPoint = [recognizer locationOfTouch:0 inView:self.canvas.drawView];
  }else if (recognizer.state == UIGestureRecognizerStateChanged){
//    if (enabled) {
      fingerSwiped = YES;
      CGPoint currentPoint = [recognizer locationOfTouch:0 inView:self.canvas.drawView];
      [self drawLineFrom:lastPoint to:currentPoint];
      lastPoint = currentPoint;
//    }
    
  }else {
//    if (enabled) {
      if (!fingerSwiped) {
          // draw a single point
          [self drawLineFrom:lastPoint to:lastPoint];
      }
      if (self.canvas.isEraser && fingerSwiped) {
            //UNDO-Manager
            UndoManager* manager = [self.canvas getUndoManager];
            [manager setImage:self.canvas.saveView.image];
          self.canvas.saveView.image = self.canvas.drawView.image;
            self.canvas.drawView.image = nil;
            self.canvas.saveView.hidden = NO;
      } else {
          UIGraphicsBeginImageContext(self.canvas.saveView.frame.size);
          [self.canvas.saveView.image drawInRect:CGRectMake(self.canvas.drawView.frame.origin.x,self.canvas.drawView.frame.origin.y, self.canvas.saveView.frame.size.width, self.canvas.saveView.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
          if (self.canvas.isEraser) {
            [self.canvas.drawView.image drawInRect:CGRectMake(self.canvas.drawView.frame.origin.x,self.canvas.drawView.frame.origin.y, self.canvas.drawView.frame.size.width, self.canvas.drawView.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0f];
          } else {
               [self.canvas.drawView.image drawInRect:CGRectMake(self.canvas.drawView.frame.origin.x,self.canvas.drawView.frame.origin.y, self.canvas.drawView.frame.size.width, self.canvas.drawView.frame.size.height) blendMode:kCGBlendModeNormal alpha:self.canvas.opacity];
          }
         
          //UNDO-Manager
          UndoManager* manager = [self.canvas getUndoManager];
          [manager setImage:self.canvas.saveView.image];
          self.canvas.saveView.image = UIGraphicsGetImageFromCurrentImageContext();
          self.canvas.drawView.image = nil;
          UIGraphicsEndImageContext();
      }
  }
  
}

-(void)drawLineFrom:(CGPoint)startPoint to:(CGPoint)endPoint {

    // 1
    UIGraphicsBeginImageContext(self.canvas.drawView.frame.size);
//    let context = UIGraphicsGetCurrentContext()
    [self.canvas.drawView.image drawInRect:CGRectMake(self.canvas.drawView.frame.origin.x,self.canvas.drawView.frame.origin.y, self.canvas.drawView.frame.size.width, self.canvas.drawView.frame.size.height)];
    
    // 2
    CGPoint mid1 = [self midPoint:startPoint and:endPoint];
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), startPoint.x, startPoint.y);
    CGContextAddQuadCurveToPoint(UIGraphicsGetCurrentContext(), startPoint.x, startPoint.y, mid1.x, mid1.y);
    CGContextAddQuadCurveToPoint(UIGraphicsGetCurrentContext(), mid1.x, mid1.y, endPoint.x, endPoint.y);
    // 3
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
    
    // 4
   CGContextStrokePath(UIGraphicsGetCurrentContext());
    
    // 5
    self.canvas.drawView.image = UIGraphicsGetImageFromCurrentImageContext();
    if (!self.canvas.isEraser) {
    [self.canvas.drawView setAlpha:self.canvas.opacity];
    }
    UIGraphicsEndImageContext();
}


-(CGPoint) midPoint:(CGPoint) p1 and:(CGPoint) p2
{
    
    return CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
    
}

- (void)drawPoint:(UITapGestureRecognizer *)recognizer{
    CGPoint point = [recognizer locationOfTouch:0 inView:self.canvas.drawView];
    [self drawLineFrom:point to:point];
    UIGraphicsBeginImageContext(self.canvas.saveView.frame.size);
    [self.canvas.saveView.image drawInRect:CGRectMake(self.canvas.drawView.frame.origin.x,self.canvas.drawView.frame.origin.y, self.canvas.saveView.frame.size.width, self.canvas.saveView.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
    if (self.canvas.isEraser) {
        [self.canvas.drawView.image drawInRect:CGRectMake(self.canvas.drawView.frame.origin.x,self.canvas.drawView.frame.origin.y, self.canvas.drawView.frame.size.width, self.canvas.drawView.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0f];
    } else {
        [self.canvas.drawView.image drawInRect:CGRectMake(self.canvas.drawView.frame.origin.x,self.canvas.drawView.frame.origin.y, self.canvas.drawView.frame.size.width, self.canvas.drawView.frame.size.height) blendMode:kCGBlendModeNormal alpha:self.canvas.opacity];
    }
    
    //UNDO-Manager
    UndoManager* manager = [self.canvas getUndoManager];
    [manager setImage:self.canvas.saveView.image];
    self.canvas.saveView.image = UIGraphicsGetImageFromCurrentImageContext();
    self.canvas.drawView.image = nil;
    UIGraphicsEndImageContext();

}

@end
