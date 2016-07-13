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

#import "PaintViewController.h"
#import "ColorPickerViewController.h"
#import "BrushPickerViewController.h"
#import "YKImageCropperView.h"
#import "LCTableViewPickerControl.h"
#import "UIImage+Rotate.h"
#import "ImageHelper.h"
#import "UIViewController+KNSemiModal.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "Util.h"
#import "LanguageTranslationDefines.h"
#import "QuartzCore/QuartzCore.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import "CatrobatAlertController.h"
#import "ActionSheetAlertViewTags.h"
#import "BDKNotifyHUD.h"

//Helper
#import "RGBAHelper.h"
//Tools
#import "FillTool.h"
#import "DrawTool.h"
#import "LineTool.h"
#import "PipetteTool.h"
#import "MirrorRotationZoomTool.h"
#import "ImagePicker.h"
#import "UndoManager.h"
#import "HandTool.h"
#import "ResizeViewManager.h"
#import "PointerTool.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>


#define kStackSize 5
#define kFillTolerance 70
#define kMaxZoomScale 5.0f
#define kMinZoomScale 0.25f
#define kControlSize 45.0f
@interface PaintViewController ()

@property (nonatomic,strong) NSArray *actionTypeArray;
@property (nonatomic,strong) UIToolbar *toolBar;
@property (nonatomic,strong) YKImageCropperView *cropperView;

//Gestures
@property (nonatomic,strong) UITapGestureRecognizer *fillRecognizer;

@property (nonatomic,strong) UIBarButtonItem* colorBarButtonItem;
@property (nonatomic,strong) NSMutableArray *undoArray;
@property (nonatomic,strong) NSMutableArray *redoArray;

@property (nonatomic,strong) DrawTool* drawTool;
@property (nonatomic,strong) LineTool* lineTool;
@property (nonatomic,strong) PipetteTool* pipetteTool;
@property (nonatomic,strong) FillTool* fillTool;
@property (nonatomic,strong) MirrorRotationZoomTool* mirrorRotationZoomTool;
@property (nonatomic,strong) ImagePicker* imagePicker;
@property (nonatomic,strong) UndoManager* undoManager;
@property (nonatomic,strong) HandTool* handTool;
@property (nonatomic,strong) ResizeViewManager* resizeViewManager;
@property (nonatomic,strong) PointerTool* pointerTool;
@property (nonatomic,strong) UIImageView* currentToolIndicator;

@end

@implementation PaintViewController
@synthesize undoManager = _undomanager;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _red = 0.0/255.0;
    _green = 0.0/255.0;
    _blue = 0.0/255.0;
    _thickness = 10.0;
    _opacity = 1.0;
    //  enabled = YES;
    _isEraser = NO;
    _horizontal = NO;
    _vertical = NO;
    _ending = Round;
    _activeAction = brush;
    _degrees = 0;
    
    self.actionTypeArray = @[@(brush),@(eraser),@(resize),@(pipette),@(mirror),@(image),@(line),@(rectangle),@(ellipse),@(stamp),@(rotate),@(zoom),@(pointer),@(fillTool),@(text)];
    
    [self setupCanvas];
    [self setupTools];
    [self setupGestures];
    [self setupToolbar];
    [self setupZoom];
    [self setupUndoManager];
    [self setupNavigationBar];
    self.colorBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"color"] style:UIBarButtonItemStylePlain target:self action:@selector(colorAction)];
    // disable swipe back gesture
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    [self.view bringSubviewToFront:self.currentToolIndicator];
    [self.view bringSubviewToFront:self.resizeViewManager.resizeViewer];
    
    
    self.text = @"Text";
    self.textFontDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                               [UIFont systemFontOfSize:40], NSFontAttributeName,
                               [NSNumber numberWithFloat:1.0], NSBaselineOffsetAttributeName, nil];
    self.textDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Bold",[NSNumber numberWithBool:NO],@"Italic",[NSNumber numberWithBool:NO],@"Underline",[NSNumber numberWithInteger:40],@"Size",[NSNumber numberWithInteger:0],@"Font", nil];
}


- (void)willMoveToParentViewController:(UIViewController *)parent
{
    if (![parent isEqual:self.parentViewController]) {
        if ([self.delegate respondsToSelector:@selector(addPaintedImage:andPath:)]) {
            UIGraphicsBeginImageContextWithOptions(self.saveView.frame.size, NO, 0.0);
            UIImage *blank = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            NSData *blankdata = UIImagePNGRepresentation(blank);
            NSData *saveViewData = UIImagePNGRepresentation(self.saveView.image);
            if (![blankdata isEqualToData:saveViewData]) {
                //NSData *editingData = UIImagePNGRepresentation(self.editingImage);
                if (self.editingImage != nil && ![self.editingImage isEqual:self.saveView.image]) {
                    [self.delegate showSavePaintImageAlert:self.saveView.image andPath:self.editingPath];
                } else if (self.editingPath == nil) {
                    [self.delegate showSavePaintImageAlert:self.saveView.image andPath:self.editingPath];
                }
            }

        }
        // reenable swipe back gesture
        if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (UIEventSubtypeMotionShake && self.undoManager.canUndo) {
    
        UIAlertController *undoAlert = [UIAlertController alertControllerWithTitle:nil
                                                                           message:kLocalizedUndoDrawingDescription
                                                                           preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:kLocalizedCancel
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction *action) { }];
        [undoAlert addAction:cancelAction];
        
        UIAlertAction *undoAction = [UIAlertAction actionWithTitle:kLocalizedUndo
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction *action) { [self undoAction]; }];
        [undoAlert addAction:undoAction];
        [self presentViewController:undoAlert animated:YES completion:nil];
    }
}



