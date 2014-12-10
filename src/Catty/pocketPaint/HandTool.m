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

#import "HandTool.h"
#import "ResizeViewManager.h"
#import "PointerTool.h"


@implementation HandTool

-(id) initWithDrawViewCanvas:(PaintViewController *)canvas
{
  self = [super init];
  if(self)
  {
    self.canvas = canvas;
    
  }
  return self;
}


-(void)changeHandToolAction
{
  if (!self.canvas.scrollView.scrollEnabled) {
    self.canvas.drawGesture.enabled = NO;
    self.canvas.pipetteRecognizer.enabled = NO;
    ResizeViewManager *resizeViewManager =(ResizeViewManager*)[self.canvas getResizeViewManager];
    resizeViewManager.rotateView.enabled = NO;
    resizeViewManager.resizeViewer.userInteractionEnabled = NO;
    PointerTool *pointerTool =(PointerTool*)[self.canvas getPointerTool];
    pointerTool.moveView.enabled = NO;
    self.canvas.lineToolGesture.enabled = NO;
    resizeViewManager.resizeView.enabled = NO;
    self.canvas.scrollView.scrollEnabled = YES;
    for (UIGestureRecognizer *recognizer in [self.canvas.scrollView gestureRecognizers]) {
      recognizer.enabled = YES;
    }
    self.canvas.handToolBarButtonItem.tintColor = [UIColor greenColor];
  } else {
    [self disableHandTool];
  }

}

-(void)disableHandTool
{
  self.canvas.handToolBarButtonItem.tintColor = [UIColor lightOrangeColor];
  if (self.canvas.activeAction == brush) {
    self.canvas.drawGesture.enabled = YES;
  } else if (self.canvas.activeAction == pipette){
    self.canvas.pipetteRecognizer.enabled = YES;
  }else if ( self.canvas.activeAction == rectangle || self.canvas.activeAction == image || self.canvas.activeAction == stamp || self.canvas.activeAction == ellipse)
  {
    ResizeViewManager *resizeViewManager =(ResizeViewManager*)[self.canvas getResizeViewManager];
//    resizeViewManager.moveView.enabled = YES;
    resizeViewManager.rotateView.enabled = YES;
    resizeViewManager.resizeView.enabled = YES;
//    resizeViewManager.controlGesture.enabled = YES;
    resizeViewManager.resizeViewer.userInteractionEnabled = YES;
    for (UIGestureRecognizer *recognizer in [self.canvas.scrollView gestureRecognizers]) {
      recognizer.enabled = NO;
    }
  }else if (self.canvas.activeAction == line)
  {
    self.canvas.lineToolGesture.enabled = YES;
  }else if (self.canvas.activeAction == pointer){
    PointerTool *pointerTool =(PointerTool*)[self.canvas getPointerTool];
    pointerTool.moveView.enabled = YES;
  }
  self.canvas.scrollView.scrollEnabled = NO;

}

@end
