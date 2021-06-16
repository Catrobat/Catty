/**
 *  Copyright (C) 2010-2021 The Catrobat Team
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
#import "ProjectParser.h"
#import "GDataXMLNode.h"
#import "Project.h"
#import <objc/runtime.h>
#import "Formula.h"
#import "Script.h"
#import "XMLObjectReference.h"
#import "OrderedMapTable.h"
#import "SpriteObject.h"
#import "NoteBrick.h"

#define kCatroidXMLPrefix               @"org.catrobat.catroid.content."
#define kCatroidXMLSpriteList           @"spriteList"
#define kParserObjectTypeString         @"T@\"NSString\""
#define kParserObjectTypeNumber         @"T@\"NSNumber\""
#define kParserObjectTypeArray          @"T@\"NSArray\""
#define kParserObjectTypeMutableArray   @"T@\"NSMutableArray\""
#define kParserObjectTypeMutableDictionary @"T@\"NSMutableDictionary\""
#define kParserObjectTypeDate           @"T@\"NSDate\""
#define kParserObjectTypeScene          @"T@\"Scene\""
#define kParserObjectTypeSprite         @"T@\"SpriteObject\""
#define kParserObjectTypeLookData       @"T@\"Look\""
#define kParserObjectTypeLoopBeginBrick @"T@\"LoopBeginBrick\""
#define kParserObjectTypeLoopEndBrick   @"T@\"LoopEndBrick\""
#define kParserObjectTypeSound          @"T@\"Sound\""
#define kParserObjectTypeHeader         @"T@\"Header\""
#define kParserObjectTypeUserVariable   @"T@\"UserVariable\""
#define kParserObjectTypeFormula        @"T@\"Formula\""
#define kParserObjectTypeIfElseBrick    @"T@\"IfLogicElseBrick\""
#define kParserObjectTypeIfEndBrick     @"T@\"IfLogicEndBrick\""
#define kParserObjectTypeIfBeginBrick   @"T@\"IfLogicBeginBrick\""
#define kParserObjectTypeElseBrick      @"T@\"ElseBrick\""
#define kParserObjectTypeUserData      @"T@\"UserDataContainer\""
#define kPropertyWeak                   @",W"


@interface ProjectParser()

- (id)parseNode:(GDataXMLElement*)node withParent:(XMLObjectReference*)parent;

@property (nonatomic, strong) id currentActiveSprite;
@property (nonatomic, strong) Project *project;
@property (nonatomic, strong) NSMutableArray *weakPropertyRetainer;

@end

@implementation ProjectParser


@synthesize weakPropertyRetainer = _weakPropertyRetainer;


- (NSMutableArray *)weakPropertyRetainer {
    if(_weakPropertyRetainer == nil) {
        _weakPropertyRetainer = [[NSMutableArray alloc] init];
    }
    return _weakPropertyRetainer;
}



- (id)loadProject:(NSData*)xmlData {
    // sanity checks
    if (!xmlData) { return nil; }
    
    NSError *error;
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData
                                                           options:0
                                                             error:&error];

    // sanity checks
    if (error || !doc) { return nil; }

    // parse and return Project object
    Project* project = nil;
    @try {
        NSInfo(@"Loading Project...");
        project = [self parseNode:doc.rootElement withParent:nil];
        NSInfo(@"Loading done...");
    } @catch(NSException* ex) {
        NSError(@"Project could not be loaded! %@", [ex description]);
    }
    return project;
}


// -----------------------------------------------------------------------------
// parseNode:
// This method is used to parse a generic GDataXMLElement (node) and their
// children. First, the method instantiates a new object using introspection
// with the name of the current node. IMPORTANT: This means, that each XML tag
// must be present as class in this project. Otherwise the application aborts.
// This procedure is done recursively for each child of this node and so on.
// Each attribute in the XML file is then used to assign a value to a
// corresponding property in the introspected class/object.
// [in] node: The current GDataXMLElement node of the XML file
- (id)parseNode:(GDataXMLElement*)node withParent:(XMLObjectReference*)parent
{
    if (! node)
        return nil;
    
    // instantiate object based on node name (= class name)
    NSString *className = [[node.name componentsSeparatedByString:@"."] lastObject]; // this is just because of org.catrobat.catroid.bla...
    if (! className)                                                                  // Maybe we can remove this when the XML is finished?
        className = node.name;

    if ([className isEqualToString:@"program"])
        className = @"project";
    className = [self classNameForString:className];
    
    id object;
    if ([className isEqualToString:@"UserVariable"]) {
        NSString *userVariableName = [node stringValue];
        object = [[UserVariable alloc] initWithName:userVariableName];
    } else if ([className isEqualToString:@"Look"]) {
        GDataXMLElement *lookName = [node childWithElementName:@"name"];
        GDataXMLElement *lookFileName = [node childWithElementName:@"fileName"];
        
        if (lookName && lookFileName) {
            object = [[Look alloc] initWithName:[lookName stringValue] andPath:[lookFileName stringValue]];
        }
    } else if ([className isEqualToString:@"Sound"]) {
        GDataXMLElement *soundName = [node childWithElementName:@"name"];
        GDataXMLElement *soundFileName = [node childWithElementName:@"fileName"];
        
        if (soundName && soundFileName) {
            object = [[Sound alloc] initWithName:[soundName stringValue] andFileName:[soundFileName stringValue]];
        }
    } else {
        object = [[NSClassFromString(className) alloc] init];
    }
    
    if (! object) {
        if ([className hasSuffix:@"Brick"]) {
            NSWarn(@"Unsupported brick type: %@ => to be replaced by a NoteBrick", className);
            object = [NoteBrick new];
            [(NoteBrick*)object setNote:[NSString stringWithFormat:@"%@ %@", kLocalizedUnsupportedBrick, className]];
            return object;
        } else {
            [NSException raise:@"ClassNotFoundException" format:@"Implementation of <%@> NOT FOUND!", className];
        }
    }
    
    if([object isKindOfClass:[Project class]])
        self.project = object;
    
    // just an educated guess...
    if ([object isKindOfClass:[SpriteObject class]]) {
        SpriteObject* spriteObject = (SpriteObject*)object;
        spriteObject.scene.project = self.project;
        self.currentActiveSprite = spriteObject;
    }
    
    XMLObjectReference* ref = [[XMLObjectReference alloc] initWithParent:parent andObject:object];
    
    for (GDataXMLElement *child in node.children) {
        NSString *propertyName = [self propertyNameForString:child.name];
        
        // workaround for description property in Header class!!
        if ([object isKindOfClass:[Header class]] && [propertyName isEqualToString:@"description"]) {
            ((Header*)object).programDescription = child.stringValue;
            continue;
        }
        
        objc_property_t property = class_getProperty([object class], [propertyName UTF8String]);
        
        if (property) {
            NSString *propertyType = [NSString stringWithUTF8String:property_getTypeString(property)];
            
            if ([propertyType isEqualToString:kParserObjectTypeArray]) {
                [NSException raise:@"WrongPropertyException" format:@"We need to keep the references at all time, please use NSMutableArray for property: %@", propertyName];
            }
            
            else if ([propertyType isEqualToString:kParserObjectTypeMutableArray] || [propertyType isEqualToString:kParserObjectTypeScene]) {
                NSMutableArray* arr = nil;
                Scene *scene = nil;
                if ([propertyType isEqualToString:kParserObjectTypeScene]) {
                    scene = [object valueForKey:propertyName];
                    if (!scene) {
                        scene = [[Scene alloc] initWithName: [Util defaultSceneNameForSceneNumber:1]];
                        [object setValue:scene forKey:propertyName];
                    }
                    scene.project = self.project;
                    arr = [[NSMutableArray alloc] initWithCapacity:child.childCount];
                } else {
                    arr = [object valueForKey:propertyName];
                    if (!arr) {
                        arr = [[NSMutableArray alloc] initWithCapacity:child.childCount];
                        [object setValue:arr forKey:propertyName];
                    }
                }
                XMLObjectReference* arrayReference = [[XMLObjectReference alloc] initWithParent:ref andObject:arr];
                for (GDataXMLElement *arrElement in child.children) {
                    if ([self isReferenceElement:arrElement]) {
                        id object = [self parseReferenceElement:arrElement withParent:arrayReference];
                        if (object)
                            [arr addObject:object];
                        else
                            NSWarn(@"Reference Element, could not be parsed!");
                    } else {
                        [arr addObject:[self parseNode:arrElement withParent:arrayReference]];
                    }
                }
                if (scene) {
                    for(SpriteObject *object in arr) {
                        [scene addObject:object];
                    }
                }
            }
            else { // NOT ARRAY
                id value = [self getSingleValue:child ofType:propertyType withParent:ref];
                [object setValue:value forKey:propertyName];
                
                if(![propertyType isEqualToString:kParserObjectTypeSprite] && [self isWeakProperty:property] && value != nil) {
                    [self.weakPropertyRetainer addObject:value];
                }
            }
        // omit property "object" in all subclasses of Brick class
        } else if ([propertyName isEqualToString:@"object"] && [className hasSuffix:@"Brick"]) {
        } else {
            [NSException raise:@"PropertyNotFoundException" format:@"property <%@> does NOT exist in our implementation of <%@>", propertyName, className];
        }
    }
    return object;
}

// -----------------------------------------------------------------------------
// getSingleValue:ofType:
// This method extracts a single value of a given GDataXMLElement for the
// corresponding (given) type, such as NSString, NSArray and so on.
- (id)getSingleValue:(GDataXMLElement*)element ofType:(NSString*)propertyType withParent:(XMLObjectReference*)parent{
    // sanity checks
    if (!element || !propertyType) { return nil; }
    
    
    // check type
    if ([propertyType isEqualToString:kParserObjectTypeString]) {
        return element.stringValue;
    }
    else if ([propertyType isEqualToString:kParserObjectTypeNumber]) {
        return [NSNumber numberWithFloat:element.stringValue.floatValue];
        
    }
    else if ([propertyType isEqualToString:kParserObjectTypeDate]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        
        [dateFormatter setDateFormat:@"yyyy-MM-ddHH:mm:ss"];
        
        NSDate *date = [dateFormatter dateFromString: element.stringValue];
        
        return date;
    }
    else if ([propertyType isEqualToString:kParserObjectTypeSprite]) {
        
        if([self isReferenceElement:element]) {
            return [self parseReferenceElement:element withParent:parent];
        }
        else {
            id object =  [self parseNode:element withParent:parent];
            return object;
        }
        
    }
    else if ([propertyType isEqualToString:kParserObjectTypeLookData]) {
        if (self.currentActiveSprite && [self.currentActiveSprite isKindOfClass:[SpriteObject class]]) {
            
            if([self isReferenceElement:element]) {
                return [self parseReferenceElement:element withParent:parent];
            }
            else {
                return [self parseNode:element withParent:parent];
            }
            
        }
    }
    else if ([propertyType isEqualToString:kParserObjectTypeSound]) {
        if([self isReferenceElement:element]) {
            return [self parseReferenceElement:element withParent:parent];
        }
        else {
            return [self parseNode:element withParent:parent];
        }
    }
    else if ([propertyType isEqualToString:kParserObjectTypeHeader]) {
        return [self parseNode:element withParent:parent];
    }
    else if ([propertyType isEqualToString:kParserObjectTypeLoopEndBrick]) {
        if([self isReferenceElement:element]) {
            return [self parseReferenceElement:element withParent:parent];
        }
        else {
            return [self parseNode:element withParent:parent];
        }
    }
    else if([propertyType isEqualToString:kParserObjectTypeUserVariable]) {
        if([self isReferenceElement:element]) {
            return [self parseReferenceElement:element withParent:parent];
        }
        else {
            return [self parseNode:element withParent:parent];
        }
    }
    else if([propertyType isEqualToString:kParserObjectTypeFormula]) {
        return [self parseFormula:element];
    }
    else if ([propertyType isEqualToString:kParserObjectTypeIfElseBrick]) {
        if([self isReferenceElement:element]) {
            return [self parseReferenceElement:element withParent:parent];
        }
        return [self parseNode:element withParent:parent];
    }
    else if ([propertyType isEqualToString:kParserObjectTypeIfEndBrick]) {
        if([self isReferenceElement:element]) {
            return [self parseReferenceElement:element withParent:parent];
        }
        return [self parseNode:element withParent:parent];
    }
    else if ([propertyType isEqualToString:kParserObjectTypeIfBeginBrick]) {
        if([self isReferenceElement:element]) {
            return [self parseReferenceElement:element withParent:parent];
        }
        return [self parseNode:element withParent:parent];
    }
    else if ([propertyType isEqualToString:kParserObjectTypeUserData]) {
        return [self parseVariablesContainer:element withParent:parent];
    } else if([propertyType isEqualToString:kParserObjectTypeLoopBeginBrick]) {
        if([self isReferenceElement:element]) {
            return [self parseReferenceElement:element withParent:parent];
        }
        return [self parseNode:element withParent:parent];
    }
    else {
        [NSException raise:@"UnknownPropertyException" format:@"Property Type: %@ not found", propertyType];
    }
    
    return nil;
}


- (id) parseFormula:(GDataXMLElement*)element
{
    NSArray* formulaTrees = [element elementsForName:@"formulaTree"];
    if(formulaTrees) {
        GDataXMLElement* formulaTree = [formulaTrees objectAtIndex:0];
        FormulaElement* formulaElement = [self parseFormulaElement:formulaTree];
        
        Formula* formula = [[Formula alloc] init];
        formula.formulaTree = formulaElement;
        
        return formula;
        
    }
    else {
        [NSException raise:@"FormulaElementNotFoundException" format:@"Tried to parse Formula, but formula tag not found!"];
        return nil;
    }
}

- (id) parseVariablesContainer:(GDataXMLElement*)element withParent:(XMLObjectReference*)parent
{
    
    UserDataContainer* userData = nil;
    
    if (self.project) {
        
        userData = [[UserDataContainer alloc] init];
        
        NSArray* objectVariableListArray= [element elementsForName:@"objectVariableList"];
        
        XMLObjectReference* ref = [[XMLObjectReference alloc] initWithParent:parent andObject:userData];
        
        if(objectVariableListArray) {
            GDataXMLElement* objectVariableList = [objectVariableListArray objectAtIndex:0];
            OrderedMapTable * objectVariables = [self parseObjectVariableMap:objectVariableList andParent:ref];
            
            for(int index = 0; index < [objectVariables count]; index++) {
                SpriteObject* spriteObject = [objectVariables keyAtIndex:index];
                
                for(UserVariable *variable in [objectVariables objectAtIndex:index]) {
                    [spriteObject.userData addVariable:variable];
                }
            }
        }
        
        NSArray* programVariableListArray = [element elementsForName:@"programVariableList"];
        
        if(programVariableListArray) {
            GDataXMLElement* programVariableList  = [programVariableListArray objectAtIndex:0];
            for(UserVariable* variable in [self parseProgramVariableList:programVariableList andParent:ref]) {
                [userData addVariable:variable];
            }
        }
    }
    
    
    return userData;
    
}

- (id) parseReferenceElement:(GDataXMLElement*)element withParent:(XMLObjectReference*)parent
{
    NSString *refString = [element attributeForName:@"reference"].stringValue;
    if (!refString || [refString isEqualToString:@""]) {
        [NSException raise:@"ReferenceException" format:@"Tried to parse Reference Element, but no refString was found!"];
    }
    
    NSArray *components = [refString componentsSeparatedByString:@"/"];
    
    id lastComponent = [self parentObjectForReferenceElement:element andParent:parent];
    
    for(int i=0; i<[components count]; i++) {
        
        NSString* pathComponent = [components objectAtIndex:i];
        pathComponent = [self propertyNameForString:pathComponent];
        if([pathComponent isEqualToString:@".."]) {
            continue;
        }
        
        
        objc_property_t property = class_getProperty([lastComponent class], [pathComponent UTF8String]);
        if (property) {
            lastComponent = [lastComponent valueForKey:pathComponent];
        }
        
        
        else if([pathComponent hasPrefix:@"object"] || [pathComponent hasPrefix:@"look"]) {
            
            NSInteger index = [self indexForArrayObject:pathComponent];
            
            if (index+1 > [lastComponent count] || index < 0) {
                [NSException raise:@"IndexOutOfBoundsException" format:@"IndexOutOfBounds for lastComponent!"];
            }
            
            lastComponent = [lastComponent objectAtIndex:index];
        }
        else if ([pathComponent hasPrefix:@"entry"]) { // e.g. objectVariableList/entry[3]
            NSInteger index = [self indexForArrayObject:pathComponent];
            
            if (index+1 > [lastComponent count] || index < 0) {
                [NSException raise:@"IndexOutOfBoundsException" format:@"IndexOutOfBounds for lastComponent!"];
            }
            
            i++;
            pathComponent = [components objectAtIndex:i];
            
            if([pathComponent isEqualToString:@"object"]) {
                lastComponent = [lastComponent keyAtIndex:index];
            }
            else {
                lastComponent = [lastComponent objectAtIndex:index];
            }
        }
        else if ([self component:pathComponent containsString:@"Brick"] || [self component:pathComponent containsString:@"Script"]) {
            
            NSMutableArray* lastComponentList = lastComponent;
            
            NSString* className = [[self stripArrayBrackets:pathComponent] firstCharacterUppercaseString];
            NSMutableArray* list = [[NSMutableArray alloc] init];
            for (id obj in lastComponentList)
                {
                if ([obj isMemberOfClass:NSClassFromString(className)])
                    [list addObject:obj];
                }
            
            NSInteger index = [self indexForArrayObject:pathComponent];
            if (index+1 > [list count] || index < 0) {
                [NSException raise:@"IndexOutOfBoundsException" format:@"IndexOutOfBounds for lastComponent!"];
            }
            
            lastComponent = [list objectAtIndex:index];
            
        }
        else {
            [NSException raise:@"UnknownPathComponentException" format:@"UNKNOWN Path Component: %@", pathComponent];
        }
        
        
    }
    
    if(lastComponent == nil) {
        NSWarn(@"LastComponent is nil: %@", refString);
        NSWarn(@"Retain Store %@", self.weakPropertyRetainer);
    }
    
    return lastComponent;
}



- (OrderedMapTable*)parseObjectVariableMap:(GDataXMLElement*)objectVariableList andParent:(XMLObjectReference*)parent
{
    
    OrderedMapTable* objectVariableMap = [OrderedMapTable weakToStrongObjectsMapTable];
    XMLObjectReference* ref = [[XMLObjectReference alloc] initWithParent:parent andObject:objectVariableMap];
    
    for (GDataXMLElement *entry in objectVariableList.children) {
        
        
        GDataXMLElement* objectElement = [[entry elementsForName:@"object"] objectAtIndex:0];
        SpriteObject* object = nil;
        
        XMLObjectReference* entryRef = [[XMLObjectReference alloc] initWithParent:ref andObject:nil];
        
        if([self isReferenceElement:objectElement]) {
            object = [self parseReferenceElement:objectElement withParent:entryRef];
        }
        else {
            object = [self parseNode:objectElement withParent:entryRef];
        }
        
        NSArray* listArray = [entry elementsForName:@"list"];
        GDataXMLElement* listElement = [listArray objectAtIndex:0];
        
        NSMutableArray* list = [[NSMutableArray alloc] initWithCapacity:listElement.childCount];
        
        XMLObjectReference* listReference = [[XMLObjectReference alloc] initWithParent:entryRef andObject:list];
        
        for(GDataXMLElement* var in listElement.children) {
            UserVariable* userVariable = nil;
            if([self isReferenceElement:var]) {
                userVariable = [self parseReferenceElement:var withParent:listReference];
            }
            else {
                userVariable = [self parseNode:var withParent:listReference];
            }
            [list addObject:userVariable];
        }
        
        [objectVariableMap setObject:list forKey:object];
    }
    
    return objectVariableMap;
    
}

- (NSMutableArray*)parseProgramVariableList:(GDataXMLElement*)progList andParent:(XMLObjectReference*)parent
{
    NSMutableArray* programVariableList = [[NSMutableArray alloc] initWithCapacity:progList.childCount];
    XMLObjectReference* projectVariableRef = [[XMLObjectReference alloc] initWithParent:parent andObject:programVariableList];
    for (GDataXMLElement *entry in progList.children) {
        UserVariable* var = nil;
        if([self isReferenceElement:entry]) {
            var = [self parseReferenceElement:entry withParent:projectVariableRef];
        }
        else {
            var = [self parseNode:entry withParent:projectVariableRef];
        }
        [programVariableList addObject:var];
        
    }
    
    return programVariableList;
    
}

- (FormulaElement*)parseFormulaElement:(GDataXMLElement*)element
{
    NSArray* valueArray = [element elementsForName:@"value"];
    NSArray* typeArray = [element elementsForName:@"type"];
    NSArray* rightChildArray = [element elementsForName:@"rightChild"];
    NSArray* leftChildArray = [element elementsForName:@"leftChild"];
    
    NSString* type = ((GDataXMLElement*)[typeArray objectAtIndex:0]).stringValue;
    NSString* value = ((GDataXMLElement*)[valueArray objectAtIndex:0]).stringValue;
    FormulaElement* leftChild = nil;
    FormulaElement* rightChild = nil;
    
    if(leftChildArray) {
        leftChild = [self parseFormulaElement:[leftChildArray objectAtIndex:0]];
    }
    if(rightChildArray) {
        rightChild = [self parseFormulaElement:[rightChildArray objectAtIndex:0]];
    }
    
    FormulaElement* parent = nil;
    
    //Parent for now set to nil
    // If needed please parse it
    FormulaElement* formulaElement = [[FormulaElement alloc] initWithType:type
                                                                    value:value
                                                                leftChild:leftChild
                                                               rightChild:rightChild
                                                                   parent:parent];
    return formulaElement;
}

#pragma mark - Helper
const char *property_getTypeString(objc_property_t property)
{
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

- (NSString*)classNameForString:(NSString*)classString
{
    NSString* className = [classString firstCharacterUppercaseString];
    
    if ([className isEqualToString:@"Object"] || [className isEqualToString:@"PointedObject"]) {
        className = @"SpriteObject";
    }
    
    else if([className isEqualToString:@"IfElseBrick"] || [className isEqualToString:@"ElseBrick"]) {
        className = @"IfLogicElseBrick";
    }
    
    else if([className isEqualToString:@"IfBeginBrick"] || [className isEqualToString:@"BeginBrick"]) {
        className = @"IfLogicBeginBrick";
    }
    
    else if([className isEqualToString:@"IfEndBrick"]) {
        className = @"IfLogicEndBrick";
    }
    
    else if([className isEqualToString:@"LoopEndlessBrick"]) {
        className = @"LoopEndBrick";
    }
    
    else if([className isEqualToString:@"SetGhostEffectBrick"]) {
        className = @"SetTransparencyBrick";
    }
    
    else if([className isEqualToString:@"ChangeGhostEffectByNBrick"]) {
        className = @"ChangeTransparencyByNBrick";
    }
    return className;
}

- (NSString*)propertyNameForString:(NSString*)propertyString
{
    NSString* propertyName = propertyString;
    
    if ([propertyName isEqualToString:@"changeGhostEffect"]) {
        propertyName = @"changeTransparency";
    }
    
    if ([propertyName isEqualToString:@"variables"]) {
        propertyName = @"userData";
    }
    
    if ([propertyName isEqualToString:@"objectList"]) {
        propertyName = @"scene";
    }
    
    return propertyName;
}

- (BOOL)isReferenceElement:(GDataXMLElement*)element
{
    NSString *refString = [element attributeForName:@"reference"].stringValue;
    if (!refString || [refString isEqualToString:@""]) {
        return NO;
    }
    return YES;
}

- (id)parentObjectForReferenceElement:(GDataXMLElement*)element andParent:(XMLObjectReference*)parent
{
    NSString *refString = [element attributeForName:@"reference"].stringValue;
    int count = [self numberOfOccurencesOfSubstring:@".." inString:refString];
    
    XMLObjectReference* tmp = parent;
    
    for(int i=0; i<count-1; i++) {
        tmp = tmp.parent;
    }
    
    return tmp.object;
    
}

- (int)numberOfOccurencesOfSubstring:(NSString*)substring inString:(NSString*)str
{
    int cnt = 0;
    NSUInteger length = [str length];
    NSRange range = NSMakeRange(0, length);
    while(range.location != NSNotFound)
        {
        range = [str rangeOfString:substring options:0 range:range];
        if(range.location != NSNotFound)
            {
            range = NSMakeRange(range.location + range.length, length - (range.location + range.length));
            cnt++;
            }
        }
    return cnt;
}

- (BOOL)component:(NSString*)component containsString:(NSString*)stringToCheck
{
    NSString* pattern = [NSString stringWithFormat:@"[a-zA-Z]*%@(\\[[0-9]+\\])*", stringToCheck];
    NSError* error = nil;
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    NSUInteger matches = [regex numberOfMatchesInString:component options:0 range:NSMakeRange(0, [component length])];
    if (matches == 1) {
        return YES;
    }
    return NO;
}

- (NSString*)stripArrayBrackets:(NSString*)stringToStrip
{
    NSError* error = nil;
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:@"[a-zA-Z]*" options:0 error:&error];
    NSArray* matches = [regex matchesInString:stringToStrip options:0 range:NSMakeRange(0, [stringToStrip length])];
    if(matches) {
        return [stringToStrip substringWithRange:[[matches objectAtIndex:0] range]];
    }
    return stringToStrip;
}

- (NSInteger)indexForArrayObject:(NSString*)arrayObject
{
    NSInteger index = -1;
    if([arrayObject hasSuffix:@"]"]) {
        NSRange begin = [arrayObject rangeOfString:@"["];
        NSRange end = [arrayObject rangeOfString:@"]"];
        NSUInteger length = end.location - begin.location - begin.length;
        NSUInteger location = begin.location + begin.length;
        NSRange indexRange = NSMakeRange(location, length);
        NSString *indexString = [arrayObject substringWithRange:indexRange];
        index = indexString.integerValue;
        index--;
    }
    else {
        index = 0;
    }
    return index;
}

- (BOOL)isWeakProperty:(objc_property_t)property
{
    NSString *propertyType = [NSString stringWithUTF8String:property_getTypeString(property)];
    NSString *attributes = [NSString stringWithUTF8String:property_getAttributes(property)];
    attributes = [attributes stringByReplacingOccurrencesOfString:propertyType withString:@""];
    return [attributes hasPrefix:kPropertyWeak];
}

@end