#pragma mark initView

- (void)setupCanvas
{
    NSInteger width = (NSInteger)self.programWidth;
    NSInteger height = (NSInteger)self.programHeight;
    CGRect rect = CGRectMake(0, 0, width, height);
    self.drawView = [[UIImageView alloc] initWithFrame:rect];
    self.saveView = [[UIImageView alloc] initWithFrame:rect];
    self.view.backgroundColor = [UIColor whiteColor];
    self.saveView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg"]];
    
    
    self.helper = [[UIView alloc] initWithFrame:rect];
//    self.saveView.backgroundColor = [UIColor whiteColor];
    //add blank image at the beginning
    if (self.editingImage) {
        UIImage *image = self.editingImage;
        UIGraphicsBeginImageContext(image.size);
        [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
        self.saveView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        self.editingImage = self.saveView.image;
        
        
        NSInteger imageWidth = self.editingImage.size.width;
        NSInteger imageHeight = self.editingImage.size.height;
        self.helper.frame = CGRectMake(0, 0, imageWidth, imageHeight);
        self.drawView.frame = CGRectMake(0, 0, imageWidth, imageHeight);
        self.saveView.frame = CGRectMake(0, 0, imageWidth, imageHeight);
        self.saveView.contentMode = UIViewContentModeScaleAspectFit;
        self.drawView.contentMode = UIViewContentModeScaleAspectFit;

    } else {
        UIGraphicsBeginImageContextWithOptions(self.saveView.frame.size, NO, 0.0);
        UIImage *blank = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        self.saveView.image = blank;
    }
    
    self.editingImage = self.saveView.image;

    [self.helper addSubview:self.saveView];
    [self.helper addSubview:self.drawView];
    self.currentToolIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 30, 30)];
    self.currentToolIndicator.image = [UIImage imageNamed:@"brush"];
    self.currentToolIndicator.alpha = 0.4f;
    self.currentToolIndicator.backgroundColor = [UIColor lightGrayColor];
    self.currentToolIndicator.layer.cornerRadius = 10.0f;
    [self.view addSubview:self.currentToolIndicator];
}

- (void)setupTools
{
    self.drawTool = [[DrawTool alloc] initWithDrawViewCanvas:self];
    self.lineTool = [[LineTool alloc] initWithDrawViewCanvas:self];
    self.pipetteTool = [[PipetteTool alloc] initWithDrawViewCanvas:self];
    self.fillTool = [[FillTool alloc] initWithDrawViewCanvas:self];
    self.mirrorRotationZoomTool = [[MirrorRotationZoomTool alloc] initWithDrawViewCanvas:self];
    self.imagePicker = [[ImagePicker alloc] initWithDrawViewCanvas:self];
    self.resizeViewManager = [[ResizeViewManager alloc] initWithDrawViewCanvas:self andImagePicker:self.imagePicker];
    self.pointerTool = [[PointerTool alloc] initWithDrawViewCanvas:self];
    self.undoManager  = [[UndoManager alloc] initWithDrawViewCanvas:self];
    self.handTool = [[HandTool alloc] initWithDrawViewCanvas:self];
    [self.helper addSubview:self.resizeViewManager.resizeViewer];
    [self.helper addSubview:self.pointerTool.pointerView];
}

- (void)setupGestures
{
    
    self.drawGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self.drawTool action:@selector(draw:)];
    self.drawGesture.delegate = self;
    [self.view addGestureRecognizer:self.drawGesture];
    
    self.drawRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self.drawTool action:@selector(drawPoint:)];
    self.drawRecognizer.delegate = self;
    [self.view addGestureRecognizer:self.drawRecognizer];
    
    self.lineToolGesture  = [[UIPanGestureRecognizer alloc] initWithTarget:self.lineTool action:@selector(drawLine:)];
    self.lineToolGesture.delegate = self;
    [self.view addGestureRecognizer:self.lineToolGesture];
    self.lineToolGesture.enabled = NO;
    
    self.pipetteRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self.pipetteTool action:@selector(pipetteAction:)];
    self.pipetteRecognizer.delegate = self;
    [self.view addGestureRecognizer:self.pipetteRecognizer];
    self.pipetteRecognizer.enabled = NO;
    
    self.fillRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self.fillTool action:@selector(fillAction:)];
    self.fillRecognizer.delegate = self;
    [self.view addGestureRecognizer:self.fillRecognizer];
    self.fillRecognizer.enabled = NO;
    
    
}


