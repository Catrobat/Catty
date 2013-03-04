//
//  PlaySoundBrick.h
//  Catty
//
//  Created by Dominik Ziegler on 9/21/12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Brick.h"
#import "Sound.h"

@interface PlaySoundBrick : Brick


#warning @mattias: Added sound property, please implement it... dunno if it's the same as fileName?!
@property (nonatomic, strong) Sound *sound;

@property (nonatomic, strong) NSString *fileName;

-(id)initWithFileName:(NSString *)fileName;

@end
