/**
 *  Copyright (C) 2010-2014 The Catrobat Team
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

@property (nonatomic, strong) NSMutableArray* keyIndexArray;
@property (nonatomic, strong) NSMapTable* mapTable;

@end

@implementation OrderedMapTable

+ (id)strongToStrongObjectsMapTable
{
    OrderedMapTable *orderedMapTable = [[OrderedMapTable alloc] init];
    orderedMapTable.mapTable = [NSMapTable strongToStrongObjectsMapTable];
    return orderedMapTable;
}


+ (id)weakToStrongObjectsMapTable
{
    OrderedMapTable *orderedMapTable = [[OrderedMapTable alloc] init];
    orderedMapTable.mapTable = [NSMapTable weakToStrongObjectsMapTable];
    return orderedMapTable;
}

+ (id)weakToWeakObjectsMapTable
{
    OrderedMapTable *orderedMapTable = [[OrderedMapTable alloc] init];
    orderedMapTable.mapTable = [NSMapTable weakToWeakObjectsMapTable];
    return orderedMapTable;
}

+ (id)strongToWeakObjectsMapTable
{
    OrderedMapTable *orderedMapTable = [[OrderedMapTable alloc] init];
    orderedMapTable.mapTable = [NSMapTable strongToWeakObjectsMapTable];
    return orderedMapTable;
}

- (id)init
{
    self = [super init];
    if(self) {
        self.keyIndexArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)setObject:(id)anObject forKey:(id)aKey
{
    [self.mapTable setObject:anObject forKey:aKey];
    [self.keyIndexArray addObject:aKey];
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

- (NSString*)description
{
    return [NSString stringWithFormat:@"OrderedMapTable: %@", self.mapTable];
}

@end
