//
//  ProgramManager.m
//  Catty
//
//  Created by Dominik Ziegler on 5/6/13.
//
//

#import "ProgramManager.h"

@implementation ProgramManager

static ProgramManager *sharedProgramManager = nil;


+ (ProgramManager *) sharedProgramManager {
    
    @synchronized(self) {
        if (sharedProgramManager == nil) {
            sharedProgramManager = [[ProgramManager alloc] init];
        }
    }
    return sharedProgramManager;
}



@end
