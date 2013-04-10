//
//  SPTextField.m
//  Sparrow
//
//  Created by Daniel Sperl on 29.06.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPTextField.h"
#import "SPImage.h"
#import "SPTexture.h"
#import "SPSubTexture.h"
#import "SPGLTexture.h"
#import "SPEnterFrameEvent.h"
#import "SPQuad.h"
#import "SPQuadBatch.h"
#import "SPBitmapFont.h"
#import "SPStage.h"
#import "SPSprite.h"
#import "SparrowClass.h"

#import <UIKit/UIKit.h>

static NSMutableDictionary *bitmapFonts = nil;

// --- class implementation ------------------------------------------------------------------------

@implementation SPTextField
{
    float _fontSize;
    uint _color;
    NSString *_text;
    NSString *_fontName;
    SPHAlign _hAlign;
    SPVAlign _vAlign;
    BOOL _autoScale;
    BOOL _kerning;
    BOOL _requiresRedraw;
    BOOL _isRenderedText;
	
    SPQuadBatch *_contents;
    SPRectangle *_textBounds;
    SPQuad *_hitArea;
    SPSprite *_border;
}

@synthesize text = _text;
@synthesize fontName = _fontName;
@synthesize fontSize = _fontSize;
@synthesize hAlign = _hAlign;
@synthesize vAlign = _vAlign;
@synthesize color = _color;
@synthesize kerning = _kerning;
@synthesize autoScale = _autoScale;

- (id)initWithWidth:(float)width height:(float)height text:(NSString*)text fontName:(NSString*)name 
          fontSize:(float)size color:(uint)color 
{
    if ((self = [super init]))
    {        
        _text = [text copy];
        _fontSize = size;
        _color = color;
        _hAlign = SPHAlignCenter;
        _vAlign = SPVAlignCenter;
        _autoScale = NO;
        _border = NO;        
		_kerning = YES;
        _requiresRedraw = YES;
        self.fontName = name;
        
        _hitArea = [[SPQuad alloc] initWithWidth:width height:height];
        _hitArea.alpha = 0.0f;
        [self addChild:_hitArea];
        
        _contents = [[SPQuadBatch alloc] init];
        _contents.touchable = NO;
        [self addChild:_contents];
        
        [self addEventListener:@selector(onFlatten:) atObject:self forType:SP_EVENT_TYPE_FLATTEN];
    }
    return self;
} 

- (id)initWithWidth:(float)width height:(float)height text:(NSString*)text
{
    return [self initWithWidth:width height:height text:text fontName:SP_DEFAULT_FONT_NAME
                     fontSize:SP_DEFAULT_FONT_SIZE color:SP_DEFAULT_FONT_COLOR];   
}

- (id)initWithWidth:(float)width height:(float)height
{
    return [self initWithWidth:width height:height text:@""];
}

- (id)initWithText:(NSString *)text
{
    return [self initWithWidth:128 height:128 text:text];
}

- (id)init
{
    return [self initWithText:@""];
}

- (void)onFlatten:(SPEvent *)event
{
    if (_requiresRedraw) [self redraw];
}

- (void)render:(SPRenderSupport *)support
{
    if (_requiresRedraw) [self redraw];    
    [super render:support];
}

- (SPRectangle *)textBounds
{
    if (_requiresRedraw) [self redraw];
    if (!_textBounds) _textBounds = [_contents boundsInSpace:_contents];
    return [_textBounds copy];
}

- (SPRectangle *)boundsInSpace:(SPDisplayObject *)targetSpace
{
    return [_hitArea boundsInSpace:targetSpace];
}

- (void)setWidth:(float)width
{
    // other than in SPDisplayObject, changing the size of the object should not change the scaling;
    // changing the size should just make the texture bigger/smaller, 
    // keeping the size of the text/font unchanged. (this applies to setHeight:, as well.)
    
    _hitArea.width = width;
    _requiresRedraw = YES;
    [self updateBorder];
}

- (void)setHeight:(float)height
{
    _hitArea.height = height;
    _requiresRedraw = YES;
    [self updateBorder];
}

- (void)setText:(NSString *)text
{
    if (![text isEqualToString:_text])
    {
        _text = [text copy];
        _requiresRedraw = YES;
    }
}

