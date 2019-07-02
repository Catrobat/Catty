/**
 *  Copyright (C) 2010-2019 The Catrobat Team
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


#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "FormulaEditorTextView.h"
#import "UIDefines.h"

#define IS_IPAD (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
#define IS_IPHONEPLUS (([Util screenHeight] - kIphone6PScreenHeight) ? NO : YES)

#define SAFE_BLOCK_CALL(__functor, ...)   \
do {    \
if (__functor) __functor(__VA_ARGS__);  \
} while (0)

#define TIMEOUT 30.0f

@protocol MYIntroductionDelegate;
@class SceneViewController;
@class ProjectLoadingInfo;
@class InputValidationResult;

@interface Util : NSObject

//#if TESTMODE // fails...
+ (BOOL)activateTestMode:(BOOL)activate;
//#endif

+ (NSString*)applicationDocumentsDirectory;

+ (UIViewController *)topViewControllerInViewController:(UIViewController *)viewController;

+ (UIViewController *)topmostViewController;

+ (void)alertWithText:(NSString*)text;

+ (void)alertWithTitle:(NSString*)title andText:(NSString*)text;

+ (void)askUserForVariableNameAndPerformAction:(SEL)action
                                        target:(id)target
                                   promptTitle:(NSString*)title
                                 promptMessage:(NSString*)message
                                minInputLength:(NSUInteger)minInputLength
                                maxInputLength:(NSUInteger)maxInputLength
                                        isList:(BOOL)isList
                                  andTextField:(FormulaEditorTextView *)textView
                                   initialText:(NSString*)initialText;

+ (NSString*)appName;

+ (NSString*)appVersion;

+ (NSString*)appBuildName;

+ (NSString*)appBuildVersion;

+ (NSString*)catrobatLanguageVersion;

+ (NSString*)catrobatMediaLicense;

+ (NSString*)catrobatProgramLicense;

+ (NSString*)deviceName;

+ (NSString*)platformName;

+ (NSOperatingSystemVersion)platformVersion;

+ (NSString*)platformVersionWithPatch;

+ (NSString*)platformVersionWithoutPatch;

/* Returns the screen size in pixel or points */
+ (CGSize)screenSize:(BOOL)inPixel;

/* Returns the screen height in pixel or points */
+ (CGFloat)screenHeight:(BOOL)inPixel;

/* Returns the screen width in pixel or points */
+ (CGFloat)screenWidth:(BOOL)inPixel;

/* Returns the screen height in points */
+ (CGFloat)screenHeight;

/* Returns the screen width in points */
+ (CGFloat)screenWidth;

+ (CATransition*)getPushCATransition;

+ (ProjectLoadingInfo*)lastUsedProjectLoadingInfo;

+ (void)setLastProjectWithName:(NSString*)projectName projectID:(NSString*)projectID;

+ (InputValidationResult*)validationResultWithName:(NSString *)name minLength:(NSUInteger)minLength maxlength:(NSUInteger)maxLength;

+ (void)askUserForUniqueNameAndPerformAction:(SEL)action
                                      target:(id)target
                                 promptTitle:(NSString*)title
                               promptMessage:(NSString*)message
                                 promptValue:(NSString*)value
                           promptPlaceholder:(NSString*)placeholder
                              minInputLength:(NSUInteger)minInputLength
                              maxInputLength:(NSUInteger)maxInputLength
                    invalidInputAlertMessage:(NSString*)invalidInputAlertMessage
                               existingNames:(NSArray*)existingNames;

+ (void)askUserForUniqueNameAndPerformAction:(SEL)action
                                      target:(id)target
                                cancelAction:(SEL)cancelAction
                                  withObject:(id)passingObject
                                 promptTitle:(NSString*)title
                               promptMessage:(NSString*)message
                                 promptValue:(NSString*)value
                           promptPlaceholder:(NSString*)placeholder
                              minInputLength:(NSUInteger)minInputLength
                              maxInputLength:(NSUInteger)maxInputLength
                    invalidInputAlertMessage:(NSString*)invalidInputAlertMessage
                               existingNames:(NSArray*)existingNames;

+ (void)askUserForTextAndPerformAction:(SEL)action
                                target:(id)target
                          cancelAction:(SEL)cancelAction
                            withObject:(id)passingObject
                           promptTitle:(NSString*)title
                         promptMessage:(NSString*)message
                           promptValue:(NSString*)value
                     promptPlaceholder:(NSString*)placeholder
                        minInputLength:(NSUInteger)minInputLength
                        maxInputLength:(NSUInteger)maxInputLength
              invalidInputAlertMessage:(NSString*)invalidInputAlertMessage;

+ (NSString*)uniqueName:(NSString*)nameToCheck existingNames:(NSArray*)existingNames;

+ (void)showNotificationWithMessage:(NSString*)message;

+ (void)showNotificationForSaveAction;

+ (CGFloat)detectCBLanguageVersionFromXMLWithPath:(NSString*)xmlPath;

+ (double)radiansToDegree:(double)rad;

+ (double)degreeToRadians:(double)deg;

+ (NSDictionary*)propertiesOfInstance:(id)instance;

+ (BOOL)isEqual:(id)object toObject:(id)objectToCompare;

+ (SpriteObject*)objectWithName:(NSString*)objectName forProject:(Project*)project;

+ (Sound*)soundWithName:(NSString*)objectName forObject:(SpriteObject*)object;

+ (Look*)lookWithName:(NSString*)objectName forObject:(SpriteObject*)object;

+ (NSArray*)allMessagesForProject:(Project*)project;

+ (BOOL)isNetworkError:(NSError*)error;

+ (void)defaultAlertForNetworkError;

+ (void)defaultAlertForUnknownError;

+ (NSDictionary*)getBrickInsertionDictionaryFromUserDefaults;

+ (void)setBrickInsertionDictionaryToUserDefaults:(NSDictionary*) statistics;

+ (void)incrementStatisticCountForBrickType:(kBrickType)brickType;

+ (void)printBrickStatistics;

+ (void)printSubsetOfTheMost:(NSUInteger)N;

+ (NSArray*)getSubsetOfTheMost:(NSUInteger)N usedBricksInDictionary:(NSDictionary*) brickCountDictionary;

+ (NSArray*)getSubsetOfTheMostFavoriteChosenBricks:(NSUInteger) amount;

+ (void)resetBrickStatistics;

+ (NSDictionary*)defaultBrickStatisticDictionary;

+ (NSString*)replaceBlockedCharactersForString:(NSString*)string;

+ (NSString*)enableBlockedCharactersForString:(NSString*)string;

+ (void)openUrlExternal:(NSURL*)url;

+ (void)setNetworkActivityIndicator:(BOOL)enabled;

+ (BOOL)isArduinoActivated;

+ (BOOL)isPhiroActivated;

+ (BOOL)isPhone;

@end
