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

-(NSString*) sha1
{
    const char *cStr = [self UTF8String];
    unsigned char result[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(cStr, strlen(cStr), result);
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

#warning could probably be imroved :)
- (NSString*) stringByEscapingHTMLEntities
{
    NSMutableString *result = [NSMutableString stringWithString:self];
    NSRange range = NSMakeRange(0, [result length]);
    [result replaceOccurrencesOfString:@"&amp;"  withString:@"&"  options:NSLiteralSearch range:range];
    [result replaceOccurrencesOfString:@"&quot;" withString:@"\"" options:NSLiteralSearch range:range];
    [result replaceOccurrencesOfString:@"&#x27;" withString:@"'"  options:NSLiteralSearch range:range];
    [result replaceOccurrencesOfString:@"&#x39;" withString:@"'"  options:NSLiteralSearch range:range];
    [result replaceOccurrencesOfString:@"&#x92;" withString:@"'"  options:NSLiteralSearch range:range];
    [result replaceOccurrencesOfString:@"&#x96;" withString:@"'"  options:NSLiteralSearch range:range];
    [result replaceOccurrencesOfString:@"&gt;"   withString:@">"  options:NSLiteralSearch range:range];
    [result replaceOccurrencesOfString:@"&lt;"   withString:@"<"  options:NSLiteralSearch range:range];
    return result;
}


- (BOOL)containsString:(NSString*)string
{
    NSRange range = [self rangeOfString:string options:0];
    return range.location != NSNotFound;
}

@end
