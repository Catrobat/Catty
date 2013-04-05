//
//  CustomExtensions.m
//  Catty
//
//  Created by Dominik Ziegler on 10/10/12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

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

@end
