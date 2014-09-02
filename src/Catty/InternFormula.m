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

#import "InternFormula.h"

@interface InternFormula()

@property (nonatomic, strong)ExternInternRepresentationMapping *externInternRepresentationMapping;
@property (nonatomic, strong)NSMutableArray *internTokenFormulaList;
@property (nonatomic, strong)NSString *externFormulaString;
@property (nonatomic, strong)InternFormulaTokenSelection *internFormulaTokenSelection;
@property (nonatomic, strong)InternToken *cursorPositionInternToken;
@property (nonatomic, strong)InternFormulaParser *internTokenFormulaParser;

@property (nonatomic)CursorTokenPosition cursorTokenPosition;
@property (nonatomic)int externCursorPosition;
@property (nonatomic)int cursorPositionInternTokenIndex;

@end

static int MAPPING_NOT_FOUND = INT_MIN;

@implementation InternFormula

-(ExternInternRepresentationMapping *)externInternRepresentationMapping
{
    if(!_externInternRepresentationMapping)
    {
        _externInternRepresentationMapping = [[ExternInternRepresentationMapping alloc]init];
    }
    
    return _externInternRepresentationMapping;
}

-(NSMutableArray *)internTokenFormulaList
{
    if (!_internTokenFormulaList) {
        _internTokenFormulaList = [[NSMutableArray alloc]init];
    }
    return _internTokenFormulaList;
}

-(NSString *)externFormulaString
{
    if(!_externFormulaString)
    {
        _externFormulaString = [[NSString alloc]init];
    }
    return _externFormulaString;
}

-(InternFormula *)initWithInternTokenList:(NSMutableArray *)internTokenList
{
    self = [super init];
    if(self)
    {
        self.internTokenFormulaList = internTokenList;
        self.externFormulaString = nil;
        self.internFormulaTokenSelection = nil;
        self.externCursorPosition = 0;
        self.cursorPositionInternTokenIndex = 0;
    }
    return self;
}

-(InternFormula *)initWithInternTokenList:(NSMutableArray *)internTokenList
              internFormulaTokenSelection:(InternFormulaTokenSelection *)internFormulaTokenSelection
                     externCursorPosition:(int)externCursorPosition
{
    self = [super init];
    if(self)
    {
        self.internTokenFormulaList = internTokenList;
        self.externFormulaString = nil;
        self.internFormulaTokenSelection = internFormulaTokenSelection;
        self.externCursorPosition = externCursorPosition;
        
        [self updateInternCursorPosition];
        
    }
    return self;
}

-(void)setCursorAndSelection:(int)externCursorPosition
                    selected:(BOOL)isSelected
{
    self.externCursorPosition = externCursorPosition;
    [self updateInternCursorPosition];
    self.internFormulaTokenSelection = nil;
//    Possible that thera are errors on that long query
    if(isSelected
       || ([self.externInternRepresentationMapping getInternTokenByExternIndex:externCursorPosition] != MAPPING_NOT_FOUND
       && ([self getFirstLeftInternToken:externCursorPosition-1] == self.cursorPositionInternToken || [self.cursorPositionInternToken isFunctionParameterBracketOpen])
       && (([self.cursorPositionInternToken isFunctionName])
           || ([self.cursorPositionInternToken isFunctionParameterBracketOpen] && self.cursorTokenPosition == LEFT)
           || ([self.cursorPositionInternToken isSensor]) || ([self.cursorPositionInternToken isUserVariable]) || ([self.cursorPositionInternToken isString]))))
    {
        [self selectCursorPositionInternToken:USER_SELECTION];
    }
}

-(void)handleKeyInputWithName:(NSString *)name butttonType:(int)resourceId
{
    NSMutableArray *keyInputInternTokenList = [[InternFormulaKeyboardAdapter alloc]createInternTokenListByResourceId:resourceId name:name];
    
    CursorTokenPropertiesAfterModification cursorTokenPropertiesAfterInput = DO_NOT_MODIFY;
    if(resourceId == CLEAR)
    {
        cursorTokenPropertiesAfterInput = [self handleDeletion];
    }else if ([self isTokenSelected])
    {
        cursorTokenPropertiesAfterInput = [self replaceSelection:keyInputInternTokenList];
        
    }else if(self.cursorTokenPosition == 0)
    {
        cursorTokenPropertiesAfterInput = [self insertRightToCurrentToken:keyInputInternTokenList];
    }
    else{
        switch (self.cursorTokenPosition) {
            case LEFT:
                cursorTokenPropertiesAfterInput = [self insertLeftToCurrentToken:keyInputInternTokenList];
                break;
            case MIDDLE:
                cursorTokenPropertiesAfterInput = [self replaceCursorPositionInternTokenByTokenList:keyInputInternTokenList];
                break;
            case RIGHT:
                cursorTokenPropertiesAfterInput = [self insertRightToCurrentToken:keyInputInternTokenList];
                break;
            default:
                break;
        }
    }
    
    [self generateExternFormulaStringAndInternExternMapping];
    [self updateExternCursorPosition:cursorTokenPropertiesAfterInput];
    [self updateInternCursorPosition];
    
}

-(void)generateExternFormulaStringAndInternExternMapping
{
    InternToExternGenerator *internToExternGenerator = [[InternToExternGenerator alloc]init];
    [internToExternGenerator generateExternStringAndMapping:self.internTokenFormulaList];
    self.externFormulaString = [internToExternGenerator getGeneratedExternFormulaString];
    self.externInternRepresentationMapping = [internToExternGenerator getGeneratedExternIternRepresentationMapping];
}

