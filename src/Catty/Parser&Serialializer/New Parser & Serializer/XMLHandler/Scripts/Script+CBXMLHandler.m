/**
 *  Copyright (C) 2010-2020 The Catrobat Team
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
#import "GDataXMLElement+CustomExtensions.h"
#import "CBXMLParserContext.h"
#import "CBXMLSerializerContext.h"
#import "CBXMLOpenedNestingBricksStack.h"
#import "BroadcastScript.h"
#import "StartScript.h"
#import "WhenScript.h"
#import "WhenTouchDownScript.h"
#import "Brick.h"
#import "CBXMLParserHelper.h"
#import "CBXMLSerializerHelper.h"
#import "Formula+CBXMLHandler.h"
#import "Pocket_Code-Swift.h"

@implementation Script (CBXMLHandler)

#pragma mark - Parsing
+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLParserContext*)context
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
        WhenScript *whenScript = [WhenScript new];
        NSArray *actionElements = [xmlElement elementsForName:@"action"];
        [XMLError exceptionIf:[actionElements count] notEquals:1 message:@"Wrong number of action elements given!"];
        GDataXMLElement *actionElement = [actionElements firstObject];
        [XMLError exceptionIf:[kWhenScriptDefaultAction isEqualToString:[actionElement stringValue]] equals:NO
                      message:@"Invalid action %@ for WhenScript given", [actionElement stringValue]];
        whenScript.action = [actionElement stringValue];
        script = whenScript;
    } else if ([scriptType isEqualToString:@"WhenTouchDownScript"]) {
        script = [WhenTouchDownScript new];
    } else if ([scriptType isEqualToString:@"WhenBackgroundChangesScript"]) {
        WhenBackgroundChangesScript *whenBackgroundChangesScript = [WhenBackgroundChangesScript new];
        
        GDataXMLElement *lookElement = [xmlElement childWithElementName:@"look"];
        if (lookElement == nil) {
            return whenBackgroundChangesScript;
        }
        
        SpriteObject *backgroundObject = context.spriteObjectList.firstObject;
        NSMutableArray *lookList = backgroundObject.lookList;
        
        Look *look = nil;
        if ([CBXMLParserHelper isReferenceElement:lookElement]) {
            GDataXMLNode *referenceAttribute = [lookElement attributeForName:@"reference"];
            NSString *xPath = [referenceAttribute stringValue];
            lookElement = [lookElement singleNodeForCatrobatXPath:xPath];
            [XMLError exceptionIfNil:lookElement message:@"Invalid reference in WhenBackgroundChangesBrick. No or too many looks found!"];
            GDataXMLNode *nameAttribute = [lookElement attributeForName:@"name"];
            [XMLError exceptionIfNil:nameAttribute message:@"Look element does not contain a name attribute!"];
            look = [CBXMLParserHelper findLookInArray:lookList withName:[nameAttribute stringValue]];
        } else {
            // OMG!! a look has been defined within the brick element...
            look = [context parseFromElement:xmlElement withClass:[Look class]];
            [XMLError exceptionIfNil:look message:@"Unable to parse look..."];
            [lookList addObject:look];
        }
        
        whenBackgroundChangesScript.look = look;
        script = whenBackgroundChangesScript;
    } else if ([scriptType isEqualToString:@"WhenConditionScript"]) {
        WhenConditionScript *whenConditionScript = [WhenConditionScript new];
        NSArray *formulaMap = [xmlElement elementsForName:@"formulaMap"];
        [XMLError exceptionIfNil:formulaMap message:@"No formulaMap element found..."];
        GDataXMLElement *formulaElement = [[formulaMap firstObject] childWithElementName:@"formula" containingAttribute:@"category" withValue:@"IF_CONDITION"];
        [XMLError exceptionIfNil:formulaElement message:@"No formula with category IF_CONDITION found..."];
        Formula *formula = [context parseFromElement:formulaElement withClass:[Formula class]];
        [XMLError exceptionIfNil:formula message:@"Unable to parse formula..."];
        whenConditionScript.condition = formula;
        script = whenConditionScript;
    } else if ([scriptType isEqualToString:@"BroadcastScript"]) {
        BroadcastScript *broadcastScript = [BroadcastScript new];
        NSArray *receivedMessageElements = [xmlElement elementsForName:@"receivedMessage"];
        [XMLError exceptionIf:[receivedMessageElements count] notEquals:1
                      message:@"Wrong number of receivedMessage elements given!"];
        GDataXMLElement *receivedMessageElement = [receivedMessageElements firstObject];
        broadcastScript.receivedMessage = [receivedMessageElement stringValue];
        script = broadcastScript;
    } else if ([scriptType hasSuffix:@"Script"]) {
        BroadcastScript *broadcastScript = [BroadcastScript new];
        broadcastScript.receivedMessage = [NSString stringWithFormat:@"%@ %@", kLocalizedUnsupportedScript, scriptType];
        script = broadcastScript;
        [context.unsupportedElements addObject:scriptType];
        NSWarn(@"Unsupported Script: %@", scriptType);
    } else {
        [XMLError exceptionWithMessage:@"Unsupported script type: %@!", scriptType];
    }

    script.object = context.spriteObject;
    script.brickList = [self parseAndCreateBricks:xmlElement forScript:script withContext:context];
    
    NSArray *commentedOutElements = [xmlElement elementsForName:@"commentedOut"];
    if ([commentedOutElements count] > 0) {
        GDataXMLElement *commentedOutElement = [commentedOutElements firstObject];
        script.isDisabled = [commentedOutElement.stringValue isEqualToString:@"true"] ? YES : NO;
    } else {
        script.isDisabled = NO;
    }
    
    return script;
}

+ (NSMutableArray*)parseAndCreateBricks:(GDataXMLElement*)scriptElement forScript:(Script*)script
                            withContext:(CBXMLParserContext*)context
{
    NSArray *brickListElements = [scriptElement elementsForName:@"brickList"];
    [XMLError exceptionIf:[brickListElements count] notEquals:1 message:@"No brickList given!"];
    NSArray *brickElements = [[brickListElements firstObject] children];
    if (! [brickElements count]) {
        return [NSMutableArray array];
    }

    NSMutableArray *brickList = [NSMutableArray arrayWithCapacity:[brickElements count]];
    context.openedNestingBricksStack = [CBXMLOpenedNestingBricksStack new]; // update context!
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
        GDataXMLElement *brickXmlElement = nil;
        if (! class) {
            // unknown brick type => replace by NoteBrick
            NSWarn(@"Unsupported brick type: %@ => to be replaced by a NoteBrick", brickTypeName);
            class = NSClassFromString(@"NoteBrick");
            [XMLError exceptionIfNil:class
                             message:@"Unable to retrieve NoteBrick class. This should never happen."];
            brickXmlElement = [GDataXMLElement elementWithName:@"brick"];
            [brickXmlElement addAttribute:[GDataXMLElement attributeWithName:@"type" escapedStringValue:@"NoteBrick"]];
            GDataXMLElement *formulaList = [GDataXMLElement elementWithName:@"formulaList"];
            GDataXMLElement *formulaElement = [GDataXMLElement elementWithName:@"formula"];
            [formulaElement addAttribute:[GDataXMLElement attributeWithName:@"category" escapedStringValue:@"NOTE"]];
            [formulaElement addChild:[GDataXMLElement elementWithName:@"type" stringValue:@"STRING"]];
            [formulaElement addChild:[GDataXMLElement elementWithName:@"value"
                                                          stringValue:[NSString stringWithFormat:@"%@ %@", kLocalizedUnsupportedBrick, brickTypeName]]];
            [formulaList addChild:formulaElement];
            [context.unsupportedElements addObject:brickTypeName];
            [brickXmlElement addChild:formulaList];
        } else {
            brickXmlElement = brickElement;
        }
        [XMLError exceptionIf:[class conformsToProtocol:@protocol(CBXMLNodeProtocol)] equals:NO
                      message:@"%@ must have a category %@+CBXMLHandler that implements CBXMLNodeProtocol",
                              brickClassName, brickClassName];
        
        Brick *brick = [context parseFromElement:brickXmlElement withClass:class];
        [XMLError exceptionIfNil:brick message:@"Unable to parse brick..."];
        brick.script = script;
        
        NSArray *commentedOutElements = [brickXmlElement elementsForName:@"commentedOut"];

        if ([commentedOutElements count] > 0) {
            GDataXMLElement *commentedOutElement = [commentedOutElements firstObject];
            brick.isDisabled = [commentedOutElement.stringValue isEqualToString:@"true"] ? YES : NO;
        } else {
            brick.isDisabled = NO;
        }
        
        [brickList addObject:brick];
    }
    [XMLError exceptionIf:[context.openedNestingBricksStack isEmpty] equals:NO
                  message:@"FATAL ERROR: there are still some unclosed nesting bricks (e.g. IF, \
     FOREVER, ...) on the stack..."];
    return brickList;
}

+ (NSString*)brickClassNameForBrickTypeName:(NSString*)brickTypeName
{
    NSMutableString *brickXMLHandlerClassName = [NSMutableString stringWithString:brickTypeName];
    if ([brickTypeName isEqualToString:@"LoopEndlessBrick"]) {
        return @"LoopEndBrick";
    }
    if ([brickTypeName isEqualToString:@"SetGhostEffectBrick"]) {
        return @"SetTransparencyBrick";
    }
    if ([brickTypeName isEqualToString:@"ChangeGhostEffectByNBrick"]) {
        return @"ChangeTransparencyByNBrick";
    }
    if (([brickTypeName isEqualToString:@"LedOnBrick"]) ||
       ([brickTypeName isEqualToString:@"LedOffBrick"])){
        return @"FlashBrick";
    }
    if (([brickTypeName isEqualToString:@"ClearBackgroundBrick"])){
        return @"PenClearBrick";
    }
    return (NSString*)brickXMLHandlerClassName;
}

#pragma mark - Serialization
- (GDataXMLElement*)xmlElementWithContext:(CBXMLSerializerContext*)context
{
    NSUInteger indexOfScript = [CBXMLSerializerHelper indexOfElement:self inArray:self.object.scriptList];
    GDataXMLElement *xmlElement = [GDataXMLElement elementWithName:@"script" xPathIndex:(indexOfScript+1)
                                                           context:context];
    NSString *scriptTypeName = NSStringFromClass([self class]);
    [xmlElement addAttribute:[GDataXMLElement attributeWithName:@"type" escapedStringValue:scriptTypeName]];
    [xmlElement addChild:[self xmlElementForBrickList:self.brickList withContext:context] context:context];
    
    NSString *commentedOutValue = ((Script*) [self.object.scriptList objectAtIndex:indexOfScript]).isDisabled ? @"true" : @"false";
    [xmlElement addChild:[GDataXMLElement elementWithName:@"commentedOut" stringValue: commentedOutValue context:context] context:context];
    
    if ([self isKindOfClass:[StartScript class]]) {
        //  Unused at the moment => TODO: implement this after Catroid has decided to officially use this feature!
        //GDataXMLElement *isUserScriptXmlElement = [GDataXMLElement elementWithName:@"isUserScript" stringValue:@"false" context:context];
        //[xmlElement addChild:isUserScriptXmlElement context:context];
    } else if ([self isKindOfClass:[BroadcastScript class]]) {
        BroadcastScript *broadcastScript = (BroadcastScript*)self;
        [XMLError exceptionIfNil:broadcastScript.receivedMessage
                         message:@"BroadcastScript contains invalid receivedMessage string"];
        GDataXMLElement *receivedMessageXmlElement = [GDataXMLElement elementWithName:@"receivedMessage"
                                                                          stringValue:broadcastScript.receivedMessage
                                                                              context:context];
        [xmlElement addChild:receivedMessageXmlElement context:context];
    } else if ([self isKindOfClass:[WhenBackgroundChangesScript class]]) {
        WhenBackgroundChangesScript *whenBackgroundChangesScript = (WhenBackgroundChangesScript*)self;
        SpriteObject *backgroundObject = context.spriteObjectList.firstObject;
        
        if (whenBackgroundChangesScript.look) {
            if([CBXMLSerializerHelper indexOfElement:whenBackgroundChangesScript.look inArray:backgroundObject.lookList] == NSNotFound) {
                whenBackgroundChangesScript.look = nil;
            } else {
                GDataXMLElement *referenceXMLElement = [GDataXMLElement elementWithName:@"look" context:context];
                NSInteger depthOfResource = [CBXMLSerializerHelper getDepthOfResource:whenBackgroundChangesScript forSpriteObject:context.spriteObject];
                NSString *refPath;
                if (self.object == backgroundObject) {
                    refPath = [CBXMLSerializerHelper relativeXPathToLook:whenBackgroundChangesScript.look inLookList:backgroundObject.lookList withDepth:depthOfResource];
                } else {
                    refPath = [CBXMLSerializerHelper relativeXPathToBackground:whenBackgroundChangesScript.look forBackgroundObject:backgroundObject withDepth:depthOfResource];
                }
                
                [referenceXMLElement addAttribute:[GDataXMLElement attributeWithName:@"reference" escapedStringValue:refPath]];
                [xmlElement addChild:referenceXMLElement context:context];
            }
        }
    } else if ([self isKindOfClass:[WhenScript class]]) {
        WhenScript *whenScript = (WhenScript*)self;
        [XMLError exceptionIfNil:whenScript.action message:@"WhenScript contains invalid action string"];
        [XMLError exceptionIf:[kWhenScriptDefaultAction isEqualToString:whenScript.action] equals:NO
                      message:@"WhenScript contains invalid action string %@", whenScript.action];
        GDataXMLElement *actionXmlElement = [GDataXMLElement elementWithName:@"action" stringValue:whenScript.action context:context];
        [xmlElement addChild:actionXmlElement context:context];
    } else if ([self isKindOfClass:[WhenTouchDownScript class]]) {
        // Nothing to do
    } else if ([self isKindOfClass:[WhenConditionScript class]]) {
        WhenConditionScript *whenConditionScript = (WhenConditionScript*)self;
        GDataXMLElement *formulaList = [GDataXMLElement elementWithName:@"formulaMap" context:context];
        GDataXMLElement *formula = [whenConditionScript.condition xmlElementWithContext:context];
        [formula addAttribute:[GDataXMLElement attributeWithName:@"category" escapedStringValue:@"IF_CONDITION"]];
        [formulaList addChild:formula context:context];
        [xmlElement addChild:formulaList context:context];
    }
    else {
        [XMLError exceptionWithMessage:@"Unsupported script type: %@!", NSStringFromClass([self class])];
    }
    
    // add pseudo <isUserScript> element for StartScript to produce a Catroid equivalent XML (unused at the moment)
    if ([self isKindOfClass:[StartScript class]]) {
        [xmlElement addChild:[GDataXMLElement elementWithName:@"isUserScript" stringValue:@"false" context:context] context:context];
    }
    
    return xmlElement;
}

- (GDataXMLElement*)xmlElementForBrickList:(NSArray*)brickList withContext:(CBXMLSerializerContext*)context
{
    // update context object
    context.brickList = self.brickList;

    // generate xml element for brickList
    GDataXMLElement *xmlElement = [GDataXMLElement elementWithName:@"brickList" context:context];
    CBXMLOpenedNestingBricksStack *openedNestingBricksStack = [CBXMLOpenedNestingBricksStack new];
    context.openedNestingBricksStack = openedNestingBricksStack;
    for (id brick in self.brickList) {
        [XMLError exceptionIf:[brick isKindOfClass:[Brick class]] equals:NO
                      message:@"Invalid brick instance given"];
        [XMLError exceptionIf:[brick conformsToProtocol:@protocol(CBXMLNodeProtocol)] equals:NO
                      message:@"Brick does not have a CBXMLHandler category that implements CBXMLNodeProtocol"];
        
        GDataXMLElement *xmlBrick = [((Brick<CBXMLNodeProtocol>*)brick) xmlElementWithContext:context];
        [xmlElement addChild:xmlBrick context:context];
    }
    [XMLError exceptionIf:[openedNestingBricksStack isEmpty] equals:NO
                  message:@"FATAL ERROR: there are still some unclosed nesting bricks (e.g. IF, \
     FOREVER, ...) on the stack..."];
    return xmlElement;
}

@end
