//
//  Util.m
//  Catty
//
//  Created by Christof Stromberger on 20.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Util.h"

@implementation Util


//retrieving path to appliaciton directory
+ (NSString *)applicationDocumentsDirectory 
{    
    NSArray *paths = 
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
    
//    //documents directory URL
//    NSURL *documentsDirectoryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
//    
//    //returns the URL to the application's Documents directory
//    return [documentsDirectoryURL absoluteString];
}

//logging possible errors and abort
+ (void)log:(NSError*)error {
    if (error) {
        NSLog(@"Error occured: %@", [error localizedDescription]);
        
        //maybe add further error handling here
        //...
        
        abort(); //stop application
    }
}


@end
