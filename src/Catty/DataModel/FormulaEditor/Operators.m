/**
 *  Copyright (C) 2010-2016 The Catrobat Team
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

#import "Operators.h"
#import "LanguageTranslationDefines.h"

@implementation Operators

+ (int)getPriority:(Operator)operator
{
    int priority = 0;
    switch (operator) {
        case LOGICAL_AND:
            priority = 2;
            break;
        case LOGICAL_OR:
            priority = 1;
            break;
        case LOGICAL_NOT:
            priority = 4;
            break;
        case EQUAL:
            priority = 3;
            break;
        case NOT_EQUAL:
            priority = 4;
            break;
        case SMALLER_OR_EQUAL:
            priority = 4;
            break;
        case GREATER_OR_EQUAL:
            priority = 4;
            break;
        case SMALLER_THAN:
            priority = 4;
            break;
        case GREATER_THAN:
            priority = 4;
            break;
        case PLUS:
            priority = 5;
            break;
        case MINUS:
            priority = 5;
            break;
        case MULT:
            priority = 6;
            break;
        case DIVIDE:
            priority = 6;
            break;
            
        default:
            NSDebug(@"Invalid operator");
            break;
    }
    
    return priority;
}

+ (BOOL)isLogicalOperator:(Operator)operator
{
    bool isLogical = false;
    switch (operator) {
        case LOGICAL_AND:
            isLogical = true;
            break;
        case LOGICAL_OR:
            isLogical = true;
            break;
        case LOGICAL_NOT:
            isLogical = true;
            break;
        case EQUAL:
            isLogical = true;
            break;
        case NOT_EQUAL:
            isLogical = true;
            break;
        case SMALLER_OR_EQUAL:
            isLogical = true;
            break;
        case GREATER_OR_EQUAL:
            isLogical = true;
            break;
        case SMALLER_THAN:
            isLogical = true;
            break;
        case GREATER_THAN:
            isLogical = true;
            break;
        case PLUS:
            isLogical = false;
            break;
        case MINUS:
            isLogical = false;
            break;
        case MULT:
            isLogical = false;
            break;
        case DIVIDE:
            isLogical = false;
            break;
            
        default:
            NSDebug(@"Invalid operator");
            break;
    }
    
    return isLogical;
}

+ (NSString*)getName:(Operator)operator
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
    NSString* name;
    switch (operator) {
        case LOGICAL_AND:
            name = @"LOGICAL_AND";
            break;
        case LOGICAL_OR:
            name = @"LOGICAL_OR";
            break;
        case LOGICAL_NOT:
            name = @"LOGICAL_NOT";
            break;
        case EQUAL:
            name = @"EQUAL";
            break;
        case NOT_EQUAL:
            name = @"NOT_EQUAL";
            break;
        case SMALLER_OR_EQUAL:
            name = @"SMALLER_OR_EQUAL";
            break;
        case GREATER_OR_EQUAL:
            name = @"GREATER_OR_EQUAL";
            break;
        case SMALLER_THAN:
            name = @"SMALLER_THAN";
            break;
        case GREATER_THAN:
            name = @"GREATER_THAN";
            break;
        case PLUS:
            name = @"PLUS";
            break;
        case MINUS:
            name = @"MINUS";
            break;
        case MULT:
            name = @"MULT";
            break;
        case DIVIDE:
            name = @"DIVIDE";
            break;
        case DECIMAL_MARK:
            name = [formatter decimalSeparator];
            break;
            
        default:
            return nil;
            break;
    }
    
    return name;
}

+ (NSString*)getExternName:(NSString *)value
{
    NSString* name;
    Operator operator = [self getOperatorByValue:value];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
    
    switch (operator) {
        case LOGICAL_AND:
            name = kUIFEOperatorAnd;
            break;
        case LOGICAL_OR:
            name = kUIFEOperatorOr;
            break;
        case LOGICAL_NOT:
            name = kUIFEOperatorNot;
            break;
        case EQUAL:
            name = @"=";
            break;
        case NOT_EQUAL:
            name = @"≠";
            break;
        case SMALLER_OR_EQUAL:
            name = @"≤";
            break;
        case GREATER_OR_EQUAL:
            name = @"≥";
            break;
        case SMALLER_THAN:
            name = @"<";
            break;
        case GREATER_THAN:
            name = @">";
            break;
        case PLUS:
            name = @"+";
            break;
        case MINUS:
            name = @"-";
            break;
        case MULT:
            name = @"*";
            break;
        case DIVIDE:
            name = @"/";
            break;
        case DECIMAL_MARK:
            name = [formatter decimalSeparator];
            break;
            
        default:
            NSDebug(@"Invalid operator");
            break;
    }
    
    return name;
}


+ (Operator)getOperatorByValue:(NSString*)name
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
    if([name isEqualToString:@"LOGICAL_AND"]) {
        return LOGICAL_AND;
    }
    if([name isEqualToString:@"LOGICAL_OR"]) {
        return LOGICAL_OR;
    }
    if([name isEqualToString:@"EQUAL"]) {
        return EQUAL;
    }
    if([name isEqualToString:@"NOT_EQUAL"]) {
        return NOT_EQUAL;
    }
    if([name isEqualToString:@"SMALLER_OR_EQUAL"]) {
        return SMALLER_OR_EQUAL;
    }
    if([name isEqualToString:@"GREATER_OR_EQUAL"]) {
        return GREATER_OR_EQUAL;
    }
    if([name isEqualToString:@"SMALLER_THAN"]) {
        return SMALLER_THAN;
    }
    if([name isEqualToString:@"GREATER_THAN"]) {
        return GREATER_THAN;
    }
    if([name isEqualToString:@"PLUS"]) {
        return PLUS;
    }
    if([name isEqualToString:@"MINUS"]) {
        return MINUS;
    }
    if([name isEqualToString:@"MULT"]) {
        return MULT;
    }
    if([name isEqualToString:@"DIVIDE"]) {
        return DIVIDE;
    }
    if([name isEqualToString:@"LOGICAL_NOT"]) {
        return LOGICAL_NOT;
    }
    if([name isEqualToString:[formatter decimalSeparator]]) {
        return DECIMAL_MARK;
    }
    
//    NSError(@"Unknown Operator: %@", name);
    return NO_OPERATOR;
}

+ (int)compareOperator:(Operator)firstOperator WithOperator:(Operator)secondOperator
{
    int returnValue = 0;
    if ([Operators getPriority:firstOperator] > [Operators getPriority:secondOperator]) {
        returnValue = 1;
    } else if ([Operators getPriority:firstOperator] == [Operators getPriority:secondOperator]) {
        returnValue = 0;
    } else if ([Operators getPriority:firstOperator] < [Operators getPriority:secondOperator]) {
        returnValue = -1;
    }
    
    return returnValue;
}

+ (BOOL)isOperator:(NSString*)value
{
    NSInteger operator = [Operators getOperatorByValue:value];
    if(operator == -1)
        return false;
    
    return true;
}

@end
