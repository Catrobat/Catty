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
#import "FormulaElement.h"
#import "UserVariable.h"
#import "VariablesContainer.h"
#import "ProgramVariablesManager.h"
#import "Program.h"

typedef enum {
    FORMULA_PARSER_OK = -1,
    FORMULA_PARSER_STACK_OVERFLOW = -2,
    FORMULA_PARSER_INPUT_SYNTAX_ERROR = -3,
    FORMULA_PARSER_STRING = -4,
    FORMULA_PARSER_NO_INPUT = -5
} FormulaParserStatus;

@interface InternFormulaParser : NSObject

@property (nonatomic, strong) NSMutableArray* internTokensToParse; // of InternToken
@property (nonatomic) int currentTokenParseIndex;
@property (nonatomic) int errorTokenIndex;
@property (nonatomic, weak) InternToken* currentToken;
@property (nonatomic) BOOL isBool;

- (id)initWithTokens:(NSArray*)tokens; // of InternToken
- (void)handleOperator:(NSString*) operator WithCurrentElement:(FormulaElement*) currentElement AndNewElement: (FormulaElement*) newElement;
- (FormulaElement*)parseFormulaForSpriteObject:(SpriteObject*)object;
- (int)getErrorTokenIndex;

@end