-(void)updateExternCursorPosition:(CursorTokenPropertiesAfterModification)cursorTakenPropertiesAfterInput
{
    switch (cursorTakenPropertiesAfterInput) {
        case AM_LEFT:
            [self setExternCursorPositionLeftTo:self.cursorPositionInternTokenIndex];
            break;
        case AM_RIGHT:
            [self setExternCursorPositionRightTo:self.cursorPositionInternTokenIndex];
            break;
        default:
            break;
    }
}

-(CursorTokenPropertiesAfterModification)insertLeftToCurrentToken:(NSMutableArray *)internTokensToInsert
{
    InternToken *firstLeftInternToken = nil;
    if(self.cursorPositionInternTokenIndex > 0)
    {
        firstLeftInternToken = [self.internTokenFormulaList objectAtIndex:self.cursorPositionInternTokenIndex - 1];
    }
    
    if([self.cursorPositionInternToken isNumber] && [InternFormulaUtils isNumberToken:internTokensToInsert])
    {
        NSString *numberToInsert = [[internTokensToInsert objectAtIndex:0] getTokenStringValue];
        [InternFormulaUtils insertIntoNumberToken:self.cursorPositionInternToken numberOffset:0 number:numberToInsert];
        self.externCursorPosition++;
        
        return DO_NOT_MODIFY;
    }
    
    if([self.cursorPositionInternToken isNumber] && [InternFormulaUtils isPeriodToken:internTokensToInsert])
    {
        NSString *numberToInsert = [[internTokensToInsert objectAtIndex:0] getTokenStringValue];
        NSCharacterSet *cset = [NSCharacterSet characterSetWithCharactersInString:@"."];
        if([numberToInsert rangeOfCharacterFromSet:cset].location != NSNotFound)
        {
            return DO_NOT_MODIFY;
        }
        
        [InternFormulaUtils insertIntoNumberToken:self.cursorPositionInternToken numberOffset:0 number:@"0."];
        self.externCursorPosition += 2;
        return DO_NOT_MODIFY;
    }
    
    if(firstLeftInternToken != nil && [firstLeftInternToken isNumber] && [InternFormulaUtils isNumberToken:internTokensToInsert])
    {
        [firstLeftInternToken appendToTokenStringValueWithArray:internTokensToInsert];
        return DO_NOT_MODIFY;
    }
    
    if(firstLeftInternToken != nil && [firstLeftInternToken isNumber] && [InternFormulaUtils isPeriodToken:internTokensToInsert])
    {
        NSString *numberString = [firstLeftInternToken getTokenStringValue];
        NSCharacterSet *cset = [NSCharacterSet characterSetWithCharactersInString:@"."];
        if([numberString rangeOfCharacterFromSet:cset].location != NSNotFound)
        {
            return DO_NOT_MODIFY;
        }
        
        [firstLeftInternToken appendToTokenStringValue:@"."];
        return DO_NOT_MODIFY;
    }
    
    if([InternFormulaUtils isPeriodToken:internTokensToInsert])
    {
        [self.internTokenFormulaList insertObject:[[InternToken alloc]initWithType:TOKEN_TYPE_NUMBER AndValue:@"0."]
                                          atIndex:self.cursorPositionInternTokenIndex];
        self.cursorPositionInternToken = nil;
        return AM_RIGHT;
    }
    
    [self addSourceArray:internTokensToInsert
                toTarget:self.internTokenFormulaList
                 atIndex:self.cursorPositionInternTokenIndex];
    
    return [self setCursorPositionAndSelectionAfterInput:self.cursorPositionInternTokenIndex];
    
}

-(CursorTokenPropertiesAfterModification)insertRightToCurrentToken:(NSMutableArray *)internTokensToInsert
{
    
    if(self.cursorPositionInternToken == nil)
    {
        if([InternFormulaUtils isPeriodToken:[NSArray arrayWithArray:internTokensToInsert]])
        {
            internTokensToInsert = [[NSMutableArray alloc]init];
            [internTokensToInsert addObject:[[InternToken alloc]initWithType:TOKEN_TYPE_NUMBER AndValue:@"0."]];
        }
        
        [self addSourceArray:internTokensToInsert toTarget:self.internTokenFormulaList atIndex:0];
        
        return [self setCursorPositionAndSelectionAfterInput:0];
    }
    
    if([self.cursorPositionInternToken isNumber] && [InternFormulaUtils isNumberToken:internTokensToInsert])
    {
        [self.cursorPositionInternToken appendToTokenStringValueWithArray:internTokensToInsert];
        return AM_RIGHT;
    }
    
    
    
    if([self.cursorPositionInternToken isNumber] && [InternFormulaUtils isPeriodToken:[NSArray arrayWithArray:internTokensToInsert]])
    {
        NSString *numberString = [self.cursorPositionInternToken getTokenStringValue];
        NSCharacterSet *cset = [NSCharacterSet characterSetWithCharactersInString:@"."];
        
        if([numberString rangeOfCharacterFromSet:cset].location != NSNotFound)
        {
            return DO_NOT_MODIFY;
        }
        [self.cursorPositionInternToken appendToTokenStringValue:@"."];
        return AM_RIGHT;
        
    }
    
    if([InternFormulaUtils isPeriodToken:internTokensToInsert])
    {
        [self.internTokenFormulaList insertObject:[[InternToken alloc]initWithType:TOKEN_TYPE_NUMBER AndValue:@"0."]
                                          atIndex:self.cursorPositionInternTokenIndex + 1];
        
        self.cursorPositionInternToken = nil;
        self.cursorPositionInternTokenIndex++;
        
        return AM_RIGHT;
    
    }
    [self addSourceArray:internTokensToInsert toTarget:self.internTokenFormulaList atIndex:self.cursorPositionInternTokenIndex + 1];
    
    
    return [self setCursorPositionAndSelectionAfterInput:self.cursorPositionInternTokenIndex +1];
    
}

