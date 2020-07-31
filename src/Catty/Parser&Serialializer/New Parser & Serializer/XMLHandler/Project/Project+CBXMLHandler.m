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

#import "Pocket_Code-Swift.h"
#import "Project+CBXMLHandler.h"
#import "GDataXMLElement+CustomExtensions.h"
#import "CBXMLValidator.h"
#import "UserDataContainer+CBXMLHandler.h"
#import "SpriteObject+CBXMLHandler.h"
#import "CBXMLParserContext.h"
#import "CBXMLSerializerContext.h"
#import "Header+CBXMLHandler.h"
#import "Script.h"
#import "BrickFormulaProtocol.h"
#import "OrderedMapTable.h"
#import "Scene+CBXMLHandler.h"

@implementation Project (CBXMLHandler)

#pragma mark - Parsing
+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLParserContext*)context
{
    [XMLError exceptionIfNode:xmlElement isNilOrNodeNameNotEquals:@"program"];
    [XMLError exceptionIfNil:context message:@"No context given!"];
    Project *project = [Project new];
    project.scene = [[Scene alloc] init];
    project.scene.project = project;
    // IMPORTANT: DO NOT CHANGE ORDER HERE!!
    project.header = [self parseAndCreateHeaderFromElement:xmlElement withContext:context];
    project.userData = [self parseAndCreateVariablesFromElement:xmlElement withContext:context];
    for (SpriteObject *object in [Scene parseAndCreateObjectsFromElement:xmlElement withContext:context]) {
        //when project will contain [scenes] then object.scene will be equal to scene where the objects belongs to
        object.scene = project.scene;
        object.scene.project = project;
        //when project will contain [scenes] then object will be added to the scene where it belongs and add scene to [scene] of project
        [project.scene addObject:object];
    }
    
    return project;
}

#pragma mark Header parsing
+ (Header*)parseAndCreateHeaderFromElement:(GDataXMLElement*)projectElement
                               withContext:(CBXMLParserContext*)context
{
    NSArray *headerNodes = [projectElement elementsForName:@"header"];
    [XMLError exceptionIf:[headerNodes count] notEquals:1 message:@"Invalid header given!"];
    return [context parseFromElement:[headerNodes objectAtIndex:0] withClass:[Header class]];
}

#pragma mark Variable parsing
+ (UserDataContainer*)parseAndCreateVariablesFromElement:(GDataXMLElement*)projectElement
                                              withContext:(CBXMLParserContext*)context
{
    return [context parseFromElement:projectElement withClass:[UserDataContainer class]];
}

+ (SpriteObject *)getSpriteObject:(NSString*)spriteName withContext:(CBXMLParserContext*)context
{
    SpriteObject *object = nil;
    for(SpriteObject *spriteObject in context.spriteObjectList) {
        if([spriteObject.name isEqualToString:spriteName]) {
            object = spriteObject;
            break;
        }
    }
    
    return object;
}



#pragma mark - Serialization
- (GDataXMLElement*)xmlElementWithContext:(CBXMLSerializerContext*)context
{
    // update context object
    context.spriteObjectList = [[NSMutableArray alloc] initWithArray:self.scene.objects];
    
    // generate xml element for program
    GDataXMLElement *xmlElement = [GDataXMLElement elementWithName:@"program" context:context];
    [xmlElement addChild:[self.header xmlElementWithContext:context] context:context];

    GDataXMLElement *objectListXmlElement = [self.scene xmlElementForObjectListWithContext:context];
    [xmlElement addChild:objectListXmlElement context:context];

    if (self.userData) {
        [xmlElement addChild:[self.userData xmlElementWithContext:context] context:context];
    }

    // add pseudo <settings/> element to produce a Catroid equivalent XML (unused at the moment)
    [xmlElement addChild:[GDataXMLElement elementWithName:@"settings" context:nil]];
    return xmlElement;
}

@end
