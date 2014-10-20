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

#import "UndoManager.h"

@implementation UndoManager

-(id) initWithDrawViewCanvas:(PaintViewController *)canvas
{
  self = [super init];
  if(self)
  {
    self.canvas = canvas;
    self.canvas.undo.enabled = NO;
    self.canvas.redo.enabled = NO;
  }
  return self;
}

- (void)setImage:(UIImage*)image
{
  if ([self.canvas.saveView.image isEqual:image])
  {
    [[self prepareWithInvocationTarget:self] setImage:self.canvas.saveView.image]; // Here we let know the undo managed what image was used before
    NSLog(@"log");
    
    // post notifications to update UI
  }else{
    [[self prepareWithInvocationTarget:self] setImage:self.canvas.saveView.image];
    self.canvas.helper.frame = CGRectMake(0,0, image.size.width, image.size.height);
    self.canvas.saveView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    self.canvas.drawView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    self.canvas.saveView.image = image;
  }
  [self updateUndoToolBarItems];
  
}

-(void)updateUndoToolBarItems
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
