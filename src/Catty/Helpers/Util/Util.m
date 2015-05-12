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

#import "Util.h"
#import "ScenePresenterViewController.h"
#import "ProgramDefines.h"
#import "ProgramLoadingInfo.h"
#import "UIDefines.h"
#import "LanguageTranslationDefines.h"
#import "CatrobatAlertView.h"
#import "CatrobatActionSheet.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "ActionSheetAlertViewTags.h"
#import "DataTransferMessage.h"
#import "UIImage+CatrobatUIImageExtensions.h"
#import "MYBlurIntroductionView.h"
#import "FormulaEditorTextView.h"
#import "CatrobatLanguageDefines.h"
#import "NSString+CatrobatNSStringExtensions.h"
#import "Formula.h"
#import "Sound.h"
#import "Look.h"
#import "Script.h"
#import "BroadcastWaitBrick.h"
#import "BroadcastBrick.h"
#import "BroadcastScript.h"
#import "SpriteObject.h"
#import <objc/runtime.h>

@interface Util () <CatrobatAlertViewDelegate>

@end

@implementation Util

+ (BOOL)activateTestMode:(BOOL)activate
{
    static BOOL alreadyActive = NO;
    if (activate) {
        alreadyActive = YES;
    }
    return alreadyActive;
}

+ (NSString*)applicationDocumentsDirectory
{    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;

}

+ (void)showComingSoonAlertView
{
    CatrobatAlertView *alert = [[CatrobatAlertView alloc] initWithTitle:kLocalizedPocketCode
                                                                message:kLocalizedThisFeatureIsComingSoon
                                                               delegate:nil
                                                      cancelButtonTitle:kLocalizedOK
                                                      otherButtonTitles:nil];
    if (! [self activateTestMode:NO]) {
        [alert show];
    }
}

+ (void)showIntroductionScreenInView:(UIView *)view delegate:(id<MYIntroductionDelegate>)delegate
{
    MYIntroductionPanel *panel1 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height) title:kLocalizedWelcomeToPocketCode description:kLocalizedWelcomeDescription image:[UIImage imageNamed:@"page1_logo"]];
    
    //Create Stock Panel With Image
    MYIntroductionPanel *panel2 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height) title:kLocalizedExploreApps description:kLocalizedExploreDescription image:[UIImage imageNamed:@"page2_explore"]];
    
       MYIntroductionPanel *panel3 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height) title:kLocalizedUpcomingVersion description:kLocalizedUpcomingVersionDescription image:[UIImage imageNamed:@"page3_info"]];

    
    //Add panels to an array
    NSArray *panels = @[panel1, panel2, panel3];
    
    //Create the introduction view and set its delegate
    MYBlurIntroductionView *introductionView = [[MYBlurIntroductionView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)];
    introductionView.delegate = delegate;
    [introductionView setEnabled:YES];
    introductionView.BackgroundImageView.image = [UIImage imageWithColor:[UIColor darkBlueColor]];
    [introductionView setBackgroundColor:[UIColor darkBlueColor]];
    //introductionView.LanguageDirection = MYLanguageDirectionRightToLeft;
    
    //Build the introduction with desired panels
    [introductionView buildIntroductionWithPanels:panels];
    
    //Add the introduction to your view
    [view addSubview:introductionView];
}

+ (CatrobatAlertView*)alertWithText:(NSString*)text
{
    return [self alertWithText:text delegate:nil tag:0];
}

+ (CatrobatAlertView*)alertWithText:(NSString*)text
                           delegate:(id<CatrobatAlertViewDelegate>)delegate
                                tag:(NSInteger)tag
{
    CatrobatAlertView *alertView = [[CatrobatAlertView alloc] initWithTitle:kLocalizedPocketCode
                                                                    message:text
                                                                   delegate:delegate
                                                          cancelButtonTitle:kLocalizedOK
                                                          otherButtonTitles:nil];
    alertView.tag = tag;
    if (! [self activateTestMode:NO]) {
        [alertView show];
    }
    return alertView;
}

+ (CatrobatAlertView*)confirmAlertWithTitle:(NSString*)title
                                    message:(NSString*)message
                                   delegate:(id<CatrobatAlertViewDelegate>)delegate
                                        tag:(NSInteger)tag
{
    CatrobatAlertView *alertView = [[CatrobatAlertView alloc] initWithTitle:title
                                                                    message:message
                                                                   delegate:delegate
                                                          cancelButtonTitle:kLocalizedNo
                                                          otherButtonTitles:nil];
    [alertView addButtonWithTitle:kLocalizedYes];
    alertView.tag = tag;
    if (! [self activateTestMode:NO]) {
        [alertView show];
    }
    return alertView;
}

