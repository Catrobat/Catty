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
#import "BrickFormulaProtocol.h"
#import "LanguageTranslationDefines.h"
#import "CatrobatActionSheet.h"
#import "LoopBeginBrick.h"
#import "LoopEndBrick.h"

NS_ENUM(NSInteger, ButtonIndex) {
    kButtonIndexDelete = 0,
    kButtonIndexCopyOrCancel = 1,
    kButtonIndexAnimate = 2,
    kButtonIndexEdit = 3,
    kButtonIndexCancel = 4
};

@interface BrickDetailViewController () <CatrobatActionSheetDelegate>
@property (strong, nonatomic) UITapGestureRecognizer *recognizer;
@property (strong, nonatomic) NSNumber *deleteBrickOrScriptFlag;
@property (strong, nonatomic) NSNumber *brickCopyFlag;
@property (strong, nonatomic) NSNumber *openFormulaEditorFlag;
@property (strong, nonatomic) NSNumber *animationFlag;
@property (strong, nonatomic) CatrobatActionSheet *brickMenu;

@end

@implementation BrickDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.clearColor;
    self.deleteBrickOrScriptFlag = [[NSNumber alloc]initWithBool:NO];
    self.brickCopyFlag = [[NSNumber alloc]initWithBool:NO];
    self.openFormulaEditorFlag = [[NSNumber alloc]initWithBool:NO];
    self.animationFlag = [[NSNumber alloc]initWithBool:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.brickMenu showInView:self.view];
    self.recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    self.recognizer.numberOfTapsRequired = 1;
    self.recognizer.cancelsTouchesInView = NO;
    [self.view.window addGestureRecognizer:self.recognizer];
}

- (void)viewWillDisappear:(BOOL)animated
 {
    if ([self.view.window.gestureRecognizers containsObject:self.recognizer]) {
        [self.view.window removeGestureRecognizer:self.recognizer];
    }
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(brickDetailViewController:viewDidDisappear:withBrickCell:copyBrick:openFormulaEditor:animateBrick:)]) {
        [self.delegate brickDetailViewController:self viewDidDisappear:self.deleteBrickOrScriptFlag.boolValue
                                   withBrickCell:self.brickCell copyBrick:self.brickCopyFlag.boolValue openFormulaEditor:self.openFormulaEditorFlag.boolValue animateBrick:self.animationFlag.boolValue];
    }
}

- (void)handleTap:(UITapGestureRecognizer *)sender
{
    if ([sender isKindOfClass:UITapGestureRecognizer.class]) {
        if (sender.state == UIGestureRecognizerStateEnded) {
            CGPoint location = [sender locationInView:nil];
            if (![self.brickCell pointInside:[self.brickCell convertPoint:location fromView:self.view] withEvent:nil] &&
                ![self.brickMenu pointInside:[self.brickMenu convertPoint:location fromView:self.view] withEvent:nil]) {
                [self dismissBrickDetailViewController];
            } else {
                if (!self.brickMenu.visible) {
                    [self.brickMenu showInView:self.view];
                }
            }
        }
    }
}

#pragma mark - getters
- (CatrobatActionSheet*)brickMenu
{
    if (! _brickMenu) {
      if ([self animateMenuItemWithBrickCell:self.brickCell] && [self editFormulaMenuItemWithBrickCell:self.brickCell]) {
        _brickMenu = [[CatrobatActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:kLocalizedClose
                                         destructiveButtonTitle:[self deleteMenuItemNameWithBrickCell:self.brickCell]
                                              otherButtonTitles:[self secondMenuItemWithBrickCell:self.brickCell],
                      [self animateMenuItemWithBrickCell:self.brickCell],
                      [self editFormulaMenuItemWithBrickCell:self.brickCell], nil];
      } else if ([self animateMenuItemWithBrickCell:self.brickCell]){
        _brickMenu = [[CatrobatActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:kLocalizedClose
                                         destructiveButtonTitle:[self deleteMenuItemNameWithBrickCell:self.brickCell]
                                              otherButtonTitles:[self secondMenuItemWithBrickCell:self.brickCell],
                                                                [self animateMenuItemWithBrickCell:self.brickCell],
                                                                nil];
      } else if ([self editFormulaMenuItemWithBrickCell:self.brickCell]){
        _brickMenu = [[CatrobatActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:kLocalizedClose
                                         destructiveButtonTitle:[self deleteMenuItemNameWithBrickCell:self.brickCell]
                                              otherButtonTitles:[self secondMenuItemWithBrickCell:self.brickCell],
                                                                [self editFormulaMenuItemWithBrickCell:self.brickCell], nil];
      } else{
          _brickMenu = [[CatrobatActionSheet alloc] initWithTitle:nil
                                                         delegate:self
                                                cancelButtonTitle:kLocalizedClose
                                           destructiveButtonTitle:[self deleteMenuItemNameWithBrickCell:self.brickCell]
                                                otherButtonTitles:[self secondMenuItemWithBrickCell:self.brickCell],
                                                                    nil];
      }
      
      
    }
        [_brickMenu setButtonBackgroundColor:[UIColor colorWithWhite:0.0f alpha:0.6f]];
        [_brickMenu setButtonTextColor:[UIColor lightOrangeColor]];
        [_brickMenu setButtonTextColor:[UIColor redColor] forButtonAtIndex:0];

        _brickMenu.transparentView = nil;
    
    return _brickMenu;
}


#pragma mark - Action Sheet Delegate
- (void)actionSheet:(CatrobatActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch ([self getAbsoluteButtonIndex:buttonIndex]) {
        case kButtonIndexDelete: {
            self.deleteBrickOrScriptFlag = [NSNumber numberWithBool:YES];
            [self dismissBrickDetailViewController];
            break;
        }
        case kButtonIndexCopyOrCancel:
            if (! [self.brickCell isScriptBrick]) {
                self.brickCopyFlag = [NSNumber numberWithBool:(! [self.brickCell isScriptBrick])];
            }
            [self dismissBrickDetailViewController];
            break;
        case kButtonIndexAnimate:
            self.animationFlag = [NSNumber numberWithBool:YES];
            [self dismissBrickDetailViewController];
            break;
        case kButtonIndexEdit:
            // formula editor button
            self.openFormulaEditorFlag = [NSNumber numberWithBool:YES];
            [self dismissBrickDetailViewController];
            break;
        case kButtonIndexCancel:
            [self dismissBrickDetailViewController];
            break;
        default:
            break;
    }
}

#pragma mark - helper methods
- (void)dismissBrickDetailViewController
{
    if (! self.presentingViewController.isBeingDismissed) {
        [self.brickMenu dismissWithClickedButtonIndex:-1 animated:YES];
        [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
    }
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
    if ([cell isScriptBrick] || (! [self isFormulaBrick:cell])) {
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

- (bool)isFormulaBrick:(BrickCell*)brickCell
{
    if ([brickCell.scriptOrBrick conformsToProtocol:@protocol(BrickFormulaProtocol)]) {
        return YES;
    }
    return NO;
}

- (NSInteger)getAbsoluteButtonIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case kButtonIndexAnimate:
            if(![self isAnimateableBrick:self.brickCell]) {
                if(![self isFormulaBrick:self.brickCell])
                    return kButtonIndexCancel;
                else
                    return kButtonIndexEdit;
            }
            break;
        case kButtonIndexEdit:
            if(![self isAnimateableBrick:self.brickCell])
                return kButtonIndexCancel;
            if(![self isFormulaBrick:self.brickCell])
                return kButtonIndexCancel;
            break;
        default:
            break;
    }
    
    return buttonIndex;
}

@end
