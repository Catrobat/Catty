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
#import "SpriteObject.h"
#import "UIDefines.h"
#import "BrickProtocol.h"

@class Script;

@interface Brick : NSObject <BrickProtocol>

#warning JUST FOR DEBUGGING PURPOSES
@property (nonatomic, strong) dispatch_semaphore_t semaphore;

@property (nonatomic, readonly) kBrickCategoryType brickCategoryType;
@property (nonatomic, readonly) kBrickType brickType;
@property (nonatomic, strong, readonly) NSString *brickTitle;
@property (nonatomic, weak) Script *script;
- (BOOL)isSelectableForObject;

- (NSString*)description;

- (SKAction*)action;

- (BOOL)isEqualToBrick:(Brick*)brick;

- (id)mutableCopyWithContext:(CBMutableCopyContext*)context AndErrorReporting:(BOOL)reportError;

- (NSUInteger)runAction;

- (void)removeReferences;

@end