+ (CatrobatAlertView*)promptWithTitle:(NSString*)title
                              message:(NSString*)message
                             delegate:(id<CatrobatAlertViewDelegate>)delegate
                          placeholder:(NSString*)placeholder
                                  tag:(NSInteger)tag
{
    return [Util promptWithTitle:title
                         message:message
                        delegate:delegate
                     placeholder:placeholder
                             tag:tag
                           value:nil];
}

+ (CatrobatAlertView*)promptWithTitle:(NSString*)title
                              message:(NSString*)message
                             delegate:(id<CatrobatAlertViewDelegate>)delegate
                          placeholder:(NSString*)placeholder
                                  tag:(NSInteger)tag
                                value:(NSString*)value
{
    CatrobatAlertView *alertView = [[CatrobatAlertView alloc] initWithTitle:title
                                                                    message:message
                                                                   delegate:delegate
                                                          cancelButtonTitle:kLocalizedCancel
                                                          otherButtonTitles:kLocalizedOK, nil];
    alertView.tag = tag;
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textField = [alertView textFieldAtIndex:0];
    textField.placeholder = placeholder;
    [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
    textField.text = value;
    textField.delegate = alertView;
    textField.returnKeyType = UIReturnKeyDone;
    [textField becomeFirstResponder];
    if (! [self activateTestMode:NO]) {
        [alertView show];
    }
    return alertView;
}

+ (CatrobatActionSheet*)actionSheetWithTitle:(NSString*)title
                                    delegate:(id<CatrobatActionSheetDelegate>)delegate
                      destructiveButtonTitle:(NSString*)destructiveButtonTitle
                           otherButtonTitles:(NSArray*)otherButtonTitles
                                         tag:(NSInteger)tag
                                        view:(UIView*)view
{
    CatrobatActionSheet *actionSheet = [[CatrobatActionSheet alloc] initWithTitle:title
                                                                         delegate:delegate
                                                                cancelButtonTitle:kLocalizedCancel
                                                           destructiveButtonTitle:destructiveButtonTitle
                                                           otherButtonTitlesArray:otherButtonTitles];
    [actionSheet setButtonBackgroundColor:[UIColor colorWithRed:0 green:37.0f/255.0f blue:52.0f/255.0f alpha:0.95f]];
    [actionSheet setButtonTextColor:[UIColor whiteColor]];

//    [actionSheet setButtonBackgroundColor:[UIColor colorWithWhite:0.0f alpha:1.0f]];
//    [actionSheet setButtonTextColor:[UIColor lightOrangeColor]];
//    [actionSheet setButtonTextColor:[UIColor redColor] forButtonAtIndex:0];
    actionSheet.transparentView.alpha = 1.0f;

//    if (destructiveButtonTitle) {
//        [actionSheet addDestructiveButtonWithTitle:destructiveButtonTitle];
//    }
//    for (id otherButtonTitle in otherButtonTitles) {
//        if ([otherButtonTitle isKindOfClass:[NSString class]]) {
//            [actionSheet addButtonWithTitle:otherButtonTitle];
//        }
//    }
//    [actionSheet addCancelButtonWithTitle:kLocalizedCancel];

    actionSheet.tag = tag;
    if (! [self activateTestMode:NO]) {
        [actionSheet showInView:view];
    }
    return actionSheet;
}

+ (UIButton*)slideViewButtonWithTitle:(NSString*)title backgroundColor:(UIColor*)backgroundColor
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = backgroundColor;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    return button;
}

+ (UIButton*)slideViewButtonMore
{
    return [Util slideViewButtonWithTitle:kLocalizedMore
                          backgroundColor:[UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0]];
}

+ (UIButton*)slideViewButtonDelete
{
    return [Util slideViewButtonWithTitle:kLocalizedDelete
                          backgroundColor:[UIColor colorWithRed:1.0f green:0.231f blue:0.188f alpha:1.0f]];
}

+ (NSString*)appName
{
  return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
}

+ (NSString*)appVersion
{
  return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

+ (NSString*)appBuildName
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CatrobatBuildName"];
}

+ (NSString*)appBuildVersion
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

+ (NSString*)catrobatLanguageVersion
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CatrobatLanguageVersion"];
}

+ (NSString*)catrobatMediaLicense
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CatrobatMediaLicense"];
}

+ (NSString*)catrobatProgramLicense
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CatrobatProgramLicense"];
}

+ (NSString*)deviceName
{
  return [[UIDevice currentDevice] model];
}

