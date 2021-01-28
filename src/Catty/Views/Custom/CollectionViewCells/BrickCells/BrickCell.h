/**
 *  Copyright (C) 2010-2021 The Catrobat Team
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
#import "ProjectDefines.h"
#import "UIDefines.h"
#import "BrickProtocol.h"
#import "BrickCellProtocol.h"
#import "BrickShapeFactory.h"

#define marginBottomSquaredBrick -4.9f
#define marginBottomRoundedBrick 2.6f

@class Brick, BrickCellInlineView, BrickCell, BrickCellFormulaData, SelectButton;
@protocol BrickCellDataDelegate, BrickCellDataProtocol;

@protocol BrickCellDelegate<NSObject>
- (void)openFormulaEditor:(BrickCellFormulaData*)formulaData withEvent:(UIEvent*)event;
@optional
- (void)brickCell:(BrickCell*)brickCell didSelectBrickCellButton:(SelectButton*)selectButton;
@end

@interface BrickCell : UICollectionViewCell
@property (nonatomic, weak) id<BrickCellDelegate> delegate;
@property (nonatomic, weak) id<BrickCellDataDelegate> dataDelegate;
@property (nonatomic, strong) id<BrickProtocol> scriptOrBrick;
@property (nonatomic, strong) NSArray *brickCategoryColors;
@property (nonatomic) BOOL enabled;
@property (nonatomic) BOOL isInserting;

@property (nonatomic, strong) SelectButton *selectButton;

- (kBrickShapeType)brickShapeType;
- (CGFloat)inlineViewHeight;
- (CGFloat)inlineViewOffsetY;

- (void)hookUpSubViews:(NSArray*)inlineViewSubViews; // abstract
- (BOOL)isScriptBrick;
- (void)selectedState:(BOOL)selected setEditingState:(BOOL)editing;
- (void)animate:(BOOL)animate;
- (void)insertAnimate:(BOOL)animate;
- (void)setupBrickCell;
- (void)setupBrickCellinSelectionView:(BOOL)inSelectionView inBackground:(BOOL)inBackground;

- (id<BrickCellDataProtocol>)dataSubviewForLineNumber:(NSInteger)line andParameterNumber:(NSInteger)parameter;
- (id<BrickCellDataProtocol>)dataSubviewWithType:(Class)className;
- (NSArray*)dataSubviews; // of id<BrickCellDataProtocol>
- (NSArray<NSString*>*)parameters;

@end
