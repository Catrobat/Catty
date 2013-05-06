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
            NSDebug(@"NUMBER");
            result = self.value.doubleValue;
            break;
        }
            
        case OPERATOR: {
            NSDebug(@"OPERATOR");
            Operator operator = [self operatorForString:self.value];
            result = [self interpretOperator:operator forSprite:sprite];
            break;
        }
            
        case FUNCTION: {
            NSDebug(@"FUNCTION");
            Function function = [self functionForString:self.value];
            result = [self interpretFunction:function forSprite:sprite];
            break;
        }
            
        case USER_VARIABLE: {
            NSDebug(@"User Variable");
            ProgramManager* manager = [ProgramManager sharedProgramManager];
            Program* program = [manager program];
            Uservariable* var = [program.variables getUserVariableNamed:self.value forSpriteObject:sprite];
            result = [var.value doubleValue];
            break;
        }
            
        case SENSOR: {
            NSDebug(@"SENSOR");
            abort();
            break;
        }
            
        default:
            NSLog(@"Unknown Type: %d", self.type);
            abort();
            break;
    }
    
    return result;
    
}

-(double) interpretFunction:(Function)function forSprite:(SpriteObject*)sprite;
{
    
    double left = 0;
    if(self.leftChild) {
        left = [self.leftChild interpretRecursiveForSprite:sprite];
    }
    
    double result = 0;
    
    
    switch (function) {
        case SIN: {
            abort();
            break;
        }
        case COS: {
            abort();
            break;
        }
        case TAN: {
            abort();
            break;
        }
        case LN: {
            abort();
            break;
        }
        case LOG: {
            abort();
            break;
        }
        case SQRT: {
            abort();
            break;
        }
        case RAND: {
            abort();
            break;
        }
        case ROUND: {
            result = round(left);
            break;
        }
        case ABS: {
            abort();
            break;
        }
        case PI_F: {
            return PI;
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
                abort();
                break;
            }
            case LOGICAL_OR: {
                abort();
                break;
            }
            case EQUAL: {
                abort();
                break;
            }
            case NOT_EQUAL: {
                abort();
                break;
            }
            case SMALLER_OR_EQUAL: {
                abort();
                break;
            }
            case GREATER_OR_EQUAL: {
                abort();
                break;
            }
            case SMALLER_THAN: {
                abort();
                break;
            }
            case GREATER_THAN: {
                abort();
                break;
            }
            case PLUS: {
                abort();
                break;
            }
        
            case MULT: {
                result = left * right;
                break;
            }
            case DIVIDE: {
                result = left / right;
                break;
            }
            case MOD: {
                abort();
                break;
            }
            case POW: {
                abort();
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
            }
                
            case LOGICAL_NOT: {
                abort();
                break;
            }
                
            default:
            abort();
            break;
        }
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



@end