+ (NSString*)platformName
{
  return [[UIDevice currentDevice] systemName];
}

+ (NSString*)platformVersion
{
  return [[UIDevice currentDevice] systemVersion];
}

+ (CGFloat)screenHeight
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    return screenRect.size.height;
}

+ (CGFloat)screenWidth
{
  CGRect screenRect = [[UIScreen mainScreen] bounds];
  return screenRect.size.width;
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

+ (ProgramLoadingInfo*)lastUsedProgramLoadingInfo
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *lastUsedProgramDirectoryName = [userDefaults objectForKey:kLastUsedProgram];
    if (! lastUsedProgramDirectoryName) {
        lastUsedProgramDirectoryName = [Program programDirectoryNameForProgramName:kLocalizedMyFirstProgram
                                                                         programID:nil];
        [userDefaults setObject:lastUsedProgramDirectoryName forKey:kLastUsedProgram];
        [userDefaults synchronize];
    }
    return [Program programLoadingInfoForProgramDirectoryName:lastUsedProgramDirectoryName];
}

+ (void)setLastProgramWithName:(NSString*)programName programID:(NSString*)programID
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    if (programName) {
        [userDefaults setObject:[Program programDirectoryNameForProgramName:programName programID:programID]
                         forKey:kLastUsedProgram];
    } else {
        [userDefaults setObject:nil forKey:kLastUsedProgram];
    }
    [userDefaults synchronize];
}

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
                               existingNames:(NSArray*)existingNames
{
    [self askUserForUniqueNameAndPerformAction:action
                                        target:target
                                  cancelAction:nil
                                    withObject:nil
                                   promptTitle:title
                                 promptMessage:message
                                   promptValue:value
                             promptPlaceholder:placeholder
                                minInputLength:minInputLength
                                maxInputLength:maxInputLength
                           blockedCharacterSet:blockedCharacterSet
                      invalidInputAlertMessage:invalidInputAlertMessage
                                 existingNames:existingNames];
}

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
{
    textFieldMaxInputLength = maxInputLength;
    textFieldBlockedCharacterSet = blockedCharacterSet;

    NSDictionary *payload = @{
        kDTPayloadAskUserAction : [NSValue valueWithPointer:action],
        kDTPayloadAskUserTarget : target,
        kDTPayloadAskUserObject : (passingObject ? passingObject : [NSNull null]),
        kDTPayloadAskUserPromptTitle : title,
        kDTPayloadAskUserPromptMessage : message,
        kDTPayloadAskUserPromptValue : (value ? value : [NSNull null]),
        kDTPayloadAskUserPromptPlaceholder : placeholder,
        kDTPayloadAskUserMinInputLength : @(minInputLength),
        kDTPayloadAskUserInvalidInputAlertMessage : invalidInputAlertMessage,
        kDTPayloadAskUserExistingNames : (existingNames ? existingNames : [NSNull null]),
        kDTPayloadCancel : (cancelAction ? [NSValue valueWithPointer:cancelAction] : [NSValue valueWithPointer:nil])
    };
    CatrobatAlertView *alertView = [[self class] promptWithTitle:title
                                                         message:message
                                                        delegate:(id<CatrobatAlertViewDelegate>)self
                                                     placeholder:placeholder
                                                             tag:kAskUserForUniqueNameAlertViewTag
                                                           value:value];
    alertView.dataTransferMessage = [DataTransferMessage messageForActionType:kDTMActionAskUserForUniqueName
                                                                  withPayload:[NSMutableDictionary dictionaryWithDictionary: payload]];
}

+ (void)askUserForReportMessageAndPerformAction:(SEL)action
                                      target:(id)target
                                 promptTitle:(NSString*)title
                               promptMessage:(NSString*)message
                              minInputLength:(NSUInteger)minInputLength
                              maxInputLength:(NSUInteger)maxInputLength
                            blockedCharacterSet:(NSCharacterSet*)blockedCharacterSet
                    invalidInputAlertMessage:(NSString*)invalidInputAlertMessage
{
    textFieldMaxInputLength = maxInputLength;
    textFieldBlockedCharacterSet = blockedCharacterSet;
    
    NSDictionary *payload = @{
                              kDTPayloadAskUserAction : [NSValue valueWithPointer:action],
                              kDTPayloadAskUserTarget : target,
                              kDTPayloadAskUserPromptTitle : title,
                              kDTPayloadAskUserPromptMessage : message,
                              kDTPayloadAskUserMinInputLength : @(minInputLength),
                              kDTPayloadAskUserInvalidInputAlertMessage : invalidInputAlertMessage,
                              };
    CatrobatAlertView *alertView = [[self class] promptWithTitle:title
                                                         message:message
                                                        delegate:(id<CatrobatAlertViewDelegate>)self
                                                     placeholder:@""
                                                             tag:kAskUserForReportMessageAlertViewTag
                                                           value:@""];
    alertView.dataTransferMessage = [DataTransferMessage messageForActionType:kDTMActionReportMessage
                                                                  withPayload:[NSMutableDictionary dictionaryWithDictionary: payload]];
}

