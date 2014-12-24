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

#import "BrickDetailViewController.h"
#import "UIDefines.h"
#import "Brick.h"
#import "LanguageTranslationDefines.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "StartScriptCell.h"
#import "WhenScriptCell.h"
#import "IfLogicElseBrickCell.h"
#import "IfLogicEndBrickCell.h"
#import "ForeverBrickCell.h"
#import "IfLogicBeginBrickCell.h"
#import "RepeatBrickCell.h"
#import "BroadcastScriptCell.h"
#import "BrickCell.h"
#import "LanguageTranslationDefines.h"
#import "CatrobatActionSheet.h"

// Button mapping.
typedef NS_ENUM(NSInteger, EditButtonIndex) {
    kButtonIndexDelete  = 0,
    kButtonIndexCopy    = 1,
    kButtonIndexEdit    = 2,
    kButtonIndexCancel  = 3,
    kButtonIndexAnimate = 4
};

@interface BrickDetailViewController () <CatrobatActionSheetDelegate>
@property(nonatomic, assign) EditButtonIndex buttonIndex;
@property(strong, nonatomic) UITapGestureRecognizer *recognizer;
@property(strong, nonatomic) CatrobatActionSheet *brickMenu;
@property(strong, nonatomic) BrickCell *brickCell;

@end

@implementation BrickDetailViewController

- (instancetype)initWithBrickCell:(BrickCell *)brickCell {
    if (self = [super init]) {
        _brickCell = brickCell;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupViews];
}

- (void)loadView {
    [super loadView];
    
    UIView *view = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    view.backgroundColor = UIColor.clearColor;
    self.view = view;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.view.window addGestureRecognizer:self.recognizer];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.brickMenu showInView:self.view];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if ([self.view.window.gestureRecognizers containsObject:self.recognizer]) {
        [self.view.window removeGestureRecognizer:self.recognizer];
    }
}

- (void)handleTap:(UITapGestureRecognizer *)sender
{
    if ([sender isKindOfClass:UITapGestureRecognizer.class]) {
        if (sender.state == UIGestureRecognizerStateEnded) {
            CGPoint location = [sender locationInView:nil];
            if ([self.brickCell pointInside:[self.brickCell convertPoint:location fromView:self.view] withEvent:nil]) {
                [self.brickMenu showInView:self.view];
            } else {
                [self dismissBrickDetailViewController];
            }
        }
    }
}

#pragma mark - Private

- (void)setupViews {
    self.recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    self.recognizer.numberOfTapsRequired = 1;
    self.recognizer.cancelsTouchesInView = NO;
}

#pragma mark - getters
- (CatrobatActionSheet*)brickMenu
{
    if (!_brickMenu) {
        if ([self isAnimateableBrick:self.brickCell]) {
            _brickMenu = [[CatrobatActionSheet alloc] initWithTitle:nil
                                                           delegate:self
                                                  cancelButtonTitle:kLocalizedClose
                                             destructiveButtonTitle:[self deleteMenuItemNameWithBrickCell:self.brickCell]
                                                  otherButtonTitles:[self secondMenuItemWithBrickCell:self.brickCell],
                          [self animateMenuItemWithBrickCell:self.brickCell],
                          [self editFormulaMenuItemWithBrickCell:self.brickCell], nil];
        } else {
            _brickMenu = [[CatrobatActionSheet alloc] initWithTitle:nil
                                                           delegate:self
                                                  cancelButtonTitle:kLocalizedClose
                                             destructiveButtonTitle:[self deleteMenuItemNameWithBrickCell:self.brickCell]
                                                  otherButtonTitles:[self secondMenuItemWithBrickCell:self.brickCell],
                                                                    [self editFormulaMenuItemWithBrickCell:self.brickCell], nil];
            
        }
        [_brickMenu setButtonBackgroundColor:[UIColor colorWithWhite:0.0f alpha:0.6f]];
        [_brickMenu setButtonTextColor:[UIColor lightOrangeColor]];
        [_brickMenu setButtonTextColor:[UIColor redColor] forButtonAtIndex:0];
        _brickMenu.transparentView = nil;
    }
    return _brickMenu;
}

#pragma mark - Action Sheet Delegate
- (void)actionSheet:(CatrobatActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    self.buttonIndex = buttonIndex;
    switch (self.buttonIndex) {
        case kButtonIndexDelete: {
            if ([self.delegate respondsToSelector:@selector(brickDetailViewController:didDeleteBrick:)])
                [self.delegate brickDetailViewController:self didDeleteBrick:self.brickCell];
            [self dismissBrickDetailViewController];
        }
            break;
        case kButtonIndexCopy: {
            if (![self.brickCell isScriptBrick])
                if ([self.delegate respondsToSelector:@selector(brickDetailViewController:didCopyBrick:)])
                    [self.delegate brickDetailViewController:self didCopyBrick:self.brickCell];
            [self dismissBrickDetailViewController];
            }
            break;
        case kButtonIndexEdit:
    
            break;
        case kButtonIndexCancel:
            [self dismissBrickDetailViewController];
            break;
        case kButtonIndexAnimate:
    
            break;
    }
}

#pragma mark - helper methods
- (void)dismissBrickDetailViewController
{
    [self.brickMenu dismissWithClickedButtonIndex:-1 animated:YES];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (NSString *)deleteMenuItemNameWithBrickCell:(BrickCell *)cell
{
    if ([cell isScriptBrick]) {
        return kLocalizedDeleteScript;
    }
    return kLocalizedDeleteBrick;
}

- (NSString *)secondMenuItemWithBrickCell:(BrickCell *)cell
{
    if ([cell isScriptBrick]) {
        return nil;
    }
    return kLocalizedCopyBrick;
}

- (NSString *)animateMenuItemWithBrickCell:(BrickCell *)cell
{
    if ([cell isScriptBrick] || (! [self isAnimateableBrick:cell])) {
        return nil;
    }
    return kLocalizedAnimateBricks;
}

- (NSString *)editFormulaMenuItemWithBrickCell:(BrickCell *)cell
{
    if ([cell isScriptBrick]) {
        return nil;
    }
    return kLocalizedEditFormula;
}

// TODO: refactor later => use property in brick class for this...
- (bool)isAnimateableBrick:(BrickCell*)brickCell
{
    if ([brickCell isKindOfClass:IfLogicElseBrickCell.class] ||
        [brickCell isKindOfClass:IfLogicEndBrickCell.class] ||
        [brickCell isKindOfClass:ForeverBrickCell.class] ||
        [brickCell isKindOfClass:IfLogicBeginBrickCell.class] ||
        [brickCell isKindOfClass:RepeatBrickCell.class]) {
        return YES;
    }
    return NO;
}

@end
