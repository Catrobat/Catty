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

#import "InternToExternGenerator.h"

@interface InternToExternGenerator ()

@property (nonatomic, strong)NSString *generatedExternFormulaString;
@property (nonatomic, strong)ExternInternRepresentationMapping *generatedExternInternRepresentationMapping;
@property (nonatomic, strong)NSMutableDictionary *INTERN_EXTERN_LANGUAGE_CONVERTER_MAP;

@end

@implementation InternToExternGenerator

-(ExternInternRepresentationMapping *)generatedExternInternRepresentationMapping
{
    if(!_generatedExternInternRepresentationMapping)
    {
        _generatedExternInternRepresentationMapping = [[ExternInternRepresentationMapping alloc]init];
    }
    return _generatedExternInternRepresentationMapping;
}

-(NSString *)generatedExternFormulaString
{
    if(!_generatedExternFormulaString)
    {
        _generatedExternFormulaString = [[NSString alloc]init];;
    }
    return _generatedExternFormulaString;
        
}

-(InternToExternGenerator *)init
{
    self = [super init];
    if(self)
    {
        self.INTERN_EXTERN_LANGUAGE_CONVERTER_MAP = [[NSMutableDictionary alloc]init];
        self.generatedExternFormulaString = [NSString stringWithFormat:@""];
        
        [self.INTERN_EXTERN_LANGUAGE_CONVERTER_MAP setObject:[Operators getName:DIVIDE] forKey:[NSNumber numberWithInt:DIVIDE]];
        [self.INTERN_EXTERN_LANGUAGE_CONVERTER_MAP setObject:[Operators getName:MINUS] forKey:[NSNumber numberWithInt:MINUS]];
        [self.INTERN_EXTERN_LANGUAGE_CONVERTER_MAP setObject:[Operators getName:PLUS] forKey:[NSNumber numberWithInt:PLUS]];
        [self.INTERN_EXTERN_LANGUAGE_CONVERTER_MAP setObject:[Operators getName:MULT] forKey:[NSNumber numberWithInt:MULT]];
        
        [self.INTERN_EXTERN_LANGUAGE_CONVERTER_MAP setObject:[Operators getName:DECIMAL_MARK] forKey:[NSNumber numberWithInt:DECIMAL_MARK]];
        
        
        [self.INTERN_EXTERN_LANGUAGE_CONVERTER_MAP setObject:[Functions getName:SIN] forKey:[NSNumber numberWithInt:SIN]];
        [self.INTERN_EXTERN_LANGUAGE_CONVERTER_MAP setObject:[Functions getName:COS] forKey:[NSNumber numberWithInt:COS]];
        [self.INTERN_EXTERN_LANGUAGE_CONVERTER_MAP setObject:[Functions getName:TAN] forKey:[NSNumber numberWithInt:TAN]];
        
        [self.INTERN_EXTERN_LANGUAGE_CONVERTER_MAP setObject:[Functions getName:LN] forKey:[NSNumber numberWithInt:LN]];
        [self.INTERN_EXTERN_LANGUAGE_CONVERTER_MAP setObject:[Functions getName:LOG] forKey:[NSNumber numberWithInt:LOG]];
        
        [self.INTERN_EXTERN_LANGUAGE_CONVERTER_MAP setObject:[Functions getName:PI_F] forKey:[NSNumber numberWithInt:PI_F]];
        [self.INTERN_EXTERN_LANGUAGE_CONVERTER_MAP setObject:[Functions getName:SQRT] forKey:[NSNumber numberWithInt:SQRT]];
        [self.INTERN_EXTERN_LANGUAGE_CONVERTER_MAP setObject:[Functions getName:RAND] forKey:[NSNumber numberWithInt:RAND]];
        [self.INTERN_EXTERN_LANGUAGE_CONVERTER_MAP setObject:[Functions getName:ABS] forKey:[NSNumber numberWithInt:ABS]];
        [self.INTERN_EXTERN_LANGUAGE_CONVERTER_MAP setObject:[Functions getName:ROUND] forKey:[NSNumber numberWithInt:ROUND]];
        [self.INTERN_EXTERN_LANGUAGE_CONVERTER_MAP setObject:[Functions getName:MOD] forKey:[NSNumber numberWithInt:MOD]];
        
        [self.INTERN_EXTERN_LANGUAGE_CONVERTER_MAP setObject:[Functions getName:ARCSIN] forKey:[NSNumber numberWithInt:ARCSIN]];
        [self.INTERN_EXTERN_LANGUAGE_CONVERTER_MAP setObject:[Functions getName:ARCCOS] forKey:[NSNumber numberWithInt:ARCCOS]];
        [self.INTERN_EXTERN_LANGUAGE_CONVERTER_MAP setObject:[Functions getName:ARCTAN] forKey:[NSNumber numberWithInt:ARCTAN]];
        
        [self.INTERN_EXTERN_LANGUAGE_CONVERTER_MAP setObject:[Functions getName:EXP] forKey:[NSNumber numberWithInt:EXP]];
        
        [self.INTERN_EXTERN_LANGUAGE_CONVERTER_MAP setObject:[Functions getName:MAX] forKey:[NSNumber numberWithInt:MAX]];
        [self.INTERN_EXTERN_LANGUAGE_CONVERTER_MAP setObject:[Functions getName:MIN] forKey:[NSNumber numberWithInt:MIN]];
        
        [self.INTERN_EXTERN_LANGUAGE_CONVERTER_MAP setObject:[Functions getName:TRUE_F] forKey:[NSNumber numberWithInt:TRUE_F]];
        [self.INTERN_EXTERN_LANGUAGE_CONVERTER_MAP setObject:[Functions getName:FALSE_F] forKey:[NSNumber numberWithInt:FALSE_F]];
        
        
        [self.INTERN_EXTERN_LANGUAGE_CONVERTER_MAP setObject:[Operators getName:LOGICAL_NOT] forKey:[NSNumber numberWithInt:LOGICAL_NOT]];
        [self.INTERN_EXTERN_LANGUAGE_CONVERTER_MAP setObject:[Operators getName:LOGICAL_OR] forKey:[NSNumber numberWithInt:LOGICAL_OR]];
        [self.INTERN_EXTERN_LANGUAGE_CONVERTER_MAP setObject:[Operators getName:LOGICAL_AND] forKey:[NSNumber numberWithInt:LOGICAL_AND]];
        [self.INTERN_EXTERN_LANGUAGE_CONVERTER_MAP setObject:[Operators getName:NOT_EQUAL] forKey:[NSNumber numberWithInt:NOT_EQUAL]];
        [self.INTERN_EXTERN_LANGUAGE_CONVERTER_MAP setObject:[Operators getName:EQUAL] forKey:[NSNumber numberWithInt:EQUAL]];
        [self.INTERN_EXTERN_LANGUAGE_CONVERTER_MAP setObject:[Operators getName:GREATER_THAN] forKey:[NSNumber numberWithInt:GREATER_THAN]];
        [self.INTERN_EXTERN_LANGUAGE_CONVERTER_MAP setObject:[Operators getName:GREATER_OR_EQUAL] forKey:[NSNumber numberWithInt:GREATER_OR_EQUAL]];
        [self.INTERN_EXTERN_LANGUAGE_CONVERTER_MAP setObject:[Operators getName:SMALLER_OR_EQUAL] forKey:[NSNumber numberWithInt:SMALLER_OR_EQUAL]];
        [self.INTERN_EXTERN_LANGUAGE_CONVERTER_MAP setObject:[Operators getName:SMALLER_THAN] forKey:[NSNumber numberWithInt:SMALLER_THAN]];
        
        
    }
    
    return self;
}

