//
//  SPBitmapChar.m
//  Sparrow
//
//  Created by Daniel Sperl on 12.10.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPBitmapChar.h"
#import "SPTexture.h"

@implementation SPBitmapChar
{
    SPTexture *_texture;
    int _charID;
    float _xOffset;
    float _yOffset;
    float _xAdvance;
    NSMutableDictionary *_kernings;
}

@synthesize charID = _charID;
@synthesize xOffset = _xOffset;
@synthesize yOffset = _yOffset;
@synthesize xAdvance = _xAdvance;
@synthesize texture = _texture;

- (id)initWithID:(int)charID texture:(SPTexture *)texture
         xOffset:(float)xOffset yOffset:(float)yOffset xAdvance:(float)xAdvance;
{
    if ((self = [super init]))
    {
        _texture = texture;
        _charID = charID;
        _xOffset = xOffset;
        _yOffset = yOffset;
        _xAdvance = xAdvance;
		_kernings = nil;
    }
    return self;
}

- (id)initWithTexture:(SPTexture *)texture
{
    return [self initWithID:0 texture:texture xOffset:0 yOffset:0 xAdvance:texture.width];
}

- (id)init
{
    return nil;
}

- (void)addKerning:(float)amount toChar:(int)charID
{
    if (!_kernings)
        _kernings = [[NSMutableDictionary alloc] init];    

	_kernings[@(charID)] = @(amount);
}

- (float)kerningToChar:(int)charID
{
	NSNumber *amount = (NSNumber *)_kernings[@(charID)];
	return [amount floatValue];
}

- (SPImage *)createImage
{
    return [SPImage imageWithTexture:_texture];
}

- (float)width
{
    return _texture.width;
}

- (float)height
{
    return _texture.height;
}

@end
