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

#import <UIKit/UIKit.h>
#import "ProgramDefines.h"
#import "UIDefines.h"

@class Brick;
@class BrickCellInlineView;

@interface BrickCell : UICollectionViewCell

@property (nonatomic, readonly) kBrickCategoryType categoryType;
@property (nonatomic, readonly) NSInteger brickType;
@property (nonatomic, getter = isBackgroundBrickCell) BOOL backgroundBrickCell;
@property (nonatomic) BOOL enabled;
@property (nonatomic, assign) BOOL editing;

- (void)renderSubViews;
- (void)hookUpSubViews:(NSArray *)inlineViewSubViews; // abstract (only called internally)

+ (NSInteger)numberOfAvailableBricksForCategoryType:(kBrickCategoryType)categoryType;
+ (CGFloat) brickCellHeightForCategoryType:(kBrickCategoryType)categoryType AndBrickType:(NSInteger)brickType;
+ (kBrickShapeType)shapeTypeForCategoryType:(kBrickCategoryType)categoryType AndBrickType:(NSInteger)brickType;
+ (BOOL)isScriptBrickCellForCategoryType:(kBrickCategoryType)categoryType AndBrickType:(NSInteger)brickType;
+ (NSString*)brickPatternImageNameForCategoryType:(kBrickCategoryType)categoryType AndBrickType:(NSInteger)brickType;
+ (void)clearImageCache;

//- (void)setEditing:(BOOL)editing;

@end
