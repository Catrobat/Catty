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

#import <Foundation/Foundation.h>
#import "InternToken.h"

@interface InternFormulaUtils : NSObject

+ (NSArray*)getFunctionByFunctionBracketClose:(NSArray*)internTokenList index:(int)functionBracketCloseInternTokenListIndex;

+ (NSArray*)getFunctionByParameterDelimiter:(NSArray*)internTokenList
                                      index:(int)functionParameterDelimiterInternTokenListIndex;

+ (NSArray*)getFunctionByFunctionBracketOpen:(NSArray*)internTokenList
                                       index:(int)functionBracketOpenInternTokenListIndex;

+ (NSArray*)getFunctionByName:(NSArray*)internTokenList index:(int)functionStartListIndex;

+ (NSArray*)generateTokenListByBracketOpen:(NSArray*)internTokenList index:(int)internTokenListIndex;

+ (NSArray*)generateTokenListByBracketClose:(NSArray*)internTokenList index:(int)internTokenListIndex;

+ (NSArray*)getFunctionParameterInternTokensAsLists:(NSArray*)functionInternTokenList;

+ (BOOL)isFunction:(NSArray*)internTokenList;

+ (InternTokenType)getFirstInternTokenType:(NSArray*)internTokens;

+ (BOOL)isPeriodToken:(NSArray*)internTokens;

+ (BOOL)isFunctionToken:(NSArray*)internTokens;

+ (BOOL)isNumberToken:(NSArray*)internTokens;

+ (NSArray*)replaceFunctionByTokens:(NSArray*)functionToReplace
                        replaceWith:(NSArray*)internTokensToReplaceWith;

+ (NSMutableArray*)insertOperatorToNumberToken:(InternToken*)numberTokenToBeModified
                                  numberOffset:(int)externNumberOffset
                                        operator:(InternToken*)operatorToInsert;

+ (InternToken*)insertIntoNumberToken:(InternToken*)numberTokenToBeModified
                         numberOffset:(int)externNumberOffset
                               number:(NSString*)numberToInsert;

+ (NSArray*)replaceFunctionButKeepParameters:(NSArray*)functionToReplace
                                 replaceWith:(NSArray*)functionToReplaceWith;

+ (int)getFunctionParameterCount:(NSArray*)functionInternTokenList;

+ (InternToken*)deleteNumberByOffset:(InternToken*)cursorPositionInternToken numberOffset:(int)externNumberOffset;

+ (BOOL)applyBracketCorrection:(NSMutableArray*)internFormula;

+ (BOOL)swapBrackets:(NSMutableArray*)internFormula firstBrackIndex:(int)firstBracketIndex
           tokenType:(InternTokenType)secondBracket;

@end
