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

#import "DrawTool.h"
#import "UndoManager.h"

static const CGFloat kPointMinDistance = 5.0f;
static const CGFloat kPointMinDistanceSquared = kPointMinDistance * kPointMinDistance;

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
          self.canvas.drawView.backgroundColor = self.canvas.saveView.backgroundColor;
      }
      CGPoint point = [recognizer locationOfTouch:0 inView:self.canvas.drawView];
      currentPoint = CGPointMake(-1, -1);
      [self drawLine:point];
  }else if (recognizer.state == UIGestureRecognizerStateChanged){

      CGPoint point = [recognizer locationOfTouch:0 inView:self.canvas.drawView];
      [self drawLine:point];
  }else {
      if (self.canvas.isEraser) {
        //UNDO-Manager
        UndoManager* manager = [self.canvas getUndoManager];
        [manager setImage:self.canvas.saveView.image];
        self.canvas.saveView.image = self.canvas.drawView.image;
        self.canvas.drawView.image = nil;
        self.canvas.drawView.backgroundColor = nil;
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

-(void)drawLine:(CGPoint)startPoint
{
    
    CGFloat dx = startPoint.x - currentPoint.x;
    CGFloat dy = startPoint.y - currentPoint.y;
    if (currentPoint.x == -1 && currentPoint.y == -1){
        beforeLastPoint = startPoint;
        lastPoint = startPoint;
        currentPoint = startPoint;
    } else if ((dx * dx + dy * dy) < kPointMinDistanceSquared) {
        // ... then ignore this movement
        return;
    } else {
        beforeLastPoint = lastPoint;
        lastPoint = currentPoint;
        currentPoint = startPoint;
    }
    
    CGPoint mid1 = [self midPoint:lastPoint and:beforeLastPoint];
    CGPoint mid2 = [self midPoint:currentPoint and:lastPoint];
    
    
    
    // 1
    UIGraphicsBeginImageContext(self.canvas.drawView.frame.size);
//    let context = UIGraphicsGetCurrentContext()
    [self.canvas.drawView.image drawInRect:CGRectMake(self.canvas.drawView.frame.origin.x,self.canvas.drawView.frame.origin.y, self.canvas.drawView.frame.size.width, self.canvas.drawView.frame.size.height)];
    
    // 2

    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), mid1.x, mid1.y);
    CGContextAddQuadCurveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y, mid2.x, mid2.y);

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
    currentPoint = CGPointMake(-1, -1);
    [self drawLine:point];
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
