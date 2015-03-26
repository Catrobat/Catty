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

#import "FormulaElement.h"
#import "ProgramManager.h"
#import "Program.h"
#import "VariablesContainer.h"
#import "UserVariable.h"
#import "SensorHandler.h"
#import "SensorManager.h"
#import "SpriteObject.h"
#import "Util.h"
#import "Operators.h"
#import "Functions.h"
#import "InternToken.h"
#import "Operators.h"
#import "InternFormulaParserException.h"

#define ARC4RANDOM_MAX 0x100000000

@implementation FormulaElement

- (id)initWithType:(NSString*)type
             value:(NSString*)value
         leftChild:(FormulaElement*)leftChild
        rightChild:(FormulaElement*)rightChild
            parent:(FormulaElement*)parent
{
    self = [super init];
    if(self) {
        [self initialize:[self elementTypeForString:type] value:value leftChild:leftChild rightChild:rightChild parent:parent];
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
    if(self) {
        [self initialize:type value:value leftChild:leftChild rightChild:rightChild parent:parent];
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
            
        case FUNCTION: {
            //NSDebug(@"FUNCTION");
            Function function = [Functions getFunctionByValue:self.value];
            result = [self interpretFunction:function forSprite:sprite];
            break;
        }
            
        case USER_VARIABLE: {
            //NSDebug(@"User Variable");
            Program* program = ProgramManager.sharedProgramManager.program;
            UserVariable* var = [program.variables getUserVariableNamed:self.value forSpriteObject:sprite];
            result = [NSNumber numberWithDouble:[var.value doubleValue]];
            break;
        }
            
        case SENSOR: {
            //NSDebug(@"SENSOR");
            Sensor sensor = [SensorManager sensorForString:self.value];
            if([SensorManager isObjectSensor:sensor]) {
                result = [NSNumber numberWithDouble:[self interpretLookSensor:sensor forSprite:sprite]];
            } else {
                result = [NSNumber numberWithDouble:[[SensorHandler sharedSensorHandler] valueForSensor:sensor]];
            }
            break;
        }
            
        case BRACKET: {
           // NSDebug(@"BRACKET");
            result = [self.rightChild interpretRecursiveForSprite:sprite];
            break;
        }
        case STRING:
            		
            result = [self interpretString:self.value];
            break;
            
        default:
            NSError(@"Unknown Type: %d", self.type);
            //abort();
            [InternFormulaParserException raise:@"Unknown Type" format:@"Unknown Type for Formula Element: %d", self.type];
            break;
    }
    
    return result;
    
}

- (id)interpretString:(NSString *)value
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    
    if(self.parent == nil && self.type != USER_VARIABLE)
    {
        NSNumber *anotherValue = [formatter numberFromString:value];
        
        if(anotherValue == nil)
        {
            return value;
        }else{
            return anotherValue;
        }
    }
    
    if(self.parent != nil)
    {
        BOOL isAParentFunction = [Functions getFunctionByValue:self.parent.value] != NO_FUNCTION;
        if(isAParentFunction && self.parent.type == STRING)
        {
               if([Functions getFunctionByValue:self.parent.value] == LETTER && self.parent.leftChild == self)
               {
                   NSNumber *anotherValue = [formatter numberFromString:value];
                   
                   if(anotherValue == nil)
                   {
                       return [NSNumber numberWithDouble:0.0f];
                   }else{
                       return anotherValue;
                   }
               }
            return value;
        }
        
        if(isAParentFunction)
        {
            NSNumber *anotherValue = [formatter numberFromString:value];
            
            if(anotherValue == nil)
            {
                return value;
            }else{
                return anotherValue;
            }
        }
        
        BOOL isParentAnOperator = [Operators getOperatorByValue:self.parent.value] != NO_OPERATOR;
        
        if(isParentAnOperator && ([Operators getOperatorByValue:self.parent.value] == EQUAL ||
                                  [Operators getOperatorByValue:self.parent.value] == NOT_EQUAL))
        {
            return value;
        }
    }
    
    if([value length] == 0)
    {
        return [NSNumber numberWithDouble:0.0f];
    }
    
    NSNumber *anotherValue = [formatter numberFromString:value];
    
    if(anotherValue == nil)
    {
        return [NSNumber numberWithDouble:0.0f];
    }else{
        return anotherValue;
    }
    
}