- (void)setupZoom
{
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height+[UIApplication sharedApplication].statusBarFrame.size.height)];
    self.scrollView.scrollEnabled = NO;
    self.scrollView.maximumZoomScale = kMaxZoomScale;
    self.scrollView.minimumZoomScale = kMinZoomScale;
    self.scrollView.zoomScale = 1.0f;
    self.scrollView.delegate = self;
    [self.scrollView addSubview:self.helper];
    [self.view addSubview:self.scrollView];
    NSInteger width = self.view.bounds.size.width;
    NSInteger height = (NSInteger)self.view.bounds.size.height+[UIApplication sharedApplication].statusBarFrame.size.height;
    NSInteger imageWidth = self.editingImage.size.width;
    NSInteger imageHeight = self.editingImage.size.height;
    if ((imageWidth >= width) || (imageHeight >= height)) {
        [self.scrollView zoomToRect:CGRectMake(0, 0, imageWidth / 0.8f, imageHeight / 0.8f) animated:NO];
    }
    
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect frameToCenter = self.helper.frame;
    // center horizontally
    frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    // center vertically
    frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2 - 64;
    self.helper.frame = frameToCenter;
}

- (void)setupToolbar
{
    [self.navigationController setToolbarHidden:NO];
    self.navigationController.navigationBar.userInteractionEnabled = YES;
    self.navigationController.toolbar.barStyle = UIBarStyleDefault;
    self.navigationController.toolbar.barTintColor = [UIColor toolBarColor];
    self.navigationController.toolbar.tintColor = [UIColor toolTintColor];
    self.navigationController.toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self updateToolbar];
}

- (void)setupNavigationBar
{
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.tintColor = [UIColor navTintColor];
    self.navigationItem.title = @"Pocket Paint";
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:kLocalizedPaintMenuButtonTitle
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(editAction)];
    self.navigationItem.rightBarButtonItem = editButton;
}

- (void)editAction
{
   
    NSArray *buttonTitles = @[kLocalizedPaintSave,kLocalizedPaintNewCanvas];
    [Util actionSheetWithTitle:kLocalizedPaintSelect delegate:self destructiveButtonTitle:nil otherButtonTitles:buttonTitles tag:kPocketPaintActionSheetTag view:self.navigationController.view];
    
}

- (void)setupUndoManager
{
    self.undoArray = [[NSMutableArray alloc] initWithCapacity:kStackSize];
    self.redoArray = [[NSMutableArray alloc] initWithCapacity:kStackSize];
}

#pragma mark scrollView delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.helper;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGSize boundsSize = scrollView.bounds.size;
    CGRect frameToCenter = self.helper.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
    {
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    }
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
    {
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2 - 64;
    }
    self.helper.frame = frameToCenter;
}

#pragma mark changing tool / toolbarItems

- (void)changeAction
{
    NSInteger height = self.view.frame.size.height * 0.65;
    LCTableViewPickerControl *pickerView = [[LCTableViewPickerControl alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, height) title:kLocalizedPaintPickItem value:self.activeAction items:self.actionTypeArray screenHeight:self.view.frame.size.height+self.navigationController.navigationBar.frame.size.height+[UIApplication sharedApplication].statusBarFrame.size.height navBarOffset:self.navigationController.navigationBar.frame.size.height+[UIApplication sharedApplication].statusBarFrame.size.height];
    pickerView.delegate = self;
    pickerView.height = height;
    self.navigationController.toolbarHidden = YES;
    self.navigationController.navigationBar.userInteractionEnabled = NO;
    pickerView.tag = 0;
    [self setBackAllActions];
    self.drawGesture.enabled = NO;
    self.drawRecognizer.enabled = NO;
    self.lineToolGesture.enabled = NO;
    [self.view addSubview:pickerView];
    self.pipetteRecognizer.enabled = NO;
    [pickerView showInView:self.view];
}