-(NSString *)getGeneratedExternFormulaString
{
    return self.generatedExternFormulaString;
}

-(ExternInternRepresentationMapping *)getGeneratedExternIternRepresentationMapping
{
    return self.generatedExternInternRepresentationMapping;
}

-(void)generateExternStringAndMapping:(NSArray *)internTokenFormula
{
    NSMutableArray *internTokenList = [[NSMutableArray alloc]init];
    for(InternToken *internToken in internTokenFormula)
    {
        [internTokenList addObject:internToken];
    }
    
    self.generatedExternFormulaString = [NSString stringWithFormat:@""];
    
    InternToken *currentToken = nil;
    InternToken *nextToken = nil;
    NSString *externTokenString;
    int externStringStartIndex;
    int externStringEndIndex;
    
    int internTokenListIndex = 0;
    
    while ([internTokenList count] != 0) {
        if([self appendWithWhitespace:currentToken andNextToken:nextToken])
        {
            self.generatedExternFormulaString = [self.generatedExternFormulaString stringByAppendingString:@" "];
        }
        externStringStartIndex = (int)[self.generatedExternFormulaString length];
        currentToken = [internTokenList objectAtIndex:0];
        if([internTokenList count] < 2)
        {
            nextToken = nil;
        }
        else
        {
            nextToken = [internTokenList objectAtIndex:1];
        }
        
        externTokenString = [self generateExternStringFromToken:currentToken];
        self.generatedExternFormulaString = [self.generatedExternFormulaString stringByAppendingString:externTokenString];
        externStringEndIndex = (int)[self.generatedExternFormulaString length];
        
        [self.generatedExternInternRepresentationMapping putMappingWithStart:externStringStartIndex andEnd:externStringEndIndex andInternListIndex:internTokenListIndex];
        
        [internTokenList removeObjectAtIndex:0];
        internTokenListIndex++;
    }
    
    self.generatedExternFormulaString = [self.generatedExternFormulaString stringByAppendingString:@" "];
}