-(CursorTokenPropertiesAfterModification)handleDeletion
{
    CursorTokenPropertiesAfterModification cursorTokenPropertiesAfterModification = DO_NOT_MODIFY;
    if(self.internFormulaTokenSelection != nil)
    {
        [self deleteInternTokensWithStart:(int)[self.internFormulaTokenSelection getStartIndex]
                                      end:(int)[self.internFormulaTokenSelection getEndIndex]];
        self.cursorPositionInternTokenIndex = (int)[self.internFormulaTokenSelection getStartIndex];
        self.cursorPositionInternToken = nil;
        self.internFormulaTokenSelection = nil;
        
        cursorTokenPropertiesAfterModification = AM_LEFT;
    }else{
        InternToken *firstLeftInternToken;
        switch (self.cursorTokenPosition) {
            case LEFT:
                firstLeftInternToken = [self getFirstLeftInternToken:self.externCursorPosition];
                if(firstLeftInternToken == nil)
                {
                    cursorTokenPropertiesAfterModification = DO_NOT_MODIFY;
                }
                else{
                    int firstLeftInternTokenIndex = (int)[self.internTokenFormulaList indexOfObject:firstLeftInternToken];
                    cursorTokenPropertiesAfterModification = [self deleteInternTokenByIndex:firstLeftInternTokenIndex];
                }
                break;
                
            case MIDDLE:
                
                cursorTokenPropertiesAfterModification = [self deleteInternTokenByIndex:self.cursorPositionInternTokenIndex];
                
                break;
            case RIGHT:
                
                cursorTokenPropertiesAfterModification = [self deleteInternTokenByIndex:self.cursorPositionInternTokenIndex];
                
                break;
                
            default:
                break;
        }
    }
    
    return cursorTokenPropertiesAfterModification;
}

-(CursorTokenPropertiesAfterModification)deleteInternTokenByIndex:(int)internTokenIndex
{
    InternToken *tokenToDelete = [self.internTokenFormulaList objectAtIndex:internTokenIndex];
    int externNumberOffset;
    
    InternToken *modifiedToken;
    NSArray *functionInternTokens;
    InternToken *lastFunctionToken;
    
    switch ([tokenToDelete getInternTokenType]) {
        case TOKEN_TYPE_NUMBER:
            externNumberOffset = [self.externInternRepresentationMapping getExternTokenStartOffset:self.externCursorPosition
                                                                                withInternOffsetTo:internTokenIndex];
            if(externNumberOffset == -1)
            {
                return DO_NOT_MODIFY;
            }
            
            modifiedToken = [InternFormulaUtils deleteNumberByOffset:tokenToDelete
                                                        numberOffset:externNumberOffset];
            if(modifiedToken == nil)
            {
                [self.internTokenFormulaList removeObjectAtIndex:internTokenIndex];
                self.cursorPositionInternTokenIndex = internTokenIndex;
                self.cursorPositionInternToken = nil;
                return AM_LEFT;
            }
            self.externCursorPosition --;
            return DO_NOT_MODIFY;
            
            break;
            
        case TOKEN_TYPE_FUNCTION_NAME:
            functionInternTokens = [InternFormulaUtils getFunctionByName:self.internTokenFormulaList index:internTokenIndex];
            if(functionInternTokens==nil || [functionInternTokens count] == 0)
            {
                return DO_NOT_MODIFY;
            }
            
            int lastListIndex = (int)[functionInternTokens count] - 1;
            lastFunctionToken = [functionInternTokens objectAtIndex:lastListIndex];
            int endIndexToDelete = (int)[self.internTokenFormulaList indexOfObject:lastFunctionToken];
            
            [self deleteInternTokensWithStart:internTokenIndex end:endIndexToDelete];
            [self setExternCursorPositionLeftTo:internTokenIndex];
            
            self.cursorPositionInternTokenIndex = internTokenIndex;
            self.cursorPositionInternToken = nil;
            
            return AM_LEFT;
            break;
            
        case TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN:
            
            functionInternTokens = [InternFormulaUtils getFunctionByFunctionBracketOpen:self.internTokenFormulaList index:internTokenIndex
                                    ];
            if(functionInternTokens == nil || [functionInternTokens count] == 0)
            {
                return DO_NOT_MODIFY;
            }
            
            int functionInternTokensLastIndex = (int)[functionInternTokens count] - 1;
            
            int startDeletionIndex = (int)[self.internTokenFormulaList indexOfObject:[functionInternTokens objectAtIndex:0]];
            endIndexToDelete = (int)[self.internTokenFormulaList indexOfObject:[functionInternTokens objectAtIndex:functionInternTokensLastIndex]];
            
            [self deleteInternTokensWithStart:startDeletionIndex end:endIndexToDelete];
            
            self.cursorPositionInternTokenIndex = startDeletionIndex;
            self.cursorPositionInternToken = nil;
            
            return AM_LEFT;
            
            break;
            
        case TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE:
            
            functionInternTokens = [InternFormulaUtils getFunctionByFunctionBracketClose:self.internTokenFormulaList index:internTokenIndex
                                    ];
            if(functionInternTokens == nil || [functionInternTokens count] == 0)
            {
                return DO_NOT_MODIFY;
            }
            
            functionInternTokensLastIndex = (int)[functionInternTokens count] - 1;
            
            startDeletionIndex = (int)[self.internTokenFormulaList indexOfObject:[functionInternTokens objectAtIndex:0]];
            endIndexToDelete = (int)[self.internTokenFormulaList indexOfObject:[functionInternTokens objectAtIndex:functionInternTokensLastIndex]];
            
            [self deleteInternTokensWithStart:startDeletionIndex end:endIndexToDelete];
            
            self.cursorPositionInternTokenIndex = startDeletionIndex;
            self.cursorPositionInternToken = nil;
            
            return AM_LEFT;
            
            break;
            
        case TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER:
            
            functionInternTokens = [InternFormulaUtils getFunctionByParameterDelimiter:self.internTokenFormulaList index:internTokenIndex
                                    ];
            if(functionInternTokens == nil || [functionInternTokens count] == 0)
            {
                return DO_NOT_MODIFY;
            }
            
            functionInternTokensLastIndex = (int)[functionInternTokens count] - 1;
            
            startDeletionIndex = (int)[self.internTokenFormulaList indexOfObject:[functionInternTokens objectAtIndex:0]];
            endIndexToDelete = (int)[self.internTokenFormulaList indexOfObject:[functionInternTokens objectAtIndex:functionInternTokensLastIndex]];
            
            [self deleteInternTokensWithStart:startDeletionIndex end:endIndexToDelete];
            
            self.cursorPositionInternTokenIndex = startDeletionIndex;
            self.cursorPositionInternToken = nil;
            
            return AM_LEFT;
            
            break;
            
        default:
            
            [self deleteInternTokensWithStart:internTokenIndex end:internTokenIndex];
            self.cursorPositionInternTokenIndex = internTokenIndex;
            self.cursorPositionInternToken = nil;
            return AM_LEFT;
            
            break;
    }
}


