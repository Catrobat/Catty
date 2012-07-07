//
//  Costume.m
//  Catty
//
//  Created by Mattias Rauter on 17.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Costume.h"

@interface Costume ()


@end

@implementation Costume

@synthesize filePath = _filePath;
@synthesize name = _name;

#pragma mark - init methods
- (id)initWithPath:(NSString*)filePath
{
    self = [super init];
    if (self) 
    {
        self.name = nil;
        if (filePath == nil || [filePath length] == 0)
        {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:@"You cannot instantiate a costume without a file path"
                                         userInfo:nil];
            return nil;
        }
        else 
        {
            self.filePath = filePath;
        }
    }
    return self;
}


- (id)initWithName:(NSString*)name andPath:(NSString*)filePath
{
    self = [super init];
    if (self) 
    {
        self.name = name;
        if (filePath == nil || [filePath length] == 0)
        {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:@"You cannot instantiate a costume without a file path"
                                         userInfo:nil];
            return nil;
        }
        else 
        {
            self.filePath = filePath;
        }
    }
    return self;
}


#pragma mark - description
- (NSString*)description
{
    return [NSString stringWithFormat:@"Path: %@ Name: %@", self.filePath, self.name];
}

@end
