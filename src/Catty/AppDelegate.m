/**
 *  Copyright (C) 2010-2015 The Catrobat Team
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
#import "CatrobatTableViewController.h"
#import "Pocket_Code-Swift.h"
#import "NetworkDefines.h"
#import "BaseTableViewController.h"

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
    
    Siren* siren = Siren.sharedInstance;
    siren.appID = kAppStoreIdentifier;

    [siren checkVersion:kSirenUpdateIntervallDaily];
    [siren setAlertType:kSirenAlertTypeOption];
    
    [self initNavigationBar];
    
    [UITextField appearance].keyboardAppearance = UIKeyboardAppearanceDark;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObject:@"YES"
                                                            forKey:@"lockiphone"];
    [defaults registerDefaults:appDefaults];
    [defaults synchronize];
    application.statusBarHidden = NO;
    application.statusBarStyle = UIStatusBarStyleLightContent;
    return YES;
}

-(void)applicationDidBecomeActive:(UIApplication *)application
{
    [Siren.sharedInstance checkVersion:kSirenUpdateIntervallDaily];
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
    
    [Siren.sharedInstance checkVersion:kSirenUpdateIntervallDaily];
}

- (void)initNavigationBar
{
    [UINavigationBar appearance].barTintColor = UIColor.navBarColor;
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor navTextColor]}];
    self.window.tintColor = [UIColor globalTintColor];
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    UINavigationController *vc = (UINavigationController*)self.window.rootViewController;
    
    [vc popToRootViewControllerAnimated:YES];
    
    if ([vc.topViewController isKindOfClass:[CatrobatTableViewController class]]){
        CatrobatTableViewController* ctvc = (CatrobatTableViewController*)vc.topViewController;
        
        NSCharacterSet* blockedCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:kTextFieldAllowedCharacters]
                                               invertedSet];
        
        [Util askUserForUniqueNameAndPerformAction:@selector(addProgramWithName:)
                                            target:ctvc
                                       promptTitle:kLocalizedNewProgram
                                     promptMessage:[NSString stringWithFormat:@"%@:", kLocalizedProgramName]
                                       promptValue:nil
                                 promptPlaceholder:kLocalizedEnterYourProgramNameHere
                                    minInputLength:kMinNumOfProgramNameCharacters
                                    maxInputLength:kMaxNumOfProgramNameCharacters
                               blockedCharacterSet:blockedCharacterSet
                          invalidInputAlertMessage:kLocalizedProgramNameAlreadyExistsDescription
                                     existingNames:[Program allProgramNames]];
        
        //[ctvc reloadInputViews];
        return YES;
    }
    

    
    return NO;
}

@end