+ (void)askUserForTextAndPerformAction:(SEL)action
                                target:(id)target
                           promptTitle:(NSString*)title
                         promptMessage:(NSString*)message
                           promptValue:(NSString*)value
                     promptPlaceholder:(NSString*)placeholder
                        minInputLength:(NSUInteger)minInputLength
                        maxInputLength:(NSUInteger)maxInputLength
                   blockedCharacterSet:(NSCharacterSet*)blockedCharacterSet
              invalidInputAlertMessage:(NSString*)invalidInputAlertMessage
{
    [self askUserForTextAndPerformAction:action
                                  target:target
                            cancelAction:nil
                              withObject:nil
                             promptTitle:title
                           promptMessage:message
                             promptValue:value
                       promptPlaceholder:placeholder
                          minInputLength:minInputLength
                          maxInputLength:maxInputLength
                     blockedCharacterSet:blockedCharacterSet
                invalidInputAlertMessage:invalidInputAlertMessage];
}

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
              invalidInputAlertMessage:(NSString*)invalidInputAlertMessage
{
    [self askUserForUniqueNameAndPerformAction:action
                                        target:target
                                  cancelAction:cancelAction
                                    withObject:passingObject
                                   promptTitle:title
                                 promptMessage:message
                                   promptValue:value
                             promptPlaceholder:placeholder
                                minInputLength:minInputLength
                                maxInputLength:maxInputLength
                           blockedCharacterSet:blockedCharacterSet
                      invalidInputAlertMessage:invalidInputAlertMessage
                                 existingNames:nil];
}

+ (void)askUserForVariableNameAndPerformAction:(SEL)action
                                         target:(id)target
                                    promptTitle:(NSString*)title
                                  promptMessage:(NSString*)message
                                 minInputLength:(NSUInteger)minInputLength
                                 maxInputLength:(NSUInteger)maxInputLength
                            blockedCharacterSet:(NSCharacterSet*)blockedCharacterSet
                       invalidInputAlertMessage:(NSString*)invalidInputAlertMessage
                                andTextField:(FormulaEditorTextView *)textView
{
    textFieldMaxInputLength = maxInputLength;
    textFieldBlockedCharacterSet = blockedCharacterSet;
    
    NSDictionary *payload = @{
                              kDTPayloadAskUserAction : [NSValue valueWithPointer:action],
                              kDTPayloadAskUserTarget : target,
                              kDTPayloadAskUserPromptTitle : title,
                              kDTPayloadAskUserPromptMessage : message,
                              kDTPayloadAskUserMinInputLength : @(minInputLength),
                              kDTPayloadAskUserInvalidInputAlertMessage : invalidInputAlertMessage,
                              kDTPayloadTextView: textView
                              };
    CatrobatAlertView *alertView = [[self class] promptWithTitle:title
                                                         message:message
                                                        delegate:(id<CatrobatAlertViewDelegate>)self
                                                     placeholder:@""
                                                             tag:kAskUserForVariableNameAlertViewTag
                                                           value:@""];
    alertView.dataTransferMessage = [DataTransferMessage messageForActionType:kDTMActionVariableName
                                                                  withPayload:[NSMutableDictionary dictionaryWithDictionary: payload]];
}


+ (void)addObjectAlertForProgram:(Program*)program andPerformAction:(SEL)action onTarget:(id)target withCancel:(SEL)cancel withCompletion:(void(^)(NSString*))completion
{
    [self askUserForUniqueNameAndPerformAction:action
                                        target:target
                                  cancelAction:cancel
                                    withObject:(id)completion
                                   promptTitle:kLocalizedAddObject
                                 promptMessage:[NSString stringWithFormat:@"%@:", kLocalizedObjectName]
                                   promptValue:nil
                             promptPlaceholder:kLocalizedEnterYourObjectNameHere
                                minInputLength:kMinNumOfObjectNameCharacters
                                maxInputLength:kMaxNumOfObjectNameCharacters
                           blockedCharacterSet:[[NSCharacterSet characterSetWithCharactersInString:kTextFieldAllowedCharacters]
                                                invertedSet]
                      invalidInputAlertMessage:kLocalizedObjectNameAlreadyExistsDescription
                                 existingNames:[[program allObjectNames] mutableCopy]];
}

