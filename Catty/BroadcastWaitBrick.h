//
//  BroadcastWaitBrick.h
//  Catty
//
//  Created by Dominik Ziegler on 9/28/12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Brick.h"

@interface BroadcastWaitBrick : Brick

@property (nonatomic, strong) NSString *broadcastMessage;

-(id)initWithMessage:(NSString*)message;

@end
