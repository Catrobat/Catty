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

#import <CommonCrypto/CommonDigest.h>

#import "NSData+Hashes.h"

static inline NSString *CCHashFunction(unsigned char *(function)(const void *data, CC_LONG len, unsigned char *md), CC_LONG digestLength, NSData *data)
{
    uint8_t digest[digestLength];
    function(data.bytes, (CC_LONG)data.length, digest);
    NSMutableString *output = [NSMutableString stringWithCapacity:digestLength * 2];
    for (int i = 0; i < digestLength; ++i) {
        [output appendFormat:@"%02x", digest[i]];
    }
    return output;
}

@implementation NSData (Hashes)

- (NSString*)md5
{
    return CCHashFunction(CC_MD5, CC_MD5_DIGEST_LENGTH, self);
}

- (NSString*)sha1
{
    return CCHashFunction(CC_SHA1, CC_SHA1_DIGEST_LENGTH, self);
}

- (NSString*)sha224
{
    return CCHashFunction(CC_SHA224, CC_SHA224_DIGEST_LENGTH, self);
}

- (NSString*)sha256
{
    return CCHashFunction(CC_SHA256, CC_SHA256_DIGEST_LENGTH, self);
}

- (NSString*)sha384
{
    return CCHashFunction(CC_SHA384, CC_SHA384_DIGEST_LENGTH, self);
}

- (NSString*)sha512
{
    return CCHashFunction(CC_SHA512, CC_SHA512_DIGEST_LENGTH, self);
}

@end