+ (NSString*)uniqueName:(NSString*)nameToCheck existingNames:(NSArray*)existingNames
{
    NSMutableString *uniqueName = [nameToCheck mutableCopy];
    unichar lastChar = [uniqueName characterAtIndex:([uniqueName length] - 1)];
    if (lastChar == 0x20) {
        [uniqueName deleteCharactersInRange:NSMakeRange(([uniqueName length] - 1), 1)];
    }

    NSUInteger counter = 0;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\(\\d\\)"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:NULL];
    NSArray *results = [regex matchesInString:uniqueName
                                      options:0
                                        range:NSMakeRange(0, [uniqueName length])];
    if ([results count]) {
        BOOL duplicate = NO;
        for (NSString *existingName in existingNames) {
            if ([existingName isEqualToString:uniqueName]) {
                duplicate = YES;
                break;
            }
        }
        if (! duplicate) {
            return [uniqueName copy];
        }
        NSTextCheckingResult *lastOccurenceResult = [results lastObject];
        NSMutableString *lastOccurence = [(NSString*)[uniqueName substringWithRange:lastOccurenceResult.range] mutableCopy];
        [uniqueName replaceOccurrencesOfString:lastOccurence
                                    withString:@""
                                       options:NSCaseInsensitiveSearch
                                         range:NSMakeRange(0, [uniqueName length])];
        unichar lastChar = [uniqueName characterAtIndex:([uniqueName length] - 1)];
        if (lastChar == 0x20) {
            [uniqueName deleteCharactersInRange:NSMakeRange(([uniqueName length] - 1), 1)];
        }
        [lastOccurence replaceOccurrencesOfString:@"("
                                       withString:@""
                                          options:NSCaseInsensitiveSearch
                                            range:NSMakeRange(0, [lastOccurence length])];
        [lastOccurence replaceOccurrencesOfString:@")"
                                       withString:@""
                                          options:NSCaseInsensitiveSearch
                                            range:NSMakeRange(0, [lastOccurence length])];
        counter = [lastOccurence integerValue];
    }
    NSString *uniqueFinalName = [uniqueName copy];
    BOOL duplicate;
    do {
        duplicate = NO;
        for (NSString *existingName in existingNames) {
            if ([existingName isEqualToString:uniqueFinalName]) {
                uniqueFinalName = [NSString stringWithFormat:@"%@ (%lu)", uniqueName, (unsigned long)++counter];
                duplicate = YES;
                break;
            }
        }
    } while (duplicate);
    return uniqueFinalName;
}

+ (CGFloat)detectCBLanguageVersionFromXMLWithPath:(NSString*)xmlPath
{
    NSError *error;
    NSString *xmlString = [NSString stringWithContentsOfFile:xmlPath
                                                    encoding:NSUTF8StringEncoding
                                                       error:&error];
    // sanity check
    if (error || ! xmlString) {
        return kCatrobatInvalidVersion;
    }
    // get the end of the xml header
    NSArray *xmlStringChunks = [xmlString componentsSeparatedByString:@"</header>"];
    if (! [xmlStringChunks count]) {
        return kCatrobatInvalidVersion;
    }
    // extract header
    NSString *xmlStringHeaderChunk = [xmlStringChunks firstObject];
    if (! xmlStringHeaderChunk) {
        return kCatrobatInvalidVersion;
    }

    // extract catrobatLanguageVersion field out of header
    NSString *languageVersionString = [xmlStringHeaderChunk stringBetweenString:@"<catrobatLanguageVersion>"
                                                                      andString:@"</catrobatLanguageVersion>"
                                                                    withOptions:NSCaseInsensitiveSearch];
    if (! languageVersionString) {
        return kCatrobatInvalidVersion;
    }

    // check if string contains valid number
    if (! [languageVersionString isValidNumber]) {
        return kCatrobatInvalidVersion;
    }

    CGFloat languageVersion = (CGFloat)[languageVersionString floatValue];
    if (languageVersion < 0.0f) {
        return kCatrobatInvalidVersion;
    }
    return languageVersion;
}

+ (double)radiansToDegree:(double)rad
{
    CGFloat temp = rad * 180.0f / M_PI;
    temp = fmod(temp, 360.0f);
    return temp;
}

+ (double)degreeToRadians:(double)deg
{
    CGFloat temp = deg * M_PI / 180.0f;
    temp =  fmod(temp, 2*M_PI);
    return temp;
}

