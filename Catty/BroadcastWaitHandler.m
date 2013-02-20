//
//  BroadcastWaitHandler.m
//  Catty
//
//  Created by Mattias Rauter on 20.02.13.
//  Copyright (c) 2013 Graz University of Technology. All rights reserved.
//

#import "BroadcastWaitHandler.h"

@interface BroadcastWaitHandler()
@property (strong, nonatomic) NSMutableDictionary *numOfObserversForNotificationMessage;
@property (strong, nonatomic) NSMutableDictionary *numOfObserversForNotificationMessageList;
@end


@implementation BroadcastWaitHandler


@synthesize numOfObserversForNotificationMessage = _numOfObserversForNotificationMessage;
@synthesize numOfObserversForNotificationMessageList = _numOfObserversForNotificationMessageList;


-(NSDictionary *)numOfObserversForNotificationMessage
{
    if (!_numOfObserversForNotificationMessage)
        _numOfObserversForNotificationMessage = [[NSMutableDictionary alloc]init];
    return _numOfObserversForNotificationMessage;
}
-(NSDictionary *)numOfObserversForNotificationMessageList
{
    if (!_numOfObserversForNotificationMessageList)
        _numOfObserversForNotificationMessageList = [[NSMutableDictionary alloc]init];
    return _numOfObserversForNotificationMessageList;
}

-(void)increaseNumberOfObserversForNotificationMessage:(NSString*)notificationMessage;
{
    NSObject *object = [self.numOfObserversForNotificationMessage objectForKey:notificationMessage];
    int newNumber = 1;
    if (object != nil) {
        newNumber += ((NSNumber*)object).intValue;
        [self.numOfObserversForNotificationMessage removeObjectForKey:notificationMessage];
    }
    [self.numOfObserversForNotificationMessage setValue:[NSNumber numberWithInt:1] forKey:notificationMessage];
}

-(void)object:(id)object isWaitingForAllObserversOfMessage:(NSString *)notificationMessage withResponseID:(NSString*)responseID
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleBroadcastWaitResponse:) name:responseID object:nil];
    NSNumber *numberOfObservers = [NSNumber numberWithInt:((NSNumber*)[self.numOfObserversForNotificationMessage valueForKey:notificationMessage]).intValue];
    [self.numOfObserversForNotificationMessageList setValue:numberOfObservers forKey:responseID];
}

-(void)handleBroadcastWaitResponse:(NSNotification*)notification
{
    NSString *responseID = notification.name;
    NSObject *object = [self.numOfObserversForNotificationMessageList objectForKey:responseID];
    if (object != nil) {
        int intValue = ((NSNumber*)object).intValue;
        [self.numOfObserversForNotificationMessageList removeObjectForKey:responseID];
        if (intValue > 0) {
            intValue -= 1;
            [self.numOfObserversForNotificationMessageList setValue:[NSNumber numberWithInt:intValue] forKey:responseID];
        } else {
            // TODO inform waiting object
        }
    }
}

-(BOOL)polling4testing__didAllObserversFinishForResponseID:(NSString *)responseID
{
    if ([self.numOfObserversForNotificationMessageList objectForKey:responseID] != nil)
        return NO;
    else
        return YES;
}

@end
