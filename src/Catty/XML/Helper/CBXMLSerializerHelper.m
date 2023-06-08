/**
 *  Copyright (C) 2010-2023 The Catrobat Team
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
#import "CBXMLParserContext.h"
#import "CBXMLPositionStack.h"
#import "Script.h"
#import "SpriteObject.h"

@implementation CBXMLSerializerHelper

+ (NSString*)relativeXPathToRessourceList:(NSInteger)depth
{
    NSString *cd = @"../";
    NSString *path = @"";
    
    for (NSInteger i = 0; i < depth; i++) {
        path = [path stringByAppendingString: cd];
    }
    
    return path;
}

+ (NSString*)indexXPathStringForIndexNumber:(NSUInteger)indexNumber
{
    NSString *index = nil;
    if ((indexNumber != NSNotFound) && (indexNumber > 0)) {
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

+ (NSString*)relativeXPathToSound:(Sound*)sound inSoundList:(NSArray*)soundList withDepth:(NSInteger)depth
{
    NSString *index = [[self class] indexXPathStringForIndexNumber:[[self class] indexOfElement:sound
                                                                                        inArray:soundList]];
    return [NSString stringWithFormat:@"%@soundList/sound%@",
            [[self class] relativeXPathToRessourceList:depth], index];
}

+ (NSString*)relativeXPathToLook:(Look*)look inLookList:(NSArray*)lookList withDepth:(NSInteger)depth
{
    NSString *index = [[self class] indexXPathStringForIndexNumber:[[self class] indexOfElement:look
                                                                                        inArray:lookList]];
    return [NSString stringWithFormat:@"%@lookList/look%@",
            [[self class] relativeXPathToRessourceList:depth], index];
}

+ (NSString*)relativeXPathToBackground:(Look*)look forBackgroundObject:(SpriteObject*)backgroundObject withDepth:(NSInteger)depth
{
    NSString *index = [[self class] indexXPathStringForIndexNumber:[[self class] indexOfElement:look
                                                                                        inArray:backgroundObject.lookList]];
    return [NSString stringWithFormat:@"%@object/lookList/look%@",
            [[self class] relativeXPathToRessourceList:depth + 1], index];
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
            [path appendFormat:@"..%@", ((times < (difference - 1)) ? @"/" : @"")];
        }
    }
    while (index < stackLengthOfDestinationPath) {
        [path appendFormat:@"/%@", [destinationPositionStack.stack objectAtIndex:index]];
        ++index;
    }
    return [path copy];
}

+ (NSInteger)getDepthOfResource:(id<BrickProtocol>)scriptOrBrick forSpriteObject:(SpriteObject*)spriteObject
{
    if ([scriptOrBrick conformsToProtocol:@protocol(ScriptProtocol)]) {
        return 3;
    }
    
    for (Script* script in spriteObject.scriptList) {
        if ([script.brickList containsObject:(id)scriptOrBrick]) {
            return 5;
        }
    }
    
    return 0;
}

@end
