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
#import "LanguageTranslationDefines.h"

//**************************************************************************************************
//
//
// WARNING: Please keep kNonIdempotentFunctions up to date every time
//          you add a new function here!!
//

typedef NS_ENUM(NSInteger, Function) {
    SIN = 500,
    COS,
    TAN,
    LN,
    LOG,
    SQRT,
    RAND,
    ROUND,
    ABS,
    PI_F,
    ARCSIN,
    ARCCOS,
    ARCTAN,
    MAX,
    MIN,
    TRUE_F,
    FALSE_F,
    MOD,
    POW,
    EXP,
    JOIN,
    LETTER,
    LENGTH,
    ARDUINODIGITAL,
    ARDUINOANALOG,
    FLOOR,
    CEIL,
    NUMBEROFITEMS,
    ELEMENT,
    CONTAINS,
    NO_FUNCTION = -1
};

#define kNonIdempotentFunctions @[@(RAND),@(ARDUINODIGITAL),@(ARDUINOANALOG)]
//**************************************************************************************************

@interface Functions : NSObject

+ (NSArray<NSNumber*>*)nonIdempotentFunctions;
+ (BOOL)isFunction:(NSString*)value;
+ (Function)getFunctionByValue:(NSString*)value;
+ (NSString*)getName:(Function)function;
+ (NSString*)getExternName:(NSString *)value;

@end
