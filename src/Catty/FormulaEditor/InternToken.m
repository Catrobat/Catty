/**
 *  Copyright (C) 2010-2017 The Catrobat Team
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

#import "InternToken.h"
#import "Operators.h"

@implementation InternToken

- (id)initWithType:(InternTokenType)internTokenType
{
    self = [super init];
    if(self) {
        self.internTokenType = internTokenType;
    }
    return self;
}

- (id)initWithType:(InternTokenType)internTokenType AndValue:(NSString*)value
{
    self = [self initWithType:internTokenType];
    if(self) {
        self.tokenStringValue = value;
    }
    return self;
}

- (BOOL)isNumber
{
    return self.internTokenType == TOKEN_TYPE_NUMBER;
}

- (BOOL)isOperator
{
    return self.internTokenType == TOKEN_TYPE_OPERATOR && (int)[Operators getOperatorByValue:self.tokenStringValue] != -1;
}

- (BOOL)isBracketOpen
{
    return (NSInteger)self.internTokenType == (NSInteger)TOKEN_TYPE_BRACKET_OPEN;
}

- (BOOL)isBracketClose
{
    return (NSInteger)self.internTokenType == (NSInteger)TOKEN_TYPE_BRACKET_CLOSE;
}

- (BOOL)isFunctionParameterBracketOpen
{
    return (NSInteger)self.internTokenType == (NSInteger)TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN;
}

- (BOOL)isFunctionParameterBracketClose
{
    return (NSInteger)self.internTokenType == (NSInteger)TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE;
}

- (BOOL)isFunctionParameterDelimiter
{
    return (NSInteger)self.internTokenType == (NSInteger)TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER;
}

- (BOOL)isFunctionName
{
    return (NSInteger)self.internTokenType == (NSInteger)TOKEN_TYPE_FUNCTION_NAME;
}

- (BOOL)isEndOfFileToken
{
    return (NSInteger)self.internTokenType == (NSInteger)TOKEN_TYPE_PARSER_END_OF_FILE;
}

- (BOOL)isSensor
{
    return self.internTokenType == TOKEN_TYPE_SENSOR;
}

- (BOOL)isUserVariable
{
    return self.internTokenType == TOKEN_TYPE_USER_VARIABLE;
}

- (BOOL)isString
{
    return self.internTokenType == TOKEN_TYPE_STRING;
}

- (void)appendToTokenStringValue:(NSString*)stringToAppend
{
    self.tokenStringValue = [[NSString alloc] initWithFormat:@"%@%@", self.tokenStringValue, stringToAppend];
}

- (void)appendToTokenStringValueWithArray:(NSArray*)internTokensToAppend
{
    for(int i = 0; i < [internTokensToAppend count]; i++) {
        InternToken *internToken = (InternToken*)[internTokensToAppend objectAtIndex:i];
        self.tokenStringValue = [[NSString alloc] initWithFormat:@"%@%@", self.tokenStringValue, internToken.tokenStringValue];
    }
}

- (BOOL)isEqualTo:(InternToken*)token
{
    return self.internTokenType == token.internTokenType && ((self.tokenStringValue == nil && token.tokenStringValue == nil) || [self.tokenStringValue isEqualToString:token.tokenStringValue]);
}

- (InternTokenType)getInternTokenType
{
    return self.internTokenType;
}

- (NSString *)getTokenStringValue
{
    return self.tokenStringValue;
}

#pragma mark - Copy
- (id)mutableCopyWithZone:(NSZone *)zone
{
    return [[InternToken alloc]initWithType:self.internTokenType AndValue:self.tokenStringValue];
}

@end
