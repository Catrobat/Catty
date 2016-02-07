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

#import "InternFormulaParser.h"
#import "InternFormulaUtils.h"
#import "Operators.h"
#import "Functions.h"
#import "SensorManager.h"
#import "InternFormulaParserException.h"
#import "InternFormulaParserEmptyStackException.h"

@implementation InternFormulaParser

const int MAXIMUM_TOKENS_TO_PARSE = 1000;

- (id)initWithTokens:(NSArray*)tokens
{
    self = [super init];
    if(self) {
        self.internTokensToParse = [[NSMutableArray alloc] initWithArray:tokens];
    }
    return self;
}

- (void)handleOperator:(NSString*) operator WithCurrentElement:(FormulaElement*) currentElement AndNewElement: (FormulaElement*) newElement
{
    if (currentElement.parent == nil) {
        FormulaElement *formulaElement = [[FormulaElement alloc] initWithElementType:OPERATOR value:operator leftChild:currentElement rightChild:newElement parent:nil];
        formulaElement.type = formulaElement.type;
        return;
    }
    
    Operator parentOperator = [Operators getOperatorByValue:currentElement.parent.value];
    Operator currentOperator = [Operators getOperatorByValue:operator];
    
    int compareOperator = [Operators compareOperator:parentOperator WithOperator:currentOperator];
    
    if (compareOperator >= 0) {
        FormulaElement *newLeftChild = [self findLowerOrEqualPriorityFormulaElement:currentOperator element:currentElement];
        FormulaElement *newParent = newLeftChild.parent;
        
        if (newParent != nil) {
            [newLeftChild replaceWithSubElement:operator rightChild:newElement];
        } else {
            FormulaElement *formulaElement = [[FormulaElement alloc] initWithElementType:OPERATOR value:operator leftChild:newLeftChild rightChild:newElement parent:nil];
            formulaElement.type = formulaElement.type;
        }
    } else {
        [currentElement replaceWithSubElement:operator rightChild:newElement];
    }
}

- (FormulaElement*)parseFormulaForSpriteObject:(SpriteObject*)object
{
    self.errorTokenIndex = FORMULA_PARSER_OK;
    self.currentTokenParseIndex = 0;
    self.isBool = NO;
    if (self.internTokensToParse == nil || [self.internTokensToParse count] == 0) {
        self.errorTokenIndex = FORMULA_PARSER_NO_INPUT;
        return nil;
    }
    if ([self.internTokensToParse count] > MAXIMUM_TOKENS_TO_PARSE) {
        self.errorTokenIndex = FORMULA_PARSER_STACK_OVERFLOW;
        self.errorTokenIndex = 0;
        return nil;
    }
    
    @try {
        NSMutableArray *copyInternTokensToParse = [[NSMutableArray alloc] initWithArray:self.internTokensToParse];
        if ([InternFormulaUtils applyBracketCorrection:copyInternTokensToParse]) {
            NSDebug(@"applyBracketCorrection-> TRUE");
            [self.internTokensToParse removeAllObjects];
            [self.internTokensToParse addObjectsFromArray:copyInternTokensToParse];
        }
    } @catch (InternFormulaParserEmptyStackException *emptyStackException) {
        NSDebug(@"emptyStackException-> TRUE");
    }
    
    [self addEndOfFileToken];
    self.currentToken = [self.internTokensToParse objectAtIndex:0];
    FormulaElement *formulaParseTree = nil;
    
    @try {
        formulaParseTree = [self formulaForSpriteObject:object];
    } @catch (InternFormulaParserException *parseExeption) {
        self.errorTokenIndex = self.currentTokenParseIndex;
    }
    
    [self removeEndOfFileToken];
    return formulaParseTree;
}

- (FormulaElement*)findLowerOrEqualPriorityFormulaElement:(Operator)currentOperator element:(FormulaElement*)currentElement
{
    FormulaElement *returnElement = currentElement.parent;
    FormulaElement *notNullElement = currentElement;
    bool condition = true;
    
    while (condition) {
        if (returnElement == nil) {
            condition = false;
            returnElement = notNullElement;
        } else {
            Operator parentOperator = [Operators getOperatorByValue:returnElement.value];
            int compareOperator = [Operators compareOperator:parentOperator WithOperator:currentOperator];
            if (compareOperator < 0) {
                condition = false;
                returnElement = notNullElement;
            } else {
                notNullElement = returnElement;
                returnElement = returnElement.parent;
            }
        }
    }
    return returnElement;
}