#pragma mark - text field delegates
static NSCharacterSet *textFieldBlockedCharacterSet = nil;

static NSUInteger textFieldMaxInputLength = 0;

+ (BOOL)textField:(UITextField*)field shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString*)characters
{
    if ([characters length] > textFieldMaxInputLength) {
        return false;
    }
    return ([characters rangeOfCharacterFromSet:textFieldBlockedCharacterSet].location == NSNotFound);
}

#pragma mark - alert view delegates
+ (void)alertView:(CatrobatAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSMutableDictionary *payload = (NSMutableDictionary*)alertView.dataTransferMessage.payload;
    if (alertView.tag == kAskUserForUniqueNameAlertViewTag) {
        if ((buttonIndex == alertView.cancelButtonIndex) || (buttonIndex != kAlertViewButtonOK)) {
            SEL action = NULL;
            if ((NSValue*)payload[kDTPayloadCancel]) {
                action = [((NSValue*)payload[kDTPayloadCancel]) pointerValue];
            }
            id target = payload[kDTPayloadAskUserTarget];
            if (action && target) {
                IMP imp = [target methodForSelector:action];
                void (*func)(id, SEL) = (void *)imp;
                func(target, action);
            }
            return;
        }

        NSString *input = [alertView textFieldAtIndex:0].text;
        id existingNamesObject = payload[kDTPayloadAskUserExistingNames];
        BOOL nameAlreadyExists = NO;
        if ([existingNamesObject isKindOfClass:[NSArray class]]) {
            NSArray *existingNames = (NSArray*)existingNamesObject;
            for (NSString *existingName in existingNames) {
                if ([existingName isEqualToString:input]) {
                    nameAlreadyExists = YES;
                }
            }
        }

        NSUInteger textFieldMinInputLength = [payload[kDTPayloadAskUserMinInputLength] unsignedIntegerValue];
        if ([input isEqualToString:kLocalizedNewElement]) {
            CatrobatAlertView *newAlertView = [Util alertWithText:kLocalizedInvalidInputDescription
                                                         delegate:(id<CatrobatAlertViewDelegate>)self
                                                              tag:kInvalidNameWarningAlertViewTag];
            payload[kDTPayloadAskUserPromptValue] = (NSValue*)input;
            newAlertView.dataTransferMessage = alertView.dataTransferMessage;
        } else if (nameAlreadyExists) {
            CatrobatAlertView *newAlertView = [Util alertWithText:payload[kDTPayloadAskUserInvalidInputAlertMessage]
                                                         delegate:(id<CatrobatAlertViewDelegate>)self
                                                              tag:kInvalidNameWarningAlertViewTag];
            payload[kDTPayloadAskUserPromptValue] = (NSValue*)input;
            newAlertView.dataTransferMessage = alertView.dataTransferMessage;
        } else if ([input length] < textFieldMinInputLength) {
            NSString *alertText = [NSString stringWithFormat:kLocalizedNoOrTooShortInputDescription,
                                   textFieldMinInputLength];
            alertText = ((textFieldMinInputLength != 1) ? [[self class] pluralString:alertText]
                                                        : [[self class] singularString:alertText]);
            CatrobatAlertView *newAlertView = [Util alertWithText:alertText
                                                         delegate:(id<CatrobatAlertViewDelegate>)self
                                                              tag:kInvalidNameWarningAlertViewTag];
            payload[kDTPayloadAskUserPromptValue] = (NSValue*)input;
            newAlertView.dataTransferMessage = alertView.dataTransferMessage;
        } else {
            // no name duplicate => call action on target
            SEL action = NULL;
            if (((NSValue*)payload[kDTPayloadAskUserAction]) != nil) {
                action = [((NSValue*)payload[kDTPayloadAskUserAction]) pointerValue];
            }
            id target = payload[kDTPayloadAskUserTarget];
            id passingObject = payload[kDTPayloadAskUserObject];
            if ((! passingObject) || [passingObject isKindOfClass:[NSNull class]]) {
                if (action) {
                    IMP imp = [target methodForSelector:action];
                    void (*func)(id, SEL, id) = (void *)imp;
                    func(target, action, input);
                }
            } else {
                if (action) {
                    IMP imp = [target methodForSelector:action];
                    void (*func)(id, SEL, id, id) = (void *)imp;
                    func(target, action, input, passingObject);
                }
            }
        }
    } else if (alertView.tag == kInvalidNameWarningAlertViewTag) {
        // title of cancel button is "OK"
        if (buttonIndex == alertView.cancelButtonIndex) {
            id value = payload[kDTPayloadAskUserPromptValue];
            CatrobatAlertView *newAlertView = [Util promptWithTitle:payload[kDTPayloadAskUserPromptTitle]
                                                            message:payload[kDTPayloadAskUserPromptMessage]
                                                           delegate:(id<CatrobatAlertViewDelegate>)self
                                                        placeholder:payload[kDTPayloadAskUserPromptPlaceholder]
                                                                tag:kAskUserForUniqueNameAlertViewTag
                                                              value:([value isKindOfClass:[NSString class]] ? value : nil)];
            newAlertView.dataTransferMessage = alertView.dataTransferMessage;
        }
    } else if (alertView.tag == kAskUserForReportMessageAlertViewTag){
        if ((buttonIndex == alertView.cancelButtonIndex) || (buttonIndex != kAlertViewButtonOK)) {
            return;
        }
        NSString *input = [alertView textFieldAtIndex:0].text;
        NSUInteger textFieldMinInputLength = [payload[kDTPayloadAskUserMinInputLength] unsignedIntegerValue];
        if ([input length] < textFieldMinInputLength) {
            NSString *alertText = [NSString stringWithFormat:kLocalizedNoOrTooShortInputDescription,
                                   textFieldMinInputLength];
            alertText = ((textFieldMinInputLength != 1) ? [[self class] pluralString:alertText]
                         : [[self class] singularString:alertText]);
            CatrobatAlertView *newAlertView = [Util alertWithText:alertText
                                                         delegate:(id<CatrobatAlertViewDelegate>)self
                                                              tag:kInvalidNameWarningAlertViewTag];
            payload[kDTPayloadAskUserPromptValue] = (NSValue*)input;
            newAlertView.dataTransferMessage = alertView.dataTransferMessage;
        } else {
                // no name duplicate => call action on target
            SEL action = NULL;
            if (((NSValue*)payload[kDTPayloadAskUserAction]) != nil) {
                action = [((NSValue*)payload[kDTPayloadAskUserAction]) pointerValue];
            }
            id target = payload[kDTPayloadAskUserTarget];
            id passingObject = payload[kDTPayloadAskUserObject];
            if ((! passingObject) || [passingObject isKindOfClass:[NSNull class]]) {
                if (action) {
                    IMP imp = [target methodForSelector:action];
                    void (*func)(id, SEL, id) = (void *)imp;
                    func(target, action, input);
                }
            } else {
                if (action) {
                    IMP imp = [target methodForSelector:action];
                    void (*func)(id, SEL, id, id) = (void *)imp;
                    func(target, action, input, passingObject);
                }
            }
        }

    }else if (alertView.tag == kAskUserForVariableNameAlertViewTag) {
        if ((buttonIndex == alertView.cancelButtonIndex) || (buttonIndex != kAlertViewButtonOK)) {
            FormulaEditorTextView *textView = (FormulaEditorTextView*)payload[kDTPayloadTextView];
            [textView becomeFirstResponder];
            return;
        }
        NSString *input = [alertView textFieldAtIndex:0].text;
        NSUInteger textFieldMinInputLength = [payload[kDTPayloadAskUserMinInputLength] unsignedIntegerValue];
        if ([input length] < textFieldMinInputLength) {
            NSString *alertText = [NSString stringWithFormat:kLocalizedNoOrTooShortInputDescription,
                                   textFieldMinInputLength];
            alertText = ((textFieldMinInputLength != 1) ? [[self class] pluralString:alertText]
                         : [[self class] singularString:alertText]);
            CatrobatAlertView *newAlertView = [Util alertWithText:alertText
                                                         delegate:(id<CatrobatAlertViewDelegate>)self
                                                              tag:kInvalidNameWarningAlertViewTag];
            payload[kDTPayloadAskUserPromptValue] = (NSValue*)input;
            newAlertView.dataTransferMessage = alertView.dataTransferMessage;
        } else {
            SEL action = NULL;
            if (((NSValue*)payload[kDTPayloadAskUserAction]) != nil) {
                action = [((NSValue*)payload[kDTPayloadAskUserAction]) pointerValue];
            }
            id target = payload[kDTPayloadAskUserTarget];
            id passingObject = payload[kDTPayloadAskUserObject];
            if ((! passingObject) || [passingObject isKindOfClass:[NSNull class]]) {
                if (action) {
                    IMP imp = [target methodForSelector:action];
                    void (*func)(id, SEL, id) = (void *)imp;
                    func(target, action, input);
                }
            } else {
                if (action) {
                    IMP imp = [target methodForSelector:action];
                    void (*func)(id, SEL, id, id) = (void *)imp;
                    func(target, action, input, passingObject);
                }
            }
        }
    }
}

