//
//  LevelParser.m
//  Catty
//
//  Created by Christof Stromberger on 19.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "LevelParser.h"
#import "GDataXMLNode.h"
#import "Project.h"
#import "Sprite.h"
#import "LookData.h"
#import "Script.h"
#import "Brick.h"
#import "SetLookBrick.h"
#import "WaitBrick.h"
#import "Sound.h"
#import "PlaceAtBrick.h"
#import "GlideToBrick.h"
#import "NextCostumeBrick.h"
#import "HideBrick.h"
#import "ShowBrick.h"
#import "SetXBrick.h"
#import "SetYBrick.h"
#import "ChangeSizeByNBrick.h"
#import "BroadcastBrick.h"
#import "BroadcastWaitBrick.h"
#import "ChangeXByBrick.h"
#import "ChangeYByBrick.h"
#import "PlaySoundBrick.h"
#import "StopAllSoundsBrick.h"
#import "ComeToFrontBrick.h"
#import "SetSizeToBrick.h"
#import "LoopBrick.h"
#import "RepeatBrick.h"
#import "EndLoopBrick.h"
#import "GoNStepsBackBrick.h"
#import "SetGhostEffectBrick.h"
#import "SpeakBrick.h"
#import "SetVolumeToBrick.h"
#import "ChangeVolumeByBrick.h"
#import "ChangeGhostEffectBrick.h"

// introspection
#import <objc/runtime.h>
#import <Foundation/NSObjCRuntime.h>

#define kCatroidXMLPrefix               @"org.catrobat.catroid.content."
#define kCatroidXMLSpriteList           @"spriteList"
#define kParserObjectTypeString         @"T@\"NSString\""
#define kParserObjectTypeInteger        @"T@\"NSNumber\""
#define kParserObjectTypeArray          @"T@\"NSArray\""
#define kParserObjectTypeMutableArray   @"T@\"NSMutableArray\""

@interface LevelParser()

@property (nonatomic, strong) NSArray *classPool;

// old
@property (nonatomic, strong, getter=theNewSprite) Sprite *newSprite;

- (Costume*)loadCostume:(GDataXMLElement*)gDataCostume;
- (Script*)loadScript:(GDataXMLElement*)gDataScript;

@end

@implementation LevelParser

@synthesize classPool = _classPool;

// old
@synthesize newSprite = _newSprite;

- (Level*)loadLevel:(NSData*)xmlData
{
    NSError *error;
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData 
                                                           options:0
                                                             error:&error];
    if (doc == nil) 
        return nil;
    
    // init class pool
    NSMutableArray *pool = [[NSMutableArray alloc] init];
    [pool addObject:@"Sprite"];
    // todo: add more...
    
    // assign class pool
    self.classPool = [NSArray arrayWithArray:pool];
    
    
    // init a new level
//    Level *level = [[Level alloc] init];
//    
//    // iterate through all elements in the xml root path
//    for (GDataXMLElement *element in doc.rootElement.children) {
//        
//        [self setValueForElement:element inClass:level];
//        
//        
//        //NSLog(@"%d, %@", element.childCount, element.name);
//    }
    
    
    
    // THEORETICAL APPROACH
    
    // arr[] = {
    // get node (first one = root node)
    // instantiate class of node name (org.catrobat.catroid.content.Project)
    // foreach child of root node
    //    if not an array:
    //       set property value based on xml
    //    else (is an array)
    //       property[] = ... -> recursive self
    // }

    //Level *temp = [[Level alloc] init];
    GDataXMLElement *rootNode = doc.rootElement;
    //NSArray *project = [self parseNode:rootNode forObject:temp];
    
    Level *temp = [self parseNode:rootNode];
    
    
    return temp;
}

