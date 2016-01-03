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

#import "Functions.h"
#import "InternFormulaParserException.h"

@implementation Functions

+ (NSArray<NSNumber*>*)nonIdempotentFunctions {
    static NSArray *nonIdempotentFunctions = nil;
    if (nonIdempotentFunctions == nil) {
        nonIdempotentFunctions = kNonIdempotentFunctions;
    }
    return nonIdempotentFunctions;
}

+ (BOOL)isFunction:(NSString*)value {
    return ([self getFunctionByValue:value] != NO_FUNCTION);
}

+ (Function)getFunctionByValue:(NSString*)value
{
    if([value isEqualToString:@"SIN"])
        return SIN;
    if([value isEqualToString:@"COS"])
        return COS;
    if([value isEqualToString:@"TAN"])
        return TAN;
    if([value isEqualToString:@"LN"])
        return LN;
    if([value isEqualToString:@"LOG"])
        return LOG;
    if([value isEqualToString:@"SQRT"])
        return SQRT;
    if([value isEqualToString:@"RAND"])
        return RAND;
    if([value isEqualToString:@"ROUND"])
        return ROUND;
    if([value isEqualToString:@"ABS"])
        return ABS;
    if([value isEqualToString:@"PI"])
        return PI_F;
    if([value isEqualToString:@"ASIN"])
        return ARCSIN;
    if([value isEqualToString:@"ACOS"])
        return ARCCOS;
    if([value isEqualToString:@"ATAN"])
        return ARCTAN;
    if([value isEqualToString:@"MAX"])
        return MAX;
    if([value isEqualToString:@"MIN"])
        return MIN;
    if([value isEqualToString:@"TRUE"])
        return TRUE_F;
    if([value isEqualToString:@"FALSE"])
        return FALSE_F;
    if([value isEqualToString:@"MOD"])
        return MOD;
    if([value isEqualToString:@"POW"])
        return POW;
    if([value isEqualToString:@"EXP"])
        return EXP;
    if([value isEqualToString:@"LETTER"])
        return LETTER;
    if([value isEqualToString:@"LENGTH"])
        return LENGTH;
    if([value isEqualToString:@"JOIN"])
        return JOIN;
    if([value isEqualToString:@"ARDUINOANALOG"])
        return ARDUINOANALOG;
    if([value isEqualToString:@"ARDUINODIGITAL"])
        return ARDUINODIGITAL;
    if([value isEqualToString:@"FLOOR"])
        return FLOOR;
    if([value isEqualToString:@"CEIL"])
        return CEIL;
    
    return NO_FUNCTION;
}

+ (NSString*)getName:(Function)function
{
    switch (function) {
        case SIN:
            return @"SIN";
            break;
        case COS:
            return @"COS";
            break;
        case TAN:
            return @"TAN";
            break;
        case LN:
            return @"LN";
            break;
        case LOG:
            return @"LOG";
            break;
        case SQRT:
            return @"SQRT";
            break;
        case RAND:
            return @"RAND";
            break;
        case ROUND:
            return @"ROUND";
            break;
        case ABS:
            return @"ABS";
            break;
        case ARCSIN:
            return @"ASIN";
            break;
        case ARCCOS:
            return @"ACOS";
            break;
        case ARCTAN:
            return @"ATAN";
            break;
        case MAX:
            return @"MAX";
            break;
        case MIN:
            return @"MIN";
            break;
        case TRUE_F:
            return @"TRUE";
            break;
        case FALSE_F:
            return @"FALSE";
            break;
        case MOD:
            return @"MOD";
            break;
        case POW:
            return @"POW";
            break;
        case PI_F:
            return @"PI";
            break;
        case EXP:
            return @"EXP";
            break;
        case JOIN:
            return @"JOIN";
            break;
        case LENGTH:
            return @"LENGTH";
            break;
        case LETTER:
            return @"LETTER";
            break;
        case ARDUINODIGITAL:
            return @"ARDUINODIGITAL";
            break;
        case ARDUINOANALOG:
            return @"ARDUINOANALOG";
            break;
        case FLOOR:
            return @"FLOOR";
            break;
        case CEIL:
            return @"CEIL";
            break;
        default:
            return nil;
            break;
    }

//    [InternFormulaParserException raise:@"Invalid Function" format:@"Invalid Function: %i", function];
    return nil;
}

+ (NSString*)getExternName:(NSString*)value {

    Function function = [self getFunctionByValue:value];
    
    switch (function) {
        case SIN:
            return @"sin";
            break;
        case COS:
            return @"cos";
            break;
        case TAN:
            return @"tan";
            break;
        case LN:
            return @"ln";
            break;
        case LOG:
            return @"log";
            break;
        case SQRT:
            return kUIFEFunctionSqrt;
            break;
        case RAND:
            return @"rand";
            break;
        case ROUND:
            return @"round";
            break;
        case ABS:
            return @"abs";
            break;
        case ARCSIN:
            return @"arcsin";
            break;
        case ARCCOS:
            return @"arccos";
            break;
        case ARCTAN:
            return @"arctan";
            break;
        case MAX:
            return @"max";
            break;
        case MIN:
            return @"min";
            break;
        case TRUE_F:
            return kUIFEFunctionTrue;
            break;
        case FALSE_F:
            return kUIFEFunctionFalse;
            break;
        case MOD:
            return @"mod";
            break;
        case POW:
            return @"pow";
            break;
        case PI_F:
            return @"pi";
            break;
        case EXP:
            return @"exp";
            break;
        case LETTER:
            return kUIFEFunctionLetter;
            break;
        case LENGTH:
            return kUIFEFunctionLength;
            break;
        case JOIN:
            return kUIFEFunctionJoin;
            break;
        case ARDUINODIGITAL:
            return @"digitalArduinoPin";
            break;
        case ARDUINOANALOG:
            return @"analogArduinoPin";
            break;
        case FLOOR:
            return kUIFEFunctionFloor;
            break;
        case CEIL:
            return kUIFEFunctionCeil;
            break;
        default:
            return @"";
            break;
    }
}


@end
