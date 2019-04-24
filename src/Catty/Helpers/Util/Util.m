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

#import "Util.h"
#import "ProjectLoadingInfo.h"
#import "UIImage+CatrobatUIImageExtensions.h"
#import "CatrobatLanguageDefines.h"
#import "NSString+CatrobatNSStringExtensions.h"
#import "Sound.h"
#import "Look.h"
#import "Script.h"
#import "BroadcastWaitBrick.h"
#import "BroadcastBrick.h"
#import "BroadcastScript.h"
#import "KeychainUserDefaultsDefines.h"
#import "BDKNotifyHUD.h"
#import <objc/runtime.h>
#import "OrderedDictionary.h"
#import "Pocket_Code-Swift.h"
#import <sys/utsname.h>

@interface Util ()
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

+ (UIViewController *)topViewControllerInViewController:(UIViewController *)viewController {
    UIViewController *result = viewController;

    while (result.presentedViewController) {
        result = result.presentedViewController;
    }

    return result;
}

+ (UIViewController *)topmostViewController {
    return [self topViewControllerInViewController:ROOTVIEW];
}

+ (void)alertWithText:(NSString*)text
{
    [Util alertWithTitle:kLocalizedPocketCode andText:text];
}

+ (void)alertWithTitle:(NSString *)title andText:(NSString *)text
{
    [[[[AlertControllerBuilder alertWithTitle:title message:text]
     addCancelActionWithTitle:kLocalizedOK handler:nil]
     build]
     showWithController:[Util topmostViewController]];
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
    // https://stackoverflow.com/a/11197770
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

+ (NSString*)platformName
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CatrobatPlatformName"];
}

+ (NSOperatingSystemVersion)platformVersion
{
    return [[NSProcessInfo processInfo] operatingSystemVersion];
}

+ (NSString*)platformVersionWithPatch
{
    NSOperatingSystemVersion os = [self platformVersion];
    NSString* major = [NSString stringWithFormat:@"%ld", (long)os.majorVersion];
    NSString* minor = [NSString stringWithFormat:@"%ld", (long)os.minorVersion];
    NSString* patch = [NSString stringWithFormat:@"%ld", (long)os.patchVersion];
    return [NSString stringWithFormat:@"%@.%@.%@", major, minor, patch];
}

+ (NSString*)platformVersionWithoutPatch
{
    NSOperatingSystemVersion os = [self platformVersion];
    NSString* major = [NSString stringWithFormat:@"%ld", (long)os.majorVersion];
    NSString* minor = [NSString stringWithFormat:@"%ld", (long)os.minorVersion];
    return [NSString stringWithFormat:@"%@.%@", major, minor];
}

+ (CGSize)screenSize:(BOOL)inPixel
{
    CGSize screenSize = inPixel ? [[UIScreen mainScreen] nativeBounds].size : [[UIScreen mainScreen] bounds].size;

    if (inPixel && IS_IPHONEPLUS) {
        CGFloat iPhonePlusDownsamplingFactor = 1.15;
        screenSize.height = screenSize.height / iPhonePlusDownsamplingFactor;
        screenSize.width = screenSize.width / iPhonePlusDownsamplingFactor;
    }
    
    return screenSize;
}

+ (CGFloat)screenHeight:(BOOL)inPixel
{
    return [self screenSize:inPixel].height;
}

+ (CGFloat)screenWidth:(BOOL)inPixel
{
    return [self screenSize:inPixel].width;
}

+ (CGFloat)screenHeight
{
    return [self screenSize:false].height;
}

+ (CGFloat)screenWidth
{
    return [self screenSize:false].width;
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

+ (ProjectLoadingInfo*)lastUsedProjectLoadingInfo
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *lastUsedProjectDirectoryName = [userDefaults objectForKey:kLastUsedProject];
    if (! lastUsedProjectDirectoryName) {
        lastUsedProjectDirectoryName = [Project projectDirectoryNameForProjectName:kLocalizedMyFirstProject
                                                                         projectID:nil];
        [userDefaults setObject:lastUsedProjectDirectoryName forKey:kLastUsedProject];
        [userDefaults synchronize];
    }
    return [Project projectLoadingInfoForProjectDirectoryName:lastUsedProjectDirectoryName];
}