- (id)parseNode:(GDataXMLElement*)node {
    // instantiate object based on node name (= class name)
    NSString *className = [[node.name componentsSeparatedByString:@"."] lastObject]; //this is just because of org.catrobat.catroid.bla...
    id object = [[NSClassFromString(className) alloc] init];
    
    if (!object) {
        NSLog(@"Implementation of <%@> NOT FOUND!", className);
        abort(); // todo: just for debug
    }
    
    for (GDataXMLElement *child in node.children) {
        // maybe check node.childCount == 0?
        
        objc_property_t property = class_getProperty([object class], [child.name UTF8String]);
        if (property) { // check if property exists
            NSString *propertyType = [NSString stringWithUTF8String:property_getTypeString(property)];
            NSLog(@"Property type: %@", propertyType);
                        
            // check if property is of type array
            if ([propertyType isEqualToString:kParserObjectTypeArray]
                || [propertyType isEqualToString:kParserObjectTypeMutableArray]) {
                // = ARRAY
                NSLog(@"%@: Array node found (count: %d)", child.name, child.childCount);

                // create new array
                NSMutableArray *arr = [[NSMutableArray alloc] init];
                for (GDataXMLElement *arrElement in child.children) {
                    [arr addObject:[self parseNode:arrElement]];
                }
                
                // now set the array property (from *arr)
                
            }
            else {
                // NOT ARRAY
                // now set the value
                NSLog(@"%@: Single node found (count: %d)", child.name, child.childCount);

                
            }
        }
        else {
            NSLog(@"property <%@> does NOT exist in our implementation of <%@>", child.name, className);
            abort(); // PROPERTY IN IMPLEMENTATION NOT FOUND!!!
            // THIS SHOULD _NOT_ HAPPEN!
        }
    }
    

    
    
    // return new object
    return object;
}


// -----------------------------------------------------------------------
//                                  NEW
// -----------------------------------------------------------------------
- (id)getSingleValue:(NSString*)node inContext:(GDataXMLDocument*)doc{
    NSArray *versionNames = [doc.rootElement elementsForName:node];
    GDataXMLElement *temp = (GDataXMLElement*)[versionNames objectAtIndex:0];
    return temp;
}

- (NSString*)getString:(id)element {
    GDataXMLElement *temp = (GDataXMLElement*)element;
    return temp.stringValue;
}

- (BOOL)checkIfPropertyExists:(NSString*)property inClass:(id)delegate {
    SEL selector = NSSelectorFromString(property);
    
    // check if this property exists
    return ([delegate respondsToSelector:selector]) ? YES : NO;
}

// temp
const char * property_getTypeString( objc_property_t property )
{
	const char * attrs = property_getAttributes( property );
	if ( attrs == NULL )
		return ( NULL );
	
	static char buffer[256];
	const char * e = strchr( attrs, ',' );
	if ( e == NULL )
		return ( NULL );
	
	int len = (int)(e - attrs);
	memcpy( buffer, attrs, len );
	buffer[len] = '\0';
	
	return ( buffer );
}


// -----------------------------------------------------------------------------
- (id)getSingleValue:(GDataXMLElement*)element ofType:(NSString*)propertyType {
    // check type
    if ([propertyType isEqualToString:kParserObjectTypeString]) {
        return element.stringValue;
    }
    else if ([propertyType isEqualToString:kParserObjectTypeInteger]) {
        NSString *temp = element.stringValue;
        return [NSNumber numberWithInt:temp.intValue];
    }
    
    return nil;
}


// -----------------------------------------------------------------------------
- (NSArray*)parseSpriteList:(GDataXMLElement*)node {
    // check children count
    if (node.childCount == 0) {
        // something went terribly wrong?!
        abort();
    }
    
    // return array
    NSMutableArray *spriteList = [[NSMutableArray alloc] init]; // array of all sprites (class: Sprite)
    
    // iterate through all children
    for (GDataXMLElement *element in node.children) {
        
        // check all classes in class pool
        for (NSString *className in self.classPool) {
            if ([element.name isEqualToString:[NSString stringWithFormat:@"%@%@", kCatroidXMLPrefix, className]]) {
                NSLog(@"Found: %@ (should proceed...)", className);
            }
        }
    }
    
    return [NSArray arrayWithArray:spriteList];
}