- (void) updateToolbar
{
    UIBarButtonItem* action = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"tools"] style:UIBarButtonItemStylePlain target:self action:@selector(changeAction)];
    self.handToolBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"hand"] style:UIBarButtonItemStylePlain target:self.handTool action:@selector(changeHandToolAction)];
    self.undo = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"undo"] style:UIBarButtonItemStylePlain target:self action:@selector(undoAction)];
    self.redo = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"redo"] style:UIBarButtonItemStylePlain target:self action:@selector(redoAction)];
    [self.undoManager updateUndoToolBarItems];
    
    self.colorBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"color"] style:UIBarButtonItemStylePlain target:self action:@selector(colorAction)];
    self.colorBarButtonItem.tintColor = [UIColor colorWithRed:self.red green:self.green blue:self.blue alpha:self.opacity];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    switch (self.activeAction) {
        case brush:{
            UIBarButtonItem* brushPicker = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"thickness"] style:UIBarButtonItemStylePlain target:self action:@selector(brushAction)];
            self.toolbarItems = [NSArray arrayWithObjects: action,flexibleSpace,self.handToolBarButtonItem ,flexibleSpace,brushPicker,flexibleSpace,self.colorBarButtonItem,flexibleSpace,self.undo,flexibleSpace,self.redo, nil];
        }
            break;
        case eraser:{
            UIBarButtonItem* brushPicker = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"thickness"] style:UIBarButtonItemStylePlain target:self action:@selector(brushAction)];
            self.toolbarItems = [NSArray arrayWithObjects: action,flexibleSpace, self.handToolBarButtonItem ,flexibleSpace,brushPicker,flexibleSpace,self.undo,flexibleSpace,self.redo, nil];
        }
            break;
        case resize:{
            UIBarButtonItem* resize = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"crop_cut"] style:UIBarButtonItemStylePlain target:self action:@selector(resizeAction)];
            self.toolbarItems = [NSArray arrayWithObjects: action,flexibleSpace, self.handToolBarButtonItem ,flexibleSpace,resize,flexibleSpace,self.undo,flexibleSpace,self.redo, nil];
        }
            break;
        case pipette:{
            self.toolbarItems = [NSArray arrayWithObjects: action,flexibleSpace, self.handToolBarButtonItem, flexibleSpace,self.colorBarButtonItem,flexibleSpace,self.undo,flexibleSpace,self.redo, nil];
        }
            break;
        case mirror:{
            UIBarButtonItem* mirrorVertical = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"mirror_vertical"] style:UIBarButtonItemStylePlain target:self.mirrorRotationZoomTool action:@selector(mirrorVerticalAction)];
            UIBarButtonItem* mirrorHorizontal = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"mirror_horizontal"] style:UIBarButtonItemStylePlain target:self.mirrorRotationZoomTool action:@selector(mirrorHorizontalAction)];
            self.toolbarItems = [NSArray arrayWithObjects: action,flexibleSpace, self.handToolBarButtonItem ,flexibleSpace,mirrorVertical,flexibleSpace,mirrorHorizontal,flexibleSpace,self.undo,flexibleSpace,self.redo, nil];
        }
            break;
        case image:{
            UIBarButtonItem* camera = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self.imagePicker action:@selector(cameraImagePickerAction)];
            UIBarButtonItem* cameraRoll = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"image_select"] style:UIBarButtonItemStylePlain target:self.imagePicker action:@selector(imagePickerAction)];
            self.toolbarItems = [NSArray arrayWithObjects: action,flexibleSpace, self.handToolBarButtonItem , flexibleSpace,camera, flexibleSpace,cameraRoll,flexibleSpace,self.undo,flexibleSpace,self.redo, nil];
        }
            break;
        case line:{
            UIBarButtonItem* brushPicker = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"thickness"] style:UIBarButtonItemStylePlain target:self action:@selector(brushAction)];
            self.toolbarItems = [NSArray arrayWithObjects: action,flexibleSpace, self.handToolBarButtonItem ,flexibleSpace,brushPicker, flexibleSpace,self.colorBarButtonItem,flexibleSpace,self.undo,flexibleSpace,self.redo, nil];
        }
            break;
        case ellipse:
        case rectangle:
        {
            self.toolbarItems = [NSArray arrayWithObjects: action, flexibleSpace,self.handToolBarButtonItem ,flexibleSpace,self.colorBarButtonItem,flexibleSpace,self.undo,flexibleSpace,self.redo, nil];
        }
            break;
        case text:
        {
            UIBarButtonItem* textChanger = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"text"] style:UIBarButtonItemStylePlain target:self action:@selector(textAction)];
            self.toolbarItems = [NSArray arrayWithObjects: action, flexibleSpace,self.handToolBarButtonItem ,flexibleSpace,self.colorBarButtonItem,flexibleSpace,textChanger,flexibleSpace,self.undo,flexibleSpace,self.redo, nil];
        }
            break;
        
        case stamp:
        {
            UIBarButtonItem* newStamp = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"stamp"] style:UIBarButtonItemStylePlain target:self action:@selector(stampAction)];
            self.toolbarItems = [NSArray arrayWithObjects: action, flexibleSpace,self.handToolBarButtonItem ,flexibleSpace,newStamp,flexibleSpace,self.undo,flexibleSpace,self.redo, nil];
        }
            break;
        case rotate:{
            UIBarButtonItem*rotateR = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"rotate_right"] style:UIBarButtonItemStylePlain target:self.mirrorRotationZoomTool action:@selector(rotateRight)];
            UIBarButtonItem*rotateL = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"rotate_left"] style:UIBarButtonItemStylePlain target:self.mirrorRotationZoomTool action:@selector(rotateLeft)];
            self.toolbarItems = [NSArray arrayWithObjects: action,flexibleSpace, self.handToolBarButtonItem ,flexibleSpace,rotateL,flexibleSpace,rotateR,flexibleSpace,self.undo,flexibleSpace,self.redo, nil];
        }
            break;
        case zoom:{
            UIBarButtonItem* zoomIn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"zoom_in"] style:UIBarButtonItemStylePlain target:self.mirrorRotationZoomTool action:@selector(zoomIn)];
            UIBarButtonItem* zoomOut = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"zoom_out"] style:UIBarButtonItemStylePlain target:self.mirrorRotationZoomTool action:@selector(zoomOut)];
            self.toolbarItems = [NSArray arrayWithObjects: action, flexibleSpace,self.handToolBarButtonItem ,flexibleSpace,zoomIn,flexibleSpace,zoomOut,flexibleSpace,self.undo,flexibleSpace,self.redo, nil];
        }
            break;
        case fillTool:{
            self.toolbarItems = [NSArray arrayWithObjects: action,flexibleSpace, self.handToolBarButtonItem ,flexibleSpace,self.colorBarButtonItem,flexibleSpace,self.undo,flexibleSpace,self.redo, nil];
        }
            break;
        case pointer:{
            UIBarButtonItem* brushPicker = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"thickness"] style:UIBarButtonItemStylePlain target:self action:@selector(brushAction)];
            self.pointerToolBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"pointer"] style:UIBarButtonItemStylePlain target:self.pointerTool action:@selector(drawingChangeAction)];
            self.toolbarItems = [NSArray arrayWithObjects: action, flexibleSpace,self.handToolBarButtonItem ,flexibleSpace,brushPicker,flexibleSpace,self.colorBarButtonItem,flexibleSpace,self.pointerToolBarButtonItem,flexibleSpace,self.undo,flexibleSpace,self.redo, nil];
        }
            break;
        default:
            break;
    }
    self.navigationController.toolbarHidden = NO;
     self.navigationController.navigationBar.userInteractionEnabled = YES;
}

