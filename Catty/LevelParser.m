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
#import "NextLookBrick.h"
#import "HideBrick.h"
#import "ShowBrick.h"
#import "SetXBrick.h"
#import "SetYBrick.h"
#import "ChangeSizeByNBrick.h"
#import "BroadcastBrick.h"
#import "BroadcastWaitBrick.h"
#import "ChangeXByNBrick.h"
#import "ChangeYByNBrick.h"
#import "PlaySoundBrick.h"
#import "StopAllSoundsBrick.h"
#import "ComeToFrontBrick.h"
#import "SetSizeToBrick.h"
#import "ForeverBrick.h"
#import "RepeatBrick.h"
#import "LoopEndBrick.h"
#import "GoNStepsBackBrick.h"
#import "SetGhostEffectBrick.h"
#import "SpeakBrick.h"
#import "SetVolumeToBrick.h"
#import "ChangeVolumeByBrick.h"
#import "ChangeGhostEffectByNBrick.h"

// introspection
#import <objc/runtime.h>
#import <Foundation/NSObjCRuntime.h>

#define kCatroidXMLPrefix               @"org.catrobat.catroid.content."
#define kCatroidXMLSpriteList           @"spriteList"
#define kParserObjectTypeString         @"T@\"NSString\""
#define kParserObjectTypeNumber         @"T@\"NSNumber\""
#define kParserObjectTypeArray          @"T@\"NSArray\""
#define kParserObjectTypeMutableArray   @"T@\"NSMutableArray\""
#define kParserObjectTypeDate           @"T@\"NSDate\""

// just temp
#define kParserObjectTypeSprite         @"T@\"Sprite\""
#define kParserObjectTypeLookData       @"T@\"LookData\""
#define kParserObjectTypeLoopEndBrick   @"T@\"LoopEndBrick\""
#define kParserObjectTypeSound          @"T@\"Sound\""


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
    
    Project *temp = [self parseNode:rootNode];
    
    NSLog(@"%@", [temp debug]);
    
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
                [object setValue:arr forKey:child.name];
            }
            else {
                // NOT ARRAY
                // now set the value
                NSLog(@"%@: Single node found (count: %d)", child.name, child.childCount);
                id value = [self getSingleValue:child ofType:propertyType]; // get value for type
                
                // check for property type
                [object setValue:value forKey:child.name]; // assume new value
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




// temp
const char * property_getTypeString(objc_property_t property) {
	const char * attrs = property_getAttributes(property);
	if (attrs == NULL) { return NULL; }
	
	static char buffer[256];
	const char *e = strchr(attrs, ',');
	if (e == NULL) { return NULL; }
	
	int len = (int)(e - attrs);
	memcpy(buffer, attrs, len);
	buffer[len] = '\0';
	
	return buffer;
}


// -----------------------------------------------------------------------------
- (id)getSingleValue:(GDataXMLElement*)element ofType:(NSString*)propertyType {
    // check type
    if ([propertyType isEqualToString:kParserObjectTypeString]) {
        return element.stringValue;
    }
    else if ([propertyType isEqualToString:kParserObjectTypeNumber]) {
        NSString *temp = element.stringValue;
        return [NSNumber numberWithFloat:temp.floatValue];
    }
    else if ([propertyType isEqualToString:kParserObjectTypeDate]) {
        NSString *temp = element.stringValue;
#warning todo: we should parse the date here
        // but we only set nil... becaue it is easier actually... :-P
        return nil;
    }
#warning JUST FOR DEBUG PURPOSES!
    // todo: set the corresponding SPRITE!!! (and lookdata) => xstream notation
    else if ([propertyType isEqualToString:kParserObjectTypeSprite]
             || [propertyType isEqualToString:kParserObjectTypeLookData]
             || [propertyType isEqualToString:kParserObjectTypeLoopEndBrick]
             || [propertyType isEqualToString:kParserObjectTypeSound]) {
        return nil; // TODO!
    }
    else {
        abort();
    }
    
    return nil;
}

@end