-(void)setExternCursorPositionLeftTo:(int)internTokenIndex
{
    if([self.internTokenFormulaList count] < 1)
    {
        self.externCursorPosition = 1;
        return;
    }
    if(internTokenIndex >= [self.internTokenFormulaList count])
    {
        [self setExternCursorPositionRightTo:(int)[self.internTokenFormulaList count] - 1];
        return;
    }
    
    int externTokenStartIndex = [self.externInternRepresentationMapping getExternTokenStartIndex:internTokenIndex];
    if(externTokenStartIndex == MAPPING_NOT_FOUND)
    {
        return;
    }
    
    self.externCursorPosition = externTokenStartIndex;
    self.cursorTokenPosition = LEFT;
}

-(void)setExternCursorPositionRightTo:(int)internTokenIndex
{
    if([self.internTokenFormulaList count] < 1)
    {
        return;
    }
    
    if(internTokenIndex >= [self.internTokenFormulaList count])
    {
        internTokenIndex = (int)[self.internTokenFormulaList count] - 1;
    }
    
    int externTokenEndIndex = [self.externInternRepresentationMapping getExternTokenEndIndex:internTokenIndex];
    
    if(externTokenEndIndex == MAPPING_NOT_FOUND)
    {
        return;
    }
    
    self.externCursorPosition = externTokenEndIndex;
    self.cursorTokenPosition = RIGHT;
    
}

-(void)deleteInternTokensWithStart:(int)deleteIndexStart end:(int)deleteIndexEnd
{
    NSMutableArray *tokenListToInsert = [[NSMutableArray alloc]init];
    [self replaceInternTokensInList:tokenListToInsert
                  replaceIndexStart:deleteIndexStart
                    replaceIndexEnd:deleteIndexEnd];
}

-(void)replaceInternTokensInList:(NSArray *)tokenListToInsert
               replaceIndexStart:(int)start
                 replaceIndexEnd:(int)end
{
    //wozu auch immer diese tokenListToRemove gut ist...
    
    NSMutableArray *tokenListToRemove = [[NSMutableArray alloc]init];
    for(int tokensToRemove = end - start; tokensToRemove >=0; tokensToRemove--)
    {
        [tokenListToRemove addObject:[self.internTokenFormulaList objectAtIndex:start]];
        [self.internTokenFormulaList removeObjectAtIndex:start];
        
        
    }
    [self addSourceArray:tokenListToInsert toTarget:self.internTokenFormulaList atIndex:start];
}

