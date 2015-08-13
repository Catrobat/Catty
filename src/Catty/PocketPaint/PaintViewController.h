/**
 *  Copyright (C) 2010-2015 The Catrobat Team
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

#import <UIKit/UIKit.h>
#import "BrushPickerViewController.h"
#import "ColorPickerViewController.h"
#import "LooksTableViewController.h"
#import "Util.h"
#import "CatrobatAlertView.h"
#import "LCTableViewPickerControl.h"

@interface PaintViewController : UIViewController  <BrushPickerViewControllerDelegate,ColorPickerViewControllerDelegate,UIGestureRecognizerDelegate,UIScrollViewDelegate,UINavigationControllerDelegate,LCItemPickerDelegate,CatrobatActionSheetDelegate,CatrobatAlertViewDelegate> {
  CGPoint lastPoint;
  BOOL fingerSwiped;
}
@property (nonatomic) CGFloat red;
@property (nonatomic) CGFloat green;
@property (nonatomic) CGFloat blue;
@property (nonatomic) CGFloat opacity;
@property (nonatomic) CGFloat thickness;
@property (nonatomic) enum LineEnding ending;
@property (nonatomic) enum ActionType activeAction;
@property (nonatomic) BOOL vertical;
@property (nonatomic) BOOL horizontal;
@property (nonatomic) NSInteger degrees;


@property(nonatomic)  BOOL isEraser;

@property (strong, nonatomic)  UIImageView *drawView;
@property (strong, nonatomic)  UIImageView *saveView;
@property (nonatomic,strong) UIView *helper;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (nonatomic,strong) UIImage *editingImage;
@property (nonatomic,strong) NSString *editingPath;
@property (nonatomic,strong) UIBarButtonItem* handToolBarButtonItem;
@property (nonatomic,strong) UIBarButtonItem* pointerToolBarButtonItem;
@property (nonatomic,strong) UIBarButtonItem* redo;
@property (nonatomic,strong) UIBarButtonItem* undo;

@property (nonatomic,weak)id<PaintDelegate> delegate;


@property (nonatomic,strong) UIPanGestureRecognizer *drawGesture;
@property (nonatomic,strong) UIPanGestureRecognizer *lineToolGesture;
@property (nonatomic,strong) UITapGestureRecognizer *pipetteRecognizer;



@property (weak, nonatomic) IBOutlet UIButton *colorButton;

- (void)updateToolbar;
- (void)setImagePickerImage:(UIImage*)image;
- (id)getUndoManager;
- (id)getResizeViewManager;
- (id)getPointerTool;
@end
