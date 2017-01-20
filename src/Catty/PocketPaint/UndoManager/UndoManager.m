/**
 *  Copyright (C) 2010-2017 The Catrobat Team
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

#import "UndoManager.h"

#define kMaxAllowedUndos 10
@implementation UndoManager

- (id) initWithDrawViewCanvas:(PaintViewController *)canvas
{
  self = [super init];
  if(self)
  {
    self.canvas = canvas;
    self.canvas.undo.enabled = NO;
    self.canvas.redo.enabled = NO;
    self.levelsOfUndo = kMaxAllowedUndos;
  }
  return self;
}

- (void)setImage:(UIImage*)image
{
    if ([self.canvas.saveView.image isEqual:image]) {
        // Here we let know the undo managed what image was used before 
        [[self prepareWithInvocationTarget:self] setImage:(CIImage*)self.canvas.saveView.image];
        
        // post notifications to update UI
    } else {
        [[self prepareWithInvocationTarget:self] setImage:(CIImage*)self.canvas.saveView.image];
        //    self.canvas.helper.frame = CGRectMake(self.canvas.helper.frame.origin.x,self.canvas.helper.frame.origin.y, image.size.width, image.size.height);
        //    self.canvas.saveView.frame = CGRectMake(self.canvas.saveView.frame.origin.x, self.canvas.saveView.frame.origin.y, image.size.width, image.size.height);
        //    self.canvas.drawView.frame = CGRectMake(self.canvas.drawView.frame.origin.x, self.canvas.drawView.frame.origin.y, image.size.width, image.size.height);
        self.canvas.saveView.image = image;
        [self.canvas.saveView setNeedsDisplay];
    }
    [self updateUndoToolBarItems];
}

- (void)updateUndoToolBarItems
{
  if (!self.canvas.undoManager.canUndo) {
    self.canvas.undo.enabled = NO;
  } else{
    self.canvas.undo.enabled = YES;
  }
  if (!self.canvas.undoManager.canRedo) {
    self.canvas.redo.enabled = NO;
  } else{
    self.canvas.redo.enabled = YES;
  }

}

@end
