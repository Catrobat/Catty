/**
 *  Copyright (C) 2010-2014 The Catrobat Team
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

#import "InternFormulaUtils.h"
#import "InternToken.h"
#import "InternFormulaParser.h"
#import "NSMutableArray+Reverse.h"
#import "InternFormulaParserException.h"

@implementation InternFormulaUtils

- (id)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"This class can not be initialized."
                                 userInfo:nil];
    return nil;
}

+ (NSArray*)getFunctionByFunctionBracketClose:(NSArray*)internTokenList index:(int)functionBracketCloseInternTokenListIndex
{
    if (functionBracketCloseInternTokenListIndex == 0 || functionBracketCloseInternTokenListIndex == [internTokenList count])
    {
        return nil;
    }
    
    NSMutableArray *functionInternTokenList = [[NSMutableArray alloc] init];
    [functionInternTokenList addObject:[internTokenList objectAtIndex:functionBracketCloseInternTokenListIndex]];

    int functionIndex = functionBracketCloseInternTokenListIndex - 1;
    InternToken *tempSearchToken;
    int nestedFunctionsCounter = 1;
    
    do {
        if (functionIndex < 0) {
            return nil;
        }
        tempSearchToken = [internTokenList objectAtIndex:functionIndex];
        functionIndex--;
        
        switch (tempSearchToken.internTokenType) {
            case TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN:
                nestedFunctionsCounter--;
                break;
                
            case TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE:
                nestedFunctionsCounter++;
                break;
                
            default:
                continue;
        }
        
        [functionInternTokenList addObject:tempSearchToken];
    } while (tempSearchToken.internTokenType != TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN || nestedFunctionsCounter != 0);
    
    if (functionIndex < 0) {
        return nil;
    }
    tempSearchToken = [internTokenList objectAtIndex:functionIndex];
    
    if (tempSearchToken.internTokenType != TOKEN_TYPE_FUNCTION_NAME) {
        return nil;
    }
    
    [functionInternTokenList addObject:tempSearchToken];
    
    [functionInternTokenList reverse];
    
    return functionInternTokenList;
}

+ (NSArray*)getFunctionByParameterDelimiter:(NSArray*)internTokenList
                                      index:(int)functionParameterDelimiterInternTokenListIndex
{
    if (functionParameterDelimiterInternTokenListIndex == 0 || functionParameterDelimiterInternTokenListIndex == [internTokenList count]) {
        return nil;
    }
    
    NSMutableArray *functionInternTokenList = [[NSMutableArray alloc] init];
    [functionInternTokenList addObject:[internTokenList objectAtIndex:functionParameterDelimiterInternTokenListIndex]];
    
    int functionIndex = functionParameterDelimiterInternTokenListIndex - 1;
    InternToken *tempSearchToken;
    int nestedFunctionsCounter = 1;
    
    do {
        if (functionIndex < 0) {
            return nil;
        }
        tempSearchToken = [internTokenList objectAtIndex:functionIndex];
        functionIndex--;
        
        switch (tempSearchToken.internTokenType) {
            case TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN:
                nestedFunctionsCounter--;
                break;
                
            case TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE:
                nestedFunctionsCounter++;
                break;
                
            default:
                continue;
        }
        
        [functionInternTokenList addObject:tempSearchToken];
        
    } while (tempSearchToken.internTokenType != TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN || nestedFunctionsCounter != 0);
    
    if (functionIndex < 0) {
        return nil;
    }
    tempSearchToken = [internTokenList objectAtIndex:functionIndex];
    
    if (tempSearchToken.internTokenType != TOKEN_TYPE_FUNCTION_NAME) {
        return nil;
    }
    
    [functionInternTokenList addObject:tempSearchToken];
    
    [functionInternTokenList reverse];
    
    functionIndex = functionParameterDelimiterInternTokenListIndex + 1;
    nestedFunctionsCounter = 1;
    
    do {
        if (functionIndex >= [internTokenList count]) {
            return nil;
        }
        tempSearchToken = [internTokenList objectAtIndex:functionIndex];
        functionIndex++;
        
        switch (tempSearchToken.internTokenType) {
            case TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN:
                nestedFunctionsCounter++;
                break;
                
            case TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE:
                nestedFunctionsCounter--;
                break;
                
            default:
                continue;
        }
        
        [functionInternTokenList addObject:tempSearchToken];
        
    } while (tempSearchToken.internTokenType != TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE || nestedFunctionsCounter != 0);
    
    return functionInternTokenList;
}

+ (NSArray*)getFunctionByFunctionBracketOpen:(NSArray*)internTokenList
                                       index:(int)functionBracketOpenInternTokenListIndex
{
    if (functionBracketOpenInternTokenListIndex <= 0 || functionBracketOpenInternTokenListIndex >= [internTokenList count]) {
        return nil;
    }
    
    InternToken *functionNameInternToken = [internTokenList objectAtIndex:(functionBracketOpenInternTokenListIndex - 1)];
    
    if (functionNameInternToken.internTokenType != TOKEN_TYPE_FUNCTION_NAME) {
        return nil;
    }
    
    NSArray *functionInternTokenList = [self getFunctionByName:internTokenList index:(functionBracketOpenInternTokenListIndex - 1)];
    
    return functionInternTokenList;
}

+ (NSArray*)getFunctionByName:(NSArray*)internTokenList index:(int)functionStartListIndex
{
    InternToken *functionNameToken = [internTokenList objectAtIndex:functionStartListIndex];
    
    NSMutableArray *functionInternTokenList = [[NSMutableArray alloc] init];
    
    if (functionNameToken.internTokenType != TOKEN_TYPE_FUNCTION_NAME) {
        return nil;
    }
    
    [functionInternTokenList addObject:functionNameToken];
    
    int functionIndex = functionStartListIndex + 1;
    
    if (functionIndex >= [internTokenList count]) {
        return functionInternTokenList;
    }
    
    InternToken *functionStartParameter = [internTokenList objectAtIndex:functionIndex];
    
    if (!functionStartParameter.isFunctionParameterBracketOpen) {
        return functionInternTokenList;
    }
    
    [functionInternTokenList addObject:functionStartParameter];
    
    functionIndex++;
    InternToken *tempSearchToken;
    int nestedFunctionsCounter = 1;
    
    do {
        if (functionIndex >= [internTokenList count]) {
            return nil;
        }
        tempSearchToken = [internTokenList objectAtIndex:functionIndex];
        functionIndex++;
        
        switch (tempSearchToken.internTokenType) {
            case TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN:
                nestedFunctionsCounter++;
                break;
                
            case TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE:
                nestedFunctionsCounter--;
                break;
                
            default:
                continue;
        }
        
        [functionInternTokenList addObject:tempSearchToken];
        
    } while (tempSearchToken.internTokenType != TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE || nestedFunctionsCounter != 0);
    
    return functionInternTokenList;
}

+ (NSArray*)generateTokenListByBracketOpen:(NSArray*)internTokenList index:(int)internTokenListIndex
{
    if (internTokenListIndex == [internTokenList count] || ((InternToken*)([internTokenList objectAtIndex:internTokenListIndex])).internTokenType != TOKEN_TYPE_BRACKET_OPEN) {
        return nil;
    }
    
    NSMutableArray* bracketInternTokenListToReturn = [[NSMutableArray alloc] init];
    [bracketInternTokenListToReturn addObject:[internTokenList objectAtIndex:internTokenListIndex]];
    
    int bracketsIndex = internTokenListIndex + 1;
    int nestedBracketsCounter = 1;
    InternToken *tempSearchToken;
    
    do {
        if (bracketsIndex >= [internTokenList count]) {
            return nil;
        }
        tempSearchToken = [internTokenList objectAtIndex:bracketsIndex];
        bracketsIndex++;
        
        switch (tempSearchToken.internTokenType) {
            case TOKEN_TYPE_BRACKET_OPEN:
                nestedBracketsCounter++;
                break;
                
            case TOKEN_TYPE_BRACKET_CLOSE:
                nestedBracketsCounter--;
                break;
                
            default:
                continue;
        }
        
        [bracketInternTokenListToReturn addObject:tempSearchToken];
        
    } while (tempSearchToken.internTokenType != TOKEN_TYPE_BRACKET_CLOSE || nestedBracketsCounter != 0);
    
    return bracketInternTokenListToReturn;
}

+ (NSArray*)generateTokenListByBracketClose:(NSArray*)internTokenList index:(int)internTokenListIndex
{
    if (internTokenListIndex == [internTokenList count] || ((InternToken*)([internTokenList objectAtIndex:internTokenListIndex])).internTokenType !=TOKEN_TYPE_BRACKET_CLOSE) {
        return nil;
    }
    
    NSMutableArray *bracketInternTokenListToReturn = [[NSMutableArray alloc] init];
    [bracketInternTokenListToReturn addObject:[internTokenList objectAtIndex:internTokenListIndex]];
    
    int bracketSearchIndex = internTokenListIndex - 1;
    int nestedBracketsCounter = 1;
    InternToken *tempSearchToken;
    
    do {
        if (bracketSearchIndex < 0) {
            return nil;
        }
        tempSearchToken = [internTokenList objectAtIndex:bracketSearchIndex];
        bracketSearchIndex--;
        
        switch (tempSearchToken.internTokenType) {
            case TOKEN_TYPE_BRACKET_CLOSE:
                nestedBracketsCounter++;
                break;
                
            case TOKEN_TYPE_BRACKET_OPEN:
                nestedBracketsCounter--;
                break;
                
            default:
                continue;
        }
        
        [bracketInternTokenListToReturn addObject:tempSearchToken];
        
    } while (tempSearchToken.internTokenType != TOKEN_TYPE_BRACKET_OPEN || nestedBracketsCounter != 0);
    
    [bracketInternTokenListToReturn reverse];
    return bracketInternTokenListToReturn;
}

+ (NSArray*)getFunctionParameterInternTokensAsLists:(NSArray*)functionInternTokenList
{
    NSMutableArray *functionParameterInternTokenList = [[NSMutableArray alloc] init];
    
    if (functionInternTokenList == nil
        || [functionInternTokenList count] < 4
        || ((InternToken*)([functionInternTokenList objectAtIndex:0])).internTokenType != TOKEN_TYPE_FUNCTION_NAME
        || ((InternToken*)([functionInternTokenList objectAtIndex:1])).internTokenType != TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN) {
        return nil;
    }
    
    int searchIndex = 2;
    NSMutableArray *currentParameterInternTokenList = [[NSMutableArray alloc] init];
    
    InternToken *tempSearchToken;
    int nestedFunctionsCounter = 1;
    
    do {
        if (searchIndex >= [functionInternTokenList count]) {
            return nil;
        }
        
        tempSearchToken = [functionInternTokenList objectAtIndex:searchIndex];
        
        switch (tempSearchToken.internTokenType) {
            case TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN:
                nestedFunctionsCounter++;
                [currentParameterInternTokenList addObject:tempSearchToken];
                break;
                
            case TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE:
                nestedFunctionsCounter--;
                if (nestedFunctionsCounter != 0) {
                    [currentParameterInternTokenList addObject:tempSearchToken ];
                }
                break;
                
            case TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER:
                if (nestedFunctionsCounter == 1) {
                    [functionParameterInternTokenList addObject:currentParameterInternTokenList];
                    currentParameterInternTokenList = [[NSMutableArray alloc] init];
                    break;
                }
                
            default:
                [currentParameterInternTokenList addObject:tempSearchToken];
                break;
        }
        
        searchIndex++;
        
    } while (tempSearchToken.internTokenType != TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE || nestedFunctionsCounter != 0);
    
    if ([currentParameterInternTokenList count] > 0) {
        [functionParameterInternTokenList addObject:currentParameterInternTokenList];
    }
    
    return functionParameterInternTokenList;
}

+ (BOOL)isFunction:(NSArray*)internTokenList
{
    NSArray *functionList = [self getFunctionByName:internTokenList index:0];
    if (functionList == nil || [functionList count] != [internTokenList count]) {
        return false;
    }
    
    return true;
}

+ (InternTokenType)getFirstInternTokenType:(NSArray*)internTokens
{
    if (internTokens == nil || [internTokens count] == 0) {
        [InternFormulaParserException raise:@"Parse Error" format:nil];
    }
    
    return ((InternToken*)[internTokens objectAtIndex:0]).internTokenType;
}

+ (BOOL)isPeriodToken:(NSArray*)internTokens
{
    if (internTokens == nil || [internTokens count] != 1) {
        return false;
    }
    
    InternTokenType firstInternTokenType = ((InternToken*)[internTokens objectAtIndex:0]).internTokenType;
    
    if (firstInternTokenType == TOKEN_TYPE_PERIOD) {
        return true;
    }
    
    return false;
}

+ (BOOL)isFunctionToken:(NSArray*)internTokens
{
    InternTokenType firstInternTokenType;
    
    @try {
        firstInternTokenType = [self getFirstInternTokenType:internTokens];
    } @catch(InternFormulaParserException *e) {
        return true;
    }
    
    if (firstInternTokenType == TOKEN_TYPE_FUNCTION_NAME) {
        return true;
    }
    
    return false;
}

+ (BOOL)isNumberToken:(NSArray*)internTokens
{
    InternTokenType firstInternTokenType;
    
    @try {
        firstInternTokenType = [self getFirstInternTokenType:internTokens];
    } @catch(InternFormulaParserException *e) {
        return true;
    }
    
    if ([internTokens count] <= 1 && firstInternTokenType == TOKEN_TYPE_NUMBER) {
        return true;
    }
    
    return false;
}

+ (NSArray*)replaceFunctionByTokens:(NSArray*)functionToReplace
                        replaceWith:(NSArray*)internTokensToReplaceWith
{
    if ([self isFunctionToken:internTokensToReplaceWith]) {
        return [self replaceFunctionButKeepParameters:functionToReplace replaceWith:internTokensToReplaceWith];
    }
    
    return internTokensToReplaceWith;
}

+ (InternToken*)insertIntoNumberToken:(InternToken*)numberTokenToBeModified
                               numberOffset:(int)externNumberOffset
                               number:(NSString*)numberToInsert
{
    NSString *numberString = numberTokenToBeModified.tokenStringValue;
    NSString *leftPart = [numberString substringWithRange:NSMakeRange(0, externNumberOffset)];
    NSString *rightPart = [numberString substringFromIndex:externNumberOffset];
    
    numberTokenToBeModified.tokenStringValue = [NSString stringWithFormat:@"%@%@%@", leftPart, numberToInsert, rightPart];
    
    return numberTokenToBeModified;
}

+ (NSArray*)replaceFunctionButKeepParameters:(NSArray*)functionToReplace
                                 replaceWith:(NSArray*)functionToReplaceWith
{
    NSArray *keepParameterInternTokenList = [self getFunctionParameterInternTokensAsLists:functionToReplace];
    NSMutableArray *replacedParametersFunction = [[NSMutableArray alloc] init];
    NSArray *originalParameterInternTokenList = [self getFunctionParameterInternTokensAsLists:functionToReplaceWith];
    
    if (functionToReplace == nil || keepParameterInternTokenList == nil || originalParameterInternTokenList == nil) {
        return functionToReplaceWith;
    }
    
    [replacedParametersFunction addObject:[functionToReplaceWith objectAtIndex:0]];
    [replacedParametersFunction addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
    
    int functionParameterCount = [self getFunctionParameterCount:functionToReplaceWith];
    
    for (int index = 0; index < functionParameterCount; index++) {
        if (index < [keepParameterInternTokenList count] && [[keepParameterInternTokenList objectAtIndex:index] count] > 0) {
            [replacedParametersFunction addObjectsFromArray:[keepParameterInternTokenList objectAtIndex:index]];
        } else {
           [replacedParametersFunction addObjectsFromArray:[originalParameterInternTokenList objectAtIndex:index]];
        }
        
        if (index < functionParameterCount - 1) {
            [replacedParametersFunction addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER]];
        }
        
    }

    [replacedParametersFunction addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE]];
    
    return replacedParametersFunction;
}

+ (int)getFunctionParameterCount:(NSArray*)functionInternTokenList
{
        if (functionInternTokenList == nil
        || [functionInternTokenList count] < 4
        || ((InternToken*)[functionInternTokenList objectAtIndex:0]).internTokenType != TOKEN_TYPE_FUNCTION_NAME
        || ((InternToken*)[functionInternTokenList objectAtIndex:1]).internTokenType != TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN) {
        return 0;
    }
    
    int searchIndex = 2;
    
    InternToken *tempSearchToken;
    int nestedFunctionsCounter = 1;
    
    int functionParameterCount = 1;
    do {
        if (searchIndex >= [functionInternTokenList count]) {
            return 0;
        }
        
        tempSearchToken = [functionInternTokenList objectAtIndex:searchIndex];
        
        switch (tempSearchToken.internTokenType) {
            case TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN:
                nestedFunctionsCounter++;
                break;
                
            case TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE:
                nestedFunctionsCounter--;
                break;
                
            case TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER:
                if (nestedFunctionsCounter == 1) {
                    functionParameterCount++;
                }
                break;
                
            default:
                continue;
        }
        
        searchIndex++;
        
    } while (tempSearchToken.internTokenType != TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE || nestedFunctionsCounter != 0);
    return functionParameterCount;
}

+ (InternToken*)deleteNumberByOffset:(InternToken*)cursorPositionInternToken numberOffset:(int)externNumberOffset
{
    NSString *numberString = cursorPositionInternToken.tokenStringValue;
    
    if (externNumberOffset < 1) {
        return cursorPositionInternToken;
    }
    
    if (externNumberOffset > [numberString length]) {
        externNumberOffset = (int)[numberString length];
    }
    
    NSString *leftPart = [numberString substringWithRange:NSMakeRange(0, externNumberOffset - 1)];
    NSString *rightPart = [numberString substringFromIndex:externNumberOffset];
    
    cursorPositionInternToken.tokenStringValue = [NSString stringWithFormat:@"%@%@", leftPart, rightPart];
    
    if (cursorPositionInternToken.tokenStringValue == nil || [cursorPositionInternToken.tokenStringValue length] <= 0) {
        return nil;
    }
    
    return cursorPositionInternToken;
}

+ (BOOL)applyBracketCorrection:(NSMutableArray*)internFormula
{
    NSMutableArray *stack = [[NSMutableArray alloc] init];
    
    for (int index = 0; index < [internFormula count]; index++) {
        
        switch (((InternToken*)[internFormula objectAtIndex:index]).internTokenType) {
            case TOKEN_TYPE_BRACKET_OPEN:
                [stack addObject:[NSNumber numberWithInt:TOKEN_TYPE_BRACKET_OPEN]];
                break;
                
            case TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN:
                [stack addObject:[NSNumber numberWithInt:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
                break;
                
            case TOKEN_TYPE_BRACKET_CLOSE:
                if ((NSNumber*)[stack lastObject] == [NSNumber numberWithInt:TOKEN_TYPE_BRACKET_OPEN]) {
                    [stack removeLastObject];
                } else {
                    if ([self swapBrackets:internFormula firstBrackIndex:index tokenType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE]) {
                        [stack removeLastObject];
                        continue;
                    }
                    return false;
                }
                break;
                
            case TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE:
                if ((NSNumber*)[stack lastObject] == [NSNumber numberWithInt:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]) {
                    [stack removeLastObject];
                } else {
                    if ([self swapBrackets:internFormula firstBrackIndex:index tokenType:TOKEN_TYPE_BRACKET_CLOSE]) {
                        [stack removeLastObject];
                        continue;
                    }
                    return false;
                }
                break;
                
            default:
                continue;
        }
        
    }
    return true;
}

+ (BOOL)swapBrackets:(NSMutableArray*)internFormula firstBrackIndex:(int)firstBracketIndex
       tokenType:(InternTokenType)secondBracket
{
    for (int index = firstBracketIndex + 1; index < [internFormula count]; index++) {
        if (((InternToken*)[internFormula objectAtIndex:index]).internTokenType == secondBracket) {
            [internFormula exchangeObjectAtIndex:index withObjectAtIndex:firstBracketIndex];
            return true;
        }
    }
    return false;
}

@end