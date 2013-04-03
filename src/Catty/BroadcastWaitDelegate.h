//
//  BroadcastWaitDelegate.h
//  Catty
//
//  Created by Mattias Rauter on 20.02.13.
//  Copyright (c) 2013 Graz University of Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BroadcastWaitDelegate <NSObject>

-(void)increaseNumberOfObserversForNotificationMessage:(NSString*)notificationMessage;
-(void)object:(id)object isWaitingForAllObserversOfMessage:(NSString*)notificationMessage withResponseID:(NSString*)responseID;
-(BOOL)polling4testing__didAllObserversFinishForResponseID:(NSString*)responseID;

@end
