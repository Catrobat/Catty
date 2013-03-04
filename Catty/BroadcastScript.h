//
//  BroadcastScript.h
//  Catty
//
//  Created by Christof Stromberger on 28.02.13.
//  Copyright (c) 2013 Graz University of Technology. All rights reserved.
//

#import "Script.h"

@interface BroadcastScript : Script

#warning @mattias: I've added this property. Please implement it correctly... :-P
@property (nonatomic, strong) Sprite *sprite;
@property (nonatomic, strong) NSString *receivedMessage;

@end