-(NSString *)generateExternStringFromToken:(InternToken *)internToken
{
    NSString *returnValue;

    switch ([internToken getInternTokenType]) {
        case TOKEN_TYPE_NUMBER:

                return [internToken getTokenStringValue];
            
            break;
            
        case TOKEN_TYPE_OPERATOR:
            return [internToken getTokenStringValue];
            
            break;
        case TOKEN_TYPE_BRACKET_OPEN:
        case TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN:
            return @"(";
            break;
        case TOKEN_TYPE_BRACKET_CLOSE:
        case TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE:
            return @")";
            break;
        case TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER:
            return @",";
            break;
        case TOKEN_TYPE_USER_VARIABLE:
            
            returnValue = [NSString stringWithFormat:@"\""];
            
            returnValue = [returnValue stringByAppendingString:[internToken getTokenStringValue]];
            returnValue = [returnValue stringByAppendingString:@"\""];
            
            return returnValue;
            break;
        case TOKEN_TYPE_STRING:
            returnValue = [NSString stringWithFormat:@"\""];
            
            returnValue = [returnValue stringByAppendingString:[internToken getTokenStringValue]];
            returnValue = [returnValue stringByAppendingString:@"\""];
            
            return returnValue;
            break;
            
        default:
            return [internToken getTokenStringValue];
            break;
    }
}

-(NSString *)getExternStringForInternTokenValue:(NSString *)internTokenValue
{
    //to interpret some intern texts (PLUS, MINUS, MULT for extern view)
    return @"";
}

-(BOOL)appendWithWhitespace:(InternToken *)currenToken andNextToken:(InternToken *)nextToken
{
    if(currenToken == nil)
    {
        return NO;
    }
    if(nextToken == nil)
    {
        return YES;
    }
    switch ([nextToken getInternTokenType]) {
        case TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN:
            return NO;
            
            break;
            
        default:
            break;
    }
    return YES;
}

@end
