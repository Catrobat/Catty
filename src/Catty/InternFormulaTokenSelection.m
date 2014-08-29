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

#import "InternFormulaTokenSelection.h"

@interface InternFormulaTokenSelection ()

@property (nonatomic)NSInteger internTokenSelectionStart;
@property (nonatomic)NSInteger internTokenSelectionEnd;
@property (nonatomic)TokenSelectionType tokenSelectionType;

@end

@implementation InternFormulaTokenSelection

-(InternFormulaTokenSelection *)initWithTokenSelectionType:(TokenSelectionType)tokenSelectionType
                                 internTokenSelectionStart:(NSInteger)internTokenSelectionStart
                                   internTokenSelectionEnd:(NSInteger)internTokenSelectionEnd
{
    self = [super init];
    if(self)
    {
        self.tokenSelectionType = tokenSelectionType;
        self.internTokenSelectionStart = internTokenSelectionStart;
        self.internTokenSelectionEnd = internTokenSelectionEnd;
    }
    
    return self;
}

-(NSInteger)getStartIndex
{
    return self.internTokenSelectionStart;
}

-(NSInteger)getEndIndex
{
    return self.internTokenSelectionEnd;
}

-(TokenSelectionType)getToketSelectionType
{
    return self.tokenSelectionType;
}

-(BOOL)equals:(id)objectToCompare
{
    if([objectToCompare isKindOfClass:[InternFormulaTokenSelection class]])
    {
        InternFormulaTokenSelection *selectionToCompare = (InternFormulaTokenSelection *)objectToCompare;
        if(self.internTokenSelectionStart!= selectionToCompare.internTokenSelectionStart
           || self.internTokenSelectionEnd != selectionToCompare.internTokenSelectionEnd
           || self.tokenSelectionType != selectionToCompare.tokenSelectionType)
        {
            return NO;
        }
        return YES;
    }
    return NO;
}

-(NSInteger)hashCode
{
    NSInteger result = 31;
    NSInteger prime = 41;
    
    result = prime * result + self.internTokenSelectionStart;
    result = prime * result + self.internTokenSelectionEnd;
    
    return result;
}


-(InternFormulaTokenSelection *)deepCopy
{
    return [[InternFormulaTokenSelection alloc]initWithTokenSelectionType:self.tokenSelectionType internTokenSelectionStart:self.internTokenSelectionStart internTokenSelectionEnd:self.internTokenSelectionEnd];
}



@end
