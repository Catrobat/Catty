/**
 *  Copyright (C) 2010-2017 The Catrobat Team
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

#import <Foundation/Foundation.h>

@class SpriteObject;

NS_ASSUME_NONNULL_BEGIN

@interface Scene : NSObject

@property (nonatomic, readonly, copy) NSString *name;
@property (nonatomic, readonly, nullable) SpriteObject *background;
@property (nonatomic) NSMutableArray<SpriteObject *> *allObjects;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithName:(NSString *)name objects:(NSMutableArray<SpriteObject *> *)objects NS_DESIGNATED_INITIALIZER;

- (void)addObject:(SpriteObject *)object;
- (void)removeObject:(SpriteObject *)object;
- (void)moveObjectFromIndex:(NSUInteger)originIndex toIndex:(NSUInteger)destinationIndex;

@end

NS_ASSUME_NONNULL_END
