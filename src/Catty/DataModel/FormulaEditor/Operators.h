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

#import <Foundation/Foundation.h>

typedef enum {
    LOGICAL_AND = 400,
    LOGICAL_OR,
    EQUAL,
    NOT_EQUAL,
    SMALLER_OR_EQUAL,
    GREATER_OR_EQUAL,
    SMALLER_THAN,
    GREATER_THAN,
    PLUS,
    MINUS,
    MULT,
    DIVIDE,
    LOGICAL_NOT,
    DECIMAL_MARK,
    NO_OPERATOR = -1
} Operator;

@interface Operators : NSObject

+ (NSString*)getName:(Operator)operator;
+ (NSString*)getExternName:(NSString *)value;
+ (Operator)getOperatorByValue:(NSString*)name;
+ (int)getPriority:(Operator)operator;
+ (BOOL)isLogicalOperator:(Operator)operator;
+ (int)compareOperator:(Operator)firstOperator WithOperator:(Operator)secondOperator;

@end