-(id) interpretFunction:(Function)function forSprite:(SpriteObject*)sprite
{
    
    double left = 0.0f;
    double right = 0.0f;
    if(self.leftChild) {
        id leftId =[self.leftChild interpretRecursiveForSprite:sprite];
        if([leftId isKindOfClass:[NSNumber class]])
        {
            left = [leftId doubleValue];
        }
    }
    if (self.rightChild) {
        id rightId = [self.rightChild interpretRecursiveForSprite:sprite];
        if([rightId isKindOfClass:[NSNumber class]])
        {
            right = [rightId doubleValue];
        }
    }
    
    id result;
    
    switch (function) {
        case SIN: {
            result = [NSNumber numberWithDouble:sin([Util degreeToRadians:left])];
            break;
        }
        case COS: {
            result = [NSNumber numberWithDouble:cos([Util degreeToRadians:left])];
            break;
        }
        case TAN: {
            result = [NSNumber numberWithDouble:tan([Util degreeToRadians:left])];
            break;
        }
        case LN: {
            result = [NSNumber numberWithDouble:log(left)];
            break;
        }
        case LOG: {
            result = [NSNumber numberWithDouble:log10(left)];
            break;
        }
        case SQRT: {
            result =  [NSNumber numberWithDouble:sqrt(left)];
            break;
        }
        case RAND: {
            
//            double right = [self.rightChild interpretRecursiveForSprite:sprite];
            double minimum;
            double maximum;
            
            if (right > left) {
                minimum = left;
                maximum = right;
            } else {
                minimum = right;
                maximum = left;
            }
            
//            double random = (double)rand() / RAND_MAX;
//            result = minimum + random * (maximum - minimum);
            double random = (double)arc4random() / ARC4RANDOM_MAX;
            result = [NSNumber numberWithDouble:minimum + random*(maximum-minimum)];

            if ([self doubleIsInteger:minimum] && [self doubleIsInteger:maximum]
                && !(self.rightChild.type == NUMBER && [self.rightChild.value containsString:@"."])
                && !(self.rightChild.type == NUMBER && [self.rightChild.value containsString:@"."])) {
                
                result = [NSNumber numberWithDouble:(int)round([result doubleValue])];
            }

            break;
        }
        case ROUND: {
            result = [NSNumber numberWithDouble:round(left)];
            break;
        }
        case ABS: {
            result = [NSNumber numberWithDouble:fabs(left)];
            break;
        }
        case PI_F: {
            result = [NSNumber numberWithDouble:M_PI];
            break;
        }
        case MOD: {
            // IEEERemainder: http://msdn.microsoft.com/de-AT/library/system.math.ieeeremainder.aspx
//                            double dividend = left;
//                            double divisor = right;
//                            result =  dividend - (divisor * round(dividend / divisor));
            while (left < 0) {
                left += right;
            }
            result = [NSNumber numberWithDouble:fmod(left, right)];
            break;
        }
        case ARCSIN: {
            double radians = asin(left);
            result = [NSNumber numberWithDouble:[Util radiansToDegree:radians]];
            break;
        }
        case ARCCOS: {
            double radians = acos(left);
            result = [NSNumber numberWithDouble:[Util radiansToDegree:radians]];
            break;
        }
        case ARCTAN: {
            double radians = atan(left);
            result = [NSNumber numberWithDouble:[Util radiansToDegree:radians]];
            break;
        }
        case POW: {
            result = [NSNumber numberWithDouble:pow(left, right)];
            break;
        }
        case MAX: {
            result = [NSNumber numberWithDouble:MAX(left, right)];
            break;
        }
        case MIN:{
            result = [NSNumber numberWithDouble:MIN(left, right)];
            break;
  
        }
        case TRUE_F: {
            result = [NSNumber numberWithDouble:1.0];
            break;
        }
        case FALSE_F: {
            result = [NSNumber numberWithDouble:0.0];
            break;
        }
        case EXP: {
            result = [NSNumber numberWithDouble:exp(left)];
            break;
        }
        case LENGTH: {
            //TODO: implement
            break;
        }
        case LETTER: {
            
            //TODO: implement
            break;
        }
        case JOIN: {
            //TODO: implement
            break;
        }
        default:
            //abort();
            [InternFormulaParserException raise:@"Unknown Function" format:@"Unknown Function: %d", function];
            break;
    }
    return result;
    
}

