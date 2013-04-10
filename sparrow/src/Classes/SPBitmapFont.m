//
//  SPBitmapFont.m
//  Sparrow
//
//  Created by Daniel Sperl on 12.10.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPBitmapFont.h"
#import "SPBitmapChar.h"
#import "SPTexture.h"
#import "SPRectangle.h"
#import "SPSubTexture.h"
#import "SPDisplayObject.h"
#import "SPSprite.h"
#import "SPImage.h"
#import "SPTextField.h"
#import "SPStage.h"
#import "SPUtils.h"
#import "SparrowClass.h"
#import "SPNSExtensions.h"
#import "SPQuadBatch.h"

#define CHAR_SPACE           32
#define CHAR_TAB              9
#define CHAR_NEWLINE         10
#define CHAR_CARRIAGE_RETURN 13

// --- helper class --------------------------------------------------------------------------------

@interface SPCharLocation : SPPoolObject

@property (nonatomic) SPBitmapChar* bitmapChar;
@property (nonatomic) float scale;
@property (nonatomic) float x;
@property (nonatomic) float y;

- (id)initWithChar:(SPBitmapChar *)bitmapChar;

@end

@implementation SPCharLocation

- (id)initWithChar:(SPBitmapChar *)bitmapChar
{
    if ((self = [super init]))
        _bitmapChar = bitmapChar;
    
    return self;
}

SP_IMPLEMENT_MEMORY_POOL();

@end

// --- class implementation ------------------------------------------------------------------------

@implementation SPBitmapFont
{
    NSString *_name;
    SPTexture *_fontTexture;
    NSMutableDictionary *_chars;
    float _size;
    float _lineHeight;
    float _baseline;
    SPImage *_helperImage;
}

@synthesize name = _name;
@synthesize lineHeight = _lineHeight;
@synthesize size = _size;

- (id)initWithContentsOfData:(NSData *)data texture:(SPTexture *)texture
{
    if ((self = [super init]))
    {
        // if no data is passed in, we create the minimal, embedded font
        if (!data)
        {
            NSData *imgData =  [NSData dataWithBase64EncodedString:MiniFontImgDataBase64];
            texture = [[SPTexture alloc] initWithContentsOfImage:[UIImage imageWithData:imgData]];
            data = [[NSData dataWithBase64EncodedString:MiniFontXmlDataBase64] gzipInflate];
        }
        
        _name = @"unknown";
        _lineHeight = _size = _baseline = SP_DEFAULT_FONT_SIZE;
        _chars = [[NSMutableDictionary alloc] init];
        _fontTexture = texture ? texture : [self textureReferencedByXmlData:data];
        _helperImage = [[SPImage alloc] initWithTexture:_fontTexture];
        
        [self parseFontData:data];
    }
    
    return self;
}

- (id)initWithContentsOfData:(NSData *)data
{
    return [self initWithContentsOfData:data texture:nil];
}

- (id)initWithContentsOfFile:(NSString *)path texture:(SPTexture *)texture
{
    NSString *absolutePath = [SPUtils absolutePathToFile:path];
    if (!absolutePath) [NSException raise:SP_EXC_FILE_NOT_FOUND format:@"file not found: %@", path];
    NSData *xmlData = [[NSData alloc] initWithContentsOfFile:absolutePath];

    if (!texture)
    {
        NSString *folder = [absolutePath stringByDeletingLastPathComponent];
        texture = [self textureReferencedByXmlData:xmlData inFolder:folder];
    }
    
    return [self initWithContentsOfData:xmlData texture:texture];
}

- (id)initWithContentsOfFile:(NSString *)path
{
    return [self initWithContentsOfFile:path texture:nil];
}

- (id)init
{
    return [self initWithContentsOfData:nil texture:nil];
}

- (id)initWithMiniFont
{
    return [self init];
}

- (SPTexture *)textureReferencedByXmlData:(NSData *)data
{
    NSString *folder = [[NSBundle mainBundle] resourcePath];
    return [self textureReferencedByXmlData:data inFolder:folder];
}

