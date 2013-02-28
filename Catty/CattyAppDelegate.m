//
//  CattyAppDelegate.m
//  Catty
//
//  Created by Christof Stromberger on 07.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "CattyAppDelegate.h"

@implementation CattyAppDelegate

@synthesize window      = _window;
@synthesize fileManager = _fileManager;

//custom filemanager getter
- (FileManager*)fileManager {
    if (_fileManager == nil) {
        _fileManager = [[FileManager alloc] init];
    }
    
    return _fileManager;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    [self initNavigationBar];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void) initNavigationBar {
    
    UIImage *navbarimage = [[UIImage imageNamed:@"darkblue"]
                            resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    [[UINavigationBar appearance] setBackgroundImage:navbarimage
                                       forBarMetrics:UIBarMetricsDefault];
    
    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor colorWithRed:111.0f/255.0f green:142.0f/255.0f blue:155.0f/255.0f alpha:1.0f], UITextAttributeTextColor,
      [UIColor clearColor], UITextAttributeTextShadowColor,
      [UIFont fontWithName:@"Arial-Bold" size:0.0], UITextAttributeFont,
      nil]
     ];
    
}

@end