- (id) interpretOperator:(Operator)operator forSprite:(SpriteObject*)sprite
{

    id result = nil;
    
    if(self.leftChild) { // binary operator
        
        double left = 0.0f;
        double right = 0.0f;
        
        id leftId = [self.leftChild interpretRecursiveForSprite:sprite];
        if([leftId isKindOfClass:[NSNumber class]])
        {
            left = [leftId doubleValue];
        }
        
        id rightId = [self.rightChild interpretRecursiveForSprite:sprite];
        if([rightId isKindOfClass:[NSNumber class]])
        {
            right = [rightId doubleValue];
        }
        
    
        switch (operator) {
            case LOGICAL_AND: {
                result = [NSNumber numberWithDouble:(left * right) != 0.0 ? 1.0 : 0.0];
                break;
            }
            case LOGICAL_OR: {
                result = [NSNumber numberWithDouble:left != 0.0 || right != 0.0 ? 1.0 : 0.0];
                break;
            }
            case EQUAL: {
                result = [NSNumber numberWithDouble:left == right ? 1.0 : 0.0];
                break;
            }
            case NOT_EQUAL: {
                result = [NSNumber numberWithDouble:left == right ? 0.0 : 1.0];
                break;
            }
            case SMALLER_OR_EQUAL: {
                result = [NSNumber numberWithDouble:left <= right ? 1.0 : 0.0];
                break;
            }
            case GREATER_OR_EQUAL: {
                result = [NSNumber numberWithDouble:left >= right ? 1.0 : 0.0];
                break;
            }
            case SMALLER_THAN: {
                result = [NSNumber numberWithDouble:left < right ? 1.0 : 0.0];
                break;
            }
            case GREATER_THAN: {
                result = [NSNumber numberWithDouble:left > right ? 1.0 : 0.0];
                break;
            }
            case PLUS: {
                result =  [NSNumber numberWithDouble:left + right];
                break;
            }
            case MINUS: {
                result = [NSNumber numberWithDouble:left - right];
                break;
            }
            case MULT: {
                result = [NSNumber numberWithDouble:left * right];
                break;
            }
            case DIVIDE: {
                /*if(right > 0.0 || right < 0.0) {
                    result = left / right;
                } else {
                    result = left;
                }*/
                result = [NSNumber numberWithDouble:left / right];
                break;
            }

            default:
                //abort();
                [InternFormulaParserException raise:@"Unknown Operator" format:@"Unknown Operator: %d", operator];
                break;
        }
    }
    else { // unary operator
        
        
        double right = 0.0f;
        
        id rightId = [self.rightChild interpretRecursiveForSprite:sprite];
        if([rightId isKindOfClass:[NSNumber class]])
        {
            right = [rightId doubleValue];
        }
        switch (operator) {
            case MINUS: {
                result = [NSNumber numberWithDouble:-right];
                break;
            }
                
            case LOGICAL_NOT: {
                result = [NSNumber numberWithDouble:right == 0.0 ? 1.0 : 0.0];
                break;
            }
                
            default:
                //abort();
                [InternFormulaParserException raise:@"Unknown Unary Operator" format:@"Unknown Unary Operator: %d", operator];
                break;
        }
    }
    
    return result;
    
    
}

