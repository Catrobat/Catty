//
//  ProgramManager.h
//  Catty
//
//  Created by Dominik Ziegler on 5/6/13.
//
//

#import <Foundation/Foundation.h>

@class Program;

@interface ProgramManager : NSObject

@property (nonatomic, weak) Program* program;

+(ProgramManager *)sharedProgramManager;

@end
