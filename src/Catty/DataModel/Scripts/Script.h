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
#import "UIDefines.h"
#import "LanguageTranslationDefines.h"
#import "BrickProtocol.h"
#import "CBMutableCopying.h"

@class Brick;
@class SpriteObject;
@class GDataXMLElement;

@interface Script : NSObject <ScriptProtocol, CBMutableCopying>

@property (nonatomic, readonly) kBrickCategoryType brickCategoryType;
@property (nonatomic, readonly) kBrickType brickType;
@property (nonatomic, strong, readonly) NSString *brickTitle;
@property (nonatomic, weak) SpriteObject *object;
@property (strong, nonatomic) NSMutableArray<Brick*> *brickList;
@property (nonatomic, getter=isAnimated) BOOL animate;
@property (nonatomic, getter=isAnimatedInsertBrick) BOOL animateInsertBrick;
@property (nonatomic, getter=isAnimatedMoveBrick) BOOL animateMoveBrick;
@property (nonatomic) BOOL isSelected;

- (BOOL)isSelectableForObject;
- (BOOL)isAnimateable;
- (void)setDefaultValuesForObject:(SpriteObject*)spriteObject;
- (void)addBrick:(Brick*)brick atIndex:(NSUInteger)index;
- (NSString*)description;
- (BOOL)isEqualToScript:(Script*)script;
- (void)removeFromObject;
- (void)removeReferences;
- (NSInteger)getRequiredResources;

@end
