/**
 *  Copyright (C) 2010-2022 The Catrobat Team
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
#import "Script.h"

@interface Brick : NSObject

@property (nonatomic, weak) Script *script;
@property (nonatomic, getter=isAnimated) BOOL animate;
@property (nonatomic, getter=isAnimatedInsertBrick) BOOL animateInsertBrick;
@property (nonatomic, getter=isAnimatedMoveBrick) BOOL animateMoveBrick;
@property (nonatomic) BOOL isSelected;
@property (nonatomic) BOOL isDisabled;

- (BOOL)isSelectableForObject;

- (BOOL)isDisabledForBackground;

- (BOOL)isAnimateable;

- (BOOL)isFormulaBrick;

- (BOOL)isIfLogicBrick;

- (BOOL)isLoopBrick;

- (BOOL)isBluetoothBrick;

- (BOOL)isPhiroBrick;

- (BOOL)isArduinoBrick;

- (NSString*)description;

- (BOOL)isEqualToBrick:(Brick*)brick;

- (id)mutableCopyWithContext:(CBMutableCopyContext*)context;

- (id)mutableCopyWithContext:(CBMutableCopyContext*)context AndErrorReporting:(BOOL)reportError;

- (void)removeFromScript;

- (void)removeReferences;

- (NSInteger)getRequiredResources;

- (void)setDefaultValuesForObject:(SpriteObject *)spriteObject;

- (Class<BrickCellProtocol>)brickCell;

- (Brick*)cloneWithScript:(Script *) script;

@end