+ (void)setLastProjectWithName:(NSString*)projectName projectID:(NSString*)projectID
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    if (projectName) {
        projectName = [projectName stringByReplacingOccurrencesOfString:@"/" withString:@"%2F"];
        [userDefaults setObject:[Project projectDirectoryNameForProjectName:projectName projectID:projectID]
                         forKey:kLastUsedProject];
    } else {
        [userDefaults setObject:nil forKey:kLastUsedProject];
    }
    [userDefaults synchronize];
}

+ (InputValidationResult*)validationResultWithName:(NSString *)name minLength:(NSUInteger)minLength maxlength:(NSUInteger)maxLength {
    NSString *invalidNameMessage = nil;
    if (name.length < minLength) {
        invalidNameMessage = [self normalizedDescriptionWithFormat:kLocalizedNoOrTooShortInputDescription formatParameter:minLength];
    } else if (name.length > maxLength) {
        invalidNameMessage = [self normalizedDescriptionWithFormat:kLocalizedTooLongInputDescription formatParameter:maxLength];
    } else if ([name stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet].length == 0) { // at least one non-space
        invalidNameMessage = [self normalizedDescriptionWithFormat:kLocalizedSpaceInputDescription formatParameter:minLength];
    } else if ([name stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"./\\~"]].length == 0) { // not only special characters
        invalidNameMessage = [self normalizedDescriptionWithFormat:kLocalizedSpecialCharInputDescription formatParameter:minLength];
    } else {
        return [InputValidationResult validInput];
    }
    
    NSAssert(invalidNameMessage != nil, @"This case should already be handled");
    return [InputValidationResult invalidInputWithLocalizedMessage:invalidNameMessage];
}

+ (void)askUserForUniqueNameAndPerformAction:(SEL)action
                                      target:(id)target
                                 promptTitle:(NSString*)title
                               promptMessage:(NSString*)message
                                 promptValue:(NSString*)value
                           promptPlaceholder:(NSString*)placeholder
                              minInputLength:(NSUInteger)minInputLength
                              maxInputLength:(NSUInteger)maxInputLength
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
                      invalidInputAlertMessage:invalidInputAlertMessage
                                 existingNames:existingNames];
}

+ (NSString *)normalizedDescriptionWithFormat:(NSString *)descriptionFormat formatParameter:(NSUInteger)formatParameter {
    NSString *desc = [NSString stringWithFormat:descriptionFormat, formatParameter];
    return formatParameter != 1 ? [Util pluralString:desc] : [Util singularString:desc];
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
                    invalidInputAlertMessage:(NSString*)invalidInputAlertMessage
                               existingNames:(NSArray*)existingNames {
    [[[[[[[[AlertControllerBuilder textFieldAlertWithTitle:title message:message]
     placeholder:placeholder]
     initialText:value]
     addCancelActionWithTitle:kLocalizedCancel handler:^{
         if (target && cancelAction) {
             IMP imp = [target methodForSelector:cancelAction];
             void (*func)(id, SEL) = (void *)imp;
             func(target, cancelAction);
         }
     }]
     addDefaultActionWithTitle:kLocalizedOK handler:^(NSString *name) {
         IMP imp = [target methodForSelector:action];
         if (target && action) {
             if (passingObject) {
                 void (*func)(id, SEL, id, id) = (void *)imp;
                 func(target, action, name, passingObject);
             } else {
                 void (*func)(id, SEL, id) = (void *)imp;
                 func(target, action, name);
             }
         }
     }]
     valueValidator:^InputValidationResult *(NSString *name) {
         InputValidationResult *result = [self validationResultWithName:name minLength:minInputLength maxlength:maxInputLength];
         
         if (!result.valid) {
             return result;
         }
         if ([name isEqualToString:kLocalizedNewElement]) {
             return [InputValidationResult invalidInputWithLocalizedMessage:kLocalizedInvalidInputDescription];
         }
         if ([existingNames containsObject:name]) {
             return [InputValidationResult invalidInputWithLocalizedMessage:invalidInputAlertMessage];
         }
         return [InputValidationResult validInput];
     }] build]
     showWithController:[self topmostViewController]];
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
                      invalidInputAlertMessage:invalidInputAlertMessage
                                 existingNames:nil];
}