- (id)setValueForElement:(GDataXMLElement*)element inClass:(id)class {
    // SINGLE VALUE OR EMPTY ARRAY - no value set
    // i.e. <applicationBuildName></applicationBuildName>
    if (element.childCount == 0) {
        // check if this property exists in the level class
        if ([self checkIfPropertyExists:element.name inClass:class]) {
            [class setValue:nil forKey:element.name];
        }
        else {
            abort(); // todo
        }
    }
    // SINGLE VALUE - value set
    // i.e. <applicationName>Catroid</applicationName>
    else if (element.childCount == 1) {
        //check if this property exists in the level class
        if ([self checkIfPropertyExists:element.name inClass:class]) {
            
            // get property of level class
            objc_property_t property = class_getProperty([class class], [element.name UTF8String]);
            if (property) { //check if this property really exists ;-)
                // check type of this property
                NSString *propertyType = [NSString stringWithUTF8String:property_getTypeString(property)];
                
                id value = [self getSingleValue:element ofType:propertyType]; // get value for type
                [class setValue:value forKey:element.name]; // assume new value
                // TODO: What happens, if the setValue:forKey: method fails? i.e. when the
                // type is not correct. Currently we assign (id)s to the properties but who
                // checks if the type is the right one or not?!
            }
        }
        else {
            abort(); // todo
        }
    }
    // MULTIPLE VALUES - values are set
    // i.e.
    // <spriteList>
    //      <org.catrobat.catroid.content.Sprite>
    //          ...
    //      </org.catrobat.catroid.content.Sprite>
    //      <org.catrobat.catroid.content.Sprite>
    //          ...
    //      </org.catrobat.catroid.content.Sprite>
    //      ...
    // </spriteList>
    else if (element.childCount > 1) {
        //check if this property exists in the level class
        if ([self checkIfPropertyExists:element.name inClass:class]) {

            // get property of level class
            objc_property_t property = class_getProperty([class class], [element.name UTF8String]);
            if (property) { //check if this property really exists ;-)
                // check type of this property
                // should be an NSArray...
                NSString *propertyType = [NSString stringWithUTF8String:property_getTypeString(property)];
                
                
                if (![propertyType isEqualToString:kParserObjectTypeMutableArray]) {
                    abort(); // just for debug...
                }
                
                
#warning todo: continue here... :-)
                for (GDataXMLElement *child in element.children) {
                    NSString *className = [[child.name componentsSeparatedByString:@"."] lastObject]; //this is just because of org.catrobat.catroid.bla...
                    id object = [[NSClassFromString(className) alloc] init];
                    //NSLog(@"instantiated %x", object);
                    
                    // now, start recursively...
                    [self setValueForElement:child inClass:object];
                }
                
                
            }
            
            
            
//#warning todo...
//            // check if it's the sprite list
//            if ([element.name isEqualToString:kCatroidXMLSpriteList]) {
//                // yep, sprite list found
//                
//                //((Level*)class).spriteList = [self parseSpriteList:element];
//                for (GDataXMLElement *child in element.children) {
//                    // one child == one sprite
//                    // should be a sprite...
//                    
//                    Sprite *sprite = [[Sprite alloc] init];
//                    
//                    
//                }
//                
//            }
//            else {
//                // nope... what should I do now???
//            }
            
            //                // get property of level class
            //                objc_property_t property = class_getProperty([level class], [element.name UTF8String]);
            //                if (property) { //check if this property really exists ;-)
            //                    // check type of this property
            //                    NSString *propertyType = [NSString stringWithUTF8String:property_getTypeString(property)];
            //
            //                    id value = [self getSingleValue:element ofType:propertyType]; // get value for type
            //                    [level setValue:value forKey:element.name]; // assume new value
            //                    // TODO: What happens, if the setValue:forKey: method fails? i.e. when the
            //                    // type is not correct. Currently we assign (id)s to the properties but who
            //                    // checks if the type is the right one or not?!
            //                }
        }
        else {
            abort(); // todo
        }
    }
    
    return nil;
}

@end
