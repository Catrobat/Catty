//
//  RetailParser.m
//  Catty
//
//  Created by Christof Stromberger on 15.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "RetailParser.h"
#import "XMLParser.h"

@implementation RetailParser

- (Level*)generateObjectForLevel:(NSString*)path
{
    NSError *error;
    //opening xml file
    NSString *xmlFile = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    NSData* xmlData = [xmlFile dataUsingEncoding:NSUTF8StringEncoding];
    
    //passing xml file as nsdata into the xml parser
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:xmlData];
    
    XMLParser *parser = [[XMLParser alloc] initXMLParser];
    [xmlParser setDelegate:parser]; //parsing xml
    
    BOOL success = [xmlParser parse];
    
    if(success)
        NSLog(@"XML parser succeeded!");
    else
        NSLog(@"A XML parser ERROR occured!");
    
    Level *ret = parser.level;
    
    return ret;
}

@end
