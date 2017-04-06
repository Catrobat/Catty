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

#import "CatrobatReorderableCollectionViewFlowLayout.h"

@interface CatrobatReorderableCollectionViewFlowLayout()

@property (strong, nonatomic) UILongPressGestureRecognizer *customLongPressGestureRecognizer;
@property (strong, nonatomic) UIPanGestureRecognizer *customPanGestureRecognizer;

@property (strong, nonatomic) NSIndexPath *selectedItemIndexPath;
@property (strong, nonatomic) UIView *currentView;
@property (assign, nonatomic, readonly) id<LXReorderableCollectionViewDataSource> dataSource;

@end

@implementation CatrobatReorderableCollectionViewFlowLayout

@dynamic currentView;
@dynamic dataSource;

- (void)setupCollectionView {
    if (![self.collectionView.gestureRecognizers containsObject:self.longPressGestureRecognizer]) {
        self.customLongPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(handleLongPressGesture:)];
        self.customLongPressGestureRecognizer.delegate = self;
        
        // Links the default long press gesture recognizer to the custom long press gesture recognizer we are creating now
        // by enforcing failure dependency so that they doesn't clash.
        for (UIGestureRecognizer *gestureRecognizer in self.collectionView.gestureRecognizers) {
            if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
                [gestureRecognizer requireGestureRecognizerToFail:self.longPressGestureRecognizer];
            }
        }
        [self.collectionView addGestureRecognizer:self.longPressGestureRecognizer];
    }
    
    if (![self.collectionView.gestureRecognizers containsObject:self.panGestureRecognizer]) {
        self.customPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                        action:@selector(handlePanGesture:)];
        self.panGestureRecognizer.delegate = self;
        [self.collectionView addGestureRecognizer:self.panGestureRecognizer];
    }
    
    // Useful in multiple scenarios: one common scenario being when the Notification Center drawer is pulled down
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationWillResignActive:) name: UIApplicationWillResignActiveNotification object:nil];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([self.longPressGestureRecognizer isEqual:gestureRecognizer]) {
        return [self.panGestureRecognizer isEqual:otherGestureRecognizer];
    }
    
    if ([self.panGestureRecognizer isEqual:gestureRecognizer]) {
        return [self.longPressGestureRecognizer isEqual:otherGestureRecognizer];
    }
    
    
    // Allow the underlying scroll view pan gestures to work as expected on iOS 9 and higher
    if ([otherGestureRecognizer isKindOfClass:NSClassFromString(@"UIScrollViewPanGestureRecognizer")] &&
        [self.collectionView.gestureRecognizers containsObject:otherGestureRecognizer]) {
        return YES;
    }
    
    return NO;
}

- (UILongPressGestureRecognizer*)longPressGestureRecognizer
{
    return self.customLongPressGestureRecognizer;
}

- (UIPanGestureRecognizer*)panGestureRecognizer
{
    return self.customPanGestureRecognizer;
}

- (void)invalidateLayoutIfNecessary {
    NSIndexPath *newIndexPath = [self.collectionView indexPathForItemAtPoint:self.currentView.center];
    NSIndexPath *previousIndexPath = self.selectedItemIndexPath;
    
    if ((newIndexPath == nil) || [newIndexPath isEqual:previousIndexPath]) {
        return;
    }
    
    if ([self.dataSource respondsToSelector:@selector(collectionView:itemAtIndexPath:canMoveToIndexPath:)] &&
        ![self.dataSource collectionView:self.collectionView itemAtIndexPath:previousIndexPath canMoveToIndexPath:newIndexPath]) {
        return;
    }
    
    self.selectedItemIndexPath = newIndexPath;
    
    if ([self.dataSource respondsToSelector:@selector(collectionView:itemAtIndexPath:willMoveToIndexPath:)]) {
        [self.dataSource collectionView:self.collectionView itemAtIndexPath:previousIndexPath willMoveToIndexPath:newIndexPath];
    }
    
    __weak typeof(self) weakSelf = self;
    [self.collectionView performBatchUpdates:^{
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf) {
 
            if([strongSelf.collectionView numberOfItemsInSection:previousIndexPath.section] == 1) {
                [strongSelf.collectionView deleteSections:[NSIndexSet indexSetWithIndex:previousIndexPath.section]];
                [strongSelf.collectionView insertSections:[NSIndexSet indexSetWithIndex:newIndexPath.section]];
            }
            else {
                [strongSelf.collectionView deleteItemsAtIndexPaths:@[ previousIndexPath ]];
                [strongSelf.collectionView insertItemsAtIndexPaths:@[ newIndexPath ]];
            }
        }
    } completion:^(BOOL finished) {
        __strong typeof(self) strongSelf = weakSelf;
        if ([strongSelf.dataSource respondsToSelector:@selector(collectionView:itemAtIndexPath:didMoveToIndexPath:)]) {
            [strongSelf.dataSource collectionView:strongSelf.collectionView itemAtIndexPath:previousIndexPath didMoveToIndexPath:newIndexPath];
        }
    }];
}

@end
