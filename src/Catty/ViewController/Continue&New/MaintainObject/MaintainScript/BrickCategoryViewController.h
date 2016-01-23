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

#import "Brick.h"
#import "UIDefines.h"


@class SpriteObject;

@class BrickCategoryViewController;
@protocol BrickCategoryViewControllerDelegate<NSObject>
@optional
- (void)brickCategoryViewController:(BrickCategoryViewController*)brickCategoryViewController
             didSelectScriptOrBrick:(id<ScriptProtocol>)scriptOrBrick;
@end

@interface BrickCategoryViewController : UICollectionViewController
@property(nonatomic, readonly) PageIndexCategoryType pageIndexCategoryType;
@property(nonatomic, weak) id<BrickCategoryViewControllerDelegate> delegate;
@property(nonatomic, readonly) NSArray *bricks;
@property(nonatomic, readonly) NSUInteger pageIndex;
@property(nonatomic, weak) SpriteObject *spriteObject;

- (instancetype)initWithBrickCategory:(PageIndexCategoryType)type andObject:(SpriteObject*)spriteObject andPageIndexArray:(NSArray*)pageIndexArray;

+ (BrickCategoryViewController*)brickCategoryViewControllerForPageIndex:(PageIndexCategoryType)pageIndex object:(SpriteObject*)spriteObject maxPage:(NSInteger)maxPage andPageIndexArray:(NSArray*)pageIndexArray;

// disallow init
- (instancetype)init __attribute__((unavailable("init is not a supported initializer for this class.")));

@end

extern NSString *CBTitleFromPageIndexCategoryType(PageIndexCategoryType pageIndexType);
