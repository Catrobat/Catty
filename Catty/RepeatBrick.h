//
//  RepeatBrick.h
//  Catty
//
//  Created by Mattias Rauter on 27.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "ForeverBrick.h"

@interface RepeatBrick : ForeverBrick

#warning @mattias: I've changed the name of this property and the type from int to NSNumber*
@property (nonatomic, assign) NSNumber *timesToRepeat;

-(id)initWithNumberOfLoops:(NSNumber*)numberOfLoops;


@end
