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

@interface Util () <CatrobatAlertViewDelegate, UITextFieldDelegate>

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

+ (NSString *)applicationDocumentsDirectory
{    
    NSArray *paths = 
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;

}

+ (void)showComingSoonAlertView
{
    CatrobatAlertView *alert = [[CatrobatAlertView alloc] initWithTitle:kUIAlertViewTitleStandard
                                                                message:kUIAlertViewMessageFeatureComingSoon
                                                               delegate:nil
                                                      cancelButtonTitle:kUIAlertViewButtonTitleOK
                                                      otherButtonTitles:nil];
    if (! [self activateTestMode:NO]) {
        [alert show];
    }
}

+ (CatrobatAlertView*)alertWithText:(NSString*)text
{
    return [self alertWithText:text delegate:nil tag:0];
}

+ (CatrobatAlertView*)alertWithText:(NSString*)text
                           delegate:(id<CatrobatAlertViewDelegate>)delegate
                                tag:(NSInteger)tag
{
    CatrobatAlertView *alertView = [[CatrobatAlertView alloc] initWithTitle:kUIAlertViewTitleStandard
                                                                    message:text
                                                                   delegate:delegate
                                                          cancelButtonTitle:kUIAlertViewButtonTitleOK
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
                                                          cancelButtonTitle:kUIAlertViewButtonTitleNo
                                                          otherButtonTitles:nil];
    [alertView addButtonWithTitle:kUIAlertViewButtonTitleYes];
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
                    textFieldDelegate:(id<UITextFieldDelegate>)textFieldDelegate
{
    return [Util promptWithTitle:title
                         message:message
                        delegate:delegate
                     placeholder:placeholder
                             tag:tag
                           value:nil
               textFieldDelegate:textFieldDelegate];
}

+ (CatrobatAlertView*)promptWithTitle:(NSString*)title
                              message:(NSString*)message
                             delegate:(id<CatrobatAlertViewDelegate>)delegate
                          placeholder:(NSString*)placeholder
                                  tag:(NSInteger)tag
                                value:(NSString*)value
                    textFieldDelegate:(id<UITextFieldDelegate>)textFieldDelegate
{
    CatrobatAlertView *alertView = [[CatrobatAlertView alloc] initWithTitle:title
                                                                    message:message
                                                                   delegate:delegate
                                                          cancelButtonTitle:kUIAlertViewButtonTitleCancel
                                                          otherButtonTitles:kUIAlertViewButtonTitleOK, nil];
    alertView.tag = tag;
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textField = [alertView textFieldAtIndex:0];
    textField.placeholder = placeholder;
    [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
    textField.text = value;
    textField.delegate = textFieldDelegate;
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
                                                                cancelButtonTitle:kUIActionSheetButtonTitleCancel
                                                           destructiveButtonTitle:destructiveButtonTitle
                                                           otherButtonTitlesArray:otherButtonTitles];
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
//    [actionSheet addCancelButtonWithTitle:kUIActionSheetButtonTitleCancel];

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
    return [Util slideViewButtonWithTitle:kUIButtonTitleMore
                          backgroundColor:[UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0]];
}

+ (UIButton*)slideViewButtonDelete
{
    return [Util slideViewButtonWithTitle:kUIButtonTitleDelete
                          backgroundColor:[UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]];
}

+ (NSString*)getProjectName
{
  NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
  return [NSString stringWithFormat:@"%@", [info objectForKey:@"CFBundleDisplayName"]];
}

+ (NSString*)getProjectVersion
{
  NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
  return [NSString stringWithFormat:@"%@", [info objectForKey:@"CFBundleVersion"]];
}

+ (NSString*)getDeviceName
{
  return [[UIDevice currentDevice] model];
}

+ (NSString*)getPlatformName
{
  return [[UIDevice currentDevice] systemName];
}

+ (NSString*)getPlatformVersion
{
  return [[UIDevice currentDevice] systemVersion];
}

+ (CGFloat)getScreenHeight
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    return screenRect.size.height;
}

+ (CGFloat)getScreenWidth
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

+ (ProgramLoadingInfo*)programLoadingInfoForProgramWithName:(NSString*)program
{
    NSString *documentsDirectory = [Util applicationDocumentsDirectory];
    NSString *programsPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, kProgramsFolder];
    ProgramLoadingInfo *info = [[ProgramLoadingInfo alloc] init];
    info.basePath = [NSString stringWithFormat:@"%@/%@/", programsPath, program];
    info.visibleName = program;
    return info;
}

+ (NSString*)lastProgram
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* lastProgram = [userDefaults objectForKey:kLastProgram];
    if (! lastProgram) {
        [userDefaults setObject:kDefaultProgramName forKey:kLastProgram];
        [userDefaults synchronize];
        lastProgram = kDefaultProgramName;
    }
    return lastProgram;
}

+ (void)setLastProgram:(NSString*)visibleName
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:visibleName forKey:kLastProgram];
    [userDefaults synchronize];
}