- (void)addEndOfFileToken {
    InternToken *endOfFileParserToken = [[InternToken alloc] initWithType: TOKEN_TYPE_PARSER_END_OF_FILE];
    [self.internTokensToParse addObject:endOfFileParserToken];
}

- (void)removeEndOfFileToken {
    [self.internTokensToParse removeObjectAtIndex:([self.internTokensToParse count] - 1)];
}
     
- (FormulaElement*)formulaForSpriteObject:(SpriteObject*)object
{
    FormulaElement *termListTree = [self termListForSpriteObject:object];
    InternFormulaParserException *exception = [[InternFormulaParserException alloc] initWithName:@"Parse Error" reason:nil userInfo:nil];
    if (termListTree.type == STRING) {
        self.errorTokenIndex = FORMULA_PARSER_STRING;
    }
    if ([self.currentToken isEndOfFileToken]) {
        return termListTree;
    }

    @throw exception;
}
     
- (FormulaElement*)termListForSpriteObject:(SpriteObject*)object
{
    FormulaElement *currentElement = [self termForSpriteObject:object];
    FormulaElement *loopTermTree;
    NSString *operatorStringValue;
    if ([self.currentToken isOperator] && ([self.currentToken.tokenStringValue isEqualToString:[Operators getName:LOGICAL_AND]]||[self.currentToken.tokenStringValue isEqualToString:[Operators getName:LOGICAL_OR]])){
        self.isBool = YES;
    }
//    if ([self.currentToken isFunctionName] && ([self.currentToken.tokenStringValue isEqualToString:[Functions getName:TRUE_F]] || [self.currentToken.tokenStringValue isEqualToString:[Functions getName:FALSE_F]])) {
//        self.isBool = YES;
//    }
    while ([self.currentToken isOperator] && ![self.currentToken.tokenStringValue isEqualToString:[Operators getName:LOGICAL_NOT]]) {
        operatorStringValue = self.currentToken.tokenStringValue;
        [self getNextToken];
        loopTermTree = [self termForSpriteObject:object];
        [self handleOperator:operatorStringValue WithCurrentElement:currentElement AndNewElement:loopTermTree];
        currentElement = loopTermTree;
    }
    return [currentElement getRoot];
}
     
- (FormulaElement*)termForSpriteObject:(SpriteObject*)object
{
    FormulaElement *termTree = [[FormulaElement alloc] initWithElementType:NUMBER value:nil leftChild:nil rightChild:nil parent:nil];
    FormulaElement *currentElement = termTree;
         
    if ([self.currentToken isOperator] && [self.currentToken.tokenStringValue isEqualToString:[Operators getName:MINUS]]) {
        currentElement = [[FormulaElement alloc]initWithElementType:NUMBER value:nil leftChild:nil rightChild:nil parent:termTree];
        FormulaElement *newFormulaElement = [[FormulaElement alloc] initWithElementType:OPERATOR value:[Operators getName:MINUS] leftChild:nil rightChild:currentElement parent:nil];
        [termTree replaceElement:newFormulaElement];
        [self getNextToken];
    } else if ([self.currentToken isOperator] && [self.currentToken.tokenStringValue isEqualToString:[Operators getName:LOGICAL_NOT]]) {
        currentElement = [[FormulaElement alloc]initWithElementType:NUMBER value:nil leftChild:nil rightChild:nil parent:termTree];
        FormulaElement *newFormulaElement = [[FormulaElement alloc] initWithElementType:OPERATOR value:[Operators getName:LOGICAL_NOT] leftChild:nil rightChild:currentElement parent:nil];
        [termTree replaceElement:newFormulaElement];
        [self getNextToken];
    }
         
    switch (self.currentToken.internTokenType) {
        case TOKEN_TYPE_NUMBER: {
            [currentElement replaceElement:NUMBER value:[self number]];
            break;
        }
         
        case TOKEN_TYPE_BRACKET_OPEN: {
            [self getNextToken];
            FormulaElement *newFormulaElement = [[FormulaElement alloc] initWithElementType:BRACKET value:nil leftChild:nil rightChild:[self termListForSpriteObject:object] parent:nil];
            [currentElement replaceElement:newFormulaElement];
            
            if (![self.currentToken isBracketClose]) {
                [InternFormulaParserException raise:@"Parse Error" format:@""];
            }
            [self getNextToken];
            break;
        }
            
        case TOKEN_TYPE_FUNCTION_NAME: {
            [currentElement replaceElement:[self functionForSpriteObject:object]];
            break;
        }
         
        case TOKEN_TYPE_SENSOR: {
            [currentElement replaceElement:[self sensor]];
            break;
        }
        case TOKEN_TYPE_STRING: {
            [currentElement replaceElement:STRING value:[self string]];
            break;
        }
         
        case TOKEN_TYPE_USER_VARIABLE: {
            [currentElement replaceElement:[self userVariableForSpriteObject:object]];
            break;
        }
         
        default: {
            [InternFormulaParserException raise:@"Parse Error" format:@""];
            break;
        }
    }
    
    return termTree;
}
     
