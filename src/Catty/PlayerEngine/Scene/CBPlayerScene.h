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

#import <SpriteKit/SpriteKit.h>

@class CBPlayerScheduler;
@class CBPlayerFrontend;
@class CBPlayerBackend;

@interface CBPlayerScene : SKScene

@property(nonatomic, readonly) CBPlayerScheduler *scheduler;
@property(nonatomic, readonly) CBPlayerFrontend *frontend;
@property(nonatomic, readonly) CBPlayerBackend *backend;

- (instancetype)init;                      // ATTENTION: may only be used for single action testing purposes!!
- (instancetype)initWithSize:(CGSize)size; // ATTENTION: may only be used for single action testing purposes!!
- (instancetype)initWithSize:(CGSize)size
                   scheduler:(CBPlayerScheduler*)scheduler
                    frontend:(CBPlayerFrontend*)frontend
                     backend:(CBPlayerBackend*)backend NS_DESIGNATED_INITIALIZER;

- (CGPoint)convertPointToScene:(CGPoint)point;
- (CGFloat)convertYCoordinateToScene:(CGFloat)y;
- (CGFloat)convertXCoordinateToScene:(CGFloat)x;
- (CGFloat)convertDegreesToScene:(CGFloat)degrees;

- (CGPoint)convertSceneCoordinateToPoint:(CGPoint)point;
- (CGFloat)convertSceneToDegrees:(CGFloat)degrees;

- (BOOL)touchedwith:(NSSet*)touches withX:(CGFloat) x andY:(CGFloat) y;
- (void)startProgram;
- (void)stopProgram;

@end
