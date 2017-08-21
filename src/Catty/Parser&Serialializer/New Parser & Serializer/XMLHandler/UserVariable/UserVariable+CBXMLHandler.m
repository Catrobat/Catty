/**
 *  Copyright (C) 2010-2017 The Catrobat Team
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

#import "UserVariable+CBXMLHandler.h"
#import "GDataXMLElement+CustomExtensions.h"
#import "CBXMLValidator.h"
#import "CBXMLParserHelper.h"
#import "CBXMLParserContext.h"
#import "CBXMLSerializerContext.h"
#import "CBXMLPositionStack.h"
#import "CBXMLSerializerHelper.h"
#import "SpriteObject.h"
#import "OrderedMapTable.h"
#import "NSArray+CustomExtension.h"

@implementation UserVariable (CBXMLHandler)

#pragma mark - Parsing
+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLParserContext*)context
{
    [XMLError exceptionIfNode:xmlElement isNilOrNodeNameNotEquals:@"userVariable"];
    if ([CBXMLParserHelper isReferenceElement:xmlElement]) {
        GDataXMLNode *referenceAttribute = [xmlElement attributeForName:@"reference"];
        NSString *xPath = [referenceAttribute stringValue];
        xmlElement = [xmlElement singleNodeForCatrobatXPath:xPath];
        [XMLError exceptionIfNil:xmlElement message:@"Invalid reference in UserVariable!"];
    }
    NSString *userVariableName = [xmlElement stringValue];
    
    [XMLError exceptionIfNil:userVariableName message:@"No name for user variable given"];
    UserVariable *userVariable = nil;
    
    SpriteObject *spriteObject = context.spriteObject;
    if (spriteObject) {
        [XMLError exceptionIfNil:spriteObject.name message:@"Given SpriteObject has no name."];
        NSMutableArray *objectUserVariables = [context.spriteObjectNameVariableList objectForKey:spriteObject.name];
        for (UserVariable *userVariableToCompare in objectUserVariables) {
            if ([userVariableToCompare.name isEqualToString:userVariableName]) {
                return userVariableToCompare;
            }
        }
    }
    userVariable = [CBXMLParserHelper findUserVariableInArray:context.programVariableList
                                                     withName:userVariableName];
    if (userVariable) {
        return userVariable;
    }
    
    // Init new UserVariable -> this method has been called from VariablesContainer+CBXMLHandler
    userVariable = [UserVariable new];
    userVariable.name = userVariableName;
    return userVariable;
}

#pragma mark - Serialization
- (GDataXMLElement*)xmlElementWithContext:(CBXMLSerializerContext*)context
{
    GDataXMLElement *xmlElement = [GDataXMLElement elementWithName:@"userVariable" stringValue:self.name
                                                           context:context]; // needed here for stack
    CBXMLPositionStack *currentPositionStack = [context.currentPositionStack mutableCopy];

    // check if userVariable has been already serialized (e.g. within a SetVariableBrick)
    CBXMLPositionStack *positionStackOfUserVariable = nil;

    // check whether objectVariable or programVariable
    SpriteObject *spriteObject = [self spriteObjectForUserVariable:self objectVariableList:context.objectVariableList];
    if (spriteObject) {
        // it is a object variable!
        NSMutableDictionary *alreadySerializedVariables = [context.spriteObjectNameUserVariableListPositions
                                                           objectForKey:spriteObject.name];
        if (alreadySerializedVariables) {
            positionStackOfUserVariable = [alreadySerializedVariables objectForKey:self.name];
            if (positionStackOfUserVariable) {
                // already serialized
                [context.currentPositionStack popXmlElementName]; // remove already added userVariable that contains stringValue!
                GDataXMLElement *xmlElement = [GDataXMLElement elementWithName:@"userVariable"
                                                                       context:context]; // add new one without stringValue!
                NSString *refPath = [CBXMLSerializerHelper relativeXPathFromSourcePositionStack:currentPositionStack
                                                                     toDestinationPositionStack:positionStackOfUserVariable];
                [xmlElement addAttribute:[GDataXMLElement attributeWithName:@"reference" escapedStringValue:refPath]];
                return xmlElement;
            }
        } else {
            alreadySerializedVariables = [NSMutableDictionary dictionary];
            [context.spriteObjectNameUserVariableListPositions setObject:alreadySerializedVariables
                                                                  forKey:spriteObject.name];
        }
        // save current stack position in context
        [alreadySerializedVariables setObject:currentPositionStack forKey:self.name];
        return xmlElement;
    }

    // it must be a program variable!
    if (![self isProgramVariable:self programVariableList:context.programVariableList]) {
        [XMLError exceptionWithMessage:@"UserVariable is neither objectVariable nor programVariable"];
    }

    positionStackOfUserVariable = [context.programUserVariableNamePositions objectForKey:self.name];
    if (positionStackOfUserVariable) {
        // already serialized
        [context.currentPositionStack popXmlElementName]; // remove already added userVariable that contains stringValue!
        GDataXMLElement *xmlElement = [GDataXMLElement elementWithName:@"userVariable"
                                                               context:context]; // add new one without stringValue!
        NSString *refPath = [CBXMLSerializerHelper relativeXPathFromSourcePositionStack:currentPositionStack
                                                             toDestinationPositionStack:positionStackOfUserVariable];
        [xmlElement addAttribute:[GDataXMLElement attributeWithName:@"reference" escapedStringValue:refPath]];
        return xmlElement;
    }
    // save current stack position in context
    [context.programUserVariableNamePositions setObject:currentPositionStack forKey:self.name];
    return xmlElement;
}

- (SpriteObject *)spriteObjectForUserVariable:(UserVariable *)variable objectVariableList:(OrderedMapTable *)objectVariableList {
    NSUInteger spriteObjectCount = objectVariableList.count;
    
    for (NSUInteger index = 0; index < spriteObjectCount; index++) {
        SpriteObject *spriteObject = [objectVariableList keyAtIndex:index];
        
        NSArray<UserVariable *> *variables = [objectVariableList objectForKey:spriteObject];
        BOOL containsVariable = [variables cb_hasAny:^BOOL(UserVariable *item) {
            return item == variable;
        }];
        
        if (containsVariable) {
            return spriteObject;
        }
    }
    return nil;
}

- (BOOL)isProgramVariable:(UserVariable *)variable programVariableList:(NSArray<UserVariable *> *)programVariableList {
    for (UserVariable *programVariable in programVariableList) {
        if ([programVariable.name isEqualToString:variable.name]) {
            return YES;
        }
    }
    return NO;
}

@end