- (void)setFontName:(NSString *)fontName
{
    if (![fontName isEqualToString:_fontName])
    {
        if ([fontName isEqualToString:SP_BITMAP_FONT_MINI] && ![bitmapFonts objectForKey:fontName])
            [SPTextField registerBitmapFont:[[SPBitmapFont alloc] initWithMiniFont]];
        
        _fontName = [fontName copy];
        _requiresRedraw = YES;        
        _isRenderedText = !bitmapFonts[_fontName];
    }
}

- (void)setFontSize:(float)fontSize
{
    if (fontSize != _fontSize)
    {
        _fontSize = fontSize;
        _requiresRedraw = YES;
    }
}
 
- (void)setHAlign:(SPHAlign)hAlign
{
    if (hAlign != _hAlign)
    {
        _hAlign = hAlign;
        _requiresRedraw = YES;
    }
}

- (void)setVAlign:(SPVAlign)vAlign
{
    if (vAlign != _vAlign)
    {
        _vAlign = vAlign;
        _requiresRedraw = YES;
    }
}

- (void)setColor:(uint)color
{
    if (color != _color)
    {
        _color = color;
        _requiresRedraw = YES;
        [self updateBorder];
    }
}

- (void)setKerning:(BOOL)kerning
{
	if (kerning != _kerning)
	{
		_kerning = kerning;
		_requiresRedraw = YES;
	}
}

- (void)setAutoScale:(BOOL)autoScale
{
    if (_autoScale != autoScale)
    {
        _autoScale = autoScale;
        _requiresRedraw = YES;
    }
}

+ (id)textFieldWithWidth:(float)width height:(float)height text:(NSString*)text
                          fontName:(NSString*)name fontSize:(float)size color:(uint)color
{
    return [[self alloc] initWithWidth:width height:height text:text fontName:name
                                     fontSize:size color:color];
}

+ (id)textFieldWithWidth:(float)width height:(float)height text:(NSString*)text
{
    return [[self alloc] initWithWidth:width height:height text:text];
}

+ (id)textFieldWithText:(NSString*)text
{
    return [[self alloc] initWithText:text];
}

+ (NSString *)registerBitmapFont:(SPBitmapFont *)font name:(NSString *)fontName
{
    if (!bitmapFonts) bitmapFonts = [[NSMutableDictionary alloc] init];
    if (!fontName) fontName = font.name;
    bitmapFonts[fontName] = font;
    return fontName;
}

+ (NSString *)registerBitmapFont:(SPBitmapFont *)font
{
    return [self registerBitmapFont:font name:nil];
}

+ (NSString *)registerBitmapFontFromFile:(NSString *)path texture:(SPTexture *)texture
                                    name:(NSString *)fontName
{
    SPBitmapFont *font = [[SPBitmapFont alloc] initWithContentsOfFile:path texture:texture];
    return [self registerBitmapFont:font name:fontName];
}

+ (NSString *)registerBitmapFontFromFile:(NSString *)path texture:(SPTexture *)texture
{
    SPBitmapFont *font = [[SPBitmapFont alloc] initWithContentsOfFile:path texture:texture];
    return [self registerBitmapFont:font];
}

+ (NSString *)registerBitmapFontFromFile:(NSString *)path
{
    SPBitmapFont *font = [[SPBitmapFont alloc] initWithContentsOfFile:path];
    return [self registerBitmapFont:font];
}

+ (void)unregisterBitmapFont:(NSString *)name
{
    [bitmapFonts removeObjectForKey:name];
}

+ (SPBitmapFont *)registeredBitmapFont:(NSString *)name
{
    return bitmapFonts[name];
}

- (void)redraw
{
    if (_requiresRedraw)
    {
        [_contents reset];
        
        if (_isRenderedText) [self createRenderedContents];
        else                 [self createComposedContents];
        
        _requiresRedraw = NO;
    }
}

