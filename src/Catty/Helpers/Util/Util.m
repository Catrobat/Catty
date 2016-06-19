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

#import "Util.h"
#import "ScenePresenterViewController.h"
#import "ProgramDefines.h"
#import "ProgramLoadingInfo.h"
#import "UIDefines.h"
#import "LanguageTranslationDefines.h"
#import "CatrobatAlertController.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "ActionSheetAlertViewTags.h"
#import "DataTransferMessage.h"
#import "UIImage+CatrobatUIImageExtensions.h"
#import <MYBlurIntroductionView/MYBlurIntroductionView.h>
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
#import "KeychainUserDefaultsDefines.h"
#import <objc/runtime.h>
#import <sys/sysctl.h>
#import "OrderedDictionary.h"

@interface Util () <CatrobatAlertViewDelegate>
#define ROOTVIEW [[[UIApplication sharedApplication] keyWindow] rootViewController]

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
    CatrobatAlertController *alert = [[CatrobatAlertController alloc] initAlertViewWithTitle:kLocalizedPocketCode
                                                                message:kLocalizedThisFeatureIsComingSoon
                                                               delegate:nil
                                                      cancelButtonTitle:kLocalizedOK
                                                      otherButtonTitles:nil];
    if (! [self activateTestMode:NO]) {
        [ROOTVIEW presentViewController:alert animated:YES completion:^{}];
    }
}

+ (void)showIntroductionScreenInView:(UIView *)view delegate:(id<MYIntroductionDelegate>)delegate
{
    MYIntroductionPanel *panel1 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height) title:kLocalizedWelcomeToPocketCode description:kLocalizedWelcomeDescription image:[UIImage imageNamed:@"page1_logo"]];
    panel1.PanelImageView.contentMode = UIViewContentModeScaleAspectFit;
    panel1.PanelDescriptionLabel.font = [UIFont systemFontOfSize:14];

    MYIntroductionPanel *panel2 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height) title:kLocalizedExploreApps description:kLocalizedExploreDescription image:[UIImage imageNamed:@"page2_explore"]];
    panel2.PanelDescriptionLabel.font = [UIFont systemFontOfSize:14];
    
    MYIntroductionPanel *panel3 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height) title:kLocalizedCreateAndEdit description:kLocalizedCreateAndEditDescription image:[UIImage imageNamed:@"page3_info"]];
    panel2.PanelDescriptionLabel.font = [UIFont systemFontOfSize:14];
    
    //Add panels to an array
    NSArray *panels = @[panel1, panel2, panel3];
    
    //Create the introduction view and set its delegate
    MYBlurIntroductionView *introductionView = [[MYBlurIntroductionView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)];
    introductionView.delegate = delegate;
    [introductionView setEnabled:YES];
    introductionView.BackgroundImageView.image = [UIImage imageWithColor:[UIColor globalTintColor]];
    [introductionView setBackgroundColor:[UIColor globalTintColor]];
    //introductionView.LanguageDirection = MYLanguageDirectionRightToLeft;
    
    //Build the introduction with desired panels
    [introductionView buildIntroductionWithPanels:panels];
    
    //Add the introduction to your view
    [view addSubview:introductionView];
}

+ (CatrobatAlertController*)alertWithText:(NSString*)text
{
    return [self alertWithText:text delegate:nil tag:0];
}

+(CatrobatAlertController *)alertWithTitle:(NSString *)title
                             andText:(NSString *)text
{
    CatrobatAlertController* alertView = [self alertWithText:text];
    alertView.title = title;
    return alertView;
}

+ (CatrobatAlertController*)alertWithText:(NSString*)text
                           delegate:(id<CatrobatAlertViewDelegate>)delegate
                                tag:(NSInteger)tag
{
    CatrobatAlertController *alertView = [[CatrobatAlertController alloc] initAlertViewWithTitle:kLocalizedPocketCode
                                                                    message:text
                                                                   delegate:delegate
                                                          cancelButtonTitle:kLocalizedOK
                                                          otherButtonTitles:nil];
    alertView.tag = tag;
    if (! [self activateTestMode:NO]) {
        [alertView show:YES];
    }
    return alertView;
}

