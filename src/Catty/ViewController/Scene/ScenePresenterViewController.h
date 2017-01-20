/**
 *  Copyright (C) 2010-2017 The Catrobat Team
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
#import <SpriteKit/SpriteKit.h>
#import "Program.h"


@protocol SpriteManagerDelegate;

@interface ScenePresenterViewController : UIViewController

@property (nonatomic, strong) Program *program;
@property (strong,nonatomic) UIButton* menuBtn;
@property (nonatomic, weak) UIButton* backButton;

@property (nonatomic, strong) UIView *menuView;
@property (weak,nonatomic) IBOutlet UIButton *menuBackButton;
@property (weak,nonatomic) IBOutlet UIButton *menuContinueButton;
@property (weak,nonatomic) IBOutlet UIButton *menuScreenshotButton;
@property (weak,nonatomic) IBOutlet UIButton *menuRestartButton;
@property (weak,nonatomic) IBOutlet UIButton *menuAxisButton;
@property (weak,nonatomic) IBOutlet UIButton *menuAspectRatioButton;
@property (weak,nonatomic) IBOutlet UIButton *menuRecordButton;
@property (weak,nonatomic) IBOutlet UIButton *menuBackLabel;
@property (weak,nonatomic) IBOutlet UIButton *menuContinueLabel;
@property (weak,nonatomic) IBOutlet UIButton *menuScreenshotLabel;
@property (weak,nonatomic) IBOutlet UIButton *menuRestartLabel;
@property (weak,nonatomic) IBOutlet UIButton *menuAxisLabel;
@property (weak,nonatomic) IBOutlet UIButton *menuRecordLabel;

- (void)pauseAction;
- (void)resumeAction;
- (void)connectionLost;

@end