- (void)setBackAllActions
{
    if (self.activeAction == resize){
        return;
    }
    self.isEraser = NO;
    self.resizeViewManager.gotImage = NO;
    self.saveView.hidden = NO;
    
    self.drawGesture.enabled = NO;
    self.drawRecognizer.enabled = NO;
    self.lineToolGesture.enabled = NO;
    self.pipetteRecognizer.enabled = NO;
    self.fillRecognizer.enabled = NO;
    
    [self.handTool disableHandTool];
    self.pointerToolBarButtonItem.tintColor = [UIColor globalTintColor];
    if (self.resizeViewManager.resizeViewer.hidden == NO) {
        [self.resizeViewManager hideResizeView];
    }
    if (self.pointerTool.pointerView.hidden == NO) {
        [self.pointerTool disable];
    }
    if (self.cropperView) {
        [self.cropperView removeFromSuperview];
        self.cropperView = nil;
        [self.navigationController setNavigationBarHidden:NO animated:NO];
        self.drawView.hidden = NO;
        self.saveView.hidden = NO;
        self.helper.hidden = NO;
        //    enabled = YES;
        for (UIGestureRecognizer *recognizer in [self.scrollView gestureRecognizers]) {
            recognizer.enabled = YES;
        }
    }
}

- (void)updateActiveAction:(id)item
{
    self.activeAction = [item intValue];
    [self setBackAllActions];
    
    switch (self.activeAction) {
        case brush:
            self.drawGesture.enabled = YES;
            self.drawRecognizer.enabled = YES;
            self.currentToolIndicator.image = [UIImage imageNamed:@"brush"];
            break;
        case eraser:
            [self eraserAction];
            self.currentToolIndicator.image = [UIImage imageNamed:@"eraser"];
            break;
        case resize:
            [self resizeInitAction];
//            self.currentToolIndicator.image = [UIImage imageNamed:@"crop"];
            break;
        case pipette:
            [self initPipette];
            self.currentToolIndicator.image = [UIImage imageNamed:@"pipette"];
            break;
        case mirror:
            self.currentToolIndicator.image = [UIImage imageNamed:@"mirror"];
            break;
        case image:
            self.currentToolIndicator.image = [UIImage imageNamed:@"image_select"];
            break;
        case stamp:
            [self initStamp];
            [self.resizeViewManager showResizeView];
            self.currentToolIndicator.image = [UIImage imageNamed:@"stamp"];
            break;
        case line:
            self.lineToolGesture.enabled = YES;
            self.currentToolIndicator.image = [UIImage imageNamed:@"line"];
            break;
        case rectangle:
            self.currentToolIndicator.image = [UIImage imageNamed:@"rect"];
            [self.resizeViewManager showResizeView];
            [self initShape];
            break;
        case ellipse:
            self.currentToolIndicator.image = [UIImage imageNamed:@"circle"];
            [self.resizeViewManager showResizeView];
            [self initShape];
            break;
        case text:
            self.currentToolIndicator.image = [UIImage imageNamed:@"text"];
            [self.resizeViewManager showResizeView];
            [self initShape];
            break;
        case rotate:
            self.currentToolIndicator.image = [UIImage imageNamed:@"rotate"];
            break;
        case fillTool:
            [self initFillTool];
            self.currentToolIndicator.image = [UIImage imageNamed:@"fill"];
            break;
        case pointer:
            [self initPointerTool];
            self.currentToolIndicator.image = [UIImage imageNamed:@"pointer"];
            break;
        case zoom:
            self.currentToolIndicator.image = [UIImage imageNamed:@"zoom"];
            break;
        default:
            break;
    }
    
}

