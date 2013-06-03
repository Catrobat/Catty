//
//  Util.m
//  Catty
//
//  Created by Christof Stromberger on 20.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Util.h"
#import "StageViewController.h"
#import "Stage.h"
#import "ProgramDefines.h"
#import "ProgramLoadingInfo.h"

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


+ (void)showComingSoonAlertView {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Catty"
                          message:@"This feature is coming soon!"
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
}


+ (void)alertWithText:(NSString*)text {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Catty"
                          message:text
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];}


+(CGFloat)getScreenHeight {
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    return screenRect.size.height;
}



+ (CATransition*)getPushCATransition
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromRight;
    return transition;
}


+ (StageViewController*)createStageViewControllerWithProgram:(NSString*)program
{
    StageViewController* viewController = [[StageViewController alloc] init];
    [viewController startWithRoot:[Stage class] supportHighResolutions:YES doubleOnPad:YES];
    
    NSString *documentsDirectoy = [Util applicationDocumentsDirectory];
    NSString *levelsPath = [NSString stringWithFormat:@"%@/%@", documentsDirectoy, kProgramsFolder];
    ProgramLoadingInfo *info = [[ProgramLoadingInfo alloc] init];
    info.basePath = [NSString stringWithFormat:@"%@/%@/", levelsPath, program];
    info.visibleName = program;
    viewController.programLoadingInfo = info;


    return viewController;
}

+ (NSString*)lastProgram
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* lastProgram = [userDefaults objectForKey:kLastProgram];
    if(!lastProgram) {
        [userDefaults setObject:kDefaultProject forKey:kLastProgram];
        [userDefaults synchronize];
        lastProgram = kDefaultProject;
    }
    return lastProgram;
    
}

+ (void)setLastProgram:(NSString*)visibleName
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:visibleName forKey:kLastProgram];
    [userDefaults synchronize];
    
}


+(double) radiansToDegree:(float)rad
{
    return rad * 180.0 / M_PI;
}

+(double) degreeToRadians:(float)deg
{
    return deg * M_PI / 180.0;
}


@end
