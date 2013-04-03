//
//  SPBlendMode.m
//  Sparrow
//
//  Created by Daniel Sperl on 29.03.13.
//
//

#import "SPBlendMode.h"
#import <GLKit/GLKit.h>

// --- C functions ---------------------------------------------------------------------------------

static inline uint encodeFactor(uint factor)
{
    if (factor == GL_ZERO || factor == GL_ONE) return factor;
    else return (factor & 0xf) + 2;
}

static inline uint decodeFactor(uint factor)
{
    if (factor == GL_ZERO || factor == GL_ONE) return factor;
    else return factor + 0x0300 - 2;
}

static NSString *getNameOfFactor(uint factor)
{
    switch (factor)
    {
        case GL_ZERO:                return @"ZERO"; break;
        case GL_ONE:                 return @"ONE"; break;
        case GL_SRC_COLOR:           return @"SRC_COLOR"; break;
        case GL_ONE_MINUS_SRC_COLOR: return @"ONE_MINUS_SRC_COLOR"; break;
        case GL_SRC_ALPHA:           return @"SRC_ALPHA"; break;
        case GL_ONE_MINUS_SRC_ALPHA: return @"ONE_MINUS_SRC_ALPHA"; break;
        case GL_DST_ALPHA:           return @"DST_ALPHA"; break;
        case GL_ONE_MINUS_DST_ALPHA: return @"ONE_MINUS_DST_ALPHA"; break;
        case GL_DST_COLOR:           return @"DST_COLOR"; break;
        case GL_ONE_MINUS_DST_COLOR: return @"ONE_MINUS_DST_COLOR"; break;
        case GL_SRC_ALPHA_SATURATE:  return @"SRC_ALPHA_SATURATE"; break;
        default:                     return @"unknown";  break;
    }
}

static NSString *getNameOfMode(uint mode)
{
    switch (mode)
    {
        case SP_BLEND_MODE_AUTO:     return @"auto";     break;
        case SP_BLEND_MODE_NONE:     return @"none";     break;
        case SP_BLEND_MODE_NORMAL:   return @"normal";   break;
        case SP_BLEND_MODE_ADD:      return @"add";      break;
        case SP_BLEND_MODE_MULTIPLY: return @"multiply"; break;
        case SP_BLEND_MODE_SCREEN:   return @"screen";   break;
        case SP_BLEND_MODE_ERASE:    return @"erase";    break;
        default:                     return nil;         break;
    }
}

// --- Class implementation ------------------------------------------------------------------------

@implementation SPBlendMode

- (id)init
{
    return nil;
}

// OpenGL blend factors are either 0, 1, or something between 0x0300 and 0x0308.
// We can use this to encode 4 blend factors in a single unsigned integer.

+ (uint)encodeBlendModeWithSourceFactor:(uint)sFactor destFactor:(uint)dFactor
{
    return [self encodeBlendModeWithSourceFactor:sFactor destFactor:dFactor
                                 sourceFactorPMA:sFactor destFactorPMA:dFactor];
}

+ (uint)encodeBlendModeWithSourceFactor:(uint)sFactor destFactor:(uint)dFactor
                        sourceFactorPMA:(uint)sFactorPMA destFactorPMA:(uint)dFactorPMA
{
    return ((encodeFactor(sFactor))    << 12) |
           ((encodeFactor(dFactor))    <<  8) |
           ((encodeFactor(sFactorPMA)) <<  4) |
           ( encodeFactor(dFactorPMA));
}

+ (void)decodeBlendMode:(uint)blendMode premultipliedAlpha:(BOOL)pma
       intoSourceFactor:(uint *)sFactor destFactor:(uint *)dFactor
{
    if (pma)
    {
        *sFactor = decodeFactor((blendMode & 0x00f0) >> 4);
        *dFactor = decodeFactor( blendMode & 0x000f);
    }
    else
    {
        *sFactor = decodeFactor((blendMode & 0xf000) >> 12);
        *dFactor = decodeFactor((blendMode & 0x0f00) >>  8);
    }
}

+ (void)applyBlendFactorsForBlendMode:(uint)blendMode premultipliedAlpha:(BOOL)pma
{
    uint srcFactor, dstFactor;
    
    [self decodeBlendMode:blendMode premultipliedAlpha:pma intoSourceFactor:&srcFactor
               destFactor:&dstFactor];
    
    glBlendFunc(srcFactor, dstFactor);
}

+ (NSString *)describeBlendMode:(uint)blendMode
{
    NSString *modeName = getNameOfMode(blendMode);
    
    if (modeName) return [NSString stringWithFormat:@"[BlendMode: %@]", modeName];
    else
    {
        uint src, dst, srcPMA, dstPMA;
        [self decodeBlendMode:blendMode premultipliedAlpha:NO  intoSourceFactor:&src destFactor:&dst];
        [self decodeBlendMode:blendMode premultipliedAlpha:YES intoSourceFactor:&srcPMA destFactor:&dstPMA];
        
        if (src == srcPMA && dst == dstPMA)
            return [NSString stringWithFormat:@"[BlendMode: src=%@, dst=%@]",
                    getNameOfFactor(src), getNameOfFactor(dst)];
        else
            return [NSString stringWithFormat:@"[BlendMode: src=%@, dst=%@, srcPMA=%@, dstPMA=%@]",
                getNameOfFactor(src),    getNameOfFactor(dst),
                getNameOfFactor(srcPMA), getNameOfFactor(dstPMA)];
    }
}

@end
