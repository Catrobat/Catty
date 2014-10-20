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

#import <Foundation/Foundation.h>
#import "PaintViewController.h"

@interface PointerTool : NSObject{
  BOOL fingerSwiped;
  CGPoint lastPoint;
}
@property (nonatomic,strong) PaintViewController* canvas;
@property (nonatomic,strong) UIView* pointerView;
@property (nonatomic,strong) UIImageView* colorView;
@property (nonatomic,strong) CALayer *border;
@property (nonatomic) BOOL drawingEnabled;

@property (nonatomic,strong) UIPanGestureRecognizer *moveView;

-(void)drawWithPointer:(UIPanGestureRecognizer *)recognizer;
-(id)initWithDrawViewCanvas:(PaintViewController*)canvas;

-(void)drawingChangeAction;
-(void)disable;
-(void)updateColorView;
@end
