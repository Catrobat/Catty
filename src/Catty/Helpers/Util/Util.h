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


#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "FormulaEditorTextView.h"
#import "UIDefines.h"

#define IS_IPAD (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
#define IS_IPHONE4 (([Util screenHeight] - kIphone4ScreenHeight) ? NO : YES)
#define IS_IPHONE5 (([Util screenHeight] - kIphone5ScreenHeight) ? NO : YES)
#define IS_IPHONE6 (([Util screenHeight] - kIphone6ScreenHeight) ? NO : YES)
#define IS_IPHONE6P (([Util screenHeight] - kIphone6PScreenHeight) ? NO : YES)

#define IS_OS_5_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0)
#define IS_OS_6_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)
#define IS_OS_7_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define IS_OS_9_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)

#define TIMEOUT 30.0f

@protocol MYIntroductionDelegate;
@class SceneViewController;
@class CatrobatAlertController;
@protocol CatrobatAlertViewDelegate;
@protocol CatrobatActionSheetDelegate;
@class ProgramLoadingInfo;

@interface Util : NSObject

//#if TESTMODE // fails...
+ (BOOL)activateTestMode:(BOOL)activate;
//#endif

+ (NSString*)applicationDocumentsDirectory;

+ (void)showComingSoonAlertView;

+ (void)showIntroductionScreenInView:(UIView*)view delegate:(id<MYIntroductionDelegate>)delegate;

+ (CatrobatAlertController*)alertWithText:(NSString*)text;

+ (CatrobatAlertController*)alertWithTitle:(NSString*)title
                             andText:(NSString*)text;

+ (CatrobatAlertController*)alertWithText:(NSString*)text
                           delegate:(id<CatrobatAlertViewDelegate>)delegate
                                tag:(NSInteger)tag;

+ (CatrobatAlertController*)confirmAlertWithTitle:(NSString*)title
                                    message:(NSString*)message
                                   delegate:(id<CatrobatAlertViewDelegate>)delegate
                                        tag:(NSInteger)tag;

+ (CatrobatAlertController*)promptWithTitle:(NSString*)title
                              message:(NSString*)message
                             delegate:(id<CatrobatAlertViewDelegate>)delegate
                          placeholder:(NSString*)placeholder
                                  tag:(NSInteger)tag;

+ (CatrobatAlertController*)promptWithTitle:(NSString*)title
                              message:(NSString*)message
                             delegate:(id<CatrobatAlertViewDelegate>)delegate
                          placeholder:(NSString*)placeholder
                                  tag:(NSInteger)tag
                                value:(NSString*)value
                               target:(id)target;

+ (CatrobatAlertController*)actionSheetWithTitle:(NSString*)title
                                    delegate:(id<CatrobatActionSheetDelegate>)delegate
                      destructiveButtonTitle:(NSString*)destructiveButtonTitle
                           otherButtonTitles:(NSArray*)otherButtonTitles
                                         tag:(NSInteger)tag
                                        view:(UIView*)view;

+ (void)askUserForVariableNameAndPerformAction:(SEL)action
                                        target:(id)target
                                   promptTitle:(NSString*)title
                                 promptMessage:(NSString*)message
                                minInputLength:(NSUInteger)minInputLength
                                maxInputLength:(NSUInteger)maxInputLength
                           blockedCharacterSet:(NSCharacterSet*)blockedCharacterSet
                      invalidInputAlertMessage:(NSString*)invalidInputAlertMessage
                                  andTextField:(FormulaEditorTextView *)textView;

+ (void)askUserForReportMessageAndPerformAction:(SEL)action
                                         target:(id)target
                                    promptTitle:(NSString*)title
                                  promptMessage:(NSString*)message
                                 minInputLength:(NSUInteger)minInputLength
                                 maxInputLength:(NSUInteger)maxInputLength
                            blockedCharacterSet:(NSCharacterSet*)blockedCharacterSet
                       invalidInputAlertMessage:(NSString*)invalidInputAlertMessage;

+ (NSString*)appName;

+ (NSString*)appVersion;

+ (NSString*)appBuildName;

+ (NSString*)appBuildVersion;

+ (NSString*)catrobatLanguageVersion;

+ (NSString*)catrobatMediaLicense;

+ (NSString*)catrobatProgramLicense;

+ (NSString*)deviceName;

+ (NSString*)platformName;

+ (NSString*)platformVersion;

+ (CGSize)screenSize;

+ (CGFloat)screenHeight;

+ (CGFloat)screenWidth;

+ (CATransition*)getPushCATransition;

+ (ProgramLoadingInfo*)lastUsedProgramLoadingInfo;

+ (void)setLastProgramWithName:(NSString*)programName programID:(NSString*)programID;

+ (void)askUserForUniqueNameAndPerformAction:(SEL)action
                                      target:(id)target
                                 promptTitle:(NSString*)title
                               promptMessage:(NSString*)message
                                 promptValue:(NSString*)value
                           promptPlaceholder:(NSString*)placeholder
                              minInputLength:(NSUInteger)minInputLength
                              maxInputLength:(NSUInteger)maxInputLength
                         blockedCharacterSet:(NSCharacterSet*)blockedCharacterSet
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
                         blockedCharacterSet:(NSCharacterSet*)blockedCharacterSet
                    invalidInputAlertMessage:(NSString*)invalidInputAlertMessage
                               existingNames:(NSArray*)existingNames;

+ (void)askUserForTextAndPerformAction:(SEL)action
                                target:(id)target
                           promptTitle:(NSString*)title
                         promptMessage:(NSString*)message
                           promptValue:(NSString*)value
                     promptPlaceholder:(NSString*)placeholder
                        minInputLength:(NSUInteger)minInputLength
                        maxInputLength:(NSUInteger)maxInputLength
                   blockedCharacterSet:(NSCharacterSet*)blockedCharacterSet
              invalidInputAlertMessage:(NSString*)invalidInputAlertMessage;

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
                   blockedCharacterSet:(NSCharacterSet*)blockedCharacterSet
              invalidInputAlertMessage:(NSString*)invalidInputAlertMessage;

+ (void)addObjectAlertForProgram:(Program*)program andPerformAction:(SEL)action onTarget:(id)target withCancel:(SEL)cancel withCompletion:(void(^)(NSString*))completion;

+ (NSString*)uniqueName:(NSString*)nameToCheck existingNames:(NSArray*)existingNames;

+ (CGFloat)detectCBLanguageVersionFromXMLWithPath:(NSString*)xmlPath;

+ (double)radiansToDegree:(double)rad;

+ (double)degreeToRadians:(double)deg;

+ (NSDictionary*)propertiesOfInstance:(id)instance;

+ (BOOL)isEqual:(id)object toObject:(id)objectToCompare;

+ (SpriteObject*)objectWithName:(NSString*)objectName forProgram:(Program*)program;

+ (Sound*)soundWithName:(NSString*)objectName forObject:(SpriteObject*)object;

+ (Look*)lookWithName:(NSString*)objectName forObject:(SpriteObject*)object;

+ (NSArray*)allMessagesForProgram:(Program*)program;

+ (void)alertView:(CatrobatAlertController*)alertView clickedButtonAtIndex:(NSInteger)index;

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

+ (BOOL)isArduinoActivated;

+ (BOOL)isPhiroActivated;

+ (BOOL)isProductionServerActivated;

@end
