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
#import "SensorHandler.h"
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

- (id)interpretRecursiveForSprite:(SpriteObject*)sprite;
{
    id result = nil;
    
    switch (self.type) {
        case NUMBER: {
            //NSDebug(@"NUMBER");
            result = [NSNumber numberWithDouble:self.value.doubleValue];
            break;
        }
            
        case OPERATOR: {
            //NSDebug(@"OPERATOR");
            Operator operator = [Operators getOperatorByValue:self.value];
            result = [self interpretOperator:operator forSprite:sprite];
            break;
        }

        case USER_VARIABLE: {
            //NSDebug(@"User Variable");
            UserVariable *var = [sprite.program.variables getUserVariableNamed:self.value forSpriteObject:sprite];
//            result = [NSNumber numberWithDouble:[var.value doubleValue]];
            if (var.value == nil) {
                return [NSNumber numberWithInt:0];
            }
            result = var.value;
            break;
        }

        case USER_LIST: {
            //NSDebug(@"User List");
            UserVariable *list = [sprite.program.variables getUserListNamed:self.value forSpriteObject:sprite];
            //            result = [NSNumber numberWithDouble:[var.value doubleValue]];
            if (list.value == nil) {
                return [NSNumber numberWithInt:0];
            }
            NSString *allListElements = @"";
            NSMutableArray *listContent = (NSMutableArray*) list.value;
            for (int i = 0; i < [listContent count]; i++) {
                id element = [listContent objectAtIndex: i];
                if ([element isKindOfClass:[NSString class]]) {
                    allListElements = [allListElements stringByAppendingString: (NSString*) element];
                } else if ([element isKindOfClass:[NSNumber class]]) {
                    allListElements = [allListElements stringByAppendingString: [((NSNumber*) element) stringValue]];
                }
                if (i < ([listContent count] - 1)) {
                    allListElements = [allListElements stringByAppendingString: @" "];
                }
            }
            result = allListElements;
            break;
        }
            
        case FUNCTION: {
            //NSDebug(@"FUNCTION");
            id leftId = [self functionParameter:self.leftChild andSpriteObject:sprite];
            id rightId = [self functionParameter:self.rightChild andSpriteObject:sprite];
            
            result = [[FunctionManager shared] valueWithTag:self.value firstParameter:leftId secondParameter:rightId];
            break;
            break;
        }
            
        case SENSOR: {
            //NSDebug(@"SENSOR");
            result = [[CBSensorManager shared] valueWithTag:self.value spriteObject:sprite];
            break;
        }
            
        case BRACKET: {
           // NSDebug(@"BRACKET");
            result = [self.rightChild interpretRecursiveForSprite:sprite];
            break;  
        }
        case STRING:
    
            result = self.value;
            break;
            
        default:
            NSError(@"Unknown Type: %d", self.type);
            //abort();
            [InternFormulaParserException raise:@"Unknown Type" format:@"Unknown Type for Formula Element: %lu", (unsigned long)self.type];
            break;
    }
    
    return result;
}

- (id)functionParameter:(FormulaElement*)formulaElement andSpriteObject:(SpriteObject*)spriteObject
{
    if (formulaElement == nil) {
        return nil;
    }
    
    if (formulaElement.type == USER_LIST) {
        return [spriteObject.program.variables getUserListNamed:formulaElement.value forSpriteObject:spriteObject];
    }
    
    return [formulaElement interpretRecursiveForSprite:spriteObject];
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

- (NSNumber*)getNumberFromString:(NSString *) numberString
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    return [formatter numberFromString:numberString];
}

- (bool)compareNumber:(double) number withNumberOrString:(id) numberOrString{
    bool match = false;
    if ([numberOrString isKindOfClass:[NSNumber class]]) {
        match = (number == [numberOrString doubleValue]);
    } else if ([numberOrString isKindOfClass:[NSString class]]) {
        NSNumber *numberFromString = [self getNumberFromString:(NSString *) numberOrString];
        match = (number == [numberFromString doubleValue]);
    }
    return match;
}

- (int)handleLengthUserVariableParameter:(SpriteObject *)sprite
{
//    ProgramManager *programManager = [ProgramManager sharedProgramManager];
    UserVariable *userVariable = [sprite.program.variables getUserVariableNamed:self.leftChild.value forSpriteObject:sprite];
    
    id userVariableVvalue = [userVariable value];
    if([userVariableVvalue isKindOfClass:[NSString class]])
    {
        return (int)[userVariableVvalue length];
    }else if([userVariableVvalue isKindOfClass:[NSNumber class]])
    {
        if([userVariableVvalue doubleValue]-[userVariableVvalue integerValue] == 0)
        {
            return (int)[[NSString stringWithFormat:@"%ld", (long)[userVariableVvalue integerValue]] length];
        }else{
            return (int)[[NSString stringWithFormat:@"%g", [userVariableVvalue doubleValue]] length];
        }
        
    }
    
    return 0;
}

- (NSNumber*) interpretOperator:(Operator)operator forSprite:(SpriteObject*)sprite
{
    return self.leftChild ? [self interpretBinaryOperator:operator forSprite:sprite] : [self interpretUnaryOperator:operator forSprite:sprite];
}