- (FormulaElement*)userVariableForSpriteObject:(SpriteObject*)object
{
    FormulaElement *formulaTree = [[FormulaElement alloc]initWithElementType:USER_VARIABLE value:[self.currentToken getTokenStringValue] leftChild:nil rightChild:nil parent:nil];
    
//    InternFormulaParserException *exception = [[InternFormulaParserException alloc] initWithName:@"Not implemented yet" reason:nil userInfo:nil];
//    @throw exception;
    [self getNextToken];
    return formulaTree;
}

- (FormulaElement*)functionForSpriteObject:(SpriteObject*)object
{
    FormulaElement *functionTree;
    
    if (![Functions isFunction:self.currentToken.tokenStringValue]) {
        [InternFormulaParserException raise:@"Parse Error" format:@""];
    }
    
    functionTree = [[FormulaElement alloc] initWithElementType:FUNCTION value:self.currentToken.tokenStringValue leftChild:nil rightChild:nil parent:nil];

    [self getNextToken];
    
    if ([self.currentToken isFunctionParameterBracketOpen]) {
        [self getNextToken];
        
        functionTree.leftChild = [self termListForSpriteObject:object];
        if ([self.currentToken isFunctionParameterDelimiter]) {
            [self getNextToken];
            functionTree.rightChild = [self termListForSpriteObject:object];
        }
        if (![self.currentToken isFunctionParameterBracketClose]) {
            [InternFormulaParserException raise:@"Parse Error" format:@""];
        }
        [self getNextToken];
    }
    return functionTree;
}

- (FormulaElement*)sensor
{
    if ((NSInteger)[SensorManager sensorForString:self.currentToken.tokenStringValue] == -1) {
        [InternFormulaParserException raise:@"Parse Error" format:@""];
    }
         
    FormulaElement *sensorTree = [[FormulaElement alloc] initWithElementType:SENSOR value:self.currentToken.tokenStringValue leftChild:nil rightChild:nil parent:nil];
    [self getNextToken];
    return sensorTree;
}

     
- (NSString*)number
{
    NSString* numberToCheck = self.currentToken.tokenStringValue;
    NSRange range = [numberToCheck rangeOfString:@"^(\\d)+(\\.(\\d)+)?$" options:NSRegularExpressionSearch];
    if (range.location == NSNotFound) {
        [InternFormulaParserException raise:@"Parse Error" format:@""];
    }
         
    [self getNextToken];
    return numberToCheck;
}

- (NSString *)string
{
    NSString *returnValue = self.currentToken.tokenStringValue;
    [self getNextToken];
    
    return returnValue;
    
}

- (void)getNextToken
{
    self.currentTokenParseIndex++;
    self.currentToken = [self.internTokensToParse objectAtIndex:self.currentTokenParseIndex];
}

- (int)getErrorTokenIndex
{
    return self.errorTokenIndex;
}

@end
