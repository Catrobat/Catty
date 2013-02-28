/**
 *  Copyright (C) 2010-2013 The Catrobat Team
 *  (<http://developer.catrobat.org/credits>)
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *
 *  An additional term exception under section 7 of the GNU Affero
 *  General Public License, version 3, is available at
 *  http://developer.catrobat.org/license_additional_term
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU Affero General Public License for more details.
 *
 *  You should have received a copy of the GNU Affero General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "ProjectParser.h"
#import "GDataXMLNode.h"
#import "Project.h"
#import <objc/runtime.h>
#import <Foundation/NSObjCRuntime.h>

#define kCatroidXMLPrefix               @"org.catrobat.catroid.content."
#define kCatroidXMLSpriteList           @"spriteList"
#define kParserObjectTypeString         @"T@\"NSString\""
#define kParserObjectTypeNumber         @"T@\"NSNumber\""
#define kParserObjectTypeArray          @"T@\"NSArray\""
#define kParserObjectTypeMutableArray   @"T@\"NSMutableArray\""
#define kParserObjectTypeDate           @"T@\"NSDate\""

// TODO: fix the user defined warnings below and remove this in final version
#define kParserObjectTypeSprite         @"T@\"Sprite\""
#define kParserObjectTypeLookData       @"T@\"LookData\""
#define kParserObjectTypeLoopEndBrick   @"T@\"LoopEndBrick\""
#define kParserObjectTypeSound          @"T@\"Sound\""


@interface ProjectParser()

- (id)parseNode:(GDataXMLElement*)node;
- (id)getSingleValue:(GDataXMLElement*)element ofType:(NSString*)propertyType;

@end

@implementation ProjectParser



// -----------------------------------------------------------------------------
// loadProject:
// This method passes the root element of the XML document into the parseNode:
// method, which in turn builds up the entire project 'tree' and returns it.
// Then this method returns this 'tree' that is stored as a Project object to
// the caller.
// [in] xmlData: The XML file as NSData*
// [out] This method returns the project 'tree' as Project object
- (Project*)loadProject:(NSData*)xmlData {
    // sanity checks
    if (!xmlData) { return nil; }
    
    NSError *error;
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData 
                                                           options:0
                                                            error:&error];
    // sanity checks
    if (error || !doc) { return nil; }

    // parse and return Project object
    return [self parseNode:doc.rootElement];
}



// -----------------------------------------------------------------------------
// parseNode:
// This method is used to parse a generic GDataXMLElement (node) and their
// children. First, the method instantiates a new object using introspection
// with the name of the current node. IMPORTANT: This means, that each XML tag
// must be present as class in this project. Otherwise the application aborts.
// This procedure is done recursively for each child of this node and so on
// [in] node: The current GDataXMLElement node of the XML file
- (id)parseNode:(GDataXMLElement*)node {
    // sanity check
    if (!node) { return nil; }
    
    // instantiate object based on node name (= class name)
    NSString *className = [[node.name componentsSeparatedByString:@"."] lastObject]; //this is just because of org.catrobat.catroid.bla...
    if (!className) {
        className = node.name;
    }
    
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



// -----------------------------------------------------------------------------
// getSingleValue:ofType:
// This method extracts a single value of a given GDataXMLElement for the
// corresponding (given) type, such as NSString, NSArray and so on.
- (id)getSingleValue:(GDataXMLElement*)element ofType:(NSString*)propertyType {
    // sanity checks
    if (!element || !propertyType) { return nil; }
    
    
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
        abort(); // TODO: just for debug purposes
    }
    
    return nil;
}



// -----------------------------------------------------------------------------
//                                   HELPER
// -----------------------------------------------------------------------------
const char* property_getTypeString(objc_property_t property) {
	const char *attrs = property_getAttributes(property);
	if (attrs == NULL) { return NULL; }
	
	static char buffer[256];
	const char *e = strchr(attrs, ',');
	if (e == NULL) { return NULL; }
	
	int len = (int)(e - attrs);
	memcpy(buffer, attrs, len);
	buffer[len] = '\0';
	
	return buffer;
}

@end