+ (CatrobatAlertController*)confirmAlertWithTitle:(NSString*)title
                                    message:(NSString*)message
                                   delegate:(id<CatrobatAlertViewDelegate>)delegate
                                        tag:(NSInteger)tag
{
    CatrobatAlertController *alertView = [[CatrobatAlertController alloc] initAlertViewWithTitle:title
                                                                    message:message
                                                                   delegate:delegate
                                                          cancelButtonTitle:kLocalizedNo
                                                          otherButtonTitles:nil];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:kLocalizedYes style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                   {
                                       [delegate alertView:alertView clickedButtonAtIndex:1];
                                   }];
    
    [alertView addAction:yesAction];
    alertView.tag = tag;
    if (! [self activateTestMode:NO]) {
        [alertView show:YES];
    }
    return alertView;
}

+ (CatrobatAlertController*)promptWithTitle:(NSString*)title
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
                           value:nil
                          target:nil];
}

+ (CatrobatAlertController*)promptWithTitle:(NSString*)title
                              message:(NSString*)message
                             delegate:(id<CatrobatAlertViewDelegate>)delegate
                          placeholder:(NSString*)placeholder
                                  tag:(NSInteger)tag
                                value:(NSString*)value
                               target:(id)target
{
    CatrobatAlertController *alertView = [[CatrobatAlertController alloc] initAlertViewWithTitle:title
                                                                    message:message
                                                                   delegate:delegate
                                                          cancelButtonTitle:kLocalizedCancel
                                                          otherButtonTitles:kLocalizedOK, nil];
    alertView.tag = tag;
//    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
//    UITextField *textField = [alertView textFieldAtIndex:0];
//    textField.placeholder = placeholder;
//    [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
//    textField.text = value;
//    textField.delegate = alertView;
//    textField.returnKeyType = UIReturnKeyDone;
//    [textField becomeFirstResponder];
    [alertView addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = placeholder;
        textField.keyboardType = UIKeyboardTypeDefault;
        [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
        textField.text = value;
        textField.returnKeyType = UIReturnKeyDone;
        [textField becomeFirstResponder];
    }];

    if (! [self activateTestMode:NO]) {
        if (target != nil) {
            [(UIViewController *)target presentViewController:alertView animated:YES completion:^{}];
        } else {
            [alertView show:YES];
        }
    }
    return alertView;
}

+ (CatrobatAlertController*)actionSheetWithTitle:(NSString*)title
                                    delegate:(id<CatrobatActionSheetDelegate>)delegate
                      destructiveButtonTitle:(NSString*)destructiveButtonTitle
                           otherButtonTitles:(NSArray*)otherButtonTitles
                                         tag:(NSInteger)tag
                                        view:(UIView*)view
{
    CatrobatAlertController *actionSheet = [[CatrobatAlertController alloc] initActionSheetWithTitle:title
                                                                         delegate:delegate
                                                                cancelButtonTitle:kLocalizedCancel
                                                           destructiveButtonTitle:destructiveButtonTitle
                                                           otherButtonTitlesArray:otherButtonTitles];
//    [actionSheet setButtonBackgroundColor:[UIColor backgroundColor]];
//    [actionSheet setButtonTextColor:[UIColor buttonTintColor]];

//    [actionSheet setButtonBackgroundColor:[UIColor colorWithWhite:0.0f alpha:1.0f]];
//    [actionSheet setButtonTextColor:[UIColor globalTintColor]];
//    [actionSheet setButtonTextColor:[UIColor redColor] forButtonAtIndex:0];
    

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
        [actionSheet show:YES];
    }
    return actionSheet;
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
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *buildVersion = [[bundle infoDictionary] objectForKey:@"CFBundleVersion"];
    return buildVersion;
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

