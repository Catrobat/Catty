/**
 *  Copyright (C) 2010-2016 The Catrobat Team
 *  (http://developer.catrobat.org/credits)
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *
 *  An additional term exception under section 7 of the GNU Affero
 *  General Public License, version 3, is available at
 *  (http://developer.catrobat.org/license_additional_term)
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU Affero General Public License for more details.
 *
 *  You should have received a copy of the GNU Affero General Public License
 *  along with this program.  If not, see http://www.gnu.org/licenses/.
 */

#import "AppDelegate.h"
#import "FileManager.h"
#import "Util.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import <AVFoundation/AVFoundation.h>
#import "ScenePresenterViewController.h"
#import "Pocket_Code-Swift.h"
#import "NetworkDefines.h"
#import "KeychainUserDefaultsDefines.h"
#import "CatrobatTableViewController.h"

void uncaughtExceptionHandler(NSException *exception)
{
    NSError(@"uncaught exception: %@", exception.description);
}

@implementation AppDelegate

- (FileManager*)fileManager
{
    if (_fileManager == nil)
        _fileManager = [[FileManager alloc] init];
    return _fileManager;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    [self initNavigationBar];
    
    [SwiftBridge sirenBridgeApplicationDidFinishLaunching];
    
    [UITextField appearance].keyboardAppearance = UIKeyboardAppearanceDefault;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObject:@"YES"
                                                            forKey:@"lockiphone"];
    [defaults registerDefaults:appDefaults];
    
    application.statusBarHidden = NO;
    application.statusBarStyle = UIStatusBarStyleLightContent;
    
    if (![Util isPhiroActivated]) {
        [defaults setBool:NO forKey:kUsePhiroBricks];
    }
    if (![Util isArduinoActivated]) {
        [defaults setBool:NO forKey:kUseArduinoBricks];
    }
    [defaults synchronize];
    return YES;
}

-(void)applicationDidBecomeActive:(UIApplication *)application
{
    [SwiftBridge sirenApplicationDidBecomeActive];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    UINavigationController *vc = (UINavigationController*)self.window.rootViewController;
    
    if ([vc.topViewController isKindOfClass:[ScenePresenterViewController class]]){
        ScenePresenterViewController* spvc = (ScenePresenterViewController*)vc.topViewController;
        [spvc pauseAction];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    UINavigationController *vc = (UINavigationController*)self.window.rootViewController;
    
    if ([vc.topViewController isKindOfClass:[ScenePresenterViewController class]]){
        ScenePresenterViewController* spvc = (ScenePresenterViewController*)vc.topViewController;
        [spvc resumeAction];
    }
    
    [SwiftBridge sirenApplicationWillEnterForeground];
}

- (void)initNavigationBar
{
    [UINavigationBar appearance].barTintColor = UIColor.navBarColor;
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor navTextColor]}];
    self.window.tintColor = [UIColor globalTintColor];
}

-(BOOL)application:(UIApplication* )application
           openURL:(NSURL* )url
 sourceApplication:(NSString* )sourceApplication
        annotation:(id)annotation
{
    UINavigationController* vc = (UINavigationController*)self.window.rootViewController;
    [vc popToRootViewControllerAnimated:YES];
    
    if ([vc.topViewController isKindOfClass:[CatrobatTableViewController class]]){
        CatrobatTableViewController* ctvc = (CatrobatTableViewController*)vc.topViewController;
        [ctvc addProgramFromInbox];
        return YES;
    }
    return NO;
}

@end