#pragma mark undo/redo

- (void)undoAction
{
    
    if (self.undoManager.canUndo) {
        [self.undoManager undo];
        //    NSLog(@"undo");
    }else{
    }
    [self.undoManager updateUndoToolBarItems];
    
}
- (void)redoAction
{
    
    if (self.undoManager.canRedo) {
        [self.undoManager redo];
        //     NSLog(@"redo");
    }else{
    }
    [self.undoManager updateUndoToolBarItems];
}

#pragma mark initActions for tools

- (void)eraserAction
{
    self.isEraser = YES;
    self.drawView.image = self.saveView.image;
    self.drawGesture.enabled = YES;
    self.drawRecognizer.enabled = YES;
}

- (void)resizeInitAction
{
    if (self.saveView.image) {
        self.cropperView = [[YKImageCropperView alloc] initWithImage:self.saveView.image andFrame:CGRectMake(0 , 0, self.view.frame.size.width-10, self.view.frame.size.height - 10)];
        [self.view addSubview:self.cropperView];
        self.cropperView.backgroundColor = self.saveView.backgroundColor;
        self.drawView.hidden = YES;
        self.saveView.hidden = YES;
        self.helper.hidden = YES;
        //    enabled = NO;
//        [self.navigationController setNavigationBarHidden:YES animated:YES]; 
        for (UIGestureRecognizer *recognizer in [self.scrollView gestureRecognizers]) {
            recognizer.enabled = NO;
        }
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:kLocalizedInformation message:kLocalizedPaintNoCrop preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:kLocalizedOK style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        }];
        [alert addAction:cancelAction];
        
    
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}

- (void)initPipette
{
    //PipetteAction
    self.pipetteRecognizer.enabled = YES;
}

- (void)initFillTool
{
    self.fillRecognizer.enabled = YES;
}

- (void)initPointerTool
{
    self.pointerTool.drawingEnabled = NO;
    self.pointerTool.pointerView.hidden = NO;
    self.pointerTool.moveView.enabled = YES;
    self.pointerTool.colorView.hidden = YES;
    self.drawView.userInteractionEnabled = YES;
}

- (void)initShape
{
    self.resizeViewManager.resizeViewer.frame = CGRectMake(self.drawView.center.x - 150, self.drawView.center.y - 150, 300, 300);
    self.resizeViewManager.resizeViewer.bounds = CGRectMake(self.resizeViewManager.resizeViewer.bounds.origin.x , self.resizeViewManager.resizeViewer.bounds.origin.y , 300 , 300);
    [self.resizeViewManager updateShape];
}

- (void)initStamp
{
    //  self.resizeViewManager.border.hidden = NO;
    self.resizeViewManager.resizeViewer.frame = CGRectMake(self.drawView.center.x - 75, self.drawView.center.y - 75, 150, 150);
    self.resizeViewManager.resizeViewer.bounds = CGRectMake(self.resizeViewManager.resizeViewer.bounds.origin.x , self.resizeViewManager.resizeViewer.bounds.origin.y , 150 , 150);
    self.resizeViewManager.resizeViewer.contentView.image = nil;
}

#pragma mark tool actions

- (void)resizeAction
{
    if ([self.cropperView superview] == self.view) {
        UIImage* croppedImage = [self.cropperView editedImage];
        self.drawView.image = nil;
        CGSize boundsSize = croppedImage.size;
        self.helper.frame = CGRectMake(0, 0, boundsSize.width*self.scrollView.zoomScale, boundsSize.height*self.scrollView.zoomScale);
        self.saveView.frame =CGRectMake(0, 0, (NSInteger)boundsSize.width, (NSInteger)boundsSize.height);
        self.drawView.frame =CGRectMake(0, 0, (NSInteger)boundsSize.width, (NSInteger)boundsSize.height);
        self.saveView.image = croppedImage;
        self.drawView.image = nil;
        self.drawView.hidden = NO;
        self.saveView.hidden = NO;
        self.helper.hidden = NO;
        //  enabled = YES;
        [self.cropperView removeFromSuperview];
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        for (UIGestureRecognizer *recognizer in [self.scrollView gestureRecognizers]) {
            recognizer.enabled = YES;
        }
        [self.scrollView zoomToRect:CGRectMake(0, 0, croppedImage.size.width, croppedImage.size.height) animated:NO];
    } else {
        [self resizeInitAction];
    }
    
}

