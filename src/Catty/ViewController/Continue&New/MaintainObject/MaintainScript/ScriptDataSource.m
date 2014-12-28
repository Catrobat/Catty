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

#import "ScriptDataSource.h"
#import "Brick.h"
#import "BrickCell.h"

@interface ScriptDataSource ()
@property(nonatomic, copy) ScriptCollectionViewConfigureBlock configureCellBlock;
@property(nonatomic, strong) NSArray *scriptList;
@property(nonatomic, copy) NSString *cellIdentifier;

@end

@implementation ScriptDataSource

#pragma mark - Init

- (instancetype)initWithScriptList:(NSArray *)scriptList
                    cellIdentifier:(NSString *) __unused cellIdentifier
                configureCellBlock:(ScriptCollectionViewConfigureBlock)configureCellBlock
{
    if (self = [super init]) {
        _configureCellBlock = [configureCellBlock copy];
        _scriptList = scriptList;
    }
    return self;
}

#pragma mark - Setters
- (void)setState:(ScriptDataSourceState)state {
    self.state = state;
    if ([self.delegate respondsToSelector:@selector(scriptDataSource:stateChanged:error:)]) {
        // TODO: Handle Error
        NSError *error = nil;
        [self.delegate scriptDataSource:self stateChanged:self.state error:error];
    }
}

#pragma mark - Collection View Datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.scriptList.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    Script *script = [self scriptAtSection:(NSUInteger)section];
    NSAssert(script != nil, @"Error, no script found");
    // +1, because script itself is a brick in IDE too.
    return script.brickList.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier;
    BrickCell *brickCell = nil;
    
    Script *script = [self scriptAtSection:indexPath.section];
    Brick *brick = nil;
    
    if (indexPath.item == 0) {
        cellIdentifier = [NSString stringWithFormat:@"%@", [script class]];
    } else {
        brick = [script.brickList objectAtIndex:indexPath.item - 1];
        cellIdentifier = [NSString stringWithFormat:@"%@", [brick class]];
    }
    
    brickCell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier
                                                          forIndexPath:indexPath];
    brickCell.brick = indexPath.item == 0 ? script : brick;
    
    self.configureCellBlock(brickCell);
    return brickCell;
}

#pragma mark - Public

- (id)itemAtIndexPath:(NSIndexPath *)indexPath
{
    id item = [self.scriptList objectAtIndex:(NSUInteger)indexPath.item];
    return item;
}

- (NSArray *)bricklistInScriptAtIndexPath:(NSIndexPath *)indexPath
{
    Script *script = [self scriptAtSection:(NSUInteger)indexPath.section];
    return script.brickList;
}

- (Brick *)brickInScriptAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *brickList = [self bricklistInScriptAtIndexPath:indexPath];
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
@end