+ (CGSize)screenSize
{
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    float iOSVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (iOSVersion < 8 && UIInterfaceOrientationIsLandscape(orientation))
    {
        screenSize.height = screenSize.width;
        screenSize.width = [[UIScreen mainScreen] bounds].size.height;
    }
    return screenSize;
}

+ (CGFloat)screenHeight
{
    return [self screenSize].height;
}

+ (CGFloat)screenWidth
{
    return [self screenSize].width;
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
        programName = [programName stringByReplacingOccurrencesOfString:@"/" withString:@"%2F"];
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
        kDTPayloadAskUserMaxInputLength : @(maxInputLength),
        kDTPayloadAskUserInvalidInputAlertMessage : invalidInputAlertMessage,
        kDTPayloadAskUserExistingNames : (existingNames ? existingNames : [NSNull null]),
        kDTPayloadCancel : (cancelAction ? [NSValue valueWithPointer:cancelAction] : [NSValue valueWithPointer:@""])
    };
    CatrobatAlertController *alertView = [[self class] promptWithTitle:title
                                                         message:message
                                                        delegate:(id<CatrobatAlertViewDelegate>)self
                                                     placeholder:placeholder
                                                             tag:kAskUserForUniqueNameAlertViewTag
                                                           value:value
                                                          target:target];
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
    CatrobatAlertController *alertView = [[self class] promptWithTitle:title
                                                         message:message
                                                        delegate:(id<CatrobatAlertViewDelegate>)self
                                                     placeholder:@""
                                                             tag:kAskUserForReportMessageAlertViewTag
                                                           value:@""
                                                          target:target];
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
                              kDTPayloadAskUserMaxInputLength : @(maxInputLength),
                              kDTPayloadAskUserInvalidInputAlertMessage : invalidInputAlertMessage,
                              kDTPayloadTextView: textView
                              };
    CatrobatAlertController *alertView = [[self class] promptWithTitle:title
                                                         message:message
                                                        delegate:(id<CatrobatAlertViewDelegate>)self
                                                     placeholder:@""
                                                             tag:kAskUserForVariableNameAlertViewTag
                                                           value:@""
                                                          target:target];
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
    double temp = deg * M_PI / 180.0f;
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
+ (void)alertView:(CatrobatAlertController *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSMutableDictionary *payload = (NSMutableDictionary*)alertView.dataTransferMessage.payload;
    if (alertView.tag == kAskUserForUniqueNameAlertViewTag) {
        if ((buttonIndex == kAlertViewCancel) || (buttonIndex != kAlertViewButtonOK)) {
            SEL action = NULL;
            if (((NSValue*)payload[kDTPayloadCancel]).pointerValue != @"") {
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

        NSString *input = ((UITextField*)[alertView.textFields objectAtIndex:0]).text;
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
        
        bool atLeastOneNotspace = NO;
        bool notOnlySpecialCharacters = NO;
        for(int i =0; i < input.length; i++){
            NSString * newString = [input substringWithRange:NSMakeRange(i, 1)];
            if(!([newString  isEqual: @" "])){
                atLeastOneNotspace = YES;
                break;
            }
        }
        for(int i =0; i < input.length; i++){
            NSString * newString = [input substringWithRange:NSMakeRange(i, 1)];
            if(!([newString  isEqual: @"."])&&!([newString  isEqual: @"/"])&&!([newString  isEqual: @"\\"])&&!([newString  isEqual: @"~"])){
                notOnlySpecialCharacters = YES;
                break;
            }
        }
        
        NSUInteger textFieldMinInputLength = [payload[kDTPayloadAskUserMinInputLength] unsignedIntegerValue];
        NSUInteger textFieldMaxInputLength = [payload[kDTPayloadAskUserMaxInputLength] unsignedIntegerValue];
        if ([input isEqualToString:kLocalizedNewElement]) {
            CatrobatAlertController *newAlertView = [Util alertWithText:kLocalizedInvalidInputDescription
                                                         delegate:(id<CatrobatAlertViewDelegate>)self
                                                              tag:kInvalidNameWarningAlertViewTag];
            payload[kDTPayloadAskUserPromptValue] = (NSValue*)input;
            newAlertView.dataTransferMessage = alertView.dataTransferMessage;
        } else if (nameAlreadyExists) {
            CatrobatAlertController *newAlertView = [Util alertWithText:payload[kDTPayloadAskUserInvalidInputAlertMessage]
                                                         delegate:(id<CatrobatAlertViewDelegate>)self
                                                              tag:kInvalidNameWarningAlertViewTag];
            payload[kDTPayloadAskUserPromptValue] = (NSValue*)input;
            newAlertView.dataTransferMessage = alertView.dataTransferMessage;
        } else if ([input length] < textFieldMinInputLength) {
            NSString *alertText = [NSString stringWithFormat:kLocalizedNoOrTooShortInputDescription,
                                   textFieldMinInputLength];
            alertText = ((textFieldMinInputLength != 1) ? [[self class] pluralString:alertText]
                                                        : [[self class] singularString:alertText]);
            CatrobatAlertController *newAlertView = [Util alertWithText:alertText
                                                         delegate:(id<CatrobatAlertViewDelegate>)self
                                                              tag:kInvalidNameWarningAlertViewTag];
            payload[kDTPayloadAskUserPromptValue] = (NSValue*)input;
            newAlertView.dataTransferMessage = alertView.dataTransferMessage;
        } else if ([input length] > textFieldMaxInputLength) {
            NSString *alertText = [NSString stringWithFormat:kLocalizedTooLongInputDescription,
                                   textFieldMaxInputLength];
            CatrobatAlertController *newAlertView = [Util alertWithText:alertText
                                                         delegate:(id<CatrobatAlertViewDelegate>)self
                                                              tag:kInvalidNameWarningAlertViewTag];
            payload[kDTPayloadAskUserPromptValue] = (NSValue*)input;
            newAlertView.dataTransferMessage = alertView.dataTransferMessage;
        } else if(!atLeastOneNotspace ||!notOnlySpecialCharacters){
            NSString *alertText;
            if (!atLeastOneNotspace) {
                alertText = [NSString stringWithFormat:kLocalizedSpaceInputDescription,
                             textFieldMinInputLength];
            } else if (!notOnlySpecialCharacters) {
                alertText = [NSString stringWithFormat:kLocalizedSpecialCharInputDescription,
                             textFieldMinInputLength];
            } 
            alertText = ((textFieldMinInputLength != 1) ? [[self class] pluralString:alertText]
                         : [[self class] singularString:alertText]);
            CatrobatAlertController *newAlertView = [Util alertWithText:alertText
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
        if (buttonIndex == kAlertViewCancel) {
            id value = payload[kDTPayloadAskUserPromptValue];
            CatrobatAlertController *newAlertView = [Util promptWithTitle:payload[kDTPayloadAskUserPromptTitle]
                                                            message:payload[kDTPayloadAskUserPromptMessage]
                                                           delegate:(id<CatrobatAlertViewDelegate>)self
                                                        placeholder:payload[kDTPayloadAskUserPromptPlaceholder]
                                                                tag:kAskUserForUniqueNameAlertViewTag
                                                              value:([value isKindOfClass:[NSString class]] ? value : nil)
                                                             target:nil];
            newAlertView.dataTransferMessage = alertView.dataTransferMessage;
        }
    } else if (alertView.tag == kAskUserForReportMessageAlertViewTag){
        if ((buttonIndex == kAlertViewCancel) || (buttonIndex != kAlertViewButtonOK)) {
            return;
        }
        NSString *input = ((UITextField*)[alertView.textFields objectAtIndex:0]).text;
        NSUInteger textFieldMinInputLength = [payload[kDTPayloadAskUserMinInputLength] unsignedIntegerValue];
        if ([input length] < textFieldMinInputLength) {
            NSString *alertText = [NSString stringWithFormat:kLocalizedNoOrTooShortInputDescription,
                                   textFieldMinInputLength];
            alertText = ((textFieldMinInputLength != 1) ? [[self class] pluralString:alertText]
                         : [[self class] singularString:alertText]);
            CatrobatAlertController *newAlertView = [Util alertWithText:alertText
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
        if ((buttonIndex == kAlertViewCancel) || (buttonIndex != kAlertViewButtonOK)) {
            FormulaEditorTextView *textView = (FormulaEditorTextView*)payload[kDTPayloadTextView];
            [textView becomeFirstResponder];
            return;
        }
        NSString *input = ((UITextField*)[alertView.textFields objectAtIndex:0]).text;
        NSUInteger textFieldMinInputLength = [payload[kDTPayloadAskUserMinInputLength] unsignedIntegerValue];
        NSUInteger textFieldMaxInputLength = [payload[kDTPayloadAskUserMaxInputLength] unsignedIntegerValue];
        if ([input length] < textFieldMinInputLength) {
            NSString *alertText = [NSString stringWithFormat:kLocalizedNoOrTooShortInputDescription,
                                   textFieldMinInputLength];
            alertText = ((textFieldMinInputLength != 1) ? [[self class] pluralString:alertText]
                         : [[self class] singularString:alertText]);
            CatrobatAlertController *newAlertView = [Util alertWithText:alertText
                                                         delegate:(id<CatrobatAlertViewDelegate>)self
                                                              tag:kInvalidNameWarningAlertViewTag];
            payload[kDTPayloadAskUserPromptValue] = (NSValue*)input;
            newAlertView.dataTransferMessage = alertView.dataTransferMessage;
        }else if ([input length] > textFieldMaxInputLength) {
            NSString *alertText = [NSString stringWithFormat:kLocalizedTooLongInputDescription,
                                   textFieldMaxInputLength];
            CatrobatAlertController *newAlertView = [Util alertWithText:alertText
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
//
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

+ (BOOL)isNetworkError:(NSError*)error
{
    return error && error.code != kCFURLErrorCancelled;
}

+ (void)defaultAlertForNetworkError
{
    if ([NSThread isMainThread]) {
        [[self class] alertWithText:kLocalizedErrorInternetConnection];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [Util defaultAlertForNetworkError];
        });
    }
}

+ (void)defaultAlertForUnknownError
{
    if ([NSThread isMainThread]) {
        [[self class] alertWithText:kLocalizedErrorUnknown];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [Util defaultAlertForUnknownError];
        });
    }
}

#pragma mark - brick statistics

+ (NSDictionary*)getBrickInsertionDictionaryFromUserDefaults
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *insertionStatistic = [userDefaults objectForKey:kUserDefaultsBrickSelectionStatisticsMap];
    if(insertionStatistic == nil)
    {
//        insertionStatistic = [self defaultBrickStatisticDictionary];
        [userDefaults setObject:insertionStatistic
                         forKey:kUserDefaultsBrickSelectionStatisticsMap];
        [userDefaults synchronize];
    }
    return insertionStatistic;
}

+ (void)setBrickInsertionDictionaryToUserDefaults:(NSDictionary*) statistics
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:statistics
                     forKey:kUserDefaultsBrickSelectionStatisticsMap];
    [userDefaults synchronize];
}


+ (void)incrementStatisticCountForBrickType:(kBrickType)brickType
{
    NSDictionary *insertionStatistic = [self getBrickInsertionDictionaryFromUserDefaults];
    NSString *wrappedBrickType = [NSNumber numberWithUnsignedInteger:(NSUInteger)brickType].stringValue;
    NSNumber *old_count = [insertionStatistic objectForKey:wrappedBrickType];
    NSMutableDictionary* mutableInsertionStatistic = [insertionStatistic mutableCopy];
    [mutableInsertionStatistic setValue:[NSNumber numberWithInt:old_count.intValue+1] forKey:wrappedBrickType];
    insertionStatistic = [NSDictionary dictionaryWithDictionary:mutableInsertionStatistic];
    [self setBrickInsertionDictionaryToUserDefaults:insertionStatistic];
}

+ (void)printBrickStatistics
{
    NSDebug(@"Brick Statistics:\n%@", [self getBrickInsertionDictionaryFromUserDefaults]);
}

+ (void)printSubsetOfTheMost:(NSUInteger)N
{
    NSDebug(@"Most %d used Bricks with their identifier:\n%@", N, [self getSubsetOfTheMost:N usedBricksInDictionary:[self getBrickInsertionDictionaryFromUserDefaults]]);
}

+ (NSArray*) getSubsetOfTheMost:(NSUInteger)N usedBricksInDictionary:(NSDictionary *)brickCountDictionary
{
    NSArray *sortedBricks = [brickCountDictionary
                             keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2)
                             {
                                 NSNumber* number1 = (NSNumber*)obj1;
                                 NSNumber* number2 = (NSNumber*)obj2;
                                 if (number1 < number2) {
                                     return NSOrderedDescending;
                                 }else{
                                     return NSOrderedAscending;
                                 }
                             }];
    
    NSUInteger count = ([sortedBricks count] >= N) ? N : [sortedBricks count];
    NSRange range;
    range.location = 0;
    range.length = count;

    return [sortedBricks subarrayWithRange:range];
}

+ (NSArray*) getSubsetOfTheMostFavoriteChosenBricks:(NSUInteger)amount
{
    return [self getSubsetOfTheMost:amount
             usedBricksInDictionary:[self getBrickInsertionDictionaryFromUserDefaults]];
}

+ (void)resetBrickStatistics
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[self defaultBrickStatisticDictionary] forKey:kUserDefaultsBrickSelectionStatisticsMap];
    [userDefaults synchronize];
}

