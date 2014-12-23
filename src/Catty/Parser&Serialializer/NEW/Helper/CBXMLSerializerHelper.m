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

#import "CBXMLSerializerHelper.h"
#import "GDataXMLElement+CustomExtensions.h"
#import "CBXMLContext.h"
#import "CBXMLPositionStack.h"

@implementation CBXMLSerializerHelper

+ (NSString*)relativeXPathToRessourceList
{
    return @"../../../../../"; // TODO: should be computed dynamically!
}

+ (NSString*)indexXPathStringForIndexNumber:(NSUInteger)indexNumber
{
    NSString *index = nil;
    if ((indexNumber != NSNotFound) && (indexNumber > 1)) {
        index = [NSString stringWithFormat:@"[%lu]", (unsigned long)(indexNumber+1)];
    } else {
        index = @"";
    }
    return index;
}

+ (NSUInteger)indexOfElement:(id)element inArray:(NSArray*)array
{
    NSUInteger index = 0;
    for (id entry in array) {
        if (entry == element) {
            return index;
        }
        ++index;
    }
    return NSNotFound;
}

+ (NSString*)relativeXPathToSound:(Sound*)sound inSoundList:(NSArray*)soundList
{
    NSString *index = [[self class] indexXPathStringForIndexNumber:[[self class] indexOfElement:sound
                                                                                        inArray:soundList]];
    return [NSString stringWithFormat:@"%@soundList/sound%@",
            [[self class] relativeXPathToRessourceList], index];
}

+ (NSString*)relativeXPathToLook:(Look*)look inLookList:(NSArray*)lookList
{
    NSString *index = [[self class] indexXPathStringForIndexNumber:[[self class] indexOfElement:look
                                                                                        inArray:lookList]];
    return [NSString stringWithFormat:@"%@lookList/look%@",
            [[self class] relativeXPathToRessourceList], index];
}

+ (NSString*)relativeXPathFromSourcePositionStack:(CBXMLPositionStack*)sourcePositionStack
                       toDestinationPositionStack:(CBXMLPositionStack*)destinationPositionStack
{
    // determine longest common path of both positions
    NSUInteger index = 0;
    NSUInteger stackLengthOfSourcePath = [sourcePositionStack.stack count];
    NSUInteger stackLengthOfDestinationPath = [destinationPositionStack.stack count];
    while ((index < stackLengthOfSourcePath) && (index < stackLengthOfDestinationPath)) {
        NSString *xmlElementNameOfSourcePath = [sourcePositionStack.stack objectAtIndex:index];
        NSString *xmlElementNameOfDestinationPath = [destinationPositionStack.stack objectAtIndex:index];
        if (! [xmlElementNameOfSourcePath isEqualToString:xmlElementNameOfDestinationPath]) {
            break;
        }
        ++index;
    }

    // path reconstruction
    NSMutableString *path = [NSMutableString new];
    // check if destination element is outside of source element => then we have to prepend "../../[../]"
    if (index < stackLengthOfSourcePath) {
        NSUInteger difference = (stackLengthOfSourcePath - index);
        for (NSUInteger times = 0; times < difference; ++times) {
            [path appendString:@"../"];
        }
    }
    NSUInteger counter = 0;
    while (index < stackLengthOfDestinationPath) {
        [path appendFormat:@"%@%@", (counter++ ? @"/" : @""),
         [destinationPositionStack.stack objectAtIndex:index]];
        ++index;
    }
    return [path copy];
}

@end
