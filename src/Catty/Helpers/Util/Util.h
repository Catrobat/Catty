/**
 *  Copyright (C) 2010-2020 The Catrobat Team
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
@protocol BrickProtocol;
@class SceneViewController;
@class ProjectLoadingInfo;
@class InputValidationResult;
@class Util;

@interface Util : NSObject

//#if TESTMODE // fails...
+ (BOOL)activateTestMode:(BOOL)activate;
//#endif

+ (NSString* _Nullable)applicationDocumentsDirectory;

+ (UIViewController* _Nullable)topViewControllerInViewController:(UIViewController* _Nullable)viewController;

+ (UIViewController* _Nonnull)topmostViewController;

+ (void)alertWithText:(NSString* _Nullable)text;

+ (void)alertWithTitle:(NSString* _Nullable)title andText:(NSString* _Nullable)text;

+ (void)askUserForVariableNameAndPerformAction:(SEL _Nullable)action
                                        target:(id _Nullable)target
                                   promptTitle:(NSString* _Nullable)title
                                 promptMessage:(NSString* _Nullable)message
                                minInputLength:(NSUInteger)minInputLength
                                maxInputLength:(NSUInteger)maxInputLength
                                        isList:(BOOL)isList
                                  andTextField:(FormulaEditorTextView* _Nullable)textView
                                   initialText:(NSString* _Nullable)initialText;

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

+ (CGFloat)statusBarHeight;

+ (CATransition* _Nonnull)getPushCATransition;

+ (ProjectLoadingInfo* _Nonnull)lastUsedProjectLoadingInfo;

+ (void)setLastProjectWithName:(NSString* _Nullable)projectName projectID:(NSString* _Nullable)projectID;

+ (InputValidationResult* _Nullable)validationResultWithName:(NSString* _Nullable)name minLength:(NSUInteger)minLength maxlength:(NSUInteger)maxLength;

+ (void)askUserForUniqueNameAndPerformAction:(SEL _Nullable)action
                                      target:(id _Nullable)target
                                 promptTitle:(NSString* _Nullable)title
                               promptMessage:(NSString* _Nullable)message
                                 promptValue:(NSString* _Nullable)value
                           promptPlaceholder:(NSString* _Nullable)placeholder
                              minInputLength:(NSUInteger)minInputLength
                              maxInputLength:(NSUInteger)maxInputLength
                    invalidInputAlertMessage:(NSString* _Nullable)invalidInputAlertMessage
                               existingNames:(NSArray* _Nullable)existingNames;

+ (void)askUserForUniqueNameAndPerformAction:(SEL _Nullable)action
                                      target:(id _Nullable)target
                                cancelAction:(SEL _Nullable)cancelAction
                                  withObject:(id _Nullable)passingObject
                                 promptTitle:(NSString* _Nullable)title
                               promptMessage:(NSString* _Nullable)message
                                 promptValue:(NSString* _Nullable)value
                           promptPlaceholder:(NSString* _Nullable)placeholder
                              minInputLength:(NSUInteger)minInputLength
                              maxInputLength:(NSUInteger)maxInputLength
                    invalidInputAlertMessage:(NSString* _Nullable)invalidInputAlertMessage
                               existingNames:(NSArray* _Nullable)existingNames;

+ (void)askUserForTextAndPerformAction:(SEL _Nullable)action
                                target:(id _Nullable)target
                          cancelAction:(SEL _Nullable)cancelAction
                            withObject:(id _Nullable)passingObject
                           promptTitle:(NSString* _Nullable)title
                         promptMessage:(NSString* _Nullable)message
                           promptValue:(NSString* _Nullable)value
                     promptPlaceholder:(NSString* _Nullable)placeholder
                        minInputLength:(NSUInteger)minInputLength
                        maxInputLength:(NSUInteger)maxInputLength
              invalidInputAlertMessage:(NSString* _Nullable)invalidInputAlertMessage;

+ (NSString* _Nullable)uniqueName:(NSString* _Nullable)nameToCheck existingNames:(NSArray* _Nullable)existingNames;

+ (void)showNotificationWithMessage:(NSString* _Nullable)message;

+ (void)showNotificationForSaveAction;

+ (CGFloat)detectCBLanguageVersionFromXMLWithPath:(NSString* _Nullable)xmlPath;

+ (double)radiansToDegree:(double)rad;

+ (double)degreeToRadians:(double)deg;

+ (NSDictionary* _Nullable)propertiesOfInstance:(id _Nullable)instance;

+ (BOOL)isEqual:(id _Nullable)object toObject:(id _Nullable)objectToCompare;

+ (SpriteObject* _Nullable)objectWithName:(NSString* _Nullable)objectName forProject:(Project* _Nullable)project;

+ (Sound* _Nullable)soundWithName:(NSString* _Nullable)objectName forObject:(SpriteObject* _Nullable)object;

+ (Look* _Nullable)lookWithName:(NSString* _Nullable)objectName forObject:(SpriteObject* _Nullable)object;

+ (NSMutableOrderedSet* _Nullable)allMessagesForProject:(Project* _Nonnull)project;

+ (BOOL)isNetworkError:(NSError* _Nullable)error;

+ (void)defaultAlertForNetworkError;

+ (void)defaultAlertForUnknownError;

+ (NSDictionary* _Nullable)getBrickInsertionDictionaryFromUserDefaults;

+ (void)setBrickInsertionDictionaryToUserDefaults:(NSDictionary* _Nullable) statistics;

+ (void)incrementStatisticCountForBrick:(id<BrickProtocol> _Nullable)brick;

+ (void)printBrickStatistics;

+ (void)printSubsetOfTheMost:(NSUInteger)N;

+ (NSArray* _Nullable)getSubsetOfTheMost:(NSUInteger)N usedBricksInDictionary:(NSDictionary* _Nullable) brickCountDictionary;

+ (NSArray* _Nullable)getSubsetOfTheMostFavoriteChosenBricks:(NSUInteger) amount;

+ (void)resetBrickStatistics;

+ (NSDictionary* _Nullable)defaultBrickStatisticDictionary;

+ (NSString* _Nullable)replaceBlockedCharactersForString:(NSString* _Nullable)string;

+ (NSString* _Nullable)enableBlockedCharactersForString:(NSString* _Nullable)string;

+ (void)openUrlExternal:(NSURL* _Nullable)url;

+ (void)setNetworkActivityIndicator:(BOOL)enabled;

+ (BOOL)isArduinoActivated;

+ (BOOL)isPhiroActivated;

+ (BOOL)isPhone;

+ (NSString* _Nonnull)defaultSceneNameForSceneNumber:(NSUInteger)sceneNumber;

@end
