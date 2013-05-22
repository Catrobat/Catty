/**
 *  Copyright (C) 2010-2013 The Catrobat Team
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

@end


@implementation OrderedMapTable


+(id)strongToStrongObjectsMapTable
{
    OrderedMapTable* orderedMapTable = (OrderedMapTable*)[super strongToStrongObjectsMapTable];
    orderedMapTable.keyIndexArray = [[NSMutableArray alloc] init];
    return orderedMapTable;
}

+(id)weakToStrongObjectsMapTable
{
    OrderedMapTable* orderedMapTable = [super weakToStrongObjectsMapTable];
    orderedMapTable.keyIndexArray = [[NSMutableArray alloc] init];
    return orderedMapTable;
}

+(id)weakToWeakObjectsMapTable
{
    OrderedMapTable* orderedMapTable = [super weakToWeakObjectsMapTable];
    orderedMapTable.keyIndexArray = [[NSMutableArray alloc] init];
    return orderedMapTable;
}

+(id)strongToWeakObjectsMapTable
{
    OrderedMapTable* orderedMapTable = [super strongToWeakObjectsMapTable];
    orderedMapTable.keyIndexArray = [[NSMutableArray alloc] init];
    return orderedMapTable;
}


-(id) init
{
    self = [super init];
    if(self) {
        
    }
    return self;
}



-(void) setObject:(id)anObject forKey:(id)aKey
{
    [super removeAllObjects];
    [self.keyIndexArray addObject:aKey];
}

-(void) removeAllObjects
{
    [super removeAllObjects];
    [self.keyIndexArray removeAllObjects];
}

-(id) keyAtIndex:(NSUInteger)index
{
    return [self.keyIndexArray objectAtIndex:index];
}

-(id) objectAtIndex:(NSUInteger)index
{
    return [super objectForKey:[self.keyIndexArray objectAtIndex:index]];
}

-(NSString*)description
{
    return [NSString stringWithFormat:@"OrderedMapTable: %@", [super description]];
}




@end
