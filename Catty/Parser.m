//
//  RetailParser.m
//  Catty
//
//  Created by Christof Stromberger on 15.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Parser.h"
#import "GDataXMLNode.h"
#import "ProjectParser.h"

@implementation Parser

- (Level*)generateObjectForLevel:(NSString*)path
{
    NSError *error;
    //opening xml file
    NSString *xmlFile = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    NSData* xmlData = [xmlFile dataUsingEncoding:NSUTF8StringEncoding];
    
    //using dom parser (gdata)
    
    ProjectParser *parser = [[ProjectParser alloc] init];
    Level *ret = [parser loadLevel:xmlData];
    
    
    return ret;
}

@end
