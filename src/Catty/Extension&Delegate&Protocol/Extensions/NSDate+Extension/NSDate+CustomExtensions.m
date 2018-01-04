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

#import "NSDate+CustomExtensions.h"
#import "LanguageTranslationDefines.h"

#define kWeekdayNamesShort @[\
    kLocalizedSu,\
    kLocalizedMo,\
    kLocalizedTu,\
    kLocalizedWe,\
    kLocalizedTh,\
    kLocalizedFr,\
    kLocalizedSa\
]

#define kWeekdayNames @[\
    kLocalizedSunday,\
    kLocalizedMonday,\
    kLocalizedTuesday,\
    kLocalizedWednesday,\
    kLocalizedThursday,\
    kLocalizedFriday,\
    kLocalizedSaturday\
]

#define kMonthNamesShort @[\
    kLocalizedJan,\
    kLocalizedFeb,\
    kLocalizedMar,\
    kLocalizedApr,\
    kLocalizedMay,\
    kLocalizedJun,\
    kLocalizedJul,\
    kLocalizedAug,\
    kLocalizedSep,\
    kLocalizedOct,\
    kLocalizedNov,\
    kLocalizedDec\
]

@implementation NSDate (CustomExtensions)

- (BOOL)isLaterThanOrEqualTo:(NSDate*)date
{
    return !([self compare:date] == NSOrderedAscending);
}

- (BOOL)isEarlierThanOrEqualTo:(NSDate*)date
{
    return !([self compare:date] == NSOrderedDescending);
}

- (BOOL) isLaterThan:(NSDate*)date
{
    return ([self compare:date] == NSOrderedDescending);
}

- (BOOL) isEarlierThan:(NSDate*)date
{
    return ([self compare:date] == NSOrderedAscending);
}

static NSDateFormatter *sameDayDateFormatter = nil;
+ (NSDateFormatter*)sameDayDateFormatter
{
    if (! sameDayDateFormatter) {
        sameDayDateFormatter = [NSDateFormatter new];
        [sameDayDateFormatter setDateFormat:@"yyyy-MM-dd"];
    }
    return sameDayDateFormatter;
}

- (BOOL)isSameDay:(NSDate*)date
{
    if ((self == nil) || (date == nil))
        return NO;

    NSDateFormatter *dateFormatter = [[self class] sameDayDateFormatter];
    NSDate *ownDate = [dateFormatter dateFromString:[dateFormatter stringFromDate:self]];
    date = [dateFormatter dateFromString:[dateFormatter stringFromDate:date]];
    return ([ownDate compare:date] == NSOrderedSame);
}

- (BOOL)isToday
{
    return [self isSameDay:[NSDate date]];
}

- (BOOL)isYesterday
{
    return [self isSameDay:[NSDate dateWithTimeIntervalSinceNow: -(60.0f*60.0f*24.0f)]];
}

- (BOOL)isWithinLastSevenDays
{
    return [self isLaterThanOrEqualTo:[NSDate dateWithTimeIntervalSinceNow: -(60.0f*60.0f*24.0f*7.0f)]];
}

- (NSString*)weekdayName:(BOOL)shortName
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitWeekday fromDate:self];
    return [(shortName ? kWeekdayNamesShort : kWeekdayNames) objectAtIndex:([components weekday] - 1)];
}

static NSDateFormatter *humanFriendlyTodayDateFormatter = nil;
+ (NSDateFormatter*)humanFriendlyTodayDateFormatter
{
    if (! humanFriendlyTodayDateFormatter) {
        humanFriendlyTodayDateFormatter = [NSDateFormatter new];
        [humanFriendlyTodayDateFormatter setDateFormat:@"HH:mm"];
    }
    return humanFriendlyTodayDateFormatter;
}

static NSDateFormatter *humanFriendlyDateFormatter = nil;
+ (NSDateFormatter*)humanFriendlyDateFormatter
{
    if (! humanFriendlyDateFormatter) {
        humanFriendlyDateFormatter = [NSDateFormatter new];
        [humanFriendlyDateFormatter setDateFormat:@"d, yyyy"];
    }
    return humanFriendlyDateFormatter;
}

- (NSString*)humanFriendlyFormattedString
{
    if ([self isToday]) {
        return [NSString stringWithFormat:@"%@ %@", kLocalizedToday,
                [[[self class] humanFriendlyTodayDateFormatter] stringFromDate:self]];
    } else if ([self isYesterday]) {
        return kLocalizedYesterday;
    }
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit options = (NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear);
    NSDateComponents *components = [calendar components:options fromDate:self];
    NSInteger index = ([components month] - 1);
    return [NSString stringWithFormat:@"%@ %@", [kMonthNamesShort objectAtIndex:index],
            [[[self class] humanFriendlyDateFormatter] stringFromDate:self]];
}

@end
