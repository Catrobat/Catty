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
    NSLock *finishedLock = [[NSLock alloc]init];
    __block NSNumber *numOfFinishedSprites = [NSNumber numberWithInt:0];
    
    NSArray *sprites = [self.spritesForMessages objectForKey:message];
    int numOfAllSprites = [sprites count];

    for (SpriteObject *sprite in sprites) {
        
        if ([sprite isKindOfClass:[SpriteObject class]] == NO) {
            NSLog(@"sprite is not a SpriteObject...abort()");
            abort();
        }


        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [sprite performBroadcastWaitScript_calledFromBroadcastWaitDelegate_withMessage:message];
    
            [finishedLock lock];
            numOfFinishedSprites = [NSNumber numberWithInt:numOfFinishedSprites.intValue+1];
            [finishedLock unlock];
            
        });
    }
    
    // TODO: avoid busy waiting!!
    while (numOfAllSprites != numOfFinishedSprites.intValue) {
        // TODO: yield?!
    }
    
    // finished!
}

@end
