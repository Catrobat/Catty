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

#import "PointerTool.h"
#import "UndoManager.h"

@implementation PointerTool
- (id) initWithDrawViewCanvas:(PaintViewController *)canvas
{
  self = [super init];
  if(self)
  {
    self.canvas = canvas;
    [self initPointerView];
  }
  return self;
}

- (void)initPointerView
{
  self.pointerView = [[UIView alloc] initWithFrame:CGRectMake(self.canvas.helper.center.x - 62.5f, self.canvas.helper.center.y - 62.5f, 125 , 125)];
  [self.pointerView setUserInteractionEnabled:YES];
  self.pointerView.backgroundColor = [UIColor clearColor];
  self.pointerView.hidden = YES;
  
  self.moveView = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(drawWithPointer:)];
  self.moveView .delegate = self.canvas;
  [self.canvas.view addGestureRecognizer:self.moveView];
  self.moveView.enabled = NO;
  
  self.colorView = [[UIImageView alloc] initWithFrame:CGRectMake(self.pointerView.center.x , self.pointerView.center.y, 10 , 10)];
  [self.colorView setUserInteractionEnabled:YES];
  self.colorView.backgroundColor = [UIColor clearColor];
  [self updateColorView];
  self.colorView.hidden = YES;
  

  
  
  self.canvas.pointerToolBarButtonItem.tintColor = [UIColor globalTintColor];
  self.drawingEnabled = NO;
  
  
  self.border = [CALayer layer];
  CGRect borderFrame = CGRectMake(0, 0, (self.pointerView.frame.size.width), (self.pointerView.frame.size.height));
  [self.border setBackgroundColor:[[UIColor clearColor] CGColor]];
  [self.border setFrame:borderFrame];
  [self.border setCornerRadius:4];
  [self.border setBorderWidth:4];
  [self.border setBorderColor:[[UIColor blackColor] CGColor]];
  [self.pointerView.layer addSublayer:self.border];
  
  [self makeLineLayer:self.pointerView.layer lineFromPointA:CGPointMake((self.pointerView.frame.size.width /2), 0) toPointB:CGPointMake((self.pointerView.frame.size.width /2), (self.pointerView.frame.size.height))];
  [self makeLineLayer:self.pointerView.layer lineFromPointA:CGPointMake(0, (self.pointerView.frame.size.height/2)) toPointB:CGPointMake((self.pointerView.frame.size.width), (self.pointerView.frame.size.height/2))];
  
  [self.pointerView addSubview:self.colorView];
}

-(void)makeLineLayer:(CALayer *)layer lineFromPointA:(CGPoint)pointA toPointB:(CGPoint)pointB
{
    CAShapeLayer *line = [CAShapeLayer layer];
    UIBezierPath *linePath=[UIBezierPath bezierPath];
    [linePath moveToPoint: pointA];
    [linePath addLineToPoint:pointB];
    line.path=linePath.CGPath;
    line.fillColor = nil;
    line.opacity = 1.0;
    line.strokeColor = [UIColor blackColor].CGColor;
    [layer addSublayer:line];
}

- (void)updateColorView
{
  self.colorView.frame = CGRectMake(0, 0,self.canvas.thickness+2, self.canvas.thickness+2);
  self.colorView.center = CGPointMake(self.pointerView.center.x-self.pointerView.frame.origin.x, self.pointerView.center.y-self.pointerView.frame.origin.y) ;
//  self.colorView.backgroundColor = [UIColor colorWithRed:self.canvas.red green:self.canvas.green blue:self.canvas.blue alpha:self.canvas.opacity];
  UIGraphicsBeginImageContext(self.colorView.frame.size);
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
  CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(),self.canvas.red, self.canvas.green, self.canvas.blue, self.canvas.opacity);
  CGContextMoveToPoint(UIGraphicsGetCurrentContext(),(self.canvas.thickness+2)/2 , (self.canvas.thickness+2)/2);
  CGContextAddLineToPoint(UIGraphicsGetCurrentContext(),(self.canvas.thickness+2)/2, (self.canvas.thickness+2)/2);
  CGContextStrokePath(UIGraphicsGetCurrentContext());
  self.colorView.image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
}