- (SPTexture *)textureReferencedByXmlData:(NSData *)data inFolder:(NSString *)folder
{
    __block SPTexture *texture = nil;
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    
    [parser parseElementsWithBlock:^(NSString *elementName, NSDictionary *attributes)
    {
        if ([elementName isEqualToString:@"page"])
        {
            int id = [[attributes valueForKey:@"id"] intValue];
            if (id != 0) [NSException raise:SP_EXC_FILE_INVALID
                                     format:@"Bitmap fonts with multiple pages are not supported"];
            
            NSString *filename = [attributes valueForKey:@"file"];
            NSString *absolutePath = [folder stringByAppendingPathComponent:filename];
            texture = [[SPTexture alloc] initWithContentsOfFile:absolutePath];
            
            // that's all info we need at this time.
            [parser abortParsing];
        }
    }];
    
    if (!texture)
        [NSException raise:SP_EXC_DATA_INVALID format:@"Font XML did not contain path to texture"];
    
    return texture;
}

- (BOOL)parseFontData:(NSData *)data
{
    if (!_fontTexture)
        [NSException raise:SP_EXC_INVALID_OPERATION format:@"Font parsing requires texture to be set"];
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    BOOL success = [parser parseElementsWithBlock:^(NSString *elementName, NSDictionary *attributes)
    {
        float scale = _fontTexture.scale;
        
        if ([elementName isEqualToString:@"char"])
        {
            int charID = [[attributes valueForKey:@"id"] intValue];
            
            SPRectangle *region = [[SPRectangle alloc] init];
            region.x = [[attributes valueForKey:@"x"] floatValue] / scale + _fontTexture.frame.x;
            region.y = [[attributes valueForKey:@"y"] floatValue] / scale + _fontTexture.frame.y;
            region.width = [[attributes valueForKey:@"width"] floatValue] / scale;
            region.height = [[attributes valueForKey:@"height"] floatValue] / scale;
            SPSubTexture *texture = [[SPSubTexture alloc] initWithRegion:region ofTexture:_fontTexture];
            
            float xOffset = [[attributes valueForKey:@"xoffset"] floatValue] / scale;
            float yOffset = [[attributes valueForKey:@"yoffset"] floatValue] / scale;
            float xAdvance = [[attributes valueForKey:@"xadvance"] floatValue] / scale;
            
            SPBitmapChar *bitmapChar = [[SPBitmapChar alloc] initWithID:charID texture:texture
                                                                xOffset:xOffset yOffset:yOffset
                                                               xAdvance:xAdvance];
            _chars[@(charID)] = bitmapChar;
        }
        else if ([elementName isEqualToString:@"kerning"])
        {
            int first  = [[attributes valueForKey:@"first"] intValue];
            int second = [[attributes valueForKey:@"second"] intValue];
            float amount = [[attributes valueForKey:@"amount"] floatValue] / scale;
            [[self charByID:second] addKerning:amount toChar:first];
        }
        else if ([elementName isEqualToString:@"info"])
        {
            _name = [[attributes valueForKey:@"face"] copy];
            _size = [[attributes valueForKey:@"size"] floatValue] / scale;
            
            if ([[attributes valueForKey:@"smooth"] isEqualToString:@"0"])
                self.smoothing = SPTextureSmoothingNone;
        }
        else if ([elementName isEqualToString:@"common"])
        {
            _lineHeight = [[attributes valueForKey:@"lineHeight"] floatValue] / scale;
            _baseline = [[attributes valueForKey:@"base"] floatValue] / scale;
        }
    }];
    
    if (!success)
        [NSException raise:SP_EXC_DATA_INVALID format:@"Error parsing font XML: %@",
                     parser.parserError.localizedDescription];
    
    return success;
}

- (SPBitmapChar *)charByID:(int)charID
{
    return (SPBitmapChar *)_chars[@(charID)];
}

