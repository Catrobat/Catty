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

@implementation CBXMLSerializerHelper

+ (NSString*)relativeXPathToRessourceList
{
    return @"../../../../../"; // TODO: maybe should be computed dynamically
}

+ (NSString*)relativeXPathToObjectList
{
    return @"../../../../../../"; // TODO: maybe should be computed dynamically REQUIRED (PointToBrick) MUST BE IMPLEMENTED!!!
}

+ (NSString*)indexXPathStringForIndexNumber:(NSUInteger)indexNumber
{
    NSString *index = nil;
    if ((indexNumber != NSNotFound) && (indexNumber > 1)) {
        index = [NSString stringWithFormat:@"[%lu]", (indexNumber+1)];
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
    NSString *index = [[self class] indexXPathStringForIndexNumber:[soundList indexOfObject:sound]];
    return [NSString stringWithFormat:@"%@soundList/sound%@",
            [[self class] relativeXPathToRessourceList], index];
}

+ (NSString*)relativeXPathToLook:(Look*)look inLookList:(NSArray*)lookList
{
    NSString *index = [[self class] indexXPathStringForIndexNumber:[lookList indexOfObject:look]];
    return [NSString stringWithFormat:@"%@lookList/look%@",
            [[self class] relativeXPathToRessourceList], index];
}

+ (NSString*)relativeXPathToObject:(SpriteObject*)object inObjectList:(NSArray*)objectList
{
    NSString *index = [[self class] indexXPathStringForIndexNumber:[objectList indexOfObject:object]];
    return [NSString stringWithFormat:@"%@objectList/object%@",
            [[self class] relativeXPathToObjectList], index];
}

@end
