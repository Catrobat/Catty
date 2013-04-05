//
//  SPBlendMode.h
//  Sparrow
//
//  Created by Daniel Sperl on 29.03.13.
//
//

#import <Foundation/Foundation.h>

#define SP_BLEND_MODE_AUTO     0xffffffff
#define SP_BLEND_MODE_NONE     0x00001010 // one, zero -- one, zero
#define SP_BLEND_MODE_NORMAL   0x00004515 // src_alpha, one_minus_src_alpha -- one, one_minus_src_alpha
#define SP_BLEND_MODE_ADD      0x00004611 // src_alpha, dst_alpha -- one, one
#define SP_BLEND_MODE_MULTIPLY 0x00008585 // dst_color, one_minus_src_alpha -- dst_color, one_minus_src_alpha
#define SP_BLEND_MODE_SCREEN   0x00004113 // src_alpha, one -- one, one_minus_src_color
#define SP_BLEND_MODE_ERASE    0x00000505 // zero, one_minus_src_alpha -- zero, one_minus_src_alpha

/// A helper class for working with Sparrow's blend modes.
@interface SPBlendMode : NSObject

/// Encodes a set of blend factors into a single unsigned integer, using the same factors regardless
/// of the premultiplied alpha state active on rendering.
+ (uint)encodeBlendModeWithSourceFactor:(uint)sFactor destFactor:(uint)dFactor;

/// Encodes a set of blend factors into a single unsigned integer, using different factors depending
/// on the premultiplied alpha state active on rendering.
+ (uint)encodeBlendModeWithSourceFactor:(uint)sFactor destFactor:(uint)dFactor
                        sourceFactorPMA:(uint)sFactorPMA destFactorPMA:(uint)dFactorPMA;

/// Decodes a blend mode into its source and destination factors.
+ (void)decodeBlendMode:(uint)blendMode premultipliedAlpha:(BOOL)pma
       intoSourceFactor:(uint *)sFactor destFactor:(uint *)destFactor;

/// Makes OpenGL use the blend factors that correspond with a certain blend mode.
+ (void)applyBlendFactorsForBlendMode:(uint)blendMode premultipliedAlpha:(BOOL)pma;

/// Returns a string that describes a blend mode.
+ (NSString *)describeBlendMode:(uint)blendMode;

@end
