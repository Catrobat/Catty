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

#import "ResizeViewManager.h"
#import "RGBAHelper.h"
#import "YKImageCropperOverlayView.h"

#define kControlSize 45.0f

@implementation ResizeViewManager

-(id) initWithDrawViewCanvas:(PaintViewController *)canvas andImagePicker:(ImagePicker*)imagePicker
{
  self = [super init];
  if(self)
  {
    self.canvas = canvas;
    self.imagePicker = imagePicker;
    [self initResizeView];
    self.gotImage = NO;
  }
  return self;
}
-(void)initResizeView
{
  self.resizeViewer = [[SPUserResizableView alloc] initWithFrame:CGRectMake(50 , 50, 150 , 150)];
  UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(50 , 50, 150 , 150)];
//  imageView.backgroundColor = [UIColor yellowColor];
  self.resizeViewer.contentView = imageView;
  self.resizeViewer.delegate = self;
  self.resizeViewer.hidden = YES;
  [self.resizeViewer showEditingHandles];
  [self.resizeViewer changeBorderWithColor:[UIColor lightOrangeColor]];
  
  self.rotateView = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotate:)];
  self.rotateView.delegate = self.canvas;
  [self.canvas.view addGestureRecognizer:self.rotateView];
  self.rotateView.enabled = NO;
  
  self.resizeView = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleResize:)];
  self.resizeView.delegate = self.canvas;
  [self.canvas.view addGestureRecognizer:self.resizeView];
  self.resizeView.enabled = NO;
  
  self.takeView =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(takeImage:)];
  self.takeView.delegate = self.canvas;
  [self.resizeViewer addGestureRecognizer:self.takeView];
  self.takeView.enabled = NO;
}


- (void)moveView:(UIPanGestureRecognizer *)recognizer {
  
  CGPoint translation = [recognizer translationInView:self.canvas.helper];
  self.resizeViewer.center = CGPointMake(self.resizeViewer.center.x + translation.x,
                                            self.resizeViewer.center.y + translation.y);
  [recognizer setTranslation:CGPointMake(0, 0) inView:self.canvas.helper];
  
}
- (void)handleRotate:(UIRotationGestureRecognizer *)recognizer {
  
  if (self.canvas.activeAction == stamp) {
    return;
  }
  if([(UIRotationGestureRecognizer*)recognizer state] == UIGestureRecognizerStateEnded) {
    
    self.rotation = 0.0;
    return;
  }
  
  CGFloat rotation = 0.0 - (self.rotation - [recognizer rotation]);
  
  CGAffineTransform currentTransform = self.resizeViewer.transform;
  CGAffineTransform newTransform = CGAffineTransformRotate(currentTransform,rotation);
  
  [self.resizeViewer setTransform:newTransform];
  
  self.rotation = [(UIRotationGestureRecognizer*)recognizer rotation];
  
}

- (void)handleResize:(UIPinchGestureRecognizer *)gestureRecognizer {
//  if([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
//      // Reset the last scale, necessary if there are multiple objects with different scales
//    self.scale = [gestureRecognizer scale];
//  }
//  
//  if ([gestureRecognizer state] == UIGestureRecognizerStateBegan ||
//      [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
//    
//    CGFloat currentScale = [[self.resizeViewer.layer valueForKeyPath:@"transform.scale"] floatValue];
//    
//      // Constants to adjust the max/min values of zoom
//    const CGFloat kMaxScale = 2.0;
//    const CGFloat kMinScale = 1.0;
//    
//    CGFloat newScale = 1 -  (self.scale - [gestureRecognizer scale]);
//    newScale = MIN(newScale, kMaxScale / currentScale);
//    newScale = MAX(newScale, kMinScale / currentScale);
//    CGAffineTransform transform = CGAffineTransformScale([self.resizeViewer transform], newScale, newScale);
//    self.resizeViewer.transform = transform;
//    
//    self.scale = [gestureRecognizer scale];  // Store the previous scale factor for the next pinch gesture call
//  }
}

