/**
 *  Copyright (C) 2010-2018 The Catrobat Team
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

#import "FormulaElement.h"
#import "Program.h"
#import "VariablesContainer.h"
#import "UserVariable.h"
#import "SpriteObject.h"
#import "Util.h"
#import "InternFormulaParserException.h"
#import "Pocket_Code-Swift.h"

#define ARC4RANDOM_MAX 0x100000000
#define kEmptyStringFallback @""
#define kZeroFallback 0



@implementation FormulaElement

- (id)initWithType:(NSString*)type
             value:(NSString*)value
         leftChild:(FormulaElement*)leftChild
        rightChild:(FormulaElement*)rightChild
            parent:(FormulaElement*)parent
{
    self = [super init];
    if (self) {
        [self initialize:[self elementTypeForString:type] value:value leftChild:leftChild rightChild:rightChild parent:parent];
        _idempotenceState = NOT_CHECKED;
    }
    return self;
}

- (id)initWithElementType:(ElementType)type
                    value:(NSString*)value
                leftChild:(FormulaElement*)leftChild
               rightChild:(FormulaElement*)rightChild
                   parent:(FormulaElement*)parent
{
    self = [super init];
    if (self) {
        [self initialize:type value:value leftChild:leftChild rightChild:rightChild parent:parent];
        _idempotenceState = NOT_CHECKED;
    }
    return self;
}

- (id)initWithElementType:(ElementType)type
                    value:(NSString*)value
{
    return [self initWithElementType:type value:value leftChild:nil rightChild:nil parent:nil];
}

- (id)initWithInteger:(int)value {
    return [self initWithType:@"NUMBER" value:[NSString stringWithFormat:@"%d", value] leftChild:nil rightChild:nil parent:nil];
}


- (id)initWithDouble:(double)value {
    return [self initWithType:@"NUMBER" value:[NSString stringWithFormat:@"%f", value] leftChild:nil rightChild:nil parent:nil];
}

- (id)initWithString:(NSString*)value {
    return [self initWithType:@"STRING" value:value leftChild:nil rightChild:nil parent:nil];
}

- (void)initialize:(ElementType)type
             value:(NSString*)value
         leftChild:(FormulaElement*)leftChild
        rightChild:(FormulaElement*)rightChild
            parent:(FormulaElement*)parent
{
    self.type = type;
    self.value = value;
    self.leftChild = leftChild;
    self.rightChild = rightChild;
    self.parent = parent;
    
    if (self.leftChild != nil) {
        self.leftChild.parent = self;
    }
    if (self.rightChild != nil) {
        self.rightChild.parent = self;
    }
}

- (bool) isStringDecimalNumber:(NSString *)stringValue
{
    bool result = false;
    
    NSString *decimalRegex = @"^(?:|-)(?:|0|[1-9]\\d*)(?:\\.\\d*)?$";
    NSPredicate *regexPredicate =
    [NSPredicate predicateWithFormat:@"SELF MATCHES %@", decimalRegex];
    
    if ([regexPredicate evaluateWithObject: stringValue]){
        //Matches
        result = true;
    }
    
    return result;
}

- (ElementType)elementTypeForString:(NSString*)type
{
    NSDictionary *dict = kelementTypeStringDict;
    NSNumber *elementType = dict[type];
    if (elementType) {
        return (ElementType)elementType.integerValue;
    }
    NSError(@"Unknown Type: %@", type);
    return -1;
}

- (NSString*)stringForElementType:(ElementType)type
{
    NSDictionary *dict = kstringElementTypeDict;
    NSString *elementType = dict[[NSNumber numberWithInt:type]];
    if (elementType) {
        return elementType;
    }
    NSError(@"Unknown Type: %@", type);
    return nil;
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"Formula Element: Type: %lu, Value: %@", (unsigned long)self.type, self.value];
}

- (BOOL)doubleIsInteger:(double)number
{
    if(ceil(number) == number || floor(number) == number) {
        return YES;
    }
    return NO;
}

- (FormulaElement*) getRoot
{
    FormulaElement *root = self;
    while (root.parent != nil) {
        root = root.parent;
    }
    return root;
}

- (void)replaceElement:(FormulaElement*)current
{
    self.parent = current.parent;
    self.leftChild = current.leftChild;
    self.rightChild = current.rightChild;
    self.value = current.value;
    self.type = current.type;
    
    if (self.leftChild != nil) {
        self.leftChild.parent = self;
    }
    if (self.rightChild != nil) {
        self.rightChild.parent = self;
    }
}

- (void)replaceElement:(ElementType)type value:(NSString*)value
{
    self.type = type;
    self.value = value;
}

- (void)replaceWithSubElement:(NSString*) operator rightChild:(FormulaElement*)rightChild
{
    FormulaElement *cloneThis = [[FormulaElement alloc] initWithElementType:OPERATOR value:operator leftChild:self rightChild:rightChild parent:self.parent];
    
    cloneThis.parent.rightChild = cloneThis;
}

- (NSMutableArray*)getInternTokenList
{
    NSMutableArray *internTokenList = [[NSMutableArray alloc] init];
    
    switch ((int)self.type) {
        case BRACKET:
            [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_BRACKET_OPEN]];
            if (self.rightChild != nil) {
                [internTokenList addObjectsFromArray:[self.rightChild getInternTokenList]];
            }
            [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_BRACKET_CLOSE]];
            break;
            
        case OPERATOR:
            if (self.leftChild != nil) {
                [internTokenList addObjectsFromArray:[self.leftChild getInternTokenList]];
            }
            [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:self.value]];
            if (self.rightChild != nil) {
                [internTokenList addObjectsFromArray:[self.rightChild getInternTokenList]];
            }
            break;
            
        case FUNCTION:
            [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:self.value]];
            BOOL functionHasParameters = false;
            if (self.leftChild != nil) {
                [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
                functionHasParameters = true;
                [internTokenList addObjectsFromArray:[self.leftChild getInternTokenList]];
            }
            if (self.rightChild != nil) {
                [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER]];
                [internTokenList addObjectsFromArray:[self.rightChild getInternTokenList]];
            }
            if (functionHasParameters) {
                [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE]];
            }
            break;
            
        case USER_VARIABLE:
            [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_USER_VARIABLE AndValue:self.value]];
            break;
        case USER_LIST:
            [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_USER_LIST AndValue:self.value]];
            break;
        case NUMBER:
            [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:self.value]];
            break;
        case SENSOR:{
            [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:self.value]];
            BOOL functionHasParameters = false;
            if (self.leftChild != nil) {
                [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
                functionHasParameters = true;
                [internTokenList addObjectsFromArray:[self.leftChild getInternTokenList]];
            }
            if (self.rightChild != nil) {
                [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER]];
                [internTokenList addObjectsFromArray:[self.rightChild getInternTokenList]];
            }
            if (functionHasParameters) {
                [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE]];
            } else {
                [internTokenList removeAllObjects];
               [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_SENSOR AndValue:self.value]];
            }
            }
            break;
        case STRING:
            [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_STRING AndValue:self.value]];
            break;
    }
    return internTokenList;
}

- (BOOL)isSingleNumberFormula
{
    if (self.type == OPERATOR) {
        if (self.value == MinusOperator.tag && self.leftChild == nil) {
            return [self.rightChild isSingleNumberFormula];
        }
        return false;
    } else if (self.type == NUMBER) {
        return true;
    }
    return false;
}

#pragma mark - Copy
- (id)mutableCopyWithContext:(CBMutableCopyContext*)context
{
    FormulaElement *leftChildClone = self.leftChild == nil ? nil : [self.leftChild mutableCopyWithContext:context];
    FormulaElement *rightChildClone = self.rightChild == nil ? nil : [self.rightChild mutableCopyWithContext:context];
    return [[FormulaElement alloc] initWithElementType:self.type value:self.value
                                             leftChild:leftChildClone
                                            rightChild:rightChildClone
                                                parent:nil];
}

- (BOOL)isEqualToFormulaElement:(FormulaElement*)formulaElement
{
    if(self.type != formulaElement.type)
        return NO;
    if(![Util isEqual:self.value toObject:formulaElement.value])
        return NO;
    if((self.leftChild != nil && formulaElement.leftChild == nil) || (self.leftChild == nil && formulaElement.leftChild != nil))
        return NO;
    if(self.leftChild != nil && ![self.leftChild isEqualToFormulaElement:formulaElement.leftChild])
        return NO;
    if((self.rightChild != nil && formulaElement.rightChild == nil) || (self.rightChild == nil && formulaElement.rightChild != nil))
        return NO;
    if(self.rightChild != nil && ![self.rightChild isEqualToFormulaElement:formulaElement.rightChild])
        return NO;
    if((self.parent != nil && formulaElement.parent == nil) || (self.parent == nil && formulaElement.parent != nil))
        return NO;
    // FIXME: this leads to an endless recursion bug!!!
    //    if(self.parent != nil && ![self.parent isEqualToFormulaElement:formulaElement.parent])
    //        return NO;
    if ((self.parent && (! formulaElement.parent)) || ((! self.parent) && formulaElement.parent))
        return NO;

    return YES;
}

#pragma mark - Resources
- (NSInteger)getRequiredResources
{
    NSInteger resources = kNoResources;
    if (self.leftChild != nil) {
        resources |= [self.leftChild getRequiredResources];
    }
    if (self.rightChild != nil) {
        resources |= [self.rightChild getRequiredResources];
    }
    if (self.type == SENSOR) {
        resources |= [[SensorManager class] requiredResourceWithTag: self.value];
    }
    if (self.type == FUNCTION) {
        resources |= [[FunctionManager class] requiredResourceWithTag: self.value];
    }
    return resources;
}

@end
