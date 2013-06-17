/**
 *  Copyright (C) 2010-2013 The Catrobat Team
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

#import "Util.h"
#import "SceneViewController.h"
#import "Stage.h"
#import "ProgramDefines.h"
#import "ProgramLoadingInfo.h"

@implementation Util


+ (NSString *)applicationDocumentsDirectory 
{    
    NSArray *paths = 
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;

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


+ (ProgramLoadingInfo*) programLoadingInfoForProgramWithName:(NSString*)program
{
    NSString *documentsDirectoy = [Util applicationDocumentsDirectory];
    NSString *levelsPath = [NSString stringWithFormat:@"%@/%@", documentsDirectoy, kProgramsFolder];
    ProgramLoadingInfo *info = [[ProgramLoadingInfo alloc] init];
    info.basePath = [NSString stringWithFormat:@"%@/%@/", levelsPath, program];
    info.visibleName = program;
    
    return info;
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
