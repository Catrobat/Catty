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

#import "LineTool.h"

@implementation LineTool

-(id) initWithDrawViewCanvas:(PaintViewController *)canvas
{
  self = [super init];
  if(self)
  {
    self.canvas = canvas;
  }
  return self;
}

-(void)drawLine:(UIPanGestureRecognizer *)recognizer
{
  if (recognizer.state == UIGestureRecognizerStateBegan){
    
    //    if (enabled) {
    fingerSwiped = NO;
    lastPoint = [recognizer locationOfTouch:0 inView:self.canvas.drawView];
    //    }
    
  }else if (recognizer.state == UIGestureRecognizerStateChanged){
    fingerSwiped = YES;
    CGPoint currentPoint = [recognizer locationOfTouch:0 inView:self.canvas.drawView];
    [self shapeMoved:currentPoint];
  }else if (recognizer.state == UIGestureRecognizerStateEnded){
    [self shapeEnd];
  }
}

-(void)shapeMoved:(CGPoint)currentPoint
  {
        //LINE
        UIGraphicsBeginImageContext(self.canvas.drawView.frame.size);
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
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), self.canvas.red, self.canvas.green, self.canvas.blue, self.canvas.opacity);
        CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        self.canvas.drawView.image = UIGraphicsGetImageFromCurrentImageContext();
        [self.canvas.drawView setAlpha:self.canvas.opacity];
        UIGraphicsEndImageContext();
  }
  
  -(void)shapeEnd
  {
    UIGraphicsBeginImageContext(self.canvas.saveView.frame.size);
    [self.canvas.saveView.image drawInRect:CGRectMake(0, 0, self.canvas.saveView.frame.size.width, self.canvas.saveView.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
    [self.canvas.drawView.image drawInRect:CGRectMake(0, 0, self.canvas.drawView.frame.size.width, self.canvas.drawView.frame.size.height) blendMode:kCGBlendModeNormal alpha:self.canvas.opacity];
    //UNDO-Manager
    [[self.canvas getUndoManager] setImage:self.canvas.saveView.image];
    self.canvas.saveView.image = UIGraphicsGetImageFromCurrentImageContext();
    self.canvas.drawView.image = nil;
    UIGraphicsEndImageContext();
  }
  

@end
