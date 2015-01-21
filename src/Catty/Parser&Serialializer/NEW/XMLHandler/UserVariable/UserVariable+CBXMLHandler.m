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

#import "UserVariable+CBXMLHandler.h"
#import "GDataXMLElement+CustomExtensions.h"
#import "CBXMLValidator.h"
#import "CBXMLParserHelper.h"
#import "CBXMLContext.h"
#import "CBXMLPositionStack.h"
#import "CBXMLSerializerHelper.h"
#import "VariablesContainer.h"
#import "SpriteObject.h"

@implementation UserVariable (CBXMLHandler)

#pragma mark - Parsing
+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLContext*)context
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
    if (context) {
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
        [XMLError exceptionWithMessage:@"This should never happen."];
    }

    // no context given => this method has been called from VariablesContainer+CBXMLHandler
    userVariable = [UserVariable new];
    userVariable.name = userVariableName;
    NSLog(@"Created new UserVariable: %@", userVariable.name);
    return userVariable;
}

#pragma mark - Serialization
- (GDataXMLElement*)xmlElementWithContext:(CBXMLContext*)context
{
    GDataXMLElement *xmlElement = [GDataXMLElement elementWithName:@"userVariable" stringValue:self.name
                                                           context:context]; // needed here for stack
    CBXMLPositionStack *currentPositionStack = [context.currentPositionStack mutableCopy];

    // check if userVariable has been already serialized (e.g. within a SetVariableBrick)
    CBXMLPositionStack *positionStackOfUserVariable = nil;

    // check whether objectVariable or programVariable
    SpriteObject *spriteObject = [context.variables spriteObjectForObjectVariable:self];
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
    if (! [context.variables isProgramVariable:self]) {
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

@end