+ (void)askUserForVariableNameAndPerformAction:(SEL)action
                                         target:(id)target
                                    promptTitle:(NSString*)title
                                  promptMessage:(NSString*)message
                                 minInputLength:(NSUInteger)minInputLength
                                 maxInputLength:(NSUInteger)maxInputLength
									     isList:(BOOL)isList
                                andTextField:(FormulaEditorTextView *)textView
                                   initialText:(NSString*)initialText
{
    [[[[[[[AlertControllerBuilder textFieldAlertWithTitle:title message:message]
     initialText: initialText]
     addCancelActionWithTitle:kLocalizedCancel handler:^{
         [textView becomeFirstResponder];
     }]
     addDefaultActionWithTitle:kLocalizedOK handler:^(NSString *name) {
         if (target && action) {
             IMP imp = [target methodForSelector:action];
             void (*func)(id, SEL, id, BOOL) = (void *)imp;
             func(target, action, name, isList);
         }
     }]
     valueValidator:^InputValidationResult *(NSString *name) {
         NSString *invalidNameMessage = nil;
         if (minInputLength > 0 && name.length < minInputLength) {
             invalidNameMessage = [self normalizedDescriptionWithFormat:kLocalizedNoOrTooShortInputDescription formatParameter:minInputLength];
         } else if (maxInputLength > 0 && name.length > maxInputLength) {
             invalidNameMessage = [self normalizedDescriptionWithFormat:kLocalizedTooLongInputDescription formatParameter:maxInputLength];
         } else {
             return [InputValidationResult validInput];
         }
         
         NSAssert(invalidNameMessage != nil, @"This case should already be handled");
         return [InputValidationResult invalidInputWithLocalizedMessage:invalidNameMessage];
     }] build]
     showWithController:[Util topmostViewController]];
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
    } else if([object isKindOfClass:[NSMutableArray class]]) {
        if([(NSMutableArray*)object isEqualToArray:(NSMutableArray*)objectToCompare])
            return YES;
    }
    return NO;
}

+ (SpriteObject*)objectWithName:(NSString*)objectName forProject:(Project*)project
{
    for(SpriteObject *object in project.objectList) {
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

+ (NSArray*)allMessagesForProject:(Project*)project
{
    NSMutableArray *messages = [[NSMutableArray alloc] init];
    for(SpriteObject *object in project.objectList) {
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

+ (void)showNotificationWithMessage:(NSString *)message
{
    BDKNotifyHUD *notficicationHud = [BDKNotifyHUD notifyHUDWithImage:nil text:message];
    UIViewController *vc = [Util topmostViewController];
    
    notficicationHud.destinationOpacity = kBDKNotifyHUDDestinationOpacity;
    notficicationHud.center = CGPointMake(vc.view.center.x, vc.view.center.y);
    
    [vc.view addSubview:notficicationHud];
    [notficicationHud presentWithDuration:kBDKNotifyHUDPresentationDuration
                                    speed:kBDKNotifyHUDPresentationSpeed
                                   inView:vc.view
                               completion:^{ [notficicationHud removeFromSuperview]; }];
}

+ (void)showNotificationForSaveAction {
    BDKNotifyHUD *hud = [BDKNotifyHUD notifyHUDWithImage:[UIImage imageNamed:kBDKNotifyHUDCheckmarkImageName] text:kLocalizedSaved];
    UIViewController *vc = [Util topmostViewController];
    
    hud.destinationOpacity = kBDKNotifyHUDDestinationOpacity;
    hud.center = CGPointMake(vc.view.center.x, vc.view.center.y + kBDKNotifyHUDCenterOffsetY);
    hud.tag = kSavedViewTag;
    
    [vc.view addSubview:hud];
    [hud presentWithDuration:kBDKNotifyHUDPresentationDuration
                       speed:kBDKNotifyHUDPresentationSpeed
                      inView:vc.view
                  completion:^{ [hud removeFromSuperview]; }];
}

+ (void)openUrlExternal:(NSURL*)url
{
    if (@available(iOS 10, *)) {
        [[UIApplication sharedApplication] openURL:url options:[NSDictionary dictionary] completionHandler:nil];
    } else {
        [[UIApplication sharedApplication] openURL:url];
    }
}

+ (void)setNetworkActivityIndicator:(BOOL)enabled {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:enabled];
}

+ (BOOL)isPhiroActivated
{
    return kPhiroActivated == 1;
}

+ (BOOL)isArduinoActivated
{
    return kArduinoActivated == 1;
}

+ (BOOL)isPhone
{
#ifdef IS_IPHONE
    return true;
#else
    return false;
#endif
}

@end
