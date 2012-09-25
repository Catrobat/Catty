//
//  Util.h
//  Catty
//
//  Created by Christof Stromberger on 20.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

//timeout for nsurlrequests
#define TIMEOUT 30.0f

@interface Util : NSObject

+ (NSString*)applicationDocumentsDirectory;
+ (void)log:(NSError*)error;
+ (void)showComingSoonAlertView;

@end