-(void)selectCursorPositionInternToken:(TokenSelectionType)internTokenSelectionType
{
    
    self.internFormulaTokenSelection = nil;
    if(self.cursorPositionInternToken == nil)
    {
        return;
    }
//    NSMutableArray *functionInternTokens;
    
    NSArray *functionInternTokens;
    NSArray *bracketsInternTokens;
    InternToken *lastFunctionToken;
    
    
    
    switch([self.cursorPositionInternToken getInternTokenType])
    {
            
        case TOKEN_TYPE_FUNCTION_NAME:
            
//            functionInternTokens = [[InternFormulaUtils getFunctionByName:self.internTokenFormulaList index:self.cursorPositionInternTokenIndex]mutableCopy];

            functionInternTokens = [InternFormulaUtils getFunctionByName:self.internTokenFormulaList
                                                                   index:self.cursorPositionInternTokenIndex];
            if(functionInternTokens == nil || [functionInternTokens count] == 0)
            {
                return;
            }
            
            int lastListIndex = (int)[functionInternTokens count]-1;
            
            lastFunctionToken = [functionInternTokens objectAtIndex:lastListIndex];
            
            int endSelectedIndex = (int)[self.internTokenFormulaList indexOfObject:lastFunctionToken];
            self.internFormulaTokenSelection = [[InternFormulaTokenSelection alloc]initWithTokenSelectionType:internTokenSelectionType
                                                                                    internTokenSelectionStart:self.cursorPositionInternTokenIndex
                                                                                      internTokenSelectionEnd:endSelectedIndex];
            
            break;
        case TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN:
            functionInternTokens = [InternFormulaUtils getFunctionByFunctionBracketOpen:self.internTokenFormulaList
                                                                                  index:self.cursorPositionInternTokenIndex];
            if(functionInternTokens == nil || [functionInternTokens count] == 0)
            {
                return;
            }
            
            int functionInternTokensLastIndex = (int)[functionInternTokens count] - 1;
            int startSelectionIndex = (int)[self.internTokenFormulaList objectAtIndex:(int)[functionInternTokens objectAtIndex:0]];
            endSelectedIndex = (int)[self.internTokenFormulaList objectAtIndex:(int)[functionInternTokens objectAtIndex:functionInternTokensLastIndex]];
    
            self.internFormulaTokenSelection = [[InternFormulaTokenSelection alloc]initWithTokenSelectionType:internTokenSelectionType
                                                                                    internTokenSelectionStart:startSelectionIndex
                                                                                      internTokenSelectionEnd:endSelectedIndex];
            
            
            break;
        case TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE:
            functionInternTokens = [InternFormulaUtils getFunctionByFunctionBracketClose:self.internTokenFormulaList
                                                                                   index:self.cursorPositionInternTokenIndex];
            if(functionInternTokens == nil || [functionInternTokens count] == 0)
            {
                return;
            }
            
            functionInternTokensLastIndex = (int)[functionInternTokens count]-1;
            startSelectionIndex = (int)[self.internTokenFormulaList objectAtIndex:(int)[functionInternTokens objectAtIndex:0]];
            endSelectedIndex = (int)[self.internTokenFormulaList objectAtIndex:(int)[functionInternTokens objectAtIndex:functionInternTokensLastIndex]];
            
            self.internFormulaTokenSelection = [[InternFormulaTokenSelection alloc]initWithTokenSelectionType:internTokenSelectionType
                                                                                    internTokenSelectionStart:startSelectionIndex
                                                                                      internTokenSelectionEnd:endSelectedIndex];
            
            break;
        case TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER:
            bracketsInternTokens = [InternFormulaUtils getFunctionByParameterDelimiter:self.internTokenFormulaList
                                                                                 index:self.cursorPositionInternTokenIndex];
            if(functionInternTokens == nil || [functionInternTokens count] == 0)
            {
                return;
            }
            
            functionInternTokensLastIndex = (int)[functionInternTokens count]-1;
            startSelectionIndex = (int)[self.internTokenFormulaList objectAtIndex:(int)[functionInternTokens objectAtIndex:0]];
            endSelectedIndex = (int)[self.internTokenFormulaList objectAtIndex:(int)[functionInternTokens objectAtIndex:functionInternTokensLastIndex]];
            
            self.internFormulaTokenSelection = [[InternFormulaTokenSelection alloc]initWithTokenSelectionType:internTokenSelectionType
                                                                                    internTokenSelectionStart:startSelectionIndex
                                                                                      internTokenSelectionEnd:endSelectedIndex];
            break;
        case TOKEN_TYPE_BRACKET_OPEN:
            bracketsInternTokens = [InternFormulaUtils generateTokenListByBracketOpen:self.internTokenFormulaList
                                                                                index:self.cursorPositionInternTokenIndex];
            if(bracketsInternTokens == nil || [bracketsInternTokens count] == 0)
            {
                return;
            }
            
            int bracketsInternTokensLastIndex = (int)[bracketsInternTokens count] - 1;
            startSelectionIndex = (int)[self.internTokenFormulaList objectAtIndex:(int)[bracketsInternTokens objectAtIndex:0]];
            endSelectedIndex = (int)[self.internTokenFormulaList objectAtIndex:(int)[bracketsInternTokens objectAtIndex:bracketsInternTokensLastIndex]];
           
            self.internFormulaTokenSelection = [[InternFormulaTokenSelection alloc]initWithTokenSelectionType:internTokenSelectionType
                                                                                    internTokenSelectionStart:startSelectionIndex
                                                                                      internTokenSelectionEnd:endSelectedIndex];
            break;
        case TOKEN_TYPE_BRACKET_CLOSE:
            bracketsInternTokens = [InternFormulaUtils generateTokenListByBracketClose:self.internTokenFormulaList
                                                                                 index:self.cursorPositionInternTokenIndex];
            if(bracketsInternTokens == nil || [bracketsInternTokens count] == 0)
            {
                return;
            }
            
            bracketsInternTokensLastIndex = (int)[bracketsInternTokens count] - 1;
            startSelectionIndex = (int)[self.internTokenFormulaList objectAtIndex:(int)[bracketsInternTokens objectAtIndex:0]];
            endSelectedIndex = (int)[self.internTokenFormulaList objectAtIndex:(int)[bracketsInternTokens objectAtIndex:bracketsInternTokensLastIndex]];
           
            self.internFormulaTokenSelection = [[InternFormulaTokenSelection alloc]initWithTokenSelectionType:internTokenSelectionType
                                                                                    internTokenSelectionStart:startSelectionIndex
                                                                                      internTokenSelectionEnd:endSelectedIndex];
            break;
        default:
            self.internFormulaTokenSelection = [[InternFormulaTokenSelection alloc]initWithTokenSelectionType:internTokenSelectionType
                                                                                    internTokenSelectionStart:self.cursorPositionInternTokenIndex
                                                                                      internTokenSelectionEnd:self.cursorPositionInternTokenIndex];
            break;
            
    }
    
    
}