- (void)createRenderedContents
{
    float width  = _hitArea.width;
    float height = _hitArea.height;    
    float fontSize = _fontSize == SP_NATIVE_FONT_SIZE ? SP_DEFAULT_FONT_SIZE : _fontSize;
    
  #if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0
    NSLineBreakMode lbm = NSLineBreakByTruncatingTail;
  #else
    UILineBreakMode lbm = UILineBreakModeTailTruncation;
  #endif

    CGSize textSize;
    
    if (_autoScale)
    {
        CGSize maxSize = CGSizeMake(width, FLT_MAX);
        fontSize += 1.0f;
        
        do
        {
            fontSize -= 1.0f;
            textSize = [_text sizeWithFont:[UIFont fontWithName:_fontName size:fontSize]
                         constrainedToSize:maxSize lineBreakMode:lbm];
        } while (textSize.height > height);
    }
    else
    {
        textSize = [_text sizeWithFont:[UIFont fontWithName:_fontName size:fontSize]
                     constrainedToSize:CGSizeMake(width, height) lineBreakMode:lbm];
    }
    
    float xOffset = 0;
    if (_hAlign == SPHAlignCenter)      xOffset = (width - textSize.width) / 2.0f;
    else if (_hAlign == SPHAlignRight)  xOffset =  width - textSize.width;
    
    float yOffset = 0;
    if (_vAlign == SPVAlignCenter)      yOffset = (height - textSize.height) / 2.0f;
    else if (_vAlign == SPVAlignBottom) yOffset =  height - textSize.height;
    
    if (!_textBounds) _textBounds = [[SPRectangle alloc] init];
    [_textBounds setX:xOffset y:yOffset width:textSize.width height:textSize.height];
    
    SPTexture *texture = [[SPTexture alloc] initWithWidth:width height:height generateMipmaps:YES
                                                     draw:^(CGContextRef context)
      {
          float red   = SP_COLOR_PART_RED(_color)   / 255.0f;
          float green = SP_COLOR_PART_GREEN(_color) / 255.0f;
          float blue  = SP_COLOR_PART_BLUE(_color)  / 255.0f;
          
          CGContextSetRGBFillColor(context, red, green, blue, 1.0f);
          
          [_text drawInRect:CGRectMake(0, yOffset, width, height)
                   withFont:[UIFont fontWithName:_fontName size:fontSize] 
              lineBreakMode:lbm alignment:(UITextAlignment)_hAlign];
      }];
    
    SPImage *image = [[SPImage alloc] initWithTexture:texture];
    [_contents addQuad:image];
}

- (void)createComposedContents
{
    SPBitmapFont *bitmapFont = bitmapFonts[_fontName];
    if (!bitmapFont)
        [NSException raise:SP_EXC_INVALID_OPERATION 
                    format:@"bitmap font %@ not registered!", _fontName];
    
    [bitmapFont fillQuadBatch:_contents withWidth:_hitArea.width height:_hitArea.height
                         text:_text fontSize:_fontSize color:_color hAlign:_hAlign vAlign:_vAlign
                    autoScale:_autoScale kerning:_kerning];
    
    _textBounds = nil; // will be created on demand
}

- (BOOL)border
{
    return _border != nil;
}

- (void)setBorder:(BOOL)value
{
    if (value && !_border)
    {
        _border = [SPSprite sprite];
        
        for (int i=0; i<4; ++i)
            [_border addChild:[[SPQuad alloc] initWithWidth:1.0f height:1.0f]];
        
        [self addChild:_border];
        [self updateBorder];
    }
    else if (!value && _border)
    {
        [_border removeFromParent];
        _border = nil;
    }
}

- (void)updateBorder
{
    if (!_border) return;
    
    float width  = _hitArea.width;
    float height = _hitArea.height;
    
    SPQuad *topLine    = (SPQuad *)[_border childAtIndex:0];
    SPQuad *rightLine  = (SPQuad *)[_border childAtIndex:1];
    SPQuad *bottomLine = (SPQuad *)[_border childAtIndex:2];
    SPQuad *leftLine   = (SPQuad *)[_border childAtIndex:3];
    
    topLine.width = width; topLine.height = 1;
    bottomLine.width = width; bottomLine.height = 1;
    leftLine.width = 1; leftLine.height = height;
    rightLine.width = 1; rightLine.height = height;
    rightLine.x = width - 1;
    bottomLine.y = height - 1;
    topLine.color = rightLine.color = bottomLine.color = leftLine.color = _color;
    
    [_border flatten];
}

@end
