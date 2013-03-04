//
//  BroadcastBrick.h
//  Catty
//
//  Created by Mattias Rauter on 18.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Brick.h"

@interface BroadcastBrick : Brick

@property (nonatomic, strong) NSString *broadcastMessage;

-(id)initWithMessage:(NSString*)message;

@end