- (SPSprite *)createSpriteWithWidth:(float)width height:(float)height
                               text:(NSString *)text fontSize:(float)size color:(uint)color
                             hAlign:(SPHAlign)hAlign vAlign:(SPVAlign)vAlign
                          autoScale:(BOOL)autoScale kerning:(BOOL)kerning
{
    NSMutableArray *charLocations = [self arrangeCharsInAreaWithWidth:width height:height
        text:text fontSize:size hAlign:hAlign vAlign:vAlign autoScale:autoScale kerning:kerning];
    
    SPSprite *sprite = [SPSprite sprite];
    
    for (SPCharLocation *charLocation in charLocations)
    {
        SPImage *charImage = [charLocation.bitmapChar createImage];
        charImage.x = charLocation.x;
        charImage.y = charLocation.y;
        charImage.scaleX = charImage.scaleY = charLocation.scale;
        charImage.color = color;
        [sprite addChild:charImage];
    }
    
    return sprite;
}

- (void)fillQuadBatch:(SPQuadBatch *)quadBatch withWidth:(float)width height:(float)height
                 text:(NSString *)text fontSize:(float)size color:(uint)color
               hAlign:(SPHAlign)hAlign vAlign:(SPVAlign)vAlign
               autoScale:(BOOL)autoScale kerning:(BOOL)kerning
{
    NSMutableArray *charLocations = [self arrangeCharsInAreaWithWidth:width height:height
        text:text fontSize:size hAlign:hAlign vAlign:vAlign autoScale:autoScale kerning:kerning];
    
    _helperImage.color = color;
    
    if (charLocations.count > 8192)
        [NSException raise:SP_EXC_INVALID_OPERATION
                    format:@"Bitmap font text is limited to 8192 characters"];
    
    for (SPCharLocation *charLocation in charLocations)
    {
        _helperImage.texture = charLocation.bitmapChar.texture;
        _helperImage.x = charLocation.x;
        _helperImage.y = charLocation.y;
        _helperImage.scaleX = _helperImage.scaleY = charLocation.scale;
        [_helperImage readjustSize];
        [quadBatch addQuad:_helperImage];
    }
}

- (NSMutableArray *)arrangeCharsInAreaWithWidth:(float)width height:(float)height
                                           text:(NSString *)text fontSize:(float)size
                                         hAlign:(SPHAlign)hAlign vAlign:(SPVAlign)vAlign
                                      autoScale:(BOOL)autoScale kerning:(BOOL)kerning

