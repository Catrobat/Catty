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

#import "OrderedMapTable.h"

@interface OrderedMapTable()

@property (nonatomic, strong) NSMutableArray *keyIndexArray;
@property (nonatomic, strong) NSMapTable *mapTable;

@end

@implementation OrderedMapTable

+ (instancetype)strongToStrongObjectsMapTable
{
    return [[OrderedMapTable alloc] initWithMapTable:[NSMapTable strongToStrongObjectsMapTable]];
}


+ (instancetype)weakToStrongObjectsMapTable
{
    return [[OrderedMapTable alloc] initWithMapTable:[NSMapTable weakToStrongObjectsMapTable]];
}

+ (instancetype)weakToWeakObjectsMapTable
{
    return [[OrderedMapTable alloc] initWithMapTable:[NSMapTable weakToWeakObjectsMapTable]];
}

+ (instancetype)strongToWeakObjectsMapTable
{
    return [[OrderedMapTable alloc] initWithMapTable:[NSMapTable strongToWeakObjectsMapTable]];
}

- (instancetype)initWithMapTable:(NSMapTable *)mapTable
{
    self = [super init];
    if(self) {
        _keyIndexArray = [[NSMutableArray alloc] init];
        _mapTable = mapTable;
    }
    return self;
}

- (void)setObject:(id)anObject forKey:(id)aKey
{
    [self.mapTable setObject:anObject forKey:aKey];
    if (![self.keyIndexArray containsObject:aKey])
    {
        [self.keyIndexArray addObject:aKey];
    }

}

- (void)removeObjectForKey:(id)aKey
{
    [self.mapTable removeObjectForKey:aKey];
    [self.keyIndexArray removeObject:aKey];
}

- (void)removeAllObjects
{
    [self.mapTable removeAllObjects];
    [self.keyIndexArray removeAllObjects];
}

- (id)keyAtIndex:(NSUInteger)index
{
    return [self.keyIndexArray objectAtIndex:index];
}

- (id)objectAtIndex:(NSUInteger)index
{
    return [self.mapTable objectForKey:[self.keyIndexArray objectAtIndex:index]];
}

- (id)objectForKey:(id)aKey
{
    return [self.mapTable objectForKey:aKey];
}

- (NSUInteger)count
{
    return [self.mapTable count];
}

- (BOOL)isEqual:(id)other
{
    if (other == self)
        return YES;
    if (![[other class] isEqual:[self class]])
        return NO;
    
    return [self isEqualToOrderedMapTable:other];
}

- (BOOL)isEqualToOrderedMapTable:(OrderedMapTable *)orderedMapTable
{
    if (self.count != orderedMapTable.count)
        return NO;
    
    for (id key in self.keyIndexArray) {
        NSUInteger index = [orderedMapTable.keyIndexArray indexOfObject:key];
        id selfObject = [self.mapTable objectForKey:key];
        id orderedMapTableObject = [orderedMapTable objectAtIndex:index];
        
        if (![selfObject isEqual:orderedMapTableObject])
            return NO;
    }
    
    return YES;
}

- (NSString *)description
{
    NSMutableString *desc = [NSMutableString stringWithString:@"OrderedMapTable: {"];
    for (id key in self.keyIndexArray) {
        [desc appendString:[NSString stringWithFormat:@"%@ = %@; ", key, [self objectForKey:key]]];
    }
    [desc appendString:@"}"];
    
    return desc;
}

- (id)mutableCopy
{
    OrderedMapTable *orderedMapTable = [[OrderedMapTable alloc] initWithMapTable:nil];
    orderedMapTable.keyIndexArray = [self.keyIndexArray mutableCopy];
    orderedMapTable.mapTable = [self.mapTable mutableCopy];
    return orderedMapTable;
}

@end