-(InternToken *)getFirstLeftInternToken:(int)externIndex
{
    for(int searchIndex = externIndex; searchIndex >=0; searchIndex--)
    {
        if([self.externInternRepresentationMapping getInternTokenByExternIndex:searchIndex] != MAPPING_NOT_FOUND)
        {
            int internTokenIndex = [self.externInternRepresentationMapping getInternTokenByExternIndex:searchIndex];
            InternToken *internTokenToReturn = [self.internTokenFormulaList objectAtIndex:internTokenIndex];
            return internTokenToReturn;
        }
    }
    return nil;
}

-(void)updateInternCursorPosition
{
    int cursorPositionTokenIndex = [self.externInternRepresentationMapping getInternTokenByExternIndex:self.externCursorPosition];
    int leftCursorPositionTokenIndex = [self.externInternRepresentationMapping getInternTokenByExternIndex:self.externCursorPosition-1];
    int leftleftCursorPositionTokenIndex = [self.externInternRepresentationMapping getInternTokenByExternIndex:self.externCursorPosition-2];
//    int leftCursorPositionTokenIndex = cursorPositionTokenIndex-1;
//    int leftleftCursorPositionTokenIndex = cursorPositionTokenIndex-2;
    
    if (cursorPositionTokenIndex != MAPPING_NOT_FOUND) {
        
        if (leftCursorPositionTokenIndex != MAPPING_NOT_FOUND
            && cursorPositionTokenIndex == leftCursorPositionTokenIndex) {
            
            self.cursorTokenPosition = MIDDLE;
            
        } else {
            self.cursorTokenPosition = LEFT;
        }
        
    }else if (leftCursorPositionTokenIndex != MAPPING_NOT_FOUND) {
        self.cursorTokenPosition = RIGHT;
        
    } else if (leftleftCursorPositionTokenIndex != MAPPING_NOT_FOUND) {
        self.cursorTokenPosition = RIGHT;
        leftCursorPositionTokenIndex = leftleftCursorPositionTokenIndex;
    } else {
        
        self.cursorTokenPosition = 0;
        self.cursorPositionInternToken = nil;
        return;
    }
    
    switch (self.cursorTokenPosition) {
        case LEFT:
            self.cursorPositionInternToken = [self.internTokenFormulaList objectAtIndex:cursorPositionTokenIndex];
            self.cursorPositionInternTokenIndex = cursorPositionTokenIndex;
            break;
        case MIDDLE:
            self.cursorPositionInternToken = [self.internTokenFormulaList objectAtIndex:cursorPositionTokenIndex];
            self.cursorPositionInternTokenIndex = cursorPositionTokenIndex;
            break;
        case RIGHT:
            self.cursorPositionInternToken = [self.internTokenFormulaList objectAtIndex:leftCursorPositionTokenIndex];
            self.cursorPositionInternTokenIndex = leftCursorPositionTokenIndex;
            break;
    }

}

-(BOOL)isTokenSelected
{
    if(self.internFormulaTokenSelection == nil)
    {
        return NO;
    }
    return YES;
}

-(CursorTokenPropertiesAfterModification)replaceSelection:(NSMutableArray *)tokenListToInsert
{
    if([InternFormulaUtils isPeriodToken:[NSArray arrayWithArray:tokenListToInsert]])
    {
        tokenListToInsert = [[NSMutableArray alloc]init];
        [tokenListToInsert addObject:[[InternToken alloc]initWithType:TOKEN_TYPE_NUMBER AndValue:[NSString stringWithFormat:@"1"]]];
    }
    
    int internTokenSelectionStart = (int)[self.internFormulaTokenSelection getStartIndex];
    int internTokenSelectionEnd = (int)[self.internFormulaTokenSelection getEndIndex];
    
    if(internTokenSelectionStart > internTokenSelectionEnd
       || internTokenSelectionStart < 0
       || internTokenSelectionEnd < 0)
    {
        self.internFormulaTokenSelection = nil;
        return DO_NOT_MODIFY;
    }
    
    NSMutableArray *tokenListToRemove = [[NSMutableArray alloc]init];
    for (int tokensToRemove = 0; tokensToRemove <= internTokenSelectionEnd - internTokenSelectionStart; tokensToRemove++) {
        [tokenListToRemove addObject:[self.internTokenFormulaList objectAtIndex:internTokenSelectionStart+tokensToRemove]];
    }
    
    if([InternFormulaUtils isFunction:[NSArray arrayWithArray:tokenListToRemove]])
    {
        self.cursorPositionInternToken = [tokenListToRemove objectAtIndex:0];
        self.cursorPositionInternTokenIndex = internTokenSelectionStart;
        return [self replaceCursorPositionInternTokenByTokenList:tokenListToInsert];
    }else
    {
        [self replaceInternTokensInList:tokenListToInsert replaceIndexStart:internTokenSelectionStart replaceIndexEnd:internTokenSelectionEnd];
        return [self setCursorPositionAndSelectionAfterInput:internTokenSelectionStart];
    }
    
}