+ (NSString*)singularString:(NSString*)string
{
    NSMutableString *mutableString = [string mutableCopy];
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:@"\\(.+?\\)"
                                  options:NSRegularExpressionCaseInsensitive
                                  error:NULL];
    [regex replaceMatchesInString:mutableString
                          options:0
                            range:NSMakeRange(0, [mutableString length])
                     withTemplate:@""];
    return [[self class] pluralString:mutableString];
}

+ (NSString*)pluralString:(NSString*)string
{
    NSMutableString *mutableString = [string mutableCopy];
    [mutableString stringByReplacingOccurrencesOfString:@"(" withString:@""];
    [mutableString stringByReplacingOccurrencesOfString:@")" withString:@""];
    return [mutableString copy];
}

+ (NSDictionary*)propertiesOfInstance:(id)instance
{
    unsigned count;
    objc_property_t *properties = class_copyPropertyList([instance class], &count);
    
    NSMutableDictionary *propertiesDictionary = [NSMutableDictionary new];
    
    unsigned i;
    for (i = 0; i < count; i++)
    {
        objc_property_t property = properties[i];
        
        NSString *name = [NSString stringWithUTF8String:property_getName(property)];
        
        // TODO use introspection
        if ([name isEqualToString:@"hash"] || [name isEqualToString:@"superclass"]
            || [name isEqualToString:@"description"] || [name isEqualToString:@"debugDescription"]
            || [name isEqualToString:@"brickCategoryType"] || [name isEqualToString:@"brickType"]) {
            continue;
        }
        
        NSObject *currentProperty = [instance valueForKey:name];
        if(currentProperty != nil)
            [propertiesDictionary setValue:currentProperty forKey:name];
    }
    
    free(properties);
    
    return propertiesDictionary;
}

