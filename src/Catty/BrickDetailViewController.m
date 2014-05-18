/**
 *  Copyright (C) 2010-2013 The Catrobat Team
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
#import "BroadcastScriptCell.h"
#import "IBActionSheet.h"
#import "CellMotionEffect.h"

@interface BrickDetailViewController () <IBActionSheetDelegate>
@property (strong, nonatomic) UITapGestureRecognizer *recognizer;
@property (strong, nonatomic) IBActionSheet *brickMenu;
@property (strong, nonatomic) NSNumber *deleteBrickOrScriptFlag;
@property (strong, nonatomic) NSNumber *brickCopyFlag;
@property (strong, nonatomic) NSString *brickName;
@property (strong, nonatomic) UIMotionEffectGroup *motionEffects;
@end

@implementation BrickDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.clearColor;
    self.deleteBrickOrScriptFlag = [[NSNumber alloc]initWithBool:NO];
    self.brickCopyFlag = [[NSNumber alloc]initWithBool:NO];
    [CellMotionEffect addMotionEffectForView:self.brickCell withDepthX:0.0f withDepthY:12.0f withMotionEffectGroup:self.motionEffects];
}

#pragma mark - getters
- (IBActionSheet *)brickMenu
{
    if (! _brickMenu) {
        _brickMenu = [[IBActionSheet alloc] initWithTitle:self.brickName
                                                     delegate:self
                                            cancelButtonTitle:kUIActionSheetButtonTitleClose
                                       destructiveButtonTitle:[self deleteMenuItemNameWithBrickCell:self.brickCell]
                                            otherButtonTitles:[self secondMenuItemWithBrickCell:self.brickCell],
                          [self editFormulaMenuItemWithVrickCell:self.brickCell], nil];
        [_brickMenu setButtonBackgroundColor:UIColor.menuDarkBlueColor];
        [_brickMenu setButtonTextColor:UIColor.lightOrangeColor];
        [_brickMenu setTitleTextColor:UIColor.skyBlueColor];
        [_brickMenu setButtonTextColor:UIColor.redColor forButtonAtIndex:0];
        _brickMenu.transparentView = nil;
    }
    return _brickMenu;
}

- (NSString *)brickName
{
    if (! _brickMenu) {
        NSString *brickName =  NSStringFromClass(self.brickCell.class);
        if (brickName.length) {
            _brickName = [brickName substringToIndex:brickName.length - 4];
        }
    }
    return _brickName;
}

- (UIMotionEffectGroup *)motionEffects {
    if (!_motionEffects) {
        _motionEffects = [UIMotionEffectGroup new];
    }
    return _motionEffects;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    self.recognizer.numberOfTapsRequired = 1;
    self.recognizer.cancelsTouchesInView = NO;
    [self.view.window addGestureRecognizer:self.recognizer];
    [self.brickMenu showInView:self.view];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [CellMotionEffect removeMotionEffect:self.motionEffects fromView:self.brickCell];
    self.motionEffects = nil;
    if ([self.view.window.gestureRecognizers containsObject:self.recognizer]) {
        [self.view.window removeGestureRecognizer:self.recognizer];
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

#pragma mark - Action Sheet Delegate
- (void)actionSheet:(IBActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0: {
            // delete brick or script
            self.deleteBrickOrScriptFlag = [NSNumber numberWithBool:YES];
            [self dismissBrickDetailViewController];
            break;
        }
            
        case 1: {
            // copy brick or highlight script
            if (! [self isScript:self.brickCell]) {
                self.brickCopyFlag = [NSNumber numberWithBool:YES];
                [self dismissBrickDetailViewController];
            } else {
                // TDOD highlight script
            }
            break;
        }
            
        case 2: {
            // edit formula or cancel if script
            if ([self isScript:self.brickCell] ) {
                [self dismissBrickDetailViewController];
            } else {
                // TODO edit formula mode
            }
            break;
        }
            
        case 3: {
            // cancel button
            [self dismissBrickDetailViewController];
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - helper methods
- (void)dismissBrickDetailViewController
{
    if (! self.presentingViewController.isBeingDismissed) {
        [self.brickMenu dismissWithClickedButtonIndex:-1 animated:YES];
        [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
            [NSNotificationCenter.defaultCenter postNotificationName:kBrickDetailViewDismissed
                                                              object:NULL
                                                            userInfo:@{@"brickDeleted": self.deleteBrickOrScriptFlag,
                                                                       @"isScript": @([self isScript:self.brickCell]),
                                                                       @"copy": self.brickCopyFlag,
                                                                       @"copiedCell": self.brickCell }];
        }];
    }
}

- (NSString *)deleteMenuItemNameWithBrickCell:(BrickCell *)cell
{
    if ([self isScript:cell]) {
        return kUIActionSheetButtonTitleDeleteScript;
    }
    return kUIActionSheetButtonTitleDeleteBrick;
}

- (NSString *)secondMenuItemWithBrickCell:(BrickCell *)cell
{
    if ([self isScript:cell]) {
        return kUIActionSheetButtonTitleHighlightScript;
    }
    return kUIActionSheetButtonTitleCopyBrick;
}

- (NSString *)editFormulaMenuItemWithVrickCell:(BrickCell *)cell
{
    if ([self isScript:cell]) {
        return nil;
    }
    return kUIActionSheetButtonTitleEditFormula;
}

- (BOOL)isScript:(BrickCell *)brickcell
{
    if ([brickcell isKindOfClass:StartScriptCell.class] ||
        [brickcell isKindOfClass:WhenScriptCell.class] ||
        [brickcell isKindOfClass:BroadcastScriptCell.class]) {
        return YES;
    }
    return NO;
}

@end
