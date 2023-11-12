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
    [project.scenes removeAllObjects];
    // IMPORTANT: DO NOT CHANGE ORDER HERE!!
    project.header = [self parseAndCreateHeaderFromElement:xmlElement withContext:context];
    project.userData = [self parseAndCreateVariablesFromElement:xmlElement withContext:context];
    if ([xmlElement childWithElementName:@"scenes"]) {
        [self parseAndCreateSceneFromElement:xmlElement ofProject:project withContext:context];
    } else {
        Scene *scene = [[Scene alloc] initWithName: [Util defaultSceneNameForSceneNumber:1]];
        project.scenes[0] = scene;
        scene.project = project;
        for (SpriteObject *object in [Scene parseAndCreateObjectsFromElement:xmlElement withContext:context]) {
            //when project will contain [scenes] then object.scene will be equal to scene where the objects belongs to
            object.scene = scene;
            object.scene.project = project;
            //when project will contain [scenes] then object will be added to the scene where it belongs and add scene to [scene] of project
            [scene addObject:object];
        }
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

+ (void)parseAndCreateSceneFromElement:(GDataXMLElement*)projectElement
                                ofProject: (Project*)project withContext:(CBXMLParserContext*)context
{
    NSArray *scenesElements = [projectElement elementsForName:@"scenes"];
    [XMLError exceptionIf:[scenesElements count] notEquals:1 message:@"No scenes given!"];
    NSArray *sceneElements = [[scenesElements firstObject] children];
    [XMLError exceptionIf:[sceneElements count] equals:0
    message:@"No scene in scenes, but there must exist "\
    "at least 1 scene!!"];
    
    for (GDataXMLElement *sceneElement in sceneElements) {
        Scene* scene = [context parseFromElement:sceneElement withClass:[Scene class]];
        scene.project = project;
        [project.scenes addObject: scene];
        [context.spriteObjectList removeAllObjects];
        [context.pointedSpriteObjectList removeAllObjects];
    }
    return;
}

#pragma mark - Serialization
- (GDataXMLElement*)xmlElementWithContext:(CBXMLSerializerContext*)context
{
    
    //Scene* scene = [self.scenes lastObject];

    // update context object
    
    GDataXMLElement *xmlElement = [GDataXMLElement elementWithName:@"program" context:context];
    [xmlElement addChild:[self.header xmlElementWithContext:context] context:context];

    // add pseudo <settings/> element to produce a Catroid equivalent XML (unused at the moment)
    [xmlElement addChild:[GDataXMLElement elementWithName:@"settings" context:nil]];
    GDataXMLElement *scenes = [GDataXMLElement elementWithName:@"scenes" context:context];
    
    context.sceneList = [[NSMutableArray alloc] initWithArray:self.scenes];
    
    for(Scene* scene in self.scenes) {
        context.spriteObjectList = [[NSMutableArray alloc] initWithArray: scene.objects];
        [scenes addChild:[scene xmlElementWithContext:context] context:context];
        context.pointedSpriteObjectList = nil;
        context.spriteObjectNamePositions = nil;
    }
    
    [xmlElement addChild:scenes context:context];

    if (self.userData) {
        GDataXMLElement *projectUserDataXmlElement = [self.userData serializeForProject:context];

        GDataXMLElement *programVariableListXmlElement = [projectUserDataXmlElement childWithElementName:@"programVariableList"];
        [XMLError exceptionIfNil:programVariableListXmlElement message:@"No programVariableList element present"];
        [xmlElement addChild:programVariableListXmlElement context:nil];

        GDataXMLElement *programListOfListsXmlElement = [projectUserDataXmlElement childWithElementName:@"programListOfLists"];
        [XMLError exceptionIfNil:programListOfListsXmlElement message:@"No programVariableList element present"];
        [xmlElement addChild:programListOfListsXmlElement context:nil];
    }

    return xmlElement;
}


@end