{
    if (text.length == 0) return [NSMutableArray array];
    if (size < 0) size *= -_size;
    
    NSMutableArray *lines;
    float scale;
    float containerWidth;
    float containerHeight;
    BOOL finished = NO;
    
    while (!finished)
    {
        lines = [NSMutableArray array];
        scale = size / _size;
        containerWidth  = width  / scale;
        containerHeight = height / scale;
        
        if (_lineHeight <= containerHeight)
        {
            int lastWhiteSpace = -1;
            int lastCharID = -1;
            int numChars = text.length;
            float currentX = 0;
            float currentY = 0;
            NSMutableArray *currentLine = [NSMutableArray array];
            
            for (int i=0; i<numChars; i++)
            {
                BOOL lineFull = NO;
                int charID = [text characterAtIndex:i];
                SPBitmapChar *bitmapChar = [self charByID:charID];
                
                if (charID == CHAR_NEWLINE || charID == CHAR_CARRIAGE_RETURN)
                {
                    lineFull = YES;
                }
                else if (!bitmapChar)
                {
                    NSLog(@"Missing character: %d", charID);
                }
                else
                {
                    if (charID == CHAR_SPACE || charID == CHAR_TAB)
                        lastWhiteSpace = i;
                    
                    if (kerning)
                        currentX += [bitmapChar kerningToChar:lastCharID];
                    
                    SPCharLocation *charLocation = [[SPCharLocation alloc] initWithChar:bitmapChar];
                    charLocation.x = currentX + bitmapChar.xOffset;
                    charLocation.y = currentY + bitmapChar.yOffset;
                    [currentLine addObject:charLocation];
                    
                    currentX += bitmapChar.xAdvance;
                    lastCharID = charID;
                    
                    if (charLocation.x + bitmapChar.width > containerWidth)
                    {
                        // remove characters and add them again to next line
                        int numCharsToRemove = lastWhiteSpace == -1 ? 1 : i - lastWhiteSpace;
                        int removeIndex = currentLine.count - numCharsToRemove;
                        
                        [currentLine removeObjectsInRange:NSMakeRange(removeIndex, numCharsToRemove)];
                        
                        if (currentLine.count == 0)
                            break;
                        
                        i -= numCharsToRemove;
                        lineFull = YES;
                    }
                }
                
                if (i == numChars - 1)
                {
                    [lines addObject:currentLine];
                    finished = YES;
                }
                else if (lineFull)
                {
                    [lines addObject:currentLine];
                    
                    if (lastWhiteSpace == i)
                        [currentLine removeLastObject];
                    
                    if (currentY + 2*_lineHeight <= containerHeight)
                    {
                        currentLine = [NSMutableArray array];
                        currentX = 0.0f;
                        currentY += _lineHeight;
                        lastWhiteSpace = -1;
                        lastCharID = -1;
                    }
                    else
                    {
                        break;
                    }
                }
            } // for each char
        } // if (_lineHeight < containerHeight)
        
        if (autoScale && !finished)
        {
            size -= 1;
            [lines removeAllObjects];
        }
        else
        {
            finished = YES;
        }
    } // while (!finished)
    
    NSMutableArray *finalLocations = [NSMutableArray array];
    int numLines = lines.count;
    float bottom = numLines * _lineHeight;
    int yOffset = 0;
    
    if (vAlign == SPVAlignBottom)      yOffset =  containerHeight - bottom;
    else if (vAlign == SPVAlignCenter) yOffset = (containerHeight - bottom) / 2;
    
    for (NSArray *line in lines)
    {
        int numChars = line.count;
        if (!numChars) continue;
        
        int xOffset = 0;
        SPCharLocation *lastLocation = [line lastObject];
        float right = lastLocation.x - lastLocation.bitmapChar.xOffset
                                     + lastLocation.bitmapChar.xAdvance;
        
        if (hAlign == SPHAlignRight)       xOffset =  containerWidth - right;
        else if (hAlign == SPHAlignCenter) xOffset = (containerWidth - right) / 2;
        
        for (SPCharLocation *charLocation in line)
        {
            charLocation.x = scale * (charLocation.x + xOffset);
            charLocation.y = scale * (charLocation.y + yOffset);
            charLocation.scale = scale;
            
            if (charLocation.bitmapChar.width > 0 && charLocation.bitmapChar.height > 0)
                [finalLocations addObject:charLocation];
        }
    }
    
    return finalLocations;
}

- (SPTextureSmoothing)smoothing
{
    return _fontTexture.smoothing;
}

- (void)setSmoothing:(SPTextureSmoothing)smoothing
{
    _fontTexture.smoothing = smoothing;
}

#pragma mark - Mini Font

