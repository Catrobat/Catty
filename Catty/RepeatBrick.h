//
//  RepeatBrick.h
//  Catty
//
//  Created by Mattias Rauter on 27.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "ForeverBrick.h"

@interface RepeatBrick : ForeverBrick

@property (nonatomic, strong) NSNumber *timesToRepeat;

-(id)initWithNumberOfLoops:(NSNumber*)numberOfLoops;


@end
