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

#import "BroadcastWaitHandler.h"
#import "SpriteObject.h"

@interface BroadcastWaitHandler()
@property (strong, nonatomic) NSMutableDictionary *spritesForMessages;
//@property (strong, nonatomic) NSLock *lock;
@end


@implementation BroadcastWaitHandler

- (NSMutableDictionary*)spritesForMessages
{
    // lazy instantiation
    if (!_spritesForMessages) {
        _spritesForMessages = [NSMutableDictionary dictionary];
    }
    return _spritesForMessages;
}

- (void)registerSprite:(SpriteObject *)sprite forMessage:(NSString *)message
{
//    [self.lock lock];
    @synchronized (self) {
        NSArray *sprites = [self.spritesForMessages objectForKey:message];
        [self.spritesForMessages removeObjectForKey:message];
        if (sprites == nil) {
            sprites = [NSArray arrayWithObject:sprite];
        } else {
            sprites = [sprites arrayByAddingObject:sprite];
        }
        [self.spritesForMessages setObject:sprites forKey:message];
    }
//    [self.lock unlock];
}

- (void)dealloc
{
    [self removeSpriteMessages];
}

//- (void)performBroadcastWaitForMessage:(NSString*)message
//{
//    NSArray *sprites = [self.spritesForMessages objectForKey:message];
//    dispatch_semaphore_t sema = dispatch_semaphore_create([sprites count]);
////    dispatch_queue_t broadcastWaitQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
//    dispatch_queue_t broadcastWaitQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
//    for (SpriteObject *sprite in sprites) {
//        if (! [sprite isKindOfClass:[SpriteObject class]]) {
//            NSError(@"sprite is not a SpriteObject...abort()");
//        }
//        __weak SpriteObject *weakSpriteObject = sprite;
//        dispatch_async(broadcastWaitQueue, ^{
//            [weakSpriteObject performBroadcastWaitScriptWithMessage:message with:sema];
//        });
//        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
//    }
//    NSInteger numberOfSprites = [sprites count];
//    for (NSInteger counter = 0; counter < numberOfSprites; ++counter) {
//        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
//    }
//    dispatch_group_t group = dispatch_group_create();
//    dispatch_group_async(group, broadcastWaitQueue, ^{});
//    for (NSInteger counter = 0; counter < numberOfSprites; ++counter) {
//        dispatch_semaphore_signal(sema);
//    }
//    // Block until we're ready
//}

- (void)removeSpriteMessages
{
    if (self.spritesForMessages.count)
        [self.spritesForMessages removeAllObjects];
}

@end
