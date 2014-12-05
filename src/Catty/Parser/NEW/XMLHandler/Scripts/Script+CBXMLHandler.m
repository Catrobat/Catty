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

#import "Script+CBXMLHandler.h"
#import "CBXMLValidator.h"
#import "GDataXMLNode.h"
#import "CBXMLContext.h"
#import "CBXMLOpenedNestingBricksStack.h"

#import "BroadcastScript.h"
#import "StartScript.h"
#import "WhenScript.h"

// IMPORTANT: do not forget to import every Brick+CBXMLHandler category
#import "SetLookBrick+CBXMLHandler.h"
#import "SetVariableBrick+CBXMLHandler.h"
#import "SetSizeToBrick+CBXMLHandler.h"
#import "ForeverBrick+CBXMLHandler.h"
#import "LoopEndBrick+CBXMLHandler.h"

@implementation Script (CBXMLHandler)

+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLContext*)context
{
    [XMLError exceptionIfNode:xmlElement isNilOrNodeNameNotEquals:@"script"];
    NSArray *attributes = [xmlElement attributes];
    [XMLError exceptionIf:[attributes count] notEquals:1
                  message:@"Parsed type-attribute of script is invalid or empty!"];

    GDataXMLNode *attribute = [attributes firstObject];
    [XMLError exceptionIfString:attribute.name isNotEqualToString:@"type"
                        message:@"Unsupported attribute: %@", attribute.name];

    NSString *scriptType = [attribute stringValue];
    Script *script = nil;
    if ([scriptType isEqualToString:@"StartScript"]) {
        script = [StartScript new];
    } else if ([scriptType isEqualToString:@"WhenScript"]) {
        script = [WhenScript new];
    } else if ([scriptType isEqualToString:@"BroadcastScript"]) {
        BroadcastScript *broadcastScript = [BroadcastScript new];
        NSArray *receivedMessageElements = [xmlElement elementsForName:@"receivedMessage"];
        [XMLError exceptionIf:[receivedMessageElements count] notEquals:1
                      message:@"Wrong number of receivedMessage elements given!"];
        GDataXMLElement *receivedMessageElement = [receivedMessageElements firstObject];
        broadcastScript.receivedMessage = [receivedMessageElement stringValue];
        script = broadcastScript;
    } else {
        [XMLError exceptionWithMessage:@"Unsupported script type: %@!", scriptType];
    }

    script.brickList = [self parseAndCreateBricks:xmlElement withContext:context];
    return script;
}

+ (NSMutableArray*)parseAndCreateBricks:(GDataXMLElement*)scriptElement withContext:(CBXMLContext*)context
{
    NSArray *brickListElements = [scriptElement elementsForName:@"brickList"];
    [XMLError exceptionIf:[brickListElements count] notEquals:1 message:@"No brickList given!"];
    NSArray *brickElements = [[brickListElements firstObject] children];
    if (! [brickElements count]) {
        // TODO: ask team if we should return nil or an empty NSMutableArray in this case!!
        return nil;
    }

    NSMutableArray *brickList = [NSMutableArray arrayWithCapacity:[brickElements count]];
    CBXMLOpenedNestingBricksStack *openedNestingBricksStack = [CBXMLOpenedNestingBricksStack new];
    context.openedNestingBricksStack = openedNestingBricksStack;
    for (GDataXMLElement *brickElement in brickElements) {
        [XMLError exceptionIfNode:brickElement isNilOrNodeNameNotEquals:@"brick"];
        NSArray *attributes = [brickElement attributes];
        [XMLError exceptionIf:[attributes count] notEquals:1
                      message:@"Parsed type-attribute of brick is invalid or empty!"];

        GDataXMLNode *attribute = [attributes firstObject];
        [XMLError exceptionIfString:attribute.name isNotEqualToString:@"type"
                            message:@"Unsupported attribute: %@", attribute.name];
        NSString *brickTypeName = [attribute stringValue];

        // get proper brick class via reflection
        NSString *brickClassName = [[self class] brickClassNameForBrickTypeName:brickTypeName];
        Class class = NSClassFromString(brickClassName);
        [XMLError exceptionIfNil:class message:@"Unsupported brick type: %@", brickTypeName];

        if (! [class conformsToProtocol:@protocol(CBParserNodeProtocol)]) {
            NSLog(@"--------------------");
            NSLog(@"brickElement:\n%@", brickElement);
            [XMLError exceptionWithMessage:@"Class for brick type %@ does not confirm to CBParserNodeProtocol", brickTypeName];
        }

        [XMLError exceptionIf:[class conformsToProtocol:@protocol(CBParserNodeProtocol)] equals:NO
                      message:@"%@ must have a category %@+CBXMLHandler that implements CBParserNodeProtocol",
                              brickClassName, brickClassName];
        Brick *brick = [class parseFromElement:brickElement withContext:context];
        [XMLError exceptionIfNil:brick message:@"Unable to parse brick..."];
        [brickList addObject:brick];
    }
    [XMLError exceptionIf:[openedNestingBricksStack isEmpty] equals:NO
                  message:@"FATAL ERROR: there are still some unclosed nesting bricks (e.g. IF, \
                            FOREVER, ...) on the stack..."];
    return brickList;
}

+ (NSString*)brickClassNameForBrickTypeName:(NSString*)brickTypeName
{
    NSMutableString *brickXMLHandlerClassName = [NSMutableString stringWithString:brickTypeName];
    // TODO: handle those class names here that do not correspond to bricktypenames...
    if ([brickTypeName isEqualToString:@"LoopEndlessBrick"])
        return [NSString stringWithFormat:@"LoopEndBrick"];
    return (NSString*)brickXMLHandlerClassName;
}

@end
