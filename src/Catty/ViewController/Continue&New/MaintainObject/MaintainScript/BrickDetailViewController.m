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

#import "BrickDetailViewController.h"
#import "UIDefines.h"
#import "Brick.h"
#import "Script.h"
#import "LanguageTranslationDefines.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "StartScript.h"
#import "WhenScript.h"
#import "IfLogicElseBrick.h"
#import "IfLogicEndBrick.h"
#import "ForeverBrick.h"
#import "LoopEndBrick.h"
#import "IfLogicBeginBrick.h"
#import "RepeatBrick.h"
#import "BroadcastScript.h"
#import "LanguageTranslationDefines.h"
#import "CatrobatActionSheet.h"
#import "BrickFormulaProtocol.h"
#import "Util.h"

// Button mapping.
typedef NS_ENUM(NSInteger, EditButtonIndex) {
    kButtonIndexDelete  = 0,
    kButtonIndexCopy    = 1,
    kButtonIndexAnimate = 2,
    kButtonIndexEdit    = 3,
    kButtonIndexCancel  = 4,
};

@interface BrickDetailViewController () <CatrobatActionSheetDelegate>
@property(nonatomic, assign) EditButtonIndex buttonIndex;
@property(strong, nonatomic) CatrobatActionSheet *brickMenu;
@property(strong, nonatomic) id<ScriptProtocol> scriptOrBrick;

@end

@implementation BrickDetailViewController
{
    BrickDetailViewControllerState _tempState;
}

#pragma mark - init
+ (BrickDetailViewController*)brickDetailViewControllerWithScriptOrBrick:(id<ScriptProtocol>)scriptOrBrick
{
    return [[BrickDetailViewController alloc] initWithScriptOrBrick:scriptOrBrick];
}

- (instancetype)initWithScriptOrBrick:(id<ScriptProtocol>)scriptOrBrick
{
    if (self = [super init]) {
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.state = BrickDetailViewControllerStateNone;
        self.scriptOrBrick = scriptOrBrick;
    }
    return self;
}

#pragma mark - UIViewController
- (void)loadView
{
    [super loadView];
    
    UIView *view = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    view.backgroundColor = [UIColor clearColor];
    self.view = view;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setupBrickMenu];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    self.state = _tempState;  // Just update state when self dismissed.
}

#pragma mark - Setters

- (void)setState:(BrickDetailViewControllerState)state
{
    if (state != _state) {
        _state = state;
        id<BrickDetailViewControllerDelegate> delegate = self.delegate;
        if ([delegate respondsToSelector:@selector(brickDetailViewController:didChangeState:)]) {
            [delegate brickDetailViewController:self didChangeState:state];
        }
    }
}

- (void)setBrick:(Brick *)brick
{
    _brick = brick;
    _state = BrickDetailViewControllerStateBrickUpdated;
}

#pragma mark - Action Sheet Delegate
- (void)actionSheet:(CatrobatActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    self.buttonIndex = [self getAbsoluteButtonIndex:buttonIndex];
    switch (self.buttonIndex) {
        case kButtonIndexCancel:
            _tempState = BrickDetailViewControllerStateNone;
            break;
    
        case kButtonIndexDelete: {
            if ([self.brick isKindOfClass:[Script class]])
                _tempState = BrickDetailViewControllerStateDeleteScript;
             else
                _tempState = BrickDetailViewControllerStateDeleteBrick;
        }
            break;
            
        case kButtonIndexCopy:
            if (![self.brick isKindOfClass:[Script class]])
                _tempState = BrickDetailViewControllerStateCopyBrick;
            break;
            
        case kButtonIndexEdit:
            _tempState = BrickDetailViewControllerStateEditFormula;
            break;
            
        case kButtonIndexAnimate:
            _tempState = BrickDetailViewControllerStateAnimateBrick;
            break;
        
        default:
            break;
    }
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - helper methods

- (NSString *)deleteMenuItemWithBrick:(Brick *)brick
{
    NSString *title = nil;
    if ([brick isKindOfClass:IfLogicElseBrick.class] ||
        [brick isKindOfClass:IfLogicEndBrick.class] ||
        [brick isKindOfClass:IfLogicBeginBrick.class]) {
        title = kLocalizedDeleteLogicBrick;
    }
    else if ([brick isKindOfClass:ForeverBrick.class] ||
             [brick isKindOfClass:RepeatBrick.class] ||
             [brick isKindOfClass:LoopEndBrick.class]) {
        title = kLocalizedDeleteLoopBrick;
    } else {
        title = kLocalizedDeleteBrick;
    }
    return title;
}


// TODO: refactor later => use property in brick class for this...
- (BOOL)isAnimateableBrick:(Brick *)brick
{
    if ([brick isKindOfClass:IfLogicElseBrick.class] ||
        [brick isKindOfClass:IfLogicEndBrick.class] ||
        [brick isKindOfClass:ForeverBrick.class] ||
        [brick isKindOfClass:IfLogicBeginBrick.class] ||
        [brick isKindOfClass:RepeatBrick.class]) {
        return YES;
    }
    return NO;
}


- (BOOL)isFormulaBrick:(Brick *)brick
{
    return ([brick conformsToProtocol:@protocol(BrickFormulaProtocol)]);
}

- (NSInteger)getAbsoluteButtonIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case kButtonIndexAnimate:
            if(![self isAnimateableBrick:self.brick]) {
                if(![self isFormulaBrick:self.brick])
                    return kButtonIndexCancel;
                else
                    return kButtonIndexEdit;
            }
            break;
            
        case kButtonIndexEdit:
            if(![self isAnimateableBrick:self.brick] || ![self isFormulaBrick:self.brick])
                return kButtonIndexCancel;
            break;
        
        default:
            break;
    }
    
    return buttonIndex;
}

#pragma mark - Setup

// TODO: move checks for brick type features (animatee, formula) to brick (category).
- (void)setupBrickMenu
{
    CBAssert(self.brick);
    
    NSArray *buttons = nil;
    if ([self isAnimateableBrick:self.brick] && [self isFormulaBrick:self.brick]) {
        buttons = @[
                    kLocalizedCopyBrick,
                    kLocalizedAnimateBricks,
                    kLocalizedEditFormula
                    ];
   
    }
    else if ([self isAnimateableBrick:self.brick]) {
        buttons = @[
                    kLocalizedCopyBrick,
                    kLocalizedAnimateBricks,
                    ];
    }
    else if ([self isFormulaBrick:self.brick]) {
        buttons = @[
                    kLocalizedCopyBrick,
                    kLocalizedEditFormula
                    ];
    } else {
        buttons = @[ kLocalizedCopyBrick ];
    }
    
    NSMutableArray *otherButtons = [NSMutableArray arrayWithArray:buttons];
    BOOL isScript = [self.brick isKindOfClass:[Script class]];
    NSString *destructiveTitle = isScript ? kLocalizedDeleteScript : [self deleteMenuItemWithBrick:self.brick];
    
    self.brickMenu = [[CatrobatActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:kLocalizedClose
                                         destructiveButtonTitle:destructiveTitle
                                              otherButtonTitles:nil];

    for (NSString *title in otherButtons) { [self.brickMenu addButtonWithTitle:title]; }
    
    [self.brickMenu setButtonBackgroundColor:[UIColor colorWithWhite:0.0f alpha:0.6f]];
    [self.brickMenu setButtonTextColor:[UIColor lightOrangeColor]];
    [self.brickMenu setButtonTextColor:[UIColor redColor] forButtonAtIndex:0];
    self.brickMenu.transparentView = nil;
    
    [self.brickMenu showInView:self.view];
}

@end
