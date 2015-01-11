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
#import "Brick.h"
#import "LoopBeginBrick.h"
#import "LoopEndBrick.h"
#import "ForeverBrick.h"
#import "RepeatBrick.h"
#import "IfLogicBeginBrick.h"
#import "IfLogicElseBrick.h"
#import "IfLogicEndBrick.h"

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
    CBAssert(self.scriptList.count, @"No bricks in Scriptlist");
    return (Script *)[self.scriptList objectAtIndex:section];
}

#pragma mark - Add, remove, copy

- (void)addBricks:(NSArray *)bricks toIndexPaths:(NSArray *)indexPaths
{
    self.state = ScriptDataSourceStateBrickAdded;
}

- (void)removeScriptsAtSections:(NSIndexSet *)sections
{
    [self removeSectionAtIndexes:sections];
}

- (void)removeBrickAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSetWithIndex:indexPath.item - 1];
    
    NSIndexSet *linkedIndexes = [self indexesForLinkedBricksWithBrickAtIndexPath:indexPath];
    [indexes addIndexes:linkedIndexes];

    [self removeItemsAtIndexes:indexes inSection:indexPath.section];
}

- (void)copyBrickAtIndexPath:(NSIndexPath *)atIndexPath
{
    // TODO: validate which extra bricks must be added (if else, if end, loop begin, loop end...)
    Brick *oldBrick = [self brickInScriptAtIndexPath:atIndexPath];
    CBAssert(oldBrick != nil, @"Error copy brick, brick == nil.");
    
    // TODO: Copy brick
    Brick *newBrick = [[oldBrick class] new];
    
    NSArray *addedBricks = @[ newBrick ];
    
    NSUInteger startIdx = (NSUInteger)atIndexPath.item - 1;
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(startIdx, addedBricks.count)];
    [self insertBricks:addedBricks atIndexes:indexes inSection:atIndexPath.section];
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

- (void)removeSectionAtIndexes:(NSIndexSet *)sections
{
    NSMutableIndexSet *sectionIndexes = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.numberOfSections)];
    NSMutableArray *scriptList = [self.scriptList mutableCopy];
    
    __block dispatch_block_t batchUpdates = ^{};
    batchUpdates = [batchUpdates copy];
    
    __weak typeof(&*self) weakself = self;
    [sections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        dispatch_block_t oldUpdates = batchUpdates;
        if ([sectionIndexes containsIndex:idx]) {
            batchUpdates = ^{
                oldUpdates();
                [scriptList removeObjectAtIndex:idx];
                weakself.scriptList = scriptList;
                [weakself informSectionsRemoved:[NSIndexSet indexSetWithIndex:idx]];
            };
        }
        batchUpdates = [batchUpdates copy];
    }];
    
    [self informBatchUpdate:^{ batchUpdates(); }];
}

- (void)removeItemsAtIndexes:(NSIndexSet *)indexes inSection:(NSUInteger)section
{
    Script *script = [self scriptAtSection:section];
    NSArray *bricks = script.brickList;
    
    NSUInteger newCount = bricks.count - indexes.count;
    NSMutableArray *newBricks = newCount > 0 ? [[NSMutableArray alloc] initWithCapacity:newCount] : nil;
    
    __block dispatch_block_t batchUpdates = ^{};
    batchUpdates = [batchUpdates copy];
    
    __weak typeof(&*self) weakself = self;
    [bricks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        dispatch_block_t oldUpdates = batchUpdates;
        if ([indexes containsIndex:idx]) {
            // Removing this object.
            batchUpdates = ^{
                oldUpdates();
                [weakself informItemsRemovedAtIndexPaths:@[[NSIndexPath indexPathForItem:idx + 1 inSection:section]]];
            };
        } else {
            // Keeping this item.
            NSUInteger newIdx = newBricks.count;
            [newBricks addObject:obj];
            batchUpdates = ^{
                oldUpdates();
                [weakself informItemMovedFromIndexPath:[NSIndexPath indexPathForItem:idx + 1 inSection:section]
                                      toIndexPaths:[NSIndexPath indexPathForItem:newIdx + 1 inSection:section]];
            };
        }
        batchUpdates = [batchUpdates copy];
    }];
    
    script.brickList = newBricks;
    [self informBatchUpdate:^{ batchUpdates(); }];
}