NSString *MiniFontXmlDataBase64 =
   @"H4sIAAAAAAAAA7Wc3XIbKRCF7/MUKt2nPM0/VXau8wZ7rbXlWLW2lFp5f7JPvxpxxgHBiEGhb1yyYn0+6Qb60DC+fz7s37"
    "98Wq3ud/vnw+p587h9WL/t9rv16rj77/TarVe/H16fHtbDerV737zuHs8vj2+Hw/vL+PLu/OnHw9vbYb963e23X7e7by/v"
    "4ZOb4wlhTz/+uHnd/vawJuHwzdeHtVHr1ffNt+3x9P746vGP7VNEfNn8eVw9Hv7an1jkaT2+i/dXu6fxPb1e/Xv+7I/z13"
    "92T6Ok07svkOBPP3B4fj5u38+if0yvP4vTP2ye/t7sx/+uCb8xZovBn9mWg00y6JYccA24v4CrOnyI2brEDgEXqj+bvAjs"
    "S91RUNxcUKgSFPIhKFKzwNUZrq6Mw1+A2wC/MhBvhothOMP1lYH4C3AKcI6EiiGMFsORUEEhLJYjoYJCWCxLQimExbEklM"
    "JQdCwJJXeGe56EhsWcBpaMCgKdZ46aQM+qhSzTR+IMXpTwCvhL8aIPHiVaDMvw87Ep0OUpNJEBKAbezsDrC6+JDUATe6iy"
    "fWIAmuB155IagK7KBYXhIjQHXIR1V96Szzo8KJdZQlUjvGSMRBjmSrDATWIBOsPDoq5ZlMtQjjSLchnGueFRHkaL4VEeRo"
    "tlUa5Sf9EZDn/Bozwk1PEoDwn1PMpDQj2P8sm8sEjXQ2peOtNhjYhH+4V3aaKLCp0E6qjItMtGe6FK9KR34buyDdZ0BrYY"
    "AtsvZCd2MUlowc/R5HXlJV005lPmcIWBbm5gU41NieXqyvaBPY3CvmyZuLmubILhGht+KZzKcGoYhi4ERQ6X7MgpmhsNNB"
    "k0i7KRsgBe3VZYmzjFvsoRFpWFfAFc1uDYV2h1CVeN8NJii8aFzmZQFzicIoty7P4Ni3ITwmJvUV4rcEKElou9RTlV4cG1"
    "uFuUV+EyxNxxxFygUHgW5SpUOM8Scy3g5XiC7kC/Vvtj+ufZFb1Q+zVc7tXavyinJdcipybatep/s3YhLfDXDMCiwJdckX"
    "eRVRz362D7n2y9ZA2goQSHLcrorpHuC1U6hAW9v4htG9muVOtcbC96w31sAfrCMY+UumSbRrYtFYxgunSWzg5wMQTlOgt5"
    "B7iTkI4jnb50k3RcIrZuZBeMkUGjOItKD7aNq2hnNk5cstnZgx3mj8/mTwe2nToWHMm001kORzYt6jNxpNOmJy2d4TYqQW"
    "PjtSMaLpQDnRyz9GU7jELPwcZVCM3BxuaWI5UuOWLpzMYJC0succDCkkvUTJZchvFtOHIJX2g4comes+XIJTrOliOX2F85"
    "jlzi2pbnyCX65J4ll9hZDSzJtMmWsy9cYVtFHOlUUC448gmnDHSxy3fztBdxNe6KnjbJkoGtkjsPnXXrpBr31S2SatyVTd"
    "j0SI5kEhy+4sgmWZUU5L5wuCvNkU9BJinJfeFYVAxHQhFym+VTNbILrUOb7JD7stEccxy6CfdjHYdwws07z6Mcx7QcynEL"
    "/KPkd4Xj8G3agHcOi5/uI3BIF2La33NoFx/3EVgGDBausG6N91ny3v4idqH7bsIs0hzoEHHPgKapzyQ54Nhy4uZKX7iQoT"
    "aLpclMDjsSevGSRtKdiOiiUXrpIgWUOwa2TTofEZsa2cWgwGtlg6ULPNQ4mUW8Axy3KGU2EGfYs0OldAXE4JpGNj9bhRfh"
    "6Nrw5DOxtxE8OgBSM/DkNLJ0uoTHEXSmvANcSKy2Wcw7wH1iQCO2amSXjBweuBMMbBqSS7Gd4XhcyLEox+NCjkd5WLU8j3"
    "JYUB7l02UEFuliOmJi0f5hEzm0C+SUcmvRgz41zQTPkIkbW7p44XYRu2jnXORC29h1q+gjG9qZjYMP2NAITo3wQplDfaYs"
    "KFFDQS4JeLGJQ7EL7Q2HCbU3wFUNjnsrMgt5F+Um9kTlwTIHrw0WPOSgMuGizjYVv6VxbcVcGYcxmxom5/QEtbtkR4uKWL"
    "RhKV61DxHXWVRm6C1LFp4T0plyWWfXhOMJRDzgVM7mInbJPeP82mRTvwscV3myqCyA2wocm1ubLSvUKLywHuIPSthrE5+W"
    "6C61+sHO5r2qs1VlFBL2trgn1BmOi0Lu2ooVw2cnZ1E5LGgW8hl403JoYgdaHipzbFMZKoSLFD6LygK4qsDx3CSWWvOBHn"
    "6ihxk0idIEur8b2ccvn+7vzn/v5X/zg7A/9kUAAA==";