-(CursorTokenPropertiesAfterModification)setCursorPositionAndSelectionAfterInput:(int)insertedInternTokenIndex
{
    InternToken *insertedInternToken = [self.internTokenFormulaList objectAtIndex:insertedInternTokenIndex];
    NSArray *functionInternTokenList;
    NSArray *functionParameters;
    NSArray *functionFirstParameter;
    
    switch ([insertedInternToken getInternTokenType]) {
        case TOKEN_TYPE_FUNCTION_NAME:
            
            functionInternTokenList = [InternFormulaUtils getFunctionByName:self.internTokenFormulaList index:insertedInternTokenIndex];
            
            if([functionInternTokenList count] < 4)
            {
                self.cursorPositionInternTokenIndex = insertedInternTokenIndex + (int)[functionInternTokenList count] - 1;
                self.cursorPositionInternToken = nil;
                return AM_RIGHT;
            }
            
            functionParameters = [InternFormulaUtils getFunctionParameterInternTokensAsLists:functionInternTokenList];
            
            functionFirstParameter = [functionParameters objectAtIndex:0];
            
            self.internFormulaTokenSelection = [[InternFormulaTokenSelection alloc] initWithTokenSelectionType:USER_SELECTION
                                                                                     internTokenSelectionStart:insertedInternTokenIndex + 2
                                                                                       internTokenSelectionEnd:insertedInternTokenIndex + (int)[functionFirstParameter count] + 1];
            
            self.cursorPositionInternTokenIndex = (int)[self.internFormulaTokenSelection getEndIndex];
            self.cursorPositionInternToken = nil;
            
            return AM_RIGHT;
            
            break;
            
        default:
            
            self.cursorPositionInternTokenIndex = insertedInternTokenIndex;
            self.cursorPositionInternToken = nil;
            self.internFormulaTokenSelection = nil;
            return AM_RIGHT;
            
            break;
    }
    
    
    
    
    
    
    
    
    
    
    
    
}

-(CursorTokenPropertiesAfterModification)replaceCursorPositionInternTokenByTokenList:(NSArray *)internTokensToReplaceWith
{
    if([self.cursorPositionInternToken isNumber] && [InternFormulaUtils isNumberToken:internTokensToReplaceWith])
    {
        InternToken *numberTokenToInsert = [internTokensToReplaceWith objectAtIndex:0];
        int externNumberOffset = [self.externInternRepresentationMapping getExternTokenStartOffset:self.externCursorPosition
                                                                                withInternOffsetTo:self.cursorPositionInternTokenIndex];
        if(externNumberOffset == -1)
        {
            return DO_NOT_MODIFY;
        }
        [InternFormulaUtils insertIntoNumberToken:self.cursorPositionInternToken numberOffset:externNumberOffset number:[numberTokenToInsert getTokenStringValue]];
        
        self.externCursorPosition++;
        return DO_NOT_MODIFY;
        
    }
    
    if([self.cursorPositionInternToken isNumber] && [InternFormulaUtils isPeriodToken:internTokensToReplaceWith])
    {
        NSString *numberString = [self.cursorPositionInternToken getTokenStringValue];
        NSCharacterSet *cset = [NSCharacterSet characterSetWithCharactersInString:@"."];
        
        if([numberString rangeOfCharacterFromSet:cset].location != NSNotFound)
        {
            return DO_NOT_MODIFY;
        }
        
        int externNumberOffset = [self.externInternRepresentationMapping getExternTokenStartOffset:self.externCursorPosition
                                                                                withInternOffsetTo:self.cursorPositionInternTokenIndex];
        if(externNumberOffset == -1)
        {
            return DO_NOT_MODIFY;
        }
        
        [InternFormulaUtils insertIntoNumberToken:self.cursorPositionInternToken numberOffset:externNumberOffset number:@"."];
        self.externCursorPosition++;

        return DO_NOT_MODIFY;
    }
    
    if([self.cursorPositionInternToken isFunctionName])
    {
        NSArray *functionInternTokens = [InternFormulaUtils getFunctionByName:self.internTokenFormulaList
                                                                        index:self.cursorPositionInternTokenIndex];
        
        if(functionInternTokens == nil)
        {
            return DO_NOT_MODIFY;
        }
        
        int lastListIndex = (int)[functionInternTokens count] - 1;
        InternToken *lastFunctionToken = [functionInternTokens objectAtIndex:lastListIndex];
        int endIndexToReplace = (int)[self.internTokenFormulaList indexOfObject:lastFunctionToken];
        
        NSArray *tokensToInsert = [InternFormulaUtils replaceFunctionByTokens:functionInternTokens replaceWith:internTokensToReplaceWith];
        
        [self replaceInternTokensInList:tokensToInsert
                      replaceIndexStart:self.cursorPositionInternTokenIndex
                        replaceIndexEnd:endIndexToReplace];
        
        return [self setCursorPositionAndSelectionAfterInput:self.cursorPositionInternTokenIndex];
        
    }
    
    if([InternFormulaUtils isPeriodToken:internTokensToReplaceWith])
    {
        [self.internTokenFormulaList insertObject:[[InternToken alloc]initWithType:TOKEN_TYPE_NUMBER
                                                                          AndValue:@"0."]
                                          atIndex:self.cursorPositionInternTokenIndex +1];
        
        self.cursorPositionInternToken = nil;
        self.cursorPositionInternTokenIndex ++;
        
        return DO_NOT_MODIFY;
        
    }
    
    [self replaceInternTokensInList:internTokensToReplaceWith
                  replaceIndexStart:self.cursorPositionInternTokenIndex
                    replaceIndexEnd:self.cursorPositionInternTokenIndex];
    
    return [self setCursorPositionAndSelectionAfterInput:self.cursorPositionInternTokenIndex];
    
    
}