- (void)stampAction
{
    self.resizeViewManager.gotImage = NO;
    self.resizeViewManager.resizeViewer.contentView.image = nil;
}


#pragma mark change color/thickness

- (void)colorAction
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
    ColorPickerViewController *cvc = [storyboard instantiateViewControllerWithIdentifier:@"colorPicker"];
    cvc.delegate = self;
    cvc.red = self.red;
    cvc.green = self.green;
    cvc.blue = self.blue;
    cvc.opacity = self.opacity;
    //  self.view.userInteractionEnabled = NO;
    //  enabled = NO;
    [self presentViewController:cvc animated:YES completion:nil];
}

- (void)brushAction
{
    BrushPickerViewController *bvc = [[BrushPickerViewController alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height*0.5, self.view.frame.size.width, self.view.frame.size.height*0.5) andController:self];
    bvc.delegate = self;
    
    [self presentSemiViewController:bvc];
}


#pragma mark change text

-(void)textAction
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
    TextInputViewController *tvc = [storyboard instantiateViewControllerWithIdentifier:@"textInputPicker"];
    tvc.delegate = self;
    tvc.text = self.text;
    tvc.fontDictionary = self.textFontDictionary;
    NSNumber *number = [self.textDictionary objectForKey:@"Bold"];
    tvc.bold  = number.boolValue;
    number = [self.textDictionary objectForKey:@"Italic"];
    tvc.italic  = number.boolValue;
    number = [self.textDictionary objectForKey:@"Underline"];
    tvc.underline  = number.boolValue;
    number = [self.textDictionary objectForKey:@"Size"];
    tvc.fontSize  = number.integerValue;
    number = [self.textDictionary objectForKey:@"Font"];
    tvc.fontType  = number.integerValue;
    
    //  self.view.userInteractionEnabled = NO;
    //  enabled = NO;
    [self presentViewController:tvc animated:YES completion:nil];
}


#pragma mark tool helpers

- (void)setImagePickerImage:(UIImage*)image
{
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    
    self.resizeViewManager.scale = 150.0f / width;
    height = height * self.resizeViewManager.scale;
    width = width * self.resizeViewManager.scale;
    image = [RGBAHelper resizeImage:image withWidth:(int)width withHeight:(int)height];
    //  self.resizeViewManager.border.frame = CGRectMake(0, 0,
    //                                 (int)width,
    //                                 (int)height);
    self.resizeViewManager.resizeViewer.frame = CGRectMake(self.resizeViewManager.resizeViewer.frame.origin.x, self.resizeViewManager.resizeViewer.frame.origin.y,
                                                            (int)width,
                                                            (int)height);
    
    self.resizeViewManager.resizeViewer.contentView.image = image;
    self.resizeViewManager.resizeViewer.contentMode = UIViewContentModeTop;
    [self.resizeViewManager showResizeView];
}
#pragma mark actionPicker delegate

- (void)dismissPickerControl:(LCTableViewPickerControl*)view
{
    [view dismiss];
}

- (void)selectControl:(LCTableViewPickerControl*)view didSelectWithItem:(id)item
{
    /*
     Check item is NSString or NSNumber , if it is necessary
     */
    if (view.tag == 0)
    {
        [self updateActiveAction:item];
        [self updateToolbar];
    }
    
    [self dismissPickerControl:view];
}

- (void)selectControl:(LCTableViewPickerControl *)view didCancelWithItem:(id)item
{
    [self updateActiveAction:item];
    [self updateToolbar];
    [self dismissPickerControl:view];
}

#pragma mark brush/color delegate

- (void)closeBrushPicker:(id)sender
{
    self.thickness = ((BrushPickerViewController*)sender).brush;
    self.ending = ((BrushPickerViewController*)sender).brushEnding;
    //  self.view.userInteractionEnabled = YES;
    //  enabled = YES;
    if (self.activeAction == pointer) {
        [self.pointerTool updateColorView];
    }
    [self dismissSemiModalView];
}

