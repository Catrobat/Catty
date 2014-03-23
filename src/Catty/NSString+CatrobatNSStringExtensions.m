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

#import "NSString+CatrobatNSStringExtensions.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (CustomExtensions)

- (NSString*)sha1
{
    const char *cStr = [self UTF8String];
    unsigned char result[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(cStr, (unsigned int)strlen(cStr), result);
    return [NSString  stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3], result[4],
            result[5], result[6], result[7],
            result[8], result[9], result[10], result[11], result[12],
            result[13], result[14], result[15],
            result[16], result[17], result[18], result[19]
            ];
}


NSMutableString* resultString;


- (NSString*) stringByEscapingHTMLEntities
{
    NSMutableString *result = [NSMutableString stringWithString:self];
    NSRange range = NSMakeRange(0, [result length]);

    NSArray *stringsToReplace = [[NSArray alloc] initWithObjects:   @"&amp;"   ,@"&quot;"  ,@"&#x27;" ,@"&#x39;"
                                 ,@"&#x92;"  ,@"&#x96;"  ,@"&gt;"   ,@"&lt;"    ,nil];
    
    NSArray *stringsReplaceBy = [[NSArray alloc] initWithObjects:   @"&"       ,@"\""      ,@"'"      ,@"'"
                                 ,@"'"       ,@"'"       ,@">"      ,@"<"       ,nil];
    
    
    for (int i =0; i< [stringsReplaceBy count]; i++)
    {
        [result replaceOccurrencesOfString:[stringsToReplace objectAtIndex:i]
                                withString:[stringsReplaceBy objectAtIndex:i]
                                   options:NSLiteralSearch
                                     range:range];
        range = NSMakeRange(0, result.length);
    }
    
    return result;
}


- (NSString*) firstCharacterUppercaseString
{
    return [[[self substringToIndex:1] uppercaseString] stringByAppendingString:[self substringFromIndex:1]];
}


+ (NSString *)uuid
{
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidStr = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);
    return uuidStr;
}

- (BOOL)containsString:(NSString*)string
{
    NSRange range = [self rangeOfString:string options:0];
    return range.location != NSNotFound;
}

@end
