//
//  BroadcastWaitHandler.m
//  Catty
//
//  Created by Mattias Rauter on 20.02.13.
//  Copyright (c) 2013 Graz University of Technology. All rights reserved.
//

#import "BroadcastWaitHandler.h"
#import "SpriteObject.h"

@interface BroadcastWaitHandler()
@property (strong, nonatomic) NSMutableDictionary *spritesForMessages; // key: (NSString*)msg   value: (NSArray*)sprites
@property (strong, nonatomic) NSLock *lock;
@end


@implementation BroadcastWaitHandler



-(NSMutableDictionary *)spritesForMessages
{
    if (!_spritesForMessages)
        _spritesForMessages = [[NSMutableDictionary alloc]init];
    return _spritesForMessages;
}


-(void)registerSprite:(SpriteObject *)sprite forMessage:(NSString *)message
{
    [self.lock lock];
    NSArray *sprites = [self.spritesForMessages objectForKey:message];
    [self.spritesForMessages removeObjectForKey:message];
    if (sprites == nil) {
        sprites = [NSArray arrayWithObject:sprite];
    } else {
        sprites = [sprites arrayByAddingObject:sprite];
    }
    [self.spritesForMessages setObject:sprites forKey:message];
    [self.lock unlock];
}


-(void)performBroadcastWaitForMessage:(NSString*)message
{
    
    NSString* queueString = [NSString stringWithFormat:@"at.tugraz.ist.%@", message];
    const char *queueName = [message cStringUsingEncoding:NSUTF8StringEncoding];
    
    dispatch_queue_t broadcastWaitQueue = dispatch_queue_create(queueName, NULL);
    dispatch_group_t group = dispatch_group_create();

    NSArray *sprites = [self.spritesForMessages objectForKey:message];
    for (SpriteObject *sprite in sprites) {

        if ([sprite isKindOfClass:[SpriteObject class]] == NO) {
            NSLog(@"sprite is not a SpriteObject...abort()");
            abort();
        }
        
        dispatch_async(broadcastWaitQueue, ^{
            [sprite performBroadcastWaitScript_calledFromBroadcastWaitDelegate_withMessage:message];
        });
    }
    
    
    
    dispatch_group_async(group, broadcastWaitQueue, ^{
    });
    
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER); // Block until we're ready
    // Now we're good to call it:
    
    
    
//    NSLock *finishedLock = [[NSLock alloc]init];
//
//    __block NSInteger numOfFinishedSprites = 0;
//    
//    NSArray *sprites = [self.spritesForMessages objectForKey:message];
//    int numOfAllSprites = [sprites count];
//    
//
//    for (SpriteObject *sprite in sprites) {
//        
//        if ([sprite isKindOfClass:[SpriteObject class]] == NO) {
//            NSLog(@"sprite is not a SpriteObject...abort()");
//            abort();
//        }
//
//
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            [sprite performBroadcastWaitScript_calledFromBroadcastWaitDelegate_withMessage:message];
//    
//            [finishedLock lock];
//            numOfFinishedSprites++;
//            [conditionLock unlockWithCondition:numOfFinishedSprites];
//            [finishedLock unlock];
//            
//        });
//    }
//    
    
//    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//        
//        NSCo
//
//        // TODO: avoid busy waiting!!
//        while (numOfAllSprites != numOfFinishedSprites.intValue) {
//            // TODO: yield?!
//        }
//        
//    });
    
    // finished!
}

@end