+ (void)askUserForUniqueNameAndPerformAction:(SEL)action
                                      target:(id)target
                                 promptTitle:(NSString*)title
                               promptMessage:(NSString*)message
                                 promptValue:(NSString*)value
                           promptPlaceholder:(NSString*)placeholder
                              maxInputLength:(NSUInteger)maxInputLength
                         blockedCharacterSet:(NSCharacterSet*)blockedCharacterSet
                    invalidInputAlertMessage:(NSString*)invalidInputAlertMessage
                               existingNames:(NSArray*)existingNames
{
    [self askUserForUniqueNameAndPerformAction:action
                                        target:target
                                    withObject:nil
                                   promptTitle:title
                                 promptMessage:message
                                   promptValue:value
                             promptPlaceholder:placeholder
                                maxInputLength:maxInputLength
                           blockedCharacterSet:blockedCharacterSet
                      invalidInputAlertMessage:invalidInputAlertMessage
                                 existingNames:existingNames];
}

+ (void)askUserForUniqueNameAndPerformAction:(SEL)action
                                      target:(id)target
                                  withObject:(id)passingObject
                                 promptTitle:(NSString*)title
                               promptMessage:(NSString*)message
                                 promptValue:(NSString*)value
                           promptPlaceholder:(NSString*)placeholder
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
        kDTPayloadAskUserInvalidInputAlertMessage : invalidInputAlertMessage,
        kDTPayloadAskUserExistingNames : existingNames
    };
    CatrobatAlertView *alertView = [[self class] promptWithTitle:title
                                                         message:message
                                                        delegate:(id<CatrobatAlertViewDelegate>)self
                                                     placeholder:kUIAlertViewPlaceholderEnterProgramName
                                                             tag:kAskUserForUniqueNameAlertViewTag
                                                           value:value
                                               textFieldDelegate:(id<UITextFieldDelegate>)self];
    alertView.dataTransferMessage = [DataTransferMessage messageForActionType:kDTMActionAskUserForUniqueName
                                                                  withPayload:[payload mutableCopy]];
}

+ (NSString*)uniqueName:(NSString*)nameToCheck existingNames:(NSArray*)existingNames
{
    NSString *uniqueName = nameToCheck;
    NSUInteger counter = 0;
    BOOL duplicate;
    do {
        duplicate = NO;
        for (NSString *existingName in existingNames) {
            if ([existingName isEqualToString:uniqueName]) {
                uniqueName = [NSString stringWithFormat:@"%@ (%lu)", nameToCheck, (unsigned long)++counter];
                duplicate = YES;
                break;
            }
        }
    } while (duplicate);
    return uniqueName;
}

+ (double)radiansToDegree:(float)rad
{
    return rad * 180.0 / M_PI;
}

+ (double)degreeToRadians:(float)deg
{
    return deg * M_PI / 180.0;
}

#pragma mark - text field delegates
static NSCharacterSet *textFieldBlockedCharacterSet = nil;
+ (NSCharacterSet*)textFieldBlockedCharacterSet
{
    return textFieldBlockedCharacterSet;
}

static NSUInteger textFieldMaxInputLength = 0;
+ (NSUInteger)textFieldMaxInputLength
{
    return textFieldMaxInputLength;
}

+ (BOOL)textField:(UITextField*)field shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString*)characters
{
    if ([characters length] > [[self class] textFieldMaxInputLength]) {
        return false;
    }
    return ([characters rangeOfCharacterFromSet:[[self class] textFieldBlockedCharacterSet]].location == NSNotFound);
}

#pragma mark - alert view delegates
+ (void)alertView:(CatrobatAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSMutableDictionary *payload = (NSMutableDictionary*)alertView.dataTransferMessage.payload;
    if (alertView.tag == kAskUserForUniqueNameAlertViewTag) {
        if ((buttonIndex == alertView.cancelButtonIndex) || (buttonIndex != kAlertViewButtonOK)) {
            return;
        }

        NSString *input = [alertView textFieldAtIndex:0].text;
        NSArray *existingNames = payload[kDTPayloadAskUserExistingNames];
        BOOL nameAlreadyExists = NO;
        for (NSString *existingName in existingNames) {
            if ([existingName isEqualToString:input]) {
                nameAlreadyExists = YES;
            }
        }

        if (nameAlreadyExists) {
            CatrobatAlertView *newAlertView = [Util alertWithText:payload[kDTPayloadAskUserInvalidInputAlertMessage]
                                                         delegate:(id<CatrobatAlertViewDelegate>)self
                                                              tag:kInvalidNameWarningAlertViewTag];
            payload[kDTPayloadAskUserPromptValue] = input;
            newAlertView.dataTransferMessage = alertView.dataTransferMessage;
        } else {
            // no name duplicate => call action on target
            SEL action = [((NSValue*)payload[kDTPayloadAskUserAction]) pointerValue];
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
                                                              value:([value isKindOfClass:[NSString class]] ? value : nil)
                                                  textFieldDelegate:(id<UITextFieldDelegate>)self];
            newAlertView.dataTransferMessage = alertView.dataTransferMessage;
        }
    }
}

@end
