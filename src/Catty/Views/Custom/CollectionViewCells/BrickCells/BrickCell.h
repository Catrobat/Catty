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

#import <UIKit/UIKit.h>
#import "ProgramDefines.h"
#import "UIDefines.h"
#import "BrickCellProtocol.h"
#import "BrickShapeFactory.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "SelectButton.h"
#import "Util.h"

#define smallBrick 44.0f
#define mediumBrick 71.0f
#define largeBrick  94.0f
#define roundedLargeBrick 102.0f
#define roundedSmallBrick 75.0f

@class Brick, BrickCellInlineView, BrickCell;
@protocol ScriptProtocol, BrickCellDataDelegate, BrickCellDataProtocol;


@protocol BrickCellDelegate<NSObject>
@optional
- (void)brickCell:(BrickCell*)brickCell didSelectBrickCellButton:(SelectButton*)selectButton;
@end

@interface BrickCell : UICollectionViewCell<BrickCellProtocol>
@property (nonatomic, weak) id<BrickCellDelegate> delegate;
@property (nonatomic, weak) id<BrickCellDataDelegate> dataDelegate;
@property (nonatomic, strong) id<ScriptProtocol> scriptOrBrick;
@property (nonatomic, strong) NSArray *brickCategoryColors;
@property (nonatomic) BOOL enabled;
@property (nonatomic) BOOL isInserting;
@property (nonatomic, strong) SelectButton *selectButton;

- (kBrickShapeType)brickShapeType;
- (CGFloat)inlineViewHeight;
- (CGFloat)inlineViewOffsetY;
+ (CGFloat)cellHeight;

- (void)hookUpSubViews:(NSArray *)inlineViewSubViews; // abstract
- (BOOL)isScriptBrick;
- (void)selectedState:(BOOL)selected setEditingState:(BOOL)editing;
- (void)animate:(BOOL)animate;
- (void)insertAnimate:(BOOL)animate;
- (void)setupBrickCell;

- (id<BrickCellDataProtocol>)dataSubviewForLineNumber:(NSInteger)line andParameterNumber:(NSInteger)parameter;
- (id<BrickCellDataProtocol>)dataSubviewWithType:(Class)className;
- (NSArray*)dataSubviews; // of id<BrickCellDataProtocol>

@end
