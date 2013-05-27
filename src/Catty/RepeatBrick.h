//
//  RepeatBrick.h
//  Catty
//
//  Created by Mattias Rauter on 27.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Foreverbrick.h"
@class Formula;

@interface Repeatbrick : Foreverbrick

@property (nonatomic, strong) Formula *timesToRepeat;

@end
