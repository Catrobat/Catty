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

# pragma mark - Setters

- (void)setScriptList:(NSArray *)scriptList
{
    if (scriptList == _scriptList || [scriptList isEqual:_scriptList]) {
        return;
    }
    
    _scriptList = [scriptList copy];
}

- (void)setState:(ScriptDataSourceState)state {
    if (state == _state) {
        return;
    }
    
    _state = state;
    
    id<ScriptDataSourceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(scriptDataSource:stateChanged:error:)]) {
        NSError *error = nil;
        [delegate scriptDataSource:self stateChanged:self.state error:error];
        if (error) {
            NSDebug(@"%@",error.localizedDescription);
        }
    }
}

#pragma mark - Getters

- (NSUInteger)numberOfSections
{
    return self.scriptList.count;
}

#pragma mark - Collection View Datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.scriptList.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    Script *script = [self.scriptList objectAtIndex:(NSUInteger)section];
    CBAssert(script != nil, @"Error, no script found");
    // +1, because script itself is a brick in IDE too.
    return script.brickList.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier;
    BrickCell *brickCell = nil;
    
    Script *script = [self.scriptList objectAtIndex:(NSUInteger)indexPath.section];
    Brick *brick = nil;
    
    if (indexPath.item == 0) {
        cellIdentifier = NSStringFromClass([script class]);
    } else {
        brick = [script.brickList objectAtIndex:indexPath.item - 1];
        cellIdentifier = NSStringFromClass([brick class]);
    }
    
    brickCell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier
                                                          forIndexPath:indexPath];
    brickCell.scriptOrBrick = indexPath.item == 0 ? script : brick;
    self.configureCellBlock(brickCell);
    return brickCell;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSDebug(@"From KVO");
    
    if([keyPath isEqualToString:@"number"])
    {
        NSDebug(@"%@ %@", [change objectForKey:NSKeyValueChangeOldKey], [change objectForKey:NSKeyValueChangeNewKey]);
    }
}

@end