+ (NSDictionary*)defaultBrickStatisticDictionary
{
    NSArray* defautArray = kDefaultFavouriteBricksStatisticArray;
    OrderedDictionary * dict = [[OrderedDictionary alloc] initWithCapacity:defautArray.count];
    for (NSString * brick in defautArray.reverseObjectEnumerator) {
        [dict insertObject:kNSNumberZero forKey:brick atIndex:0];
    }
    return dict;
}

+ (NSString*)replaceBlockedCharactersForString:(NSString*)string
{
    string = [string stringByReplacingOccurrencesOfString:@"/" withString:@"%2F"];
    string = [string stringByReplacingOccurrencesOfString:@"~" withString:@"%5C"];
    string = [string stringByReplacingOccurrencesOfString:@"<" withString:@"%3C"];
    string = [string stringByReplacingOccurrencesOfString:@">" withString:@"%3E"];
    return string;
}

+ (NSString*)enableBlockedCharactersForString:(NSString*)string
{
    string = [string stringByReplacingOccurrencesOfString:@"%2F" withString:@"/"];
    string = [string stringByReplacingOccurrencesOfString:@"%5C" withString:@"~"];
    string = [string stringByReplacingOccurrencesOfString:@"%3C" withString:@"<"];
    string = [string stringByReplacingOccurrencesOfString:@"%3E" withString:@">"];
    return string;
}

+ (BOOL)isPhiroActivated
{
    return kPhiroActivated == 1;
}

+ (BOOL)isArduinoActivated
{
    return kArduinoActivated == 1;
}

+ (BOOL)isProductionServerActivated
{
    return kProductionServerActivated == 1;
}

@end
