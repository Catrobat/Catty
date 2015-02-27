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

#import <Foundation/Foundation.h>
#import "ScriptDataSource.h"

typedef NS_ENUM(NSUInteger, ScriptDataSourceState) {
    ScriptDataSourceStateBrickAdded = 0,
    ScriptDataSourceStateScriptDeleted,
    ScriptDataSourceStateBrickDeleted,
    ScriptDataSourceStateBrickCopied
};

@class ScriptDataSourceDelegate, ScriptDataSource;
@protocol ScriptDataSourceDelegate <NSObject>

@optional
// Maybe change to key-value observing later....
- (void)scriptDataSource:(ScriptDataSource *)scriptDataSource stateChanged:(ScriptDataSourceState)state error:(NSError *)error;
- (void)scriptDataSource:(ScriptDataSource *)scriptDataSource didInsertItemsAtIndexPaths:(NSArray *)indexPaths;
- (void)scriptDataSource:(ScriptDataSource *)scriptDataSource didRemoveItemsAtIndexPaths:(NSArray *)indexPaths;
- (void)scriptDataSource:(ScriptDataSource *)scriptDataSource didCopyItemsAtIndexPaths:(NSArray *)indexPaths;
- (void)scriptDataSource:(ScriptDataSource *)scriptDataSource didMoveItemAtIndexPath:(NSIndexPath *)fromIndexPath
                                                                         toIndexPath:(NSIndexPath *)newIndexPath;

- (void)scriptDataSource:(ScriptDataSource *)scriptDataSource didInsertSections:(NSIndexSet *)sections;
- (void)scriptDataSource:(ScriptDataSource *)scriptDataSource didRemoveSections:(NSIndexSet *)sections;

- (void)scriptDataSource:(ScriptDataSource *)scriptDataSource performBatchUpdate:(dispatch_block_t)update complete:(dispatch_block_t)complete;

@end

@interface ScriptDataSource ()
@property(nonatomic, weak) id<ScriptDataSourceDelegate> delegate;

@end