-(void)addSourceArray:(NSArray *)source toTarget:(NSMutableArray *)target atIndex:(int)index
{
    for(int i = (int)[source count]-1; i >= 0; i--)
    {
        [target insertObject:[source objectAtIndex:i]  atIndex:index];
    }
}

-(int)getExternCursorPosition
{
    return self.externCursorPosition;
}

-(InternFormulaParser *)getInternFormulaParser
{
    self.internTokenFormulaParser = [[InternFormulaParser alloc]initWithTokens:self.internTokenFormulaList];
    return self.internTokenFormulaParser;
}

-(TokenSelectionType)getExternSelectionType
{
    if(![self isTokenSelected])
    {
        return 0;
    }
    return [self.internFormulaTokenSelection getToketSelectionType];
}

-(void)selectWholeFormula
{
    if([self.internTokenFormulaList count] == 0)
    {
        return;
    }
    
    self.internFormulaTokenSelection = [[InternFormulaTokenSelection alloc]initWithTokenSelectionType:USER_SELECTION internTokenSelectionStart:0 internTokenSelectionEnd:[self.internTokenFormulaList count]-1];
}

-(NSString *)getExternFormulaString
{
    return self.externFormulaString;
}

-(InternFormulaTokenSelection *)getSelection
{
    return self.internFormulaTokenSelection;
}

-(void)selectParseErrorTokenAndSetCursor
{
    if(self.internTokenFormulaParser == nil || [self.internTokenFormulaList count] == 0)
    {
        return;
    }
    
    int internErrorTokenIndex = [self.internTokenFormulaParser getErrorTokenIndex];
    
    if(internErrorTokenIndex < 0)
    {
        return;
    }
    
    if(internErrorTokenIndex >= [self.internTokenFormulaList count])
    {
        internErrorTokenIndex = (int)[self.internTokenFormulaList count] - 1;
    }
    
    [self setExternCursorPositionRightTo:internErrorTokenIndex];
    self.cursorPositionInternTokenIndex = internErrorTokenIndex;
    self.cursorPositionInternToken = [self.internTokenFormulaList objectAtIndex:self.cursorPositionInternTokenIndex];
    [self selectCursorPositionInternToken:PARSER_ERROR_SELECTION];
    
    
}

-(BOOL)isThereSomethingToDelete
{
    if(self.internFormulaTokenSelection != nil)
    {
        return YES;
    }
    if(self.cursorTokenPosition == 0
       || (self.cursorTokenPosition == LEFT && [self getFirstLeftInternToken:self.externCursorPosition - 1]== nil))
    {
        return NO;
    }
    
    return YES;
}

-(int)getExternSelectionStartIndex
{
    if(self.internFormulaTokenSelection == nil)
    {
        return -1;
    }
    
    int externSelectionStartIndex = [self.externInternRepresentationMapping getExternTokenStartIndex:(int)[self.internFormulaTokenSelection getStartIndex]];
    
    if(externSelectionStartIndex == MAPPING_NOT_FOUND)
    {
        return -1;
    }
    
    return externSelectionStartIndex;
}

-(int)getExternSelectionEndIndex
{
    if(self.internFormulaTokenSelection == nil)
    {
        return -1;
    }
    
    int externSelectionEndIndex = [self.externInternRepresentationMapping getExternTokenEndIndex:(int)[self.internFormulaTokenSelection getEndIndex]];
    
    if(externSelectionEndIndex == MAPPING_NOT_FOUND)
    {
        return -1;
    }
    
    return externSelectionEndIndex;
}

-(InternFormulaState *)getInternFormulaState
{
    NSMutableArray *deepCopyOfInternTokenFormula = [[NSMutableArray alloc]init];
    
    for(InternToken *tokenToCopy in self.internTokenFormulaList)
    {
        [deepCopyOfInternTokenFormula addObject:[tokenToCopy deepCopy]];
    }
    
    InternFormulaTokenSelection *deepCopyOfInternFormulaTokenSelection = [[InternFormulaTokenSelection alloc]init];
    
    if([self isTokenSelected])
    {
        deepCopyOfInternFormulaTokenSelection = [self.internFormulaTokenSelection deepCopy];
    }
    
    return [[InternFormulaState alloc]initWithList:deepCopyOfInternTokenFormula
                                         selection:deepCopyOfInternFormulaTokenSelection
                           andExternCursorPosition:self.externCursorPosition];
}
















@end
