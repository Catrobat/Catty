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
#import "SpriteObject.h"
#import "UIDefines.h"
#import "BrickProtocol.h"

@class Script;

@interface Brick : NSObject <BrickProtocol>

@property (nonatomic, readonly) kBrickCategoryType brickCategoryType;
@property (nonatomic, readonly) kBrickType brickType;
@property (nonatomic, strong, readonly) NSString *brickTitle;
@property (nonatomic, weak) Script *script;
@property (nonatomic, getter=isAnimated) BOOL animate;
@property (nonatomic, getter=isAnimatedInsertBrick) BOOL animateInsertBrick;
@property (nonatomic, getter=isAnimatedMoveBrick) BOOL animateMoveBrick;
@property (nonatomic) BOOL isSelected;

- (BOOL)isSelectableForObject;

- (BOOL)isAnimateable;

- (BOOL)isFormulaBrick;

- (BOOL)isBluetoothBrick;

- (BOOL)isPhiroBrick;

- (BOOL)isArduinoBrick;

- (BOOL)requiresStringFormula;

- (NSString*)description;

- (BOOL)isEqualToBrick:(Brick*)brick;

- (id)mutableCopyWithContext:(CBMutableCopyContext*)context AndErrorReporting:(BOOL)reportError;

- (void)removeFromScript;

- (void)removeReferences;

- (NSInteger)getRequiredResources;

@end
