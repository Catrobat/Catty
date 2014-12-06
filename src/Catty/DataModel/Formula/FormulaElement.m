/**
 *  Copyright (C) 2010-2014 The Catrobat Team
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
#import "NSString+CatrobatNSStringExtensions.h"
#import "Util.h"
#import "Operators.h"
#import "Functions.h"
#import "GDataXMLNode+CustomExtensions.h"

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
        self.type = [self elementTypeForString:type];
        self.value = value;
        self.leftChild = leftChild;
        self.rightChild = rightChild;
        self.parent = parent;
    }
    return self;
}

-(double) interpretRecursiveForSprite:(SpriteObject*)sprite;
{
    double result = -1;
    
    switch (self.type) {
        case NUMBER: {
            //NSDebug(@"NUMBER");
            result = self.value.doubleValue;
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
            result = [var.value doubleValue];
            break;
        }
            
        case SENSOR: {
            //NSDebug(@"SENSOR");
            Sensor sensor = [SensorManager sensorForString:self.value];
            if([SensorManager isObjectSensor:sensor]) {
                result = [self interpretLookSensor:sensor forSprite:sprite];
            } else {
                result = [[SensorHandler sharedSensorHandler] valueForSensor:sensor];
            }
            break;
        }
            
        case BRACKET: {
           // NSDebug(@"BRACKET");
            result = [self.rightChild interpretRecursiveForSprite:sprite];
            break;
        }
            
        default:
            NSError(@"Unknown Type: %d", self.type);
            abort();
            break;
    }
    
    return result;
    
}

-(double) interpretFunction:(Function)function forSprite:(SpriteObject*)sprite
{
    
    double left = 0;
    double right = 0;
    if(self.leftChild) {
        left = [self.leftChild interpretRecursiveForSprite:sprite];
    }
    if (self.rightChild) {
        right = [self.rightChild interpretRecursiveForSprite:sprite];
    }
    
    double result = 0;
    
    
    switch (function) {
        case SIN: {
            result = sin([Util degreeToRadians:left]);
            break;
        }
        case COS: {
            result = cos([Util degreeToRadians:left]);
            break;
        }
        case TAN: {
            result = tan([Util degreeToRadians:left]);
            break;
        }
        case LN: {
            result = log(left);
            break;
        }
        case LOG: {
            result = log10(left);
            break;
        }
        case SQRT: {
            result =  sqrt(left);
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
            result = minimum + random*(maximum-minimum);

            if ([self doubleIsInteger:minimum] && [self doubleIsInteger:maximum]
                && !(self.rightChild.type == NUMBER && [self.rightChild.value containsString:@"."])
                && !(self.rightChild.type == NUMBER && [self.rightChild.value containsString:@"."])) {
                
                result = (int)round(result);
            }

            break;
        }
        case ROUND: {
            result = round(left);
            break;
        }
        case ABS: {
            result = fabs(left);
            break;
        }
        case PI_F: {
            result = M_PI;
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
            result = fmod(left, right);
            break;
        }
        case ARCSIN: {
            double radians = asin(left);
            result = [Util radiansToDegree:radians];
            break;
        }
        case ARCCOS: {
            double radians = acos(left);
            result = [Util radiansToDegree:radians];
            break;
        }
        case ARCTAN: {
            double radians = atan(left);
            result = [Util radiansToDegree:radians];
            break;
        }
        case POW: {
            result = pow(left, right);
            break;
        }
        case MAX: {
            result = MAX(left, right);
            break;
        }
        case MIN:{
            result = MIN(left, right);
            break;
  
        }
        case TRUE_F: {
            result = 1.0;
            break;
        }
            
        case FALSE_F: {
            result = 0.0;
            break;
        }
        default:
            abort();
            break;
    }
    return result;
    
}

- (double) interpretOperator:(Operator)operator forSprite:(SpriteObject*)sprite
{

    double result = 0;
    
    
    if(self.leftChild) { // binary operator
        
        double left = [self.leftChild interpretRecursiveForSprite:sprite];
        double right = [self.rightChild interpretRecursiveForSprite:sprite];
    
        switch (operator) {
            case LOGICAL_AND: {
                result = (left * right) != 0.0 ? 1.0 : 0.0;
                break;
            }
            case LOGICAL_OR: {
                result = left != 0.0 || right != 0.0 ? 1.0 : 0.0;
                break;
            }
            case EQUAL: {
                result = left == right ? 1.0 : 0.0;
                break;
            }
            case NOT_EQUAL: {
                result = left == right ? 0.0 : 1.0;
                break;
            }
            case SMALLER_OR_EQUAL: {
                result = left <= right ? 1.0 : 0.0;
                break;
            }
            case GREATER_OR_EQUAL: {
                result = left >= right ? 1.0 : 0.0;
                break;
            }
            case SMALLER_THAN: {
                result = left < right ? 1.0 : 0.0;
                break;
            }
            case GREATER_THAN: {
                result = left > right ? 1.0 : 0.0;
                break;
            }
            case PLUS: {
                result =  left + right;
                break;
            }
            case MINUS: {
                result = left - right;
                break;
            }
            case MULT: {
                result = left * right;
                break;
            }
            case DIVIDE: {
                if(right > 0.0 || right < 0.0) {
                    result = left / right;
                } else {
                    result = left;
                }
                break;
            }

            default:
                abort();
                break;
        }
    }
    else { // unary operator
        
        double right = [self.rightChild interpretRecursiveForSprite:sprite];

        switch (operator) {
            case MINUS: {
                result = -right;
                break;
            }
                
            case LOGICAL_NOT: {
                result = right == 0.0 ? 1.0 : 0.0;
                break;
            }
                
            default:
            abort();
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

- (NSArray*)XMLChildElements
{
    NSMutableArray *childs = [NSMutableArray array];
    if (self.leftChild) {
        GDataXMLElement *leftChildXMLElement = [GDataXMLNode elementWithName:@"leftChild"];
        for (GDataXMLElement *childElement in [self.leftChild XMLChildElements]) {
            [leftChildXMLElement addChild:childElement];
        }
        [childs addObject:leftChildXMLElement];
    }
    if (self.rightChild) {
        GDataXMLElement *rightChildXMLElement = [GDataXMLNode elementWithName:@"rightChild"];
        for (GDataXMLElement *childElement in [self.rightChild XMLChildElements]) {
            [rightChildXMLElement addChild:childElement];
        }
        [childs addObject:rightChildXMLElement];
    }

    GDataXMLElement *typeXMLElement = [GDataXMLNode elementWithName:@"type"
                                                        stringValue:[self stringForElementType:self.type]];
    [childs addObject:typeXMLElement];

    if (self.value) {
        GDataXMLElement *valueXMLElement = [GDataXMLNode elementWithName:@"value"
                                                     optionalStringValue:self.value];
        [childs addObject:valueXMLElement];
    }

    return [childs copy];
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
    if(self.parent != nil && ![self.parent isEqualToFormulaElement:formulaElement.parent])
        return NO;
    
    return YES;
}

@end