- (NSNumber*) interpretUnaryOperator:(Operator)operator forSprite:(SpriteObject*)sprite
{
    id rightId = [self.rightChild interpretRecursiveForSprite:sprite];
    double rightDouble = [self doubleWithId:rightId];
    
    switch (operator) {
        case MINUS: {
            return [NSNumber numberWithDouble:rightDouble * -1];
        }
        case LOGICAL_NOT: {
            return [NSNumber numberWithDouble:rightDouble == 0.0 ? 1.0 : 0.0];
        }
            
        default:
            //abort();
            [InternFormulaParserException raise:@"Unknown Unary Operator" format:@"Unknown Unary Operator: %d", operator];
            break;
    }
    
    return nil;
}

- (NSNumber*) interpretBinaryOperator:(Operator)operator forSprite:(SpriteObject*)sprite
{
    id leftId = [self.leftChild interpretRecursiveForSprite:sprite];
    id rightId = [self.rightChild interpretRecursiveForSprite:sprite];
    double leftDouble = [self doubleWithId:leftId];
    double rightDouble = [self doubleWithId:rightId];
    
    switch (operator) {
        case LOGICAL_AND: {
            return [NSNumber numberWithDouble:(leftDouble * rightDouble) != 0.0 ? 1.0 : 0.0];
        }
        case LOGICAL_OR: {
            return [NSNumber numberWithDouble:leftDouble != 0.0 || rightDouble != 0.0 ? 1.0 : 0.0];
        }
        case EQUAL: {
            if(leftId == nil || rightId == nil)
            {
                return [NSNumber numberWithDouble:0.0f];
            } else if([leftId isKindOfClass:[NSString class]] && [rightId isKindOfClass:[NSString class]])
            {
                return [NSNumber numberWithDouble:([leftId isEqualToString:rightId] ? 1.0f : 0.0f)];
            }
            return [NSNumber numberWithDouble:leftDouble == rightDouble ? 1.0 : 0.0];
        }
        case NOT_EQUAL: {
            if(leftId == nil || rightId == nil)
            {
                return [NSNumber numberWithDouble:1.0f];
            } else if([leftId isKindOfClass:[NSString class]] && [rightId isKindOfClass:[NSString class]])
            {
                return [NSNumber numberWithDouble:[leftId isEqualToString:rightId] ? 0.0f : 1.0f];
            }
            return [NSNumber numberWithDouble:leftDouble == rightDouble ? 0.0 : 1.0];
        }
        case SMALLER_OR_EQUAL: {
            return [NSNumber numberWithDouble:leftDouble <= rightDouble ? 1.0 : 0.0];
        }
        case GREATER_OR_EQUAL: {
            return [NSNumber numberWithDouble:leftDouble >= rightDouble ? 1.0 : 0.0];
        }
        case SMALLER_THAN: {
            return [NSNumber numberWithDouble:leftDouble < rightDouble ? 1.0 : 0.0];
        }
        case GREATER_THAN: {
            return [NSNumber numberWithDouble:leftDouble > rightDouble ? 1.0 : 0.0];
        }
        case PLUS: {
            return [NSNumber numberWithDouble:leftDouble + rightDouble];
        }
        case MINUS: {
            return [NSNumber numberWithDouble:leftDouble - rightDouble];
        }
        case MULT: {
            return [NSNumber numberWithDouble:leftDouble * rightDouble];
        }
        case DIVIDE: {
            return [NSNumber numberWithDouble:leftDouble / rightDouble];
        }
            
        default:
            //abort();
            [InternFormulaParserException raise:@"Unknown Operator" format:@"Unknown Operator: %d", operator];
            break;
    }
    
    return nil;
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

- (BOOL)isLogicalOperator
{
    if (self.type == OPERATOR) {
        return [Operators isLogicalOperator:[Operators getOperatorByValue:self.value]];
    }
    return false;
}

- (BOOL)isSingleNumberFormula
{
    if (self.type == OPERATOR) {
        Operator operator = [Operators getOperatorByValue:self.value];
        if (operator == MINUS && self.leftChild == nil) {
            return [self.rightChild isSingleNumberFormula];
        }
        return false;
    } else if (self.type == NUMBER) {
        return true;
    }
    return false;
}

- (BOOL)containsElement:(ElementType)elementType
{
    if (self.type == elementType
        || (self.leftChild != nil && [self.leftChild containsElement:elementType])
        || (self.rightChild != nil && [self.rightChild containsElement:elementType])) {
        return true;
    }
    return false;
}

- (double)doubleWithId:(id)object
{
    if ([object isKindOfClass:[NSNumber class]] || [object isKindOfClass:[NSString class]]) {
        return [object doubleValue];
    }
    return 0.0;
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
// XXX: this leads to an endless recursion bug!!!
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
        resources |= [[CBSensorManager shared] requiredResourceWithTag: self.value];
    }
    if (self.type == FUNCTION) {
        resources |= [[FunctionManager shared] requiredResourceWithTag: self.value];
    }
    return resources;
}

@end
