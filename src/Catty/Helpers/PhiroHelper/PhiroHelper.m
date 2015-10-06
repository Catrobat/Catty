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

#import "PhiroHelper.h"
#import "PhiroDefines.h"
#import "LanguageTranslationDefines.h"

@implementation PhiroHelper

+ (NSString*)toneToString:(Tone)formatType {
    NSString *result = nil;
    
    switch(formatType) {
        case DO:
            result = kLocalizedPhiroDO;
            break;
        case RE:
            result = kLocalizedPhiroRE;
            break;
        case MI:
            result = kLocalizedPhiroMI;
            break;
        case FA:
            result = kLocalizedPhiroFA;
            break;
        case SO:
            result = kLocalizedPhiroSO;
            break;
        case LA:
            result = kLocalizedPhiroLA;
            break;
        case TI:
            result = kLocalizedPhiroTI;
            break;
            
        default:
            [NSException raise:NSGenericException format:@"Unexpected FormatType."];
    }
    
    return result;
}
+ (Tone)stringToTone:(NSString*)string {
    if ([string isEqualToString:kLocalizedPhiroDO]) {
        return DO;
    } else if ([string isEqualToString:kLocalizedPhiroRE]) {
        return RE;
    } else if ([string isEqualToString:kLocalizedPhiroMI]) {
        return MI;
    } else if ([string isEqualToString:kLocalizedPhiroFA]) {
        return FA;
    } else if ([string isEqualToString:kLocalizedPhiroSO]) {
        return SO;
    } else if ([string isEqualToString:kLocalizedPhiroLA]) {
        return LA;
    }  else if ([string isEqualToString:kLocalizedPhiroTI]) {
        return TI;
    }
    return DO;
}

+ (NSString*)motorToString:(Motor)formatType {
    NSString *result = nil;
    
    switch(formatType) {
        case MotorBoth:
            result = kLocalizedPhiroBoth;
            break;
        case MotorRight:
            result = kLocalizedPhiroRight;
            break;
        case MotorLeft:
            result = kLocalizedPhiroLeft;
            break;
            
        default:
            [NSException raise:NSGenericException format:@"Unexpected FormatType."];
    }
    
    return result;
}
+ (Motor)stringToMotor:(NSString*)string {
    if ([string isEqualToString:kLocalizedPhiroBoth]) {
        return MotorBoth;
    } else if ([string isEqualToString:kLocalizedPhiroRight]) {
        return MotorRight;
    } else if ([string isEqualToString:kLocalizedPhiroLeft]) {
        return MotorLeft;
    }
    return MotorBoth;
}

+ (NSString*)lightToString:(Light)formatType {
    NSString *result = nil;
    
    switch(formatType) {
        case LightBoth:
            result = kLocalizedPhiroBoth;
            break;
        case LightRight:
            result = kLocalizedPhiroRight;
            break;
        case LightLeft:
            result = kLocalizedPhiroLeft;
            break;
            
        default:
            [NSException raise:NSGenericException format:@"Unexpected FormatType."];
    }
    
    return result;
}

+ (Light)stringToLight:(NSString*)string {
    if ([string isEqualToString:kLocalizedPhiroBoth]) {
        return LightBoth;
    } else if ([string isEqualToString:kLocalizedPhiroRight]) {
        return LightRight;
    } else if ([string isEqualToString:kLocalizedPhiroLeft]) {
        return LightLeft;
    }
    return LightBoth;
}

@end
