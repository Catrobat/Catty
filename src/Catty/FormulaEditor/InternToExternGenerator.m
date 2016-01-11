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

#import "InternToExternGenerator.h"

@interface InternToExternGenerator ()

@property (nonatomic, strong)NSString *generatedExternFormulaString;
@property (nonatomic, strong)ExternInternRepresentationMapping *generatedExternInternRepresentationMapping;
@property (nonatomic, strong)NSMutableDictionary *INTERN_EXTERN_LANGUAGE_CONVERTER_MAP;

@end

@implementation InternToExternGenerator

- (ExternInternRepresentationMapping *)generatedExternInternRepresentationMapping
{
    if(!_generatedExternInternRepresentationMapping)
    {
        _generatedExternInternRepresentationMapping = [[ExternInternRepresentationMapping alloc]init];
    }
    return _generatedExternInternRepresentationMapping;
}

- (NSString *)generatedExternFormulaString
{
    if(!_generatedExternFormulaString)
    {
        _generatedExternFormulaString = [[NSString alloc]init];;
    }
    return _generatedExternFormulaString;
        
}

- (InternToExternGenerator *)init
{
    self = [super init];
    if(self)
    {
      
    }
    
    return self;
}

- (NSString *)getGeneratedExternFormulaString
{
    return self.generatedExternFormulaString;
}

- (ExternInternRepresentationMapping *)getGeneratedExternIternRepresentationMapping
{
    return self.generatedExternInternRepresentationMapping;
}

- (void)generateExternStringAndMapping:(NSArray *)internTokenFormula
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
}

- (NSString *)generateExternStringFromToken:(InternToken *)internToken
{
    NSString *returnValue;
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithString:[[internToken getTokenStringValue] stringByReplacingOccurrencesOfString:@" " withString:@""]];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];

    switch ([internToken getInternTokenType]) {
        case TOKEN_TYPE_NUMBER:

            if(![[NSDecimalNumber notANumber] isEqual:number])
            {
                NSString *returnString = [formatter stringFromNumber:[NSNumber numberWithDouble:[number doubleValue]]];
                if([[internToken getTokenStringValue] hasSuffix:@"."])
                {
                    returnString = [returnString stringByAppendingString:[formatter decimalSeparator]];
                }
                return returnString;
            } else {
                return [internToken getTokenStringValue];
            }
            
            break;
            
        case TOKEN_TYPE_OPERATOR:
            return [Operators getExternName:[internToken getTokenStringValue]];
            
            break;
            
        case TOKEN_TYPE_FUNCTION_NAME:
            return [Functions getExternName:[internToken getTokenStringValue]];
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
            returnValue = [NSString stringWithFormat:@"\'"];
            
            returnValue = [returnValue stringByAppendingString:[internToken getTokenStringValue]];
            returnValue = [returnValue stringByAppendingString:@"\'"];
            
            return returnValue;
            break;
        case TOKEN_TYPE_SENSOR:
            return [SensorManager getExternName:[internToken getTokenStringValue]];
            break;
        default:
            return [internToken getTokenStringValue];
            break;
    }
}


- (BOOL)appendWithWhitespace:(InternToken *)currenToken andNextToken:(InternToken *)nextToken
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
