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
#import "Script.h"
#import "LanguageTranslationDefines.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "StartScript.h"
#import "WhenScript.h"
#import "IfLogicElseBrick.h"
#import "IfLogicEndBrick.h"
#import "ForeverBrick.h"
#import "IfLogicBeginBrick.h"
#import "RepeatBrick.h"
#import "BroadcastScript.h"
#import "LanguageTranslationDefines.h"
#import "CatrobatActionSheet.h"
#import "BrickFormulaProtocol.h"

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
@property(strong, nonatomic) Brick *brick;

@end

@implementation BrickDetailViewController {
    BrickDetailViewControllerState _tempState;
}

+ (BrickDetailViewController *)brickDetailViewController
{
    return [[self alloc] initWithBrick:nil];
}

- (instancetype)initWithBrick:(Brick *)brick {
    if (self = [super init]) {
        _state = BrickDetailViewControllerStateNone;
        _brick = brick;
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    UIView *view = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    view.backgroundColor = UIColor.clearColor;
    self.view = view;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.brickMenu showInView:self.view];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    self.state = _tempState;  // Just update state when self dismissed.
}

#pragma mark - Setters

- (void)setState:(BrickDetailViewControllerState)state
{
    // Key value observing.
    if (state != _state) {
        _state = state;
    }
}

- (void)setBrick:(Brick *)brick
{
    _brick = brick;
    _state = BrickDetailViewControllerStateBrickUpdated;
}

#pragma mark - Getters

- (CatrobatActionSheet*)brickMenu
{
    if (!_brickMenu) {
        if (! _brickMenu) {
            if ([self animateMenuItemWithBrick:self.brick] && [self editFormulaMenuItemWithBrick:self.brick]) {
                _brickMenu = [[CatrobatActionSheet alloc] initWithTitle:nil
                                                               delegate:self
                                                      cancelButtonTitle:kLocalizedClose
                                                 destructiveButtonTitle:[self deleteMenuItemNameWithBrick:self.brick]
                                                      otherButtonTitles:[self secondMenuItemWithBrick:self.brick],
                                                                        [self animateMenuItemWithBrick:self.brick],
                                                                        [self editFormulaMenuItemWithBrick:self.brick], nil];
            } else if ([self animateMenuItemWithBrick:self.brick]){
                _brickMenu = [[CatrobatActionSheet alloc] initWithTitle:nil
                                                               delegate:self
                                                      cancelButtonTitle:kLocalizedClose
                                                 destructiveButtonTitle:[self deleteMenuItemNameWithBrick:self.brick]
                                                      otherButtonTitles:[self secondMenuItemWithBrick:self.brick],
                                                                        [self animateMenuItemWithBrick:self.brick],
                                                                        nil];
            } else if ([self editFormulaMenuItemWithBrick:self.brick]){
                _brickMenu = [[CatrobatActionSheet alloc] initWithTitle:nil
                                                               delegate:self
                                                      cancelButtonTitle:kLocalizedClose
                                                 destructiveButtonTitle:[self deleteMenuItemNameWithBrick:self.brick]
                                                      otherButtonTitles:[self secondMenuItemWithBrick:self.brick],
                                                                        [self editFormulaMenuItemWithBrick:self.brick], nil];
            } else {
                _brickMenu = [[CatrobatActionSheet alloc] initWithTitle:nil
                                                               delegate:self
                                                      cancelButtonTitle:kLocalizedClose
                                                 destructiveButtonTitle:[self deleteMenuItemNameWithBrick:self.brick]
                                                      otherButtonTitles:[self secondMenuItemWithBrick:self.brick], nil];
            }
            
            
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

- (NSString *)deleteMenuItemNameWithBrick:(Brick *)brick
{
    if ([brick isKindOfClass:[Script class]]) {
        return kLocalizedDeleteScript;
    }
    return kLocalizedDeleteBrick;
}

- (NSString *)secondMenuItemWithBrick:(Brick *)brick
{
    if ([brick isKindOfClass:[Script class]]) {
        return nil;
    }
    return kLocalizedCopyBrick;
}

- (NSString *)animateMenuItemWithBrick:(Brick *)brick
{
    if ([brick isKindOfClass:[Script class]] || (![self isAnimateableBrick:brick])) {
        return nil;
    }
    return kLocalizedAnimateBricks;
}

- (NSString *)editFormulaMenuItemWithBrick:(Brick *)brick
{
    if ([brick isKindOfClass:[Script class]] || (![self isFormulaBrick:brick])) {
        return nil;
    }
    return kLocalizedEditFormula;
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


@end