- (void)insertBricks:(NSArray *)bricks atIndexes:(NSIndexSet *)indexes inSection:(NSUInteger)section
{
    Script *script = [self scriptAtSection:section];
    NSMutableArray *brickList = [script.brickList mutableCopy];
    [brickList insertObjects:bricks atIndexes:indexes];
    
    script.brickList = brickList;
    
    NSMutableArray *insertedIndexPaths = [[NSMutableArray alloc] initWithCapacity:indexes.count];
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            [insertedIndexPaths addObject:[NSIndexPath indexPathForItem:idx + 1 inSection:section]];
    }];
    
    [self informItemsInsertedAtIndexPaths:insertedIndexPaths];
}

#pragma mark - Inform collectionview about changes

- (void)informSectionsRemoved:(NSIndexSet *)sections
{
    CBAssertIfNotMainThread();
    
    id<ScriptDataSourceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(scriptDataSource:didRemoveSections:)]) {
        [delegate scriptDataSource:self didRemoveSections:sections];
    }
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

- (void)informItemsInsertedAtIndexPaths:(NSArray *)insertedIndexPaths
{
    CBAssertIfNotMainThread();
    
    id<ScriptDataSourceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(scriptDataSource:didInsertItemsAtIndexPaths:)]) {
        [delegate scriptDataSource:self didInsertItemsAtIndexPaths:insertedIndexPaths];
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

#pragma mark - Indexes for linked bricks

- (NSIndexSet *)indexesForLinkedBricksWithBrickAtIndexPath:(NSIndexPath *)indexPath
{
    Script *script = [self scriptAtSection:indexPath.section];
    NSArray *bricks = script.brickList;
    Brick *brick = [self brickInScriptAtIndexPath:indexPath];
    CBAssert(brick != nil, @"No brick found.");
    
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    
    // Loop bricks.
    if ([brick isKindOfClass:[ForeverBrick class]]) {
        ForeverBrick *foreverBrick = (ForeverBrick *)brick;
        CBAssert(foreverBrick.loopEndBrick);
        [indexes addIndex:[bricks indexOfObject:foreverBrick.loopEndBrick]];
    }
    
    if ([brick isKindOfClass:[RepeatBrick class]]) {
        RepeatBrick *repeatBrick = (RepeatBrick *)brick;
        CBAssert(repeatBrick.loopEndBrick);
        [indexes addIndex:[bricks indexOfObject:repeatBrick.loopEndBrick]];
    }
    
    else if ([brick isKindOfClass:[LoopEndBrick class]]) {
        LoopEndBrick *loopendBrick = (LoopEndBrick *)brick;
        CBAssert(loopendBrick.loopBeginBrick);
        [indexes addIndex:[bricks indexOfObject:loopendBrick.loopBeginBrick]];
    }
    
    // Logic bricks.
    else if ([brick isKindOfClass:[IfLogicBeginBrick class]]) {
        IfLogicBeginBrick *beginBrick = (IfLogicBeginBrick *)brick;
        CBAssert(beginBrick.ifElseBrick && beginBrick.ifEndBrick);
        [indexes addIndex:[bricks indexOfObject:beginBrick.ifElseBrick]];
        [indexes addIndex:[bricks indexOfObject:beginBrick.ifEndBrick]];
    }
    
    else if ([brick isKindOfClass:[IfLogicEndBrick class]]) {
        IfLogicEndBrick *endBrick = (IfLogicEndBrick *)brick;
        CBAssert(endBrick.ifBeginBrick && endBrick.ifElseBrick);
        [indexes addIndex:[bricks indexOfObject:endBrick.ifBeginBrick]];
        [indexes addIndex:[bricks indexOfObject:endBrick.ifElseBrick]];
    }
    
    else if ([brick isKindOfClass:[IfLogicElseBrick class]]) {
        IfLogicElseBrick *elseBrick = (IfLogicElseBrick *)brick;
        CBAssert(elseBrick.ifBeginBrick && elseBrick.ifEndBrick);
        [indexes addIndex:[bricks indexOfObject:elseBrick.ifBeginBrick]];
        [indexes addIndex:[bricks indexOfObject:elseBrick.ifEndBrick]];
    }
    
    return indexes;
}


@end
