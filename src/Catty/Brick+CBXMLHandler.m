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

#import "Brick+CBXMLHandler.h"
#import "CBXMLValidator.h"
#import "GDataXMLNode.h"
#import "CBXMLContext.h"
#import "CBXMLOpenedNestingBricksStack.h"

// IMPORTANT: do not forgot to import every Brick+CBXMLHandler category
#import "SetLookBrick+CBXMLHandler.h"
#import "SetVariableBrick+CBXMLHandler.h"
#import "SetSizeToBrick+CBXMLHandler.h"
#import "ForeverBrick+CBXMLHandler.h"
#import "LoopEndBrick+CBXMLHandler.h"

@implementation Brick (CBXMLHandler)

+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLContext*)context
{
    [XMLError exceptionIfNode:xmlElement isNilOrNodeNameNotEquals:@"brick"];
    NSArray *attributes = [xmlElement attributes];
    [XMLError exceptionIf:[attributes count] notEquals:1
                  message:@"Parsed type-attribute of brick is invalid or empty!"];

    GDataXMLNode *attribute = [attributes firstObject];
    [XMLError exceptionIfString:attribute.name isNotEqualToString:@"type"
                        message:@"Unsupported attribute: %@", attribute.name];
    NSString *brickTypeName = [attribute stringValue];

    // Get proper brick class via reflection
    NSString *brickClassName = [[self class] brickClassNameForBrickTypeName:brickTypeName];
    Class class = NSClassFromString(brickClassName);
    
    // NSClassFromString returns nil if class was not loaded/found
    if(!class) {
        [XMLError exceptionWithMessage:@"Unsupported brick type: %@. Please implement %@+CBXMLHandler class", brickTypeName, brickTypeName];
    }

    Brick *brick = [class parseFromElement:xmlElement withContext:context];
    return brick;
}

+ (NSString*)brickClassNameForBrickTypeName:(NSString*)brickTypeName
{
    NSMutableString *brickXMLHandlerClassName = [NSMutableString stringWithString:brickTypeName];
    // TODO: handle those class names here that do not correspond to bricktypenames...
    if([brickTypeName isEqualToString:@"LoopEndlessBrick"])
        return [NSString stringWithFormat:@"LoopEndBrick"];
    return (NSString*)brickXMLHandlerClassName;
}

@end