- (void)closeColorPicker:(id)sender
{
    self.red =((ColorPickerViewController*)sender).red;
    self.green =((ColorPickerViewController*)sender).green;
    self.blue =((ColorPickerViewController*)sender).blue;
    self.opacity =((ColorPickerViewController*)sender).opacity;
    //  self.view.userInteractionEnabled = YES;
    [self updateToolbar];
    //  enabled = YES;
    if (self.activeAction == rectangle || self.activeAction == ellipse || self.activeAction == text) {
        [self.resizeViewManager updateShape];
    }
    if (self.activeAction == pointer) {
        [self.pointerTool updateColorView];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark textPickerDelegate

- (void)closeTextInput:(id)sender andDictionary:(NSDictionary *)dict
{
    if (dict) {
        self.textDictionary = dict;
        self.text = ((TextInputViewController*)sender).text;
        self.textFontDictionary = ((TextInputViewController*)sender).fontDictionary;
        [self.resizeViewManager updateShape];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark actionSheetActions

- (void)saveAction
{
    PHAuthorizationStatus statusCameraRoll = [PHPhotoLibrary authorizationStatus];
    UIAlertController *alertControllerCameraRoll = [UIAlertController
                                                    alertControllerWithTitle:nil
                                                    message:kLocalizedNoAccesToImagesCheckSettingsDescription
                                                    preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:kLocalizedCancel
                                   style:UIAlertActionStyleCancel
                                   handler:nil];
    
    UIAlertAction *settingsAction = [UIAlertAction
                                     actionWithTitle:kLocalizedSettings
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction *action)
                                     {
                                         if ([self.delegate respondsToSelector:@selector(addPaintedImage:andPath:)]) {
                                             if (self.editingPath) {
                                                 [self.delegate addPaintedImage:self.saveView.image andPath:self.editingPath];
                                             } else {
                                                 [self.delegate addPaintedImage:self.saveView.image andPath:@"settings"];
                                             }
                                         }
                                         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                     }];
    
    [alertControllerCameraRoll addAction:cancelAction];
    [alertControllerCameraRoll addAction:settingsAction];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if([self checkUserAuthorisation])
        {
            if (statusCameraRoll == PHAuthorizationStatusAuthorized) {
                UIImageWriteToSavedPhotosAlbum(self.saveView.image, nil, nil, nil);
                dispatch_async(dispatch_get_main_queue(), ^{
                   [self showSavedView];
                });
            }else
            {
                [self presentViewController:alertControllerCameraRoll animated:YES completion:nil];
            }
        }
    });

    NSDebug(@"saved to Camera Roll");
}

- (void)showSavedView
{
    BDKNotifyHUD *hud = [BDKNotifyHUD notifyHUDWithImage:[UIImage imageNamed:kBDKNotifyHUDCheckmarkImageName]
                                                    text:kLocalizedSaved];
    hud.destinationOpacity = kBDKNotifyHUDDestinationOpacity;
    hud.center = CGPointMake(self.view.center.x, self.view.center.y + kBDKNotifyHUDCenterOffsetY);
    [self.view addSubview:hud];
    [hud presentWithDuration:kBDKNotifyHUDPresentationDuration
                       speed:kBDKNotifyHUDPresentationSpeed
                      inView:self.view
                  completion:^{ [hud removeFromSuperview]; }];
}


- (void)newCanvasAction
{
   
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:kLocalizedPaintNewCanvas message:kLocalizedPaintAskNewCanvas preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:kLocalizedYes style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UIGraphicsBeginImageContextWithOptions(self.saveView.frame.size, NO, 0.0);
        UIImage *blank = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        self.saveView.image = blank;
        self.editingImage = blank;
    }];
    
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:kLocalizedNo style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    
        // Add actions to the controller so they will appear
    [alert addAction:yesAction];
    [alert addAction:noAction];
    
     [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark Getter

- (id)getUndoManager
{
    return self.undoManager;
}

- (id)getResizeViewManager
{
    return self.resizeViewManager;
}

- (id)getPointerTool
{
    return self.pointerTool;
}

#pragma mark - gestureRecognizer Delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
        return NO;
    } else if ([otherGestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
        return NO;
    }
    
    return YES;
}

#pragma mark - statusBar Delegate
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}



#pragma mark dealloc

- (void)dealloc
{
    self.fillTool = nil;
    self.fillRecognizer = nil;
    NSLog(@"dealloc");
}

- (BOOL)checkUserAuthorisation
{
    BOOL state = NO;
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined) {
        
        PHFetchOptions *allPhotosOptions = [PHFetchOptions new];
        allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        
        PHFetchResult *allPhotosResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:allPhotosOptions];
        [allPhotosResult enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
            NSDebug(@"asset %@", asset);
            if (*stop) {
//                if ([self.delegate respondsToSelector:@selector(addPaintedImage:andPath:)]) {
//                    UIGraphicsBeginImageContextWithOptions(self.saveView.frame.size, NO, 0.0);
//                    UIImage *blank = UIGraphicsGetImageFromCurrentImageContext();
//                    UIGraphicsEndImageContext();
//                    if (![self.saveView.image isEqual:blank]) {
//                        [self.delegate addPaintedImage:self.saveView.image andPath:self.editingPath];
//                    }
//                }
//                [self.navigationController popViewControllerAnimated:YES];
                return;
            }
            *stop = TRUE;
        }];
    }else{
        state = YES;
    }
    return state;
}

#pragma mark actionsheet delegate

-(void)actionSheet:(CatrobatAlertController *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == kPocketPaintActionSheetTag) {
        switch (buttonIndex) {
            case 1:
                [self saveAction];
                break;
            case 2:
                [self newCanvasAction];
            default:
                break;
        }
    }
}


@end
