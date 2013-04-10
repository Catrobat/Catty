//
//  SPTextureAtlas.m
//  Sparrow
//
//  Created by Daniel Sperl on 27.06.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPTextureAtlas.h"
#import "SPMacros.h"
#import "SPTexture.h"
#import "SPSubTexture.h"
#import "SPGLTexture.h"
#import "SPRectangle.h"
#import "SPUtils.h"
#import "SparrowClass.h"
#import "SPNSExtensions.h"

// --- private interface ---------------------------------------------------------------------------

@interface SPTextureAtlas()

- (void)parseAtlasXml:(NSString*)path;

@end

// --- class implementation ------------------------------------------------------------------------

@implementation SPTextureAtlas
{
    SPTexture *_atlasTexture;
    NSString *_path;
    NSMutableDictionary *_textureRegions;
    NSMutableDictionary *_textureFrames;
}

- (id)initWithContentsOfFile:(NSString *)path texture:(SPTexture *)texture
{
    if ((self = [super init]))
    {
        _textureRegions = [[NSMutableDictionary alloc] init];
        _textureFrames  = [[NSMutableDictionary alloc] init];
        _atlasTexture = texture;
        [self parseAtlasXml:path];
    }
    return self;    
}

- (id)initWithContentsOfFile:(NSString *)path
{
    return [self initWithContentsOfFile:path texture:nil];
}

- (id)initWithTexture:(SPTexture *)texture
{
    return [self initWithContentsOfFile:nil texture:(SPTexture *)texture];
}

- (id)init
{
    return [self initWithContentsOfFile:nil texture:nil];
}

- (void)parseAtlasXml:(NSString *)path
{
    if (!path) return;

    _path = [SPUtils absolutePathToFile:path];
    if (!_path) [NSException raise:SP_EXC_FILE_NOT_FOUND format:@"file not found: %@", path];
    
    NSData *xmlData = [[NSData alloc] initWithContentsOfFile:_path];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:xmlData];
    
    BOOL success = [parser parseElementsWithBlock:^(NSString *elementName, NSDictionary *attributes)
    {
        if ([elementName isEqualToString:@"SubTexture"])
        {
            float scale = _atlasTexture.scale;
            
            NSString *name = attributes[@"name"];
            SPRectangle *frame = nil;
            
            float x = [attributes[@"x"] floatValue] / scale;
            float y = [attributes[@"y"] floatValue] / scale;
            float width = [attributes[@"width"] floatValue] / scale;
            float height = [attributes[@"height"] floatValue] / scale;
            float frameX = [attributes[@"frameX"] floatValue] / scale;
            float frameY = [attributes[@"frameY"] floatValue] / scale;
            float frameWidth = [attributes[@"frameWidth"] floatValue] / scale;
            float frameHeight = [attributes[@"frameHeight"] floatValue] / scale;
            
            if (frameWidth && frameHeight)
                frame = [SPRectangle rectangleWithX:frameX y:frameY width:frameWidth height:frameHeight];
            
            [self addRegion:[SPRectangle rectangleWithX:x y:y width:width height:height]
                   withName:name frame:frame];
        }
        else if ([elementName isEqualToString:@"TextureAtlas"] && !_atlasTexture)
        {
            // load atlas texture
            NSString *filename = [attributes valueForKey:@"imagePath"];
            NSString *folder = [_path stringByDeletingLastPathComponent];
            NSString *absolutePath = [folder stringByAppendingPathComponent:filename];
            _atlasTexture = [[SPTexture alloc] initWithContentsOfFile:absolutePath];
        }
    }];
    
    if (!success)
        [NSException raise:SP_EXC_FILE_INVALID format:@"could not parse texture atlas %@. Error: %@",
                           path, parser.parserError.localizedDescription];
}

- (int)numTextures
{
    return [_textureRegions count];
}

- (SPTexture *)textureByName:(NSString *)name
{
    SPRectangle *frame  = _textureFrames[name];
    SPRectangle *region = _textureRegions[name];
    
    if (region) return [[SPTexture alloc] initWithRegion:region frame:frame ofTexture:_atlasTexture];
    else        return nil;
}

- (NSArray *)textures
{
    return [self texturesStartingWith:nil];
}

- (NSArray *)texturesStartingWith:(NSString *)prefix
{
    NSArray *names = [self namesStartingWith:prefix];
    
    NSMutableArray *textures = [NSMutableArray arrayWithCapacity:names.count];
    for (NSString *textureName in names)
        [textures addObject:[self textureByName:textureName]];
    
    return textures;
}

- (NSArray *)names
{
    return [self namesStartingWith:nil];
}

- (NSArray *)namesStartingWith:(NSString *)prefix
{
    NSMutableArray *names = [[NSMutableArray alloc] init];
    
    if (prefix)
    {
        for (NSString *name in _textureRegions)
            if ([name rangeOfString:prefix].location == 0)
                [names addObject:name];
    }
    else
        [names addObjectsFromArray:[_textureRegions allKeys]];
    
    [names sortUsingSelector:@selector(localizedStandardCompare:)];
    return names;
}

- (void)addRegion:(SPRectangle *)region withName:(NSString *)name
{
    [self addRegion:region withName:name frame:nil];
}

- (void)addRegion:(SPRectangle *)region withName:(NSString *)name frame:(SPRectangle *)frame
{
    _textureRegions[name] = region;    
    if (frame) _textureFrames[name] = frame;
}

- (void)removeRegion:(NSString *)name
{
    [_textureRegions removeObjectForKey:name];
    [_textureFrames  removeObjectForKey:name];
}

+ (id)atlasWithContentsOfFile:(NSString *)path
{
    return [[self alloc] initWithContentsOfFile:path];
}

@end
