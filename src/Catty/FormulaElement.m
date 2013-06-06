/**
 *  Copyright (C) 2010-2013 The Catrobat Team
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
            Operator operator = [self operatorForString:self.value];
            result = [self interpretOperator:operator forSprite:sprite];
            break;
        }
            
        case FUNCTION: {
            //NSDebug(@"FUNCTION");
            Function function = [self functionForString:self.value];
            result = [self interpretFunction:function forSprite:sprite];
            break;
        }
            
        case USER_VARIABLE: {
            //NSDebug(@"User Variable");
            ProgramManager* manager = [ProgramManager sharedProgramManager];
            Program* program = [manager program];
            UserVariable* var = [program.variables getUserVariableNamed:self.value forSpriteObject:sprite];
            result = [var.value doubleValue];
            break;
        }
            
        case SENSOR: {
            //NSDebug(@"SENSOR");
            Sensor sensor = [SensorManager sensorForString:self.value];
            if([SensorManager isLookSensor:sensor]) {
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
    if(self.leftChild) {
        left = [self.leftChild interpretRecursiveForSprite:sprite];
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
            
            double right = [self.rightChild interpretRecursiveForSprite:sprite];
            double minimum;
            double maximum;
            
            if (right > left) {
                minimum = left;
                maximum = right;
            } else {
                minimum = right;
                maximum = left;
            }
            
            double random = (double)rand() / RAND_MAX;
            result = minimum + random * (maximum - minimum);
            

            if ([self doubleIsInteger:minimum] && [self doubleIsInteger:maximum]
                && !(self.rightChild.type == NUMBER && [self.rightChild.value containsString:@"."])
                && !(self.rightChild.type == NUMBER && [self.rightChild.value containsString:@"."])) {
                
                result = (int)result;
                if ((fabs(result) - (int) fabs(result)) >= 0.5) {
                    result +=1;
                }
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
                result = left == right ? 1.0 : 0.0; //TODO Double equality, maybe round first?
                break;
            }
            case NOT_EQUAL: {
                result = left == right ? 0.0 : 1.0; //TODO Double equality, maybe round first?
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
            case MOD: {
                abort();
                break;
            }
            case POW: {
                result = pow(left, right);
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
            
        case LOOK_X: {
            result = [sprite position].x;
            break;
        }
        case LOOK_Y: {
            result = [sprite position].y;
            break;
        }
        case LOOK_GHOSTEFFECT: {
            result = sprite.alpha;
            break;
        }
        case LOOK_BRIGHTNESS: {
            abort();
            break;
        }
        case LOOK_SIZE: {
            result = sprite.scaleX;
            break;
        }
        case LOOK_ROTATION: {
            result = sprite.rotation;
            break;
        }
        case LOOK_LAYER: {
            result = sprite.zIndex;
            break;
        }
            
        default:
            abort();
            break;
    }
    
    return result;

}

- (Function) functionForString:(NSString*)function
{
    
    if([function isEqualToString:@"SIN"]) {
        return SIN;
    }
    if([function isEqualToString:@"COS"]) {
        return COS;
    }
    if([function isEqualToString:@"TAN"]) {
        return TAN;
    }
    if([function isEqualToString:@"LN"]) {
        return LN;
    }
    if([function isEqualToString:@"LOG"]) {
        return LOG;
    }
    if([function isEqualToString:@"SQRT"]) {
        return SQRT;
    }
    if([function isEqualToString:@"RAND"]) {
        return RAND;
    }
    if([function isEqualToString:@"ROUND"]) {
        return ROUND;
    }
    if([function isEqualToString:@"ABS"]) {
        return ABS;
    }
    if([function isEqualToString:@"LN"]) {
        return LN;
    }
    if([function isEqualToString:@"PI"]) {
        return PI_F;
    }
    
    return -1;
}

-(Operator) operatorForString:(NSString*)operator
{
    if([operator isEqualToString:@"LOGICAL_AND"]) {
        return LOGICAL_AND;
    }
    if([operator isEqualToString:@"LOGICAL_OR"]) {
        return LOGICAL_OR;
    }
    if([operator isEqualToString:@"EQUAL"]) {
        return EQUAL;
    }
    if([operator isEqualToString:@"NOT_EQUAL"]) {
        return NOT_EQUAL;
    }
    if([operator isEqualToString:@"SMALLER_OR_EQUAL"]) {
        return SMALLER_OR_EQUAL;
    }
    if([operator isEqualToString:@"GREATER_OR_EQUAL"]) {
        return GREATER_OR_EQUAL;
    }
    if([operator isEqualToString:@"SMALLER_THAN"]) {
        return SMALLER_THAN;
    }
    if([operator isEqualToString:@"GREATER_THAN"]) {
        return GREATER_THAN;
    }
    if([operator isEqualToString:@"PLUS"]) {
        return PLUS;
    }
    if([operator isEqualToString:@"MINUS"]) {
        return MINUS;
    }
    if([operator isEqualToString:@"MULT"]) {
        return MULT;
    }
    if([operator isEqualToString:@"DIVIDE"]) {
        return DIVIDE;
    }
    if([operator isEqualToString:@"MOD"]) {
        return MOD;
    }
    if([operator isEqualToString:@"POW"]) {
        return POW;
    }
    if([operator isEqualToString:@"LOGICAL_NOT"]) {
        return LOGICAL_NOT;
    }
    
    return -1;
}


-(ElementType)elementTypeForString:(NSString*)type
{
    
    if([type isEqualToString:@"OPERATOR"]) {
        return OPERATOR;
    }
    if([type isEqualToString:@"FUNCTION"]) {
        return FUNCTION;
    }
    if([type isEqualToString:@"NUMBER"]) {
        return NUMBER;
    }
    if([type isEqualToString:@"SENSOR"]) {
        return SENSOR;
    }
    if([type isEqualToString:@"USER_VARIABLE"]) {
        return USER_VARIABLE;
    }
    if([type isEqualToString:@"BRACKET"]) {
        return BRACKET;
    }
    
    return -1;
    
}


-(NSString*)description
{
    return [NSString stringWithFormat:@"Formula Element: Type: %d, Value: %@", self.type, self.value];
}


-(BOOL) doubleIsInteger:(double)number {
    if(ceil(number) == number || floor(number) == number) {
        return YES;
    }
    
    return NO;
}



@end
