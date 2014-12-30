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

#import "ScriptDataSource+Extensions.h"
#import "ScriptDataSource_Private.h"
#import "Util.h"

@interface ScriptDataSource ()
@property(nonatomic, assign) ScriptDataSourceState state;

@end

@implementation ScriptDataSource (Extensions)

#pragma mark - Set state

- (void)setState:(ScriptDataSourceState)state {
    self.state = state;
    if ([self.delegate respondsToSelector:@selector(scriptDataSource:stateChanged:error:)]) {
        // TODO: Handle Error
        NSError *error = nil;
        id<ScriptDataSourceDelegate> delegate = self.delegate;
        [delegate scriptDataSource:self stateChanged:self.state error:error];
    }
}

#pragma mark - Get Data

- (id)itemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.scriptList objectAtIndex:(NSUInteger)indexPath.item];
}


// We are using a index for brick items with index in bricklist + 1.
// Script bricks always have index 0.
- (NSArray *)indexPathsForItem:(id)item
{
    NSMutableArray *indexPaths = [NSMutableArray array];
    
    // Search for Scripts indexpaths.
    [self.scriptList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([item isKindOfClass:[Script class]]) {
            if ([obj isEqual:item]) {
                [indexPaths addObject:[NSIndexPath indexPathForItem:0 inSection:idx]];
            }
        } else
            *stop = YES;
    }];
    
    // Search for brick indexpaths.
    if (![item isKindOfClass:[Script class]]) {
        NSUInteger section = 0;
        for (Script *script in self.scriptList) {
            [script.brickList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([obj isEqual:item]) {
                    [indexPaths addObject:[NSIndexPath indexPathForItem:idx + 1 inSection:section]];
                }
            }];
            section += 1;
        }
    }

    return indexPaths;
}

- (NSArray *)brickListInScriptAtIndexPath:(NSIndexPath *)indexPath
{
    Script *script = [self scriptAtSection:(NSUInteger)indexPath.section];
    return script.brickList;
}

- (Brick *)brickInScriptAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *brickList = [self brickListInScriptAtIndexPath:indexPath];
    NSInteger index = indexPath.item - 1;
    if (index >= 0 && index < brickList.count) {
        return [brickList objectAtIndex:(NSUInteger)index];
    }
    return nil;
}

- (Script *)scriptAtSection:(NSUInteger)section
{
    NSAssert(self.scriptList.count, @"No bricks in Scriptlist");
    return (Script *)[self.scriptList objectAtIndex:section];
}

#pragma mark - Add, remove, copy

- (void)addBricks:(NSArray *)bricks toIndexPaths:(NSArray *)indexPaths
{
    self.state = ScriptDataSourceStateBrickAdded;
}

- (void)removeScriptAtSection:(NSUInteger)section
{
    self.state = ScriptDataSourceStateScriptDeleted;
}

- (void)removeBrickAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndex:indexPath.item];
    [self removeItemsAtIndexes:indexes inSection:indexPath.section];
}

- (void)copyBrickAtIndexPath:(NSIndexPath *)atIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    self.state = ScriptDataSourceStateBrickCopied;
}

#pragma mark - Checks

- (BOOL)isSectionAtIndexPathValidScript:(NSIndexPath *)indexPath
{
    if (indexPath.section >= self.scriptList.count) {
        return NO;
    }
    return [[self scriptAtSection:(NSUInteger)indexPath.section] isKindOfClass:[Script class]];
}

#pragma mark - Private

- (void)removeItemsAtIndexes:(NSIndexSet *)indexes inSection:(NSUInteger)section
{
    Script *script = [self.scriptList objectAtIndex:section];
    NSArray *bricks = script.brickList;
    
    NSUInteger newCount = bricks.count - indexes.count;
    NSMutableArray *newBricks = newCount > 0 ? [[NSMutableArray alloc] initWithCapacity:newCount] : nil;
    
    __block dispatch_block_t batchUpdates = ^{};
    batchUpdates = [batchUpdates copy];
    
    [bricks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        dispatch_block_t oldUpdates = batchUpdates;
        if ([indexes containsIndex:idx]) {
            // Removing this object.
            batchUpdates = ^{
                oldUpdates();
                [self informItemsRemovedAtIndexPaths:@[[NSIndexPath indexPathForItem:idx inSection:section]]];
            };
        } else {
            // Keeping this item.
            NSUInteger newIdx = newBricks.count;
            [newBricks addObject:obj];
            batchUpdates = ^{
                oldUpdates();
                [self informItemMovedFromIndexPath:[NSIndexPath indexPathForItem:idx + 1 inSection:section]
                                      toIndexPaths:[NSIndexPath indexPathForItem:newIdx + 1 inSection:section]];
            };
        }
        batchUpdates = [batchUpdates copy];
    }];
    
    script.brickList = newBricks;
    NSMutableArray *scriptList = [self.scriptList mutableCopy];
    [scriptList replaceObjectAtIndex:section withObject:script];
    
    self.scriptList = scriptList;
    
    [self informBatchUpdate:^{ batchUpdates(); }];
}

- (void)informItemsRemovedAtIndexPaths:(NSArray *)removedIndexPaths
{
    CBAssertIfNotMainThread();
    
    id<ScriptDataSourceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(scriptDataSource:didRemoveItemsAtIndexPaths:)]) {
        [delegate scriptDataSource:self didRemoveItemsAtIndexPaths:removedIndexPaths];
    }
}

- (void)informItemMovedFromIndexPath:(NSIndexPath *)indexPath toIndexPaths:(NSIndexPath *)newIndexPath
{
    CBAssertIfNotMainThread();
    
    id<ScriptDataSourceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(scriptDataSource:didMoveItemAtIndexPath:toIndexPath:)]) {
        [delegate scriptDataSource:self didMoveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
    }
}

- (void)informBatchUpdate:(dispatch_block_t)update
{
    [self informBatchUpdate:update complete:nil];
}

- (void)informBatchUpdate:(dispatch_block_t)update complete:(dispatch_block_t)complete
{
    CBAssertIfNotMainThread();
    
    id<ScriptDataSourceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(scriptDataSource:performBatchUpdate:complete:)]) {
        [delegate scriptDataSource:self performBatchUpdate:update complete:complete];
    } else {
        if (update) { update(); }
        if (complete) { complete(); }
    }
}

@end
