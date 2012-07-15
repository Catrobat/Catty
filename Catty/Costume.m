//
//  Costume.m
//  Catty
//
//  Created by Mattias Rauter on 17.04.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Costume.h"

@interface Costume ()


@end

@implementation Costume

@synthesize costumeFileName = _costumeFileName;
@synthesize costumeName = _costumeName;

#pragma mark - init methods
- (id)initWithPath:(NSString*)filePath
{
    self = [super init];
    if (self) 
    {
        self.costumeName = nil;
        if (filePath == nil || [filePath length] == 0)
        {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:@"You cannot instantiate a costume without a file path"
                                         userInfo:nil];
            return nil;
        }
        else 
        {
            self.costumeFileName = filePath;
        }
    }
    return self;
}


- (id)initWithName:(NSString*)name andPath:(NSString*)filePath
{
    self = [super init];
    if (self) 
    {
        self.costumeName = name;
        if (filePath == nil || [filePath length] == 0)
        {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:@"You cannot instantiate a costume without a file path"
                                         userInfo:nil];
            return nil;
        }
        else 
        {
            self.costumeFileName = filePath;
        }
    }
    return self;
}


#pragma mark - description
- (NSString*)description
{
    return [NSString stringWithFormat:@"Path: %@ Name: %@", self.costumeFileName, self.costumeName];
}

@end