+ (BOOL)isEqual:(id)object toObject:(id)objectToCompare
{
    if(object == nil && objectToCompare == nil)
        return YES;
    if([object isKindOfClass:[NSString class]]) {
        if([(NSString*)object isEqualToString:(NSString*)objectToCompare])
            return YES;
    } else if([object isKindOfClass:[NSNumber class]]) {
        if([(NSNumber*)object isEqualToNumber:(NSNumber*)objectToCompare])
            return YES;
    } else if([object isKindOfClass:[NSDate class]]) {
        if([(NSDate*)object isEqualToDate:(NSDate*)objectToCompare])
            return YES;
    } else if([object isKindOfClass:[Formula class]]) {
        if([(Formula*)object isEqualToFormula:(Formula*)objectToCompare])
            return YES;
    } else if([object isKindOfClass:[SpriteObject class]]) {
        if([(SpriteObject*)object isEqualToSpriteObject:(SpriteObject*)objectToCompare])
            return YES;
    }
    
    return NO;
}

+ (SpriteObject*)objectWithName:(NSString*)objectName forProgram:(Program*)program
{
    for(SpriteObject *object in program.objectList) {
        if([object.name isEqualToString:objectName]) {
            return object;
        }
    }
    return nil;
}

+ (Sound*)soundWithName:(NSString*)objectName forObject:(SpriteObject*)object
{
    for(Sound *sound in object.soundList) {
        if([sound.name isEqualToString:objectName]) {
            return sound;
        }
    }
    return nil;
}

+ (Look*)lookWithName:(NSString*)objectName forObject:(SpriteObject*)object
{
    for(Look *look in object.lookList) {
        if([look.name isEqualToString:objectName]) {
            return look;
        }
    }
    return nil;
}

+ (NSArray*)allMessagesForProgram:(Program*)program
{
    NSMutableArray *messages = [[NSMutableArray alloc] init];
    for(SpriteObject *object in program.objectList) {
        for(Script *script in object.scriptList) {
            if([script isKindOfClass:[BroadcastScript class]]) {
                BroadcastScript *broadcastScript = (BroadcastScript*)script;
                [messages addObject:broadcastScript.receivedMessage];
            }
            for(Brick *brick in script.brickList) {
                if([brick isKindOfClass:[BroadcastBrick class]]) {
                    BroadcastBrick *broadcastBrick = (BroadcastBrick*)brick;
                    [messages addObject:broadcastBrick.broadcastMessage];
                } else if([brick isKindOfClass:[BroadcastWaitBrick class]]) {
                    BroadcastWaitBrick *broadcastBrick = (BroadcastWaitBrick*)brick;
                    [messages addObject:broadcastBrick.broadcastMessage];
                }
            }
        }
    }
    return messages;
}

@end
