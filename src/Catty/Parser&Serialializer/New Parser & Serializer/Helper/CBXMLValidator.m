/**
 *  Copyright (C) 2010-2021 The Catrobat Team
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

+ (void)throwExceptionWithMessage:(NSString*)exceptionMessage arguments:(va_list)argList NS_FORMAT_FUNCTION(1,0)
{
    if (exceptionMessage) {
        exceptionMessage = [[NSString alloc] initWithFormat:exceptionMessage arguments:argList];
    } else {
        exceptionMessage = @"XML exception without message";
    }
    
    [NSException raise:NSStringFromClass([self class]) format:exceptionMessage, nil];
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
