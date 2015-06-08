/**
 *  Copyright (C) 2010-2015 The Catrobat Team
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

#import "ExternInternRepresentationMapping.h"
#import "ExternToken.h"

@interface ExternInternRepresentationMapping ()

@property (nonatomic, strong)NSMutableDictionary *externInternMapping;
@property (nonatomic, strong)NSMutableDictionary *internExternMapping;
@property (nonatomic) int externStringLength;

@end

static int MAPPING_NOT_FOUND = INT_MIN;

@implementation ExternInternRepresentationMapping

- (ExternInternRepresentationMapping *)init
{
    self = [super init];
    if(self)
    {
        self.externStringLength = 0;
    }
    
    return self;
        
}

- (NSMutableDictionary *)externInternMapping
{
    if(!_externInternMapping)
    {
        _externInternMapping = [[NSMutableDictionary alloc]init];
    }
    
    return _externInternMapping;
}

- (NSMutableDictionary *)internExternMapping
{
    if(!_internExternMapping)
    {
        _internExternMapping = [[NSMutableDictionary alloc]init];
    }
    
    return _internExternMapping;
}

- (void)addItemToList:(NSMutableDictionary *)list withKey:(int)key andValue:(id)obj
{
    [list setObject:obj forKey:[NSNumber numberWithInt:key]];
}

- (id)getItemfromList:(NSMutableDictionary *)list withKey:(int)key
{
//    NSDebug(@"get Value %@ from list!", [list objectForKey:[NSNumber numberWithInt:key]]);
    return [list objectForKey:[NSNumber numberWithInt:key]];
}

- (void)putMappingWithStart:(int)externStringStartIndex andEnd:(int)externStringEndIndex andInternListIndex:(int)internListIndex
{
    [self addItemToList:self.externInternMapping
                withKey:externStringStartIndex
               andValue:[NSNumber numberWithInt:internListIndex]];
    
    [self addItemToList:self.externInternMapping
                withKey:externStringEndIndex-1
               andValue:[NSNumber numberWithInt:internListIndex]];
    
    ExternToken *externToken = [[ExternToken alloc]initWithIndex:externStringStartIndex andEndIndex:externStringEndIndex];
    
    [self addItemToList:self.internExternMapping
                withKey:internListIndex
               andValue:externToken];
    
    if(externStringEndIndex >= self.externStringLength)
    {
        self.externStringLength = externStringEndIndex;
    }
}

- (int)getExternTokenStartIndex:(int)internIndex
{
    ExternToken *externToken = [self getItemfromList:self.internExternMapping withKey:internIndex];
    if(externToken==nil)
    {
        return MAPPING_NOT_FOUND;
    }
    
    return [externToken getStartIndex];
}

- (int)getExternTokenEndIndex:(int)internIndex
{
    ExternToken *externToken = [self getItemfromList:self.internExternMapping withKey:internIndex];
    if(externToken==nil)
    {
        return MAPPING_NOT_FOUND;
    }
    
    return [externToken getEndIndex];
}

- (int)getInternTokenByExternIndex:(int)externIndex
{
    if(externIndex<0)
    {
        return MAPPING_NOT_FOUND;
    }
    
    int searchDownInternToken  = [self searchDownIn:self.externInternMapping withBeginIndex:externIndex-1];
    int currentInternToken;
    if([self getItemfromList:self.externInternMapping withKey:externIndex]!=nil)
    {
        currentInternToken = [[self getItemfromList:self.externInternMapping withKey:externIndex]intValue];
    }else
    {
        currentInternToken = MAPPING_NOT_FOUND;
    }
    
    int searchUpInternToken = [self searchUpIn:self.externInternMapping withBeginIndex:externIndex +1];
    
    if(currentInternToken != MAPPING_NOT_FOUND)
    {
        return currentInternToken;
    }
    
    if(searchDownInternToken != MAPPING_NOT_FOUND && searchUpInternToken != MAPPING_NOT_FOUND && searchDownInternToken == searchUpInternToken)
    {
        return searchDownInternToken;
    }
    
    return MAPPING_NOT_FOUND;
    
}

- (int)getExternTokenStartOffset:(int)externIndex withInternOffsetTo:(int)internOffsetTo
{
    for(int searchIndex = externIndex; searchIndex >=0; searchIndex--)
    {
        if([self getItemfromList:self.externInternMapping withKey:searchIndex] != nil && [[self getItemfromList:self.externInternMapping withKey:searchIndex]intValue] == internOffsetTo)
        {
            int rightEdgeSelectionToken = [self getExternTokenStartOffset:searchIndex-1 withInternOffsetTo:internOffsetTo];
            if(rightEdgeSelectionToken == -1)
            {
                return externIndex - searchIndex;
            }
            return externIndex - searchIndex + rightEdgeSelectionToken + 1;
        }
    }
    return -1;
}


- (int)searchDownIn:(NSMutableDictionary *)mapping withBeginIndex:(int)index
{
    for(int searchIndex = index; searchIndex>=0; searchIndex--)
    {
        if([self getItemfromList:mapping withKey:searchIndex] != nil)
        {
            NSDebug(@"SearchDown found Value: %d", [[self getItemfromList:mapping withKey:searchIndex]intValue]);
            return [[self getItemfromList:mapping withKey:searchIndex]intValue];
        }
    }
    
    return MAPPING_NOT_FOUND;
}

- (int)searchUpIn:(NSMutableDictionary *)mapping withBeginIndex:(int)index
{
    for(int searchIndex = index; searchIndex<self.externStringLength; searchIndex++)
    {
        if([self getItemfromList:mapping withKey:searchIndex] != nil)
        {
            return [[self getItemfromList:mapping withKey:searchIndex]intValue];
        }
    }
    
    return MAPPING_NOT_FOUND;
}


@end
