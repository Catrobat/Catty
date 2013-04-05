//
//  PlaySoundBrick.h
//  Catty
//
//  Created by Dominik Ziegler on 9/21/12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Brick.h"
@class Sound;

@interface Playsoundbrick : Brick

@property (nonatomic, strong) Sound *sound;

//-(id)initWithFileName:(NSString *)fileName;

@end
