/**
 *  Copyright (C) 2010-2018 The Catrobat Team
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

#import "InternFormulaState.h"
#import "InternToken.h"
#import "InternFormula.h"

@interface InternFormulaState ()

@property (nonatomic, strong)NSMutableArray *internTokenFormulaList;

@end


@implementation InternFormulaState

- (InternFormulaState *)initWithList:(NSMutableArray *)internTokenFormulaList
                          selection:(InternFormulaTokenSelection *)tokenSelection
            andExternCursorPosition:(int)externCursorPosition
{
    self = [super init];
    if (self) {
        
        self.internTokenFormulaList = internTokenFormulaList;
        self.tokenSelection = tokenSelection;
        self.externCursorPosition = externCursorPosition;
        
    }
    return self;

}


- (BOOL)isEqual:(id)objectToCompare
{
    if([objectToCompare isKindOfClass:[InternFormulaState class]])
    {
        InternFormulaState *stateToCompare = (InternFormulaState *)objectToCompare;
        if(self.externCursorPosition != stateToCompare.externCursorPosition
           || (self.tokenSelection == nil && stateToCompare.tokenSelection != nil)
           || (self.tokenSelection != nil && stateToCompare.tokenSelection == nil)
           || [self.internTokenFormulaList count] != [stateToCompare.internTokenFormulaList count])
        {
            return NO;
        }
        
        for (int index = 0; index < [self.internTokenFormulaList count]; index++) {
            InternToken *original = [self.internTokenFormulaList objectAtIndex:index];
            InternToken *internTokenToCompare = [stateToCompare.internTokenFormulaList objectAtIndex:index];
            
            
            if([original getInternTokenType] != [internTokenToCompare getInternTokenType])
            {
                return NO;
            }
            if(!([original getTokenStringValue] == nil && [internTokenToCompare getTokenStringValue] == nil))
            {
                if(![[original getTokenStringValue] isEqualToString:[internTokenToCompare getTokenStringValue]])
                {
                    return NO;
                }
            }
        }
        
        
        return YES;
    }
    
    return [super isEqual:objectToCompare];
}

- (InternFormula *)createInternFormulaFromState
{
    NSMutableArray *deepCopyOfInternTokenFormula = [[NSMutableArray alloc]init];
    
    for(InternToken *tokenToCopy in self.internTokenFormulaList)
    {
        [deepCopyOfInternTokenFormula addObject:[tokenToCopy mutableCopyWithZone:nil]];
    }
    
    InternFormulaTokenSelection *deepCopyOfInternFormulaTokenSelection = [[InternFormulaTokenSelection alloc]init];
    
    if(self.tokenSelection != nil)
    {
        deepCopyOfInternFormulaTokenSelection = [self.tokenSelection mutableCopyWithZone:nil];
    }
    
    return [[InternFormula alloc]initWithInternTokenList:deepCopyOfInternTokenFormula
                             internFormulaTokenSelection:deepCopyOfInternFormulaTokenSelection
                                    externCursorPosition:self.externCursorPosition];


}





@end