NSString *MiniFontImgDataBase64 =
   @"iVBORw0KGgoAAAANSUhEUgAAAIAAAABABAMAAAAg+GJMAAAAJFBMVEUAAAD///////////////////////////////////"
    "////////+0CY3pAAAAC3RSTlMAAgQGCg4QFNn5/aulndcAAANHSURBVFhH7ZYxrhtHEESf4J+9RLGu4NCRoHQBBZv5EEp8"
    "AAVMfAQf4R+hAgIK6nIOenZJSt+GjW/IiRrN4XA4XV1dPcshvNrevFkubyFAELybfzshRATg3bvl4dkjNHw5YV6eKAkAz8"
    "/LH23Q/41JIs3ptuO3FTydHAwakUYS3fabsyjfrZzROQHcdieQxDOrrc3yu8QLQG4ArbpI9HHjXzO4B0Cp2w75KtM3Gtz8"
    "a4ARD0eV721zMhpyOoSix+wtJIKY20wgQAsjyw1SJMkxe9YpmtzPwCFAI4xaD0h/b3b2NkeD8NNv4qg5Q+y0926NOGfmad"
    "qAK/d5YrZc9xk+5nqZgXNtywEwDCYOEfzlwyPAzjUzvAQw9a/gLA3GF/G7EsithHNtuvBakxFFqYlluh8xFut8yog69Mk6"
    "MECmb7OS6xan03JUTSzw5XIjrfNakUc0SYjQ5gEg0Dl7lh45l+mHO4DrlgZCs9pfmuCW605z1W2V8DIDi2tpkRRiB0BeBD"
    "gkCQmkpU1Yz4sUVm8zJVjiocGh2OrCgH5fa1szNDLVBwsWm3mjx9imjV01g7/+DFQGYCTjy+cFuRNy3ZKnhBk5PKNR22CS"
    "SJL8npCVvdltJiuBPI3EpGnTALKORyKReThXaxaDI/c9g5wMcKGbeZ+WreKDJeReg8CdBq82UZykU6/tLC4/LznWb9fNEU"
    "yNbruMjyzKdDWwNorO7PPFz5d1meEYHgxyA1j7oaU5qTBEZ8Ps7XGbZ+U/0wvBqRXBSQ+67eRBg5k3yMkDOe7YMN/euSPj"
    "a+3IjRynwyNHhwqrGJyKmgYJdELDVGo7MOv/xK5bYQEUa8kpSyNhXTATnQyGVkurF9sBeMpVSQJzSWRffYWQA0No3Hb3ol"
    "53wHuAOtUcDBh5uWkw39GgS4PSTglLI6EJyn9ggxMy/MZqJFJ7XIYNJwdJKzFgCfHiBcTDM6/tenFL8GOiW8oUUQjlWiCC"
    "DEyOB+MGkAHYiW5hqTBi053pQKYYmXAX/dD1GNEJmxOc+xJGg+OILAlOgb6HqTHaEm2dmvLTHyRJiM7T2Kr9hp5BOmcrjH"
    "wXwvv3ujr2dcijOSoMA1BCXLL+E5M5NT/sh/2v9idsZLc1sYX4WAAAAABJRU5ErkJggg==";

@end
