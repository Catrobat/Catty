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

#import "CBXMLValidator.h"
#import "GDataXMLNode.h"

@implementation CBXMLValidator

+ (NSString*)exceptionName
{
    NSString *sourceString = [[NSThread callStackSymbols] objectAtIndex:3];
    // Example: 1   UIKit                               0x00540c89 -[UIApplication _callInitializationDelegatesForURL:payload:suspended:] + 1163
    NSCharacterSet *separatorSet = [NSCharacterSet characterSetWithCharactersInString:@" -[]+?.,"];
    NSMutableArray *array = [NSMutableArray arrayWithArray:[sourceString componentsSeparatedByCharactersInSet:separatorSet]];
    [array removeObject:@""];
    NSUInteger index = 0;
    NSDebug(@"Stack = %@", [array objectAtIndex:index++]);
#if DEBUG == 1
    NSString *framework = [array objectAtIndex:index++];
    NSString *tempString = [array objectAtIndex:index++];
    NSString *memoryAddress = nil;
    NSCharacterSet *chars = [[NSCharacterSet
                              characterSetWithCharactersInString:@"0123456789ABCDEF"] invertedSet];
    BOOL tempStringContainsValidMemoryAddress = (NSNotFound == [tempString rangeOfCharacterFromSet:chars].location);
    if (tempStringContainsValidMemoryAddress) {
        memoryAddress = tempString;
    } else {
        framework = [NSString stringWithFormat:@"%@ %@", framework, tempString];
        memoryAddress = [array objectAtIndex:index++];
    }
    NSLog(@"Framework = %@", framework);
    NSLog(@"Memory address = %@", memoryAddress);
#endif // DEBUG
    NSString *classCaller = [array objectAtIndex:index++];
    return classCaller;
}

+ (NSString*)exceptionMessagePrefix
{
    NSString *sourceString = [[NSThread callStackSymbols] objectAtIndex:3];
    // Example: 1   UIKit                               0x00540c89 -[UIApplication _callInitializationDelegatesForURL:payload:suspended:] + 1163
    NSCharacterSet *separatorSet = [NSCharacterSet characterSetWithCharactersInString:@" -[]+?.,"];
    NSMutableArray *array = [NSMutableArray arrayWithArray:[sourceString componentsSeparatedByCharactersInSet:separatorSet]];
    [array removeObject:@""];
    NSUInteger index = 0;
    NSDebug(@"Stack = %@", [array objectAtIndex:index++]);
#if DEBUG == 1
    NSString *framework = [array objectAtIndex:index++];
    NSString *tempString = [array objectAtIndex:index++];
    NSString *memoryAddress = nil;
    NSCharacterSet *chars = [[NSCharacterSet
                              characterSetWithCharactersInString:@"0123456789ABCDEF"] invertedSet];
    BOOL tempStringContainsValidMemoryAddress = (NSNotFound == [tempString rangeOfCharacterFromSet:chars].location);
    if (tempStringContainsValidMemoryAddress) {
        memoryAddress = tempString;
    } else {
        framework = [NSString stringWithFormat:@"%@ %@", framework, tempString];
        memoryAddress = [array objectAtIndex:index++];
    }
    NSLog(@"Framework = %@", framework);
    NSLog(@"Memory address = %@", memoryAddress);
#endif // DEBUG

    NSString *classCaller = [array objectAtIndex:index++];
    NSString *functionCaller = [array objectAtIndex:index++];
    NSString *lineCaller = [array objectAtIndex:index++];
    NSDebug(@"Class caller = %@", classCaller);
    NSDebug(@"Function caller = %@", functionCaller);
    NSDebug(@"Line caller = %@", lineCaller);
    return [NSString stringWithFormat:@"[%@:%@(%@)]", classCaller, functionCaller, lineCaller];
}

+ (void)throwExceptionWithMessage:(NSString*)exceptionMessage arguments:(va_list)argList NS_FORMAT_FUNCTION(1,0)
{
    if (exceptionMessage) {
        exceptionMessage = [[NSString alloc] initWithFormat:exceptionMessage arguments:argList];
        NSString *exceptionName = [[self class] exceptionName];
        NSString *exceptionMessagePrefix = [[self class] exceptionMessagePrefix];
        exceptionMessage = [NSString stringWithFormat:@"%@ %@",
                            exceptionMessagePrefix,
                            exceptionMessage];
        [NSException raise:exceptionName
                    format:exceptionMessage, nil];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wformat-security"
        [NSException raise:[[self class] exceptionName] format:[[self class] exceptionMessagePrefix]];
#pragma clang diagnostic pop
    }
}

+ (void)exceptionIfNode:(GDataXMLNode*)node isNilOrNodeNameNotEquals:(NSString*)expectedNodeName
{
    [self exceptionIfNil:node message:@"The expected node element %@ is nil", expectedNodeName];
    [self exceptionIfString:node.name
         isNotEqualToString:expectedNodeName
                    message:@"The name of the rootElement is '%@' but should be '%@'",
                            node.name, expectedNodeName];
}

+ (void)exceptionIfNil:(id)object message:(NSString*)exceptionMessage, ...
{
    if (! object) {
        va_list args;
        va_start(args, exceptionMessage);
        [self throwExceptionWithMessage:exceptionMessage arguments:args];
        va_end(args);
    }
}

+ (void)exceptionIfNull:(void*)pointer message:(NSString*)exceptionMessage, ... NS_FORMAT_FUNCTION(2,3)
{
    if (! pointer) {
        va_list args;
        va_start(args, exceptionMessage);
        [self throwExceptionWithMessage:exceptionMessage arguments:args];
        va_end(args);
    }
}

+ (void)exceptionIfString:(NSString*)firstString
       isNotEqualToString:(NSString*)secondString
                  message:(NSString*)exceptionMessage, ...
{
    if (! [firstString isEqualToString:secondString]) {
        va_list args;
        va_start(args, exceptionMessage);
        [self throwExceptionWithMessage:exceptionMessage arguments:args];
        va_end(args);
    }
}

+ (void)exceptionIf:(NSInteger)compareValue
          notEquals:(NSInteger)integerValue
            message:(NSString *)exceptionMessage, ...
{
    if (compareValue != integerValue) {
        va_list args;
        va_start(args, exceptionMessage);
        [self throwExceptionWithMessage:exceptionMessage arguments:args];
        va_end(args);
    }
}

+ (void)exceptionIf:(NSInteger)compareValue
             equals:(NSInteger)integerValue
            message:(NSString *)exceptionMessage, ...
{
    if (compareValue == integerValue) {
        va_list args;
        va_start(args, exceptionMessage);
        [self throwExceptionWithMessage:exceptionMessage arguments:args];
        va_end(args);
    }
}

+ (void)exceptionWithMessage:(NSString*)exceptionMessage, ...
{
    va_list args;
    va_start(args, exceptionMessage);
    [self throwExceptionWithMessage:exceptionMessage arguments:args];
    va_end(args);
}

@end
