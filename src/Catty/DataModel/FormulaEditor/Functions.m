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

#import "Functions.h"
#import "InternFormulaParserException.h"

@implementation Functions

+ (BOOL)isFunction:(NSString*)value
{
    @try {
        [self getFunctionByValue:value];
    } @catch(InternFormulaParserException *e) {
        return false;
    }
    return true;
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
    
    [InternFormulaParserException raise:@"Invalid Function Name" format:@"Invalid Function Name: %@", value];
    return -1;
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

        default:
            break;
    }

    [InternFormulaParserException raise:@"Invalid Function" format:@"Invalid Function: %i", function];
    return nil;
}

@end