-(void)updateShape
{
  self.resizeViewer.contentView = nil;
  switch (self.canvas.activeAction) {
    case rectangle:{
      // RECT
      UIGraphicsBeginImageContext(self.resizeViewer.frame.size);
      //      CGContextSetLineWidth(UIGraphicsGetCurrentContext(), thickness);
      CGContextSetRGBFillColor(UIGraphicsGetCurrentContext(), self.canvas.red, self.canvas.green, self.canvas.blue, self.canvas.opacity);
      CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), self.canvas.red, self.canvas.green,self.canvas.blue, self.canvas.opacity);
      CGRect rectangle = CGRectMake(0,
                                    0,
                                    self.resizeViewer.frame.size.width,
                                    self.resizeViewer.frame.size.height);
      CGContextFillRect(UIGraphicsGetCurrentContext(), rectangle);
      CGContextAddRect(UIGraphicsGetCurrentContext(), rectangle);
      CGContextStrokePath(UIGraphicsGetCurrentContext());
      
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
      
      CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
      UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
      UIImageView *imageView =[[UIImageView alloc] initWithImage:image];
      self.resizeViewer.contentView = imageView;
      [self.resizeViewer setAlpha:self.canvas.opacity];
      UIGraphicsEndImageContext();
    }
      
      break;
    case ellipse:{
      // Circle
      UIGraphicsBeginImageContext( self.resizeViewer.frame.size);
      //      CGContextSetLineWidth(UIGraphicsGetCurrentContext(), thickness);
      CGContextSetRGBFillColor(UIGraphicsGetCurrentContext(), self.canvas.red, self.canvas.green, self.canvas.blue, self.canvas.opacity);
      CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), self.canvas.red, self.canvas.green, self.canvas.blue,self.canvas.opacity);
      //      CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), [UIColor colorWithRed:red green:green blue:blue alpha:opacity].CGColor);
      CGRect rectangle = CGRectMake(0,
                                    0,
                                    self.resizeViewer.frame.size.width,
                                    self.resizeViewer.frame.size.height);
      
      
      CGContextFillEllipseInRect(UIGraphicsGetCurrentContext(), rectangle);
      CGContextAddEllipseInRect(UIGraphicsGetCurrentContext(), rectangle);
      CGContextStrokePath(UIGraphicsGetCurrentContext());
      
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
      
      CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
      UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
      UIImageView *imageView =[[UIImageView alloc] initWithImage:image];
      self.resizeViewer.contentView = imageView;
      [self.resizeViewer.contentView setAlpha:self.canvas.opacity];
      UIGraphicsEndImageContext();
      [self.resizeViewer setNeedsDisplay];
    }
      break;
      
    default:
      break;
  }
  
}

-(void)showResizeView
{
  self.resizeViewer.hidden = NO;
  self.takeView.enabled = YES;
  self.rotateView.enabled = YES;
  self.resizeView.enabled = YES;
  for (UIGestureRecognizer *recognizer in [self.canvas.scrollView gestureRecognizers]) {
    recognizer.enabled = NO;
  }
}

-(void)hideResizeView
{
  self.resizeViewer.hidden = YES;
  
  self.takeView.enabled = NO;
  self.rotateView.enabled = NO;
  self.resizeView.enabled = NO;
  
  self.resizeViewer.transform = CGAffineTransformMakeRotation(0);
  self.resizeViewer.frame = CGRectMake(50 , 50, 150 , 150);
  self.resizeViewer.bounds = CGRectMake(0 , 0, 150 , 150);
  
  for (UIGestureRecognizer *recognizer in [self.canvas.scrollView gestureRecognizers]) {
    recognizer.enabled = YES;
  }
}



