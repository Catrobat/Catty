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
#import <SpriteKit/SpriteKit.h>
#import "Program.h"


@protocol SpriteManagerDelegate;

@interface ScenePresenterViewController : UIViewController

@property (nonatomic, strong) Program *program;
@property (strong,nonatomic) UIButton* menuBtn;
@property (nonatomic, weak) UIButton* backButton;

@property (nonatomic, strong) UIView *menuView;
@property (strong,nonatomic) UIButton *menuBackButton;
@property (strong,nonatomic) UIButton *menuContinueButton;
@property (strong,nonatomic) UIButton *menuScreenshotButton;
@property (strong,nonatomic) UIButton *menuRestartButton;
@property (strong,nonatomic) UIButton *menuAxisButton;
@property (strong,nonatomic) UIButton *menuAspectRatioButton;
@property (strong,nonatomic) UILabel *menuBackLabel;
@property (strong,nonatomic) UILabel *menuContinueLabel;
@property (strong,nonatomic) UILabel *menuScreenshotLabel;
@property (strong,nonatomic) UILabel *menuRestartLabel;
@property (strong,nonatomic) UILabel *menuAxisLabel;

- (void)pause;
- (void)resume;

@end
