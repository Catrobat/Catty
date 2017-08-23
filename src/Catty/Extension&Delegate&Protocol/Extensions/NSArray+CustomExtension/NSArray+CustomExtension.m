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

#import "NSArray+CustomExtension.h"

@implementation NSArray (CustomExtension)

- (NSArray *)cb_mapUsingBlock:(id(^)(id))block {
    NSParameterAssert(block);
    
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[self count]];
    for (id item in self) {
        [result addObject:block(item)];
    }
    
    return [result copy];
}

- (id)cb_foldLeftWithInitialValue:(id)value usingBlock:(id (^)(id accumulator, id nextItem))block {
    NSParameterAssert(block);
    
    __typeof__(value) accumulator = value;
    for (id item in self) {
        accumulator = block(accumulator, item);
    }
    
    return accumulator;
}

- (instancetype)cb_foreachUsingBlock:(void (^)(id item))block {
    NSParameterAssert(block);
    
    for (id item in self) {
        block(item);
    }
    return self;
}

- (id)cb_findFirst:(BOOL (^)(id))predicate {
    NSParameterAssert(predicate);
    
    for (__block id item in self) {
        if (predicate(item)) {
            return item;
        }
    }
    return nil;
}

- (BOOL)cb_hasAny:(BOOL (^)(id))predicate {
    NSParameterAssert(predicate);
    
    return [self cb_findFirst:predicate] != nil;
}

@end