- (double) interpretLookSensor:(Sensor)sensor forSprite:(SpriteObject*)sprite
{
    double result = 0;
    
    switch (sensor) {
            
        case OBJECT_X: {
            result = sprite.xPosition;
            break;
        }
        case OBJECT_Y: {
            result = sprite.yPosition;
            break;
        }
        case OBJECT_GHOSTEFFECT: {
            result = sprite.alpha;
            break;
        }
        case OBJECT_BRIGHTNESS: {
            result = sprite.brightness;
            break;
        }
        case OBJECT_SIZE: {
            result = sprite.scaleX;
            break;
        }
        case OBJECT_ROTATION: {
            result = sprite.rotation;
            break;
        }
        case OBJECT_LAYER: {
            result = sprite.zIndex;
            break;
        }
            
        default:
            abort();
            break;
    }
    
    return result;

}

// TODO: use map for this...
- (ElementType)elementTypeForString:(NSString*)type
{
    if ([type isEqualToString:@"OPERATOR"]) {
        return OPERATOR;
    }
    if ([type isEqualToString:@"FUNCTION"]) {
        return FUNCTION;
    }
    if ([type isEqualToString:@"NUMBER"]) {
        return NUMBER;
    }
    if ([type isEqualToString:@"SENSOR"]) {
        return SENSOR;
    }
    if ([type isEqualToString:@"USER_VARIABLE"]) {
        return USER_VARIABLE;
    }
    if ([type isEqualToString:@"BRACKET"]) {
        return BRACKET;
    }
    if ([type isEqualToString:@"STRING"]) {
        return STRING;
    }
    NSError(@"Unknown Type: %@", type);
    return -1;
}

- (NSString*)stringForElementType:(ElementType)type
{
    if (type == OPERATOR) {
        return @"OPERATOR";
    }
    if (type == FUNCTION) {
        return @"FUNCTION";
    }
    if (type == NUMBER) {
        return @"NUMBER";
    }
    if (type == SENSOR) {
        return @"SENSOR";
    }
    if (type == USER_VARIABLE) {
        return @"USER_VARIABLE";
    }
    if (type == BRACKET) {
        return @"BRACKET";
    }
    if (type == STRING) {
        return @"STRING";
    }
    NSError(@"Unknown Type: %@", type);
    return nil;
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"Formula Element: Type: %d, Value: %@", self.type, self.value];
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
        case NUMBER:
            [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:self.value]];
            break;
        case SENSOR:
            [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_SENSOR AndValue:self.value]];
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

- (BOOL)isLogicalFunction
{
    if(self.type == FUNCTION)
    {
        Function function = [Functions getFunctionByValue:self.value];
        if((function == FALSE_F || function == TRUE_F) && self.leftChild == nil && self.rightChild == nil)
        {
            return YES;
        }
    }else
    {
        return NO;
    }
    
    return NO;
}

//- (BOOL)hasFunctionStringReturnType
//{
//    int function = [Functions getFunctionByValue:self.value];
//    if (function == -1) {
//        return NO;
//    }
//    
//    return NO;
//}

- (BOOL)containsElement:(ElementType)elementType
{
    if (self.type == elementType
        || (self.leftChild != nil && [self.leftChild containsElement:elementType])
        || (self.rightChild != nil && [self.rightChild containsElement:elementType])) {
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
// XXX: this leads to an endless recursion bug!!!
//    if(self.parent != nil && ![self.parent isEqualToFormulaElement:formulaElement.parent])
//        return NO;
    if ((self.parent && (! formulaElement.parent)) || ((! self.parent) && formulaElement.parent))
        return NO;

    return YES;
}

@end