- (void)drawingChangeAction
{
  if (self.drawingEnabled == YES) {
    self.drawingEnabled = NO;
    self.colorView.hidden = YES;
    self.canvas.pointerToolBarButtonItem.tintColor = [UIColor navTintColor];
    
  } else{
    self.drawingEnabled = YES;
    self.colorView.hidden = NO;
    self.canvas.pointerToolBarButtonItem.tintColor = [UIColor whiteColor];
    [self updateColorView];
  }
  
}

- (void)disable
{
  self.drawingEnabled = NO;
  self.pointerView.hidden = YES;
  self.moveView.enabled = NO;
  self.colorView.hidden = YES;
}

- (void)drawWithPointer:(UIPanGestureRecognizer *)recognizer
{
  //Move View
  CGPoint translation = [recognizer translationInView:self.canvas.helper];
  self.pointerView.center = CGPointMake(self.pointerView.center.x + translation.x,
                                            self.pointerView.center.y + translation.y);
  [recognizer setTranslation:CGPointMake(0, 0) inView:self.canvas.helper];
  
  if (self.drawingEnabled) {
    if (recognizer.state == UIGestureRecognizerStateBegan){
      
      //    if (enabled) {
      fingerSwiped = NO;
      lastPoint = CGPointMake(self.pointerView.center.x, self.pointerView.center.y) ;
      //    }
      
    }else if (recognizer.state == UIGestureRecognizerStateChanged){
      //    if (enabled) {
      fingerSwiped = YES;
      CGPoint currentPoint = CGPointMake(self.pointerView.center.x, self.pointerView.center.y);
      UIGraphicsBeginImageContext(self.canvas.drawView.frame.size);
      [self.canvas.drawView.image drawInRect:CGRectMake(self.canvas.drawView.frame.origin.x, self.canvas.drawView.frame.origin.y, self.canvas.drawView.frame.size.width, self.canvas.drawView.frame.size.height)];
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
          [self.canvas.drawView.image drawInRect:CGRectMake(self.canvas.drawView.frame.origin.x, self.canvas.drawView.frame.origin.y, self.canvas.drawView.frame.size.width, self.canvas.drawView.frame.size.height)];
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
          
          [image drawInRect:CGRectMake(self.canvas.drawView.frame.origin.x, self.canvas.drawView.frame.origin.y, self.canvas.drawView.frame.size.width, self.canvas.drawView.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
          [self.canvas.drawView.image drawInRect:CGRectMake(self.canvas.drawView.frame.origin.x, self.canvas.drawView.frame.origin.y, self.canvas.drawView.frame.size.width, self.canvas.drawView.frame.size.height) blendMode:kCGBlendModeClear alpha:1];
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
          [self.canvas.drawView.image drawInRect:CGRectMake(self.canvas.drawView.frame.origin.x, self.canvas.drawView.frame.origin.y, self.canvas.drawView.frame.size.width, self.canvas.drawView.frame.size.height)];
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
        [self.canvas.saveView.image drawInRect:CGRectMake(self.canvas.drawView.frame.origin.x, self.canvas.drawView.frame.origin.y, self.canvas.saveView.frame.size.width, self.canvas.saveView.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
        [self.canvas.drawView.image drawInRect:CGRectMake(self.canvas.drawView.frame.origin.x, self.canvas.drawView.frame.origin.y, self.canvas.drawView.frame.size.width, self.canvas.drawView.frame.size.height) blendMode:kCGBlendModeNormal alpha:self.canvas.opacity];
          //UNDO-Manager
          UndoManager* manager = [self.canvas getUndoManager];
          [manager setImage:self.canvas.saveView.image];
        self.canvas.saveView.image = UIGraphicsGetImageFromCurrentImageContext();
        self.canvas.drawView.image = nil;
        UIGraphicsEndImageContext();
      }
    }

  }
  
}

@end
