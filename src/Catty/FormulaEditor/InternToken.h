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

#import <Foundation/Foundation.h>

typedef enum {
    BRACKET_OPEN = 1000,
    BRACKET_CLOSE,
    FUNCTION_PARAMETERS_BRACKET_OPEN,
    FUNCTION_PARAMETERS_BRACKET_CLOSE
} BracketType;

typedef enum {
    FUNCTION_PARAMETER_DELIMITER = 2000,
    FUNCTION_NAME,
    PARSER_END_OF_FILE
} ParserDelimiters;

typedef enum {
	TOKEN_TYPE_NUMBER = 3000,
    TOKEN_TYPE_OPERATOR,
    TOKEN_TYPE_FUNCTION_NAME,
    TOKEN_TYPE_BRACKET_OPEN,
    TOKEN_TYPE_BRACKET_CLOSE,
    TOKEN_TYPE_SENSOR,
    TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN,
    TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE,
    TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER,
    TOKEN_TYPE_PERIOD,
    TOKEN_TYPE_USER_VARIABLE,
    TOKEN_TYPE_STRING,
    TOKEN_TYPE_PARSER_END_OF_FILE
} InternTokenType;

typedef enum KeyboardButtonTypes
{
    CLEAR = 4000
}KeyboardButtonTypes;

typedef enum KeyboardNumbers
{
    TOKEN_TYPE_NUMBER_0 = 1,
    TOKEN_TYPE_NUMBER_1,
    TOKEN_TYPE_NUMBER_2,
    TOKEN_TYPE_NUMBER_3,
    TOKEN_TYPE_NUMBER_4,
    TOKEN_TYPE_NUMBER_5,
    TOKEN_TYPE_NUMBER_6,
    TOKEN_TYPE_NUMBER_7,
    TOKEN_TYPE_NUMBER_8,
    TOKEN_TYPE_NUMBER_9,
}KeyboardNumbers;

@interface InternToken : NSObject<NSMutableCopying>

@property (nonatomic, strong) NSString *tokenStringValue;
@property (nonatomic) InternTokenType internTokenType;

- (id)initWithType:(InternTokenType)internTokenType;
- (id)initWithType:(InternTokenType)internTokenType AndValue:(NSString*)value;
- (BOOL)isNumber;
- (BOOL)isOperator;
- (BOOL)isBracketOpen;
- (BOOL)isBracketClose;
- (BOOL)isFunctionParameterBracketOpen;
- (BOOL)isFunctionParameterBracketClose;
- (BOOL)isFunctionParameterDelimiter;
- (BOOL)isFunctionName;
- (BOOL)isSensor;
- (BOOL)isEndOfFileToken;
- (BOOL)isUserVariable;
- (BOOL)isString;
- (void)appendToTokenStringValue:(NSString*)stringToAppend;
- (void)appendToTokenStringValueWithArray:(NSArray*)internTokensToAppend;
- (BOOL)isEqualTo:(InternToken*)token;
- (InternTokenType)getInternTokenType;
- (NSString *)getTokenStringValue;

@end
