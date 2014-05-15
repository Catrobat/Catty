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

@interface BrickDetailViewController () <UIActionSheetDelegate>
@property (strong, nonatomic) UITapGestureRecognizer *recognizer;
@property (strong, nonatomic) UIActionSheet *brickMenu;
@property (strong, nonatomic) NSNumber *deleteBrickOrScriptFlag;
@property (strong, nonatomic) NSNumber *brickCopyFlag;
@end

@implementation BrickDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.clearColor;
    
    self.brickMenu = [[UIActionSheet alloc] initWithTitle:self.brickName
                                                 delegate:self
                                        cancelButtonTitle:kUIActionSheetButtonTitleClose
                                   destructiveButtonTitle:[self deleteMenuItemNameWithBrickCell:self.brickCell]
                                        otherButtonTitles:[self secondMenuItemWithBrickCell:self.brickCell],
                                                          [self editFormulaMenuItemWithVrickCell:self.brickCell], nil];
    self.deleteBrickOrScriptFlag = [[NSNumber alloc]initWithBool:NO];
    self.brickCopyFlag = [[NSNumber alloc]initWithBool:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    self.recognizer.numberOfTapsRequired = 1;
    self.recognizer.cancelsTouchesInView = NO;
    [self.view.window addGestureRecognizer:self.recognizer];
    [self.brickMenu showFromToolbar:self.scriptCollectionViewControllerToolbar];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.self.scriptCollectionViewControllerToolbar.hidden = NO;
    
    if ([self.view.window.gestureRecognizers containsObject:self.recognizer]) {
        [self.view.window removeGestureRecognizer:self.recognizer];
    }
}


- (void)handleTap:(UITapGestureRecognizer *)sender {
    if ([sender isKindOfClass:UITapGestureRecognizer.class]) {
        if (sender.state == UIGestureRecognizerStateEnded) {
            CGPoint location = [sender locationInView:nil];
            if (![self.view pointInside:[self.view convertPoint:location fromView:self.view.window] withEvent:nil]) {
                [self dismissBrickDetailViewController];
            } else {
                [self.brickMenu showFromToolbar:self.scriptCollectionViewControllerToolbar];
            }
        }
    }
}

#pragma mark - Action Sheet Delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: {
            // delete brick or script
            self.deleteBrickOrScriptFlag = [NSNumber numberWithBool:YES];
            [self dismissBrickDetailViewController];
        }
            
        case 1:
            // copy brick or highlight script
            if (![self isScript:self.brickCell]) {
                self.brickCopyFlag = [NSNumber numberWithBool:YES];
                [self dismissBrickDetailViewController];
            }
            break;
            
        case 2:
            // edit formula or cancel if script
            if ([self isScript:self.brickCell] ) {
                [self dismissBrickDetailViewController];
            }
            break;
            
        case 3:
            // cancel button
            [self dismissBrickDetailViewController];
            break;
            
        default:
            break;
    }
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
    if (self.scriptCollectionViewControllerToolbar.hidden) {
        self.scriptCollectionViewControllerToolbar.hidden = NO;
    }
}

- (void)didPresentActionSheet:(UIActionSheet *)actionSheet {
    if (!self.scriptCollectionViewControllerToolbar.hidden) {
        self.scriptCollectionViewControllerToolbar.hidden = YES;
    }
}

#pragma mark - helper methods
- (void)dismissBrickDetailViewController {
    [self dismissViewControllerAnimated:YES completion:^{
        [NSNotificationCenter.defaultCenter postNotificationName:kBrickDetailViewDismissed
                                                          object:NULL
                                                        userInfo:@{@"brickDeleted": self.deleteBrickOrScriptFlag,
                                                                   @"isScript": @([self isScript:self.brickCell]),
                                                                   @"copy": self.brickCopyFlag,
                                                                   @"copiedCell": self.brickCell }];
    }];
}

- (NSString *)deleteMenuItemNameWithBrickCell:(BrickCell *)cell {
    if ([self isScript:cell]) {
        return kUIActionSheetButtonTitleDeleteScript;
    }
    return kUIActionSheetButtonTitleDeleteBrick;
}

- (NSString *)secondMenuItemWithBrickCell:(BrickCell *)cell {
    if ([self isScript:cell]) {
        return kUIActionSheetButtonTitleHighlightScript;
    }
    return kUIActionSheetButtonTitleCopyBrick;
}

- (NSString *)editFormulaMenuItemWithVrickCell:(BrickCell *)cell {
    if ([self isScript:cell]) {
        return nil;
    }
    return kUIActionSheetButtonTitleEditFormula;
}

- (BOOL)isScript:(BrickCell *)brickcell {
    if ([brickcell isKindOfClass:StartScriptCell.class] ||
        [brickcell isKindOfClass:WhenScriptCell.class] ||
        [brickcell isKindOfClass:BroadcastScriptCell.class]) {
        return YES;
    }
    return NO;
}

@end