- (void)takeImage:(UITapGestureRecognizer *)recognizer
{
  
  if (self.canvas.activeAction == stamp) {
    if (!self.gotImage) {
      if (self.canvas.saveView.image != nil) {
        //        [self updateTransform:self.resizeImageView transform:0];
        //        [self updateTransform:self.saveView transform:0];
        CGFloat scale = self.canvas.scrollView.zoomScale;
        CGRect rect = self.resizeViewer.frame;
        rect.origin.x = (rect.origin.x + self.canvas.saveView.frame.origin.x) * scale;
        rect.origin.y = (rect.origin.y + self.canvas.saveView.frame.origin.y) * scale;
        rect.size.width *= scale;
        rect.size.height *= scale;
        
        UIGraphicsBeginImageContext(rect.size);
        //        CGContextRotateCTM(UIGraphicsGetCurrentContext(), -self.rotation);
        //        CGContextClipToRect(UIGraphicsGetCurrentContext(), CGRectMake(0,0, rect.size.width, rect.size.height));
        CGPoint contextCenter = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
        CGContextTranslateCTM(UIGraphicsGetCurrentContext(), contextCenter.x, contextCenter.y);
        
        CGContextTranslateCTM(UIGraphicsGetCurrentContext(), -contextCenter.x, -contextCenter.y);
        //TODO rotate rect -> CGRectMake(-rect.origin.x, -rect.origin.y, self.saveView.image.size.width , self.saveView.image.size.height)
//        self.canvas.saveView.transform = CGAffineTransformMakeRotation(self.rotation);
        CGRect newrect = CGRectApplyAffineTransform(rect,self.resizeViewer.transform);
        [self.canvas.saveView.image drawInRect:CGRectMake(-newrect.origin.x, -newrect.origin.y, self.canvas.saveView.image.size.width , self.canvas.saveView.image.size.height)];
        CGContextRotateCTM(UIGraphicsGetCurrentContext(), self.rotation);
//        CGContextRotateCTM(UIGraphicsGetCurrentContext(), self.rotation);
        UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
//        self.canvas.saveView.transform = CGAffineTransformMakeRotation(0);
        UIGraphicsEndImageContext();
        self.stampImage = img;
        self.resizeViewer.contentView.image = img;
        self.gotImage = YES;
        //        [self updateTransform:self.saveView transform:0];
        //        [self updateTransform:self.resizeImageView transform:-self.rotation];
        return;
        
      }else{
        //TODO: alert image is nil;
      }
    }
  }
  [self.resizeViewer hideEditingHandles];
  self.canvas.saveView.backgroundColor = [UIColor clearColor];
  CGFloat scale = self.canvas.scrollView.zoomScale;
  [self.canvas.scrollView setZoomScale:1.0f];
  UIGraphicsBeginImageContextWithOptions(self.canvas.helper.frame.size, NO, self.canvas.scrollView.zoomScale);
  [self.canvas.helper.layer renderInContext:UIGraphicsGetCurrentContext()];
  UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
  //  UIGraphicsEndImageContext();
  //  CGContextRef context = UIGraphicsGetCurrentContext();
  //
  //  // -renderInContext: renders in the coordinate space of the layer,
  //  // so we must first apply the layer's geometry to the graphics context
  //  CGContextSaveGState(context);
  //  // Center the context around the view's anchor point
  ////  CGContextTranslateCTM(context, [self.helper center].x, [self.helper center].y);
  //  // Apply the view's transform about the anchor point
  //  CGContextConcatCTM(context, [self.helper transform]);
  //  // Offset by the portion of the bounds left of and above the anchor point
  //  CGContextTranslateCTM(context,
  //                        -[self.helper bounds].size.width * [[self.helper layer] anchorPoint].x,
  //                        -[self.helper bounds].size.height * [[self.helper layer] anchorPoint].y);
  //
  //  // Render the layer hierarchy to the current context
  //  [[self.helper layer] renderInContext:context];
  //
  //  // Restore the context
  //  CGContextRestoreGState(context);
  //
  //  // Retrieve the screenshot image
  //  UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
  
  UIGraphicsEndImageContext();
  [self.canvas.scrollView setZoomScale:scale];
  
  //UNDO-Manager
  [[self.canvas getUndoManager] setImage:self.canvas.saveView.image];
  
  self.canvas.saveView.image = img;
  [self showUserAction];
  self.canvas.saveView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg"]];
}

-(void)showUserAction
{
  [self.resizeViewer changeBorderWithColor:[UIColor greenColor]];
  [self.resizeViewer showEditingHandles];
  [NSTimer scheduledTimerWithTimeInterval:0.15f target:self selector:@selector(hideShowUserAction) userInfo:nil repeats:NO];
}

-(void)hideShowUserAction
{
  if (self.canvas.activeAction == stamp) {
//    [self.resizeViewer hideEditingHandles];
  } else{
    [self.resizeViewer showEditingHandles];
  }
  [self.resizeViewer changeBorderWithColor:[UIColor blueColor]];
}



#pragma mark - resize Delegate
- (void)userResizableViewDidBeginEditing:(SPUserResizableView *)userResizableView
{
  
}
- (void)userResizableViewDidEndEditing:(SPUserResizableView *)userResizableView
{
  
}


@end
