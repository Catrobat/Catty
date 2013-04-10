//
//  BroadcastWaitDelegate.h
//  Catty
//
//  Created by Mattias Rauter on 20.02.13.
//  Copyright (c) 2013 Graz University of Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SpriteObject;

@protocol BroadcastWaitDelegate <NSObject>

-(void)registerSprite:(SpriteObject*)sprite forMessage:(NSString*)message;
-(void)performBroadcastWaitForMessage:(NSString*)message;

@end
