//
//  SPBlendModeTest.m
//  Sparrow
//
//  Created by Daniel Sperl on 29.03.13.
//
//

#import <SenTestingKit/SenTestingKit.h>
#import <GLKit/GLKit.h>

#import "SPBlendMode.h"

@interface SPBlendModeTest : SenTestCase
@end


@implementation SPBlendModeTest

- (void)testBlendModeEncoding
{
    uint sFactor, dFactor, sFactorPMA, dFactorPMA;
    uint sFactorOut, dFactorOut;
    uint blendMode;
    
    // ---
    
    sFactor = GL_ZERO;
    dFactor = GL_ONE;
    sFactorPMA = GL_SRC_ALPHA;
    dFactorPMA = GL_SRC_COLOR;
    
    blendMode = [SPBlendMode encodeBlendModeWithSourceFactor:sFactor destFactor:dFactor
                                             sourceFactorPMA:sFactorPMA destFactorPMA:dFactorPMA];
    
    [SPBlendMode decodeBlendMode:blendMode premultipliedAlpha:NO
                intoSourceFactor:&sFactorOut destFactor:&dFactorOut];
    
    STAssertEquals(sFactor, sFactorOut, @"wrong source factor (no pma)");
    STAssertEquals(dFactor, dFactorOut, @"wrong dest factor (no pma)");
    
    [SPBlendMode decodeBlendMode:blendMode premultipliedAlpha:YES
                intoSourceFactor:&sFactorOut destFactor:&dFactorOut];
    
    STAssertEquals(sFactorPMA, sFactorOut, @"wrong source factor (pma)");
    STAssertEquals(dFactorPMA, dFactorOut, @"wrong dest factor (pma)");
    
    // ---
    
    sFactor = GL_DST_ALPHA;
    dFactor = GL_DST_COLOR;
    sFactorPMA = GL_ONE_MINUS_SRC_COLOR;
    dFactorPMA = GL_ONE_MINUS_SRC_ALPHA;
    
    blendMode = [SPBlendMode encodeBlendModeWithSourceFactor:sFactor destFactor:dFactor
                                             sourceFactorPMA:sFactorPMA destFactorPMA:dFactorPMA];
    
    [SPBlendMode decodeBlendMode:blendMode premultipliedAlpha:NO
                intoSourceFactor:&sFactorOut destFactor:&dFactorOut];
    
    STAssertEquals(sFactor, sFactorOut, @"wrong source factor (no pma)");
    STAssertEquals(dFactor, dFactorOut, @"wrong dest factor (no pma)");
    
    [SPBlendMode decodeBlendMode:blendMode premultipliedAlpha:YES
                intoSourceFactor:&sFactorOut destFactor:&dFactorOut];
    
    STAssertEquals(sFactorPMA, sFactorOut, @"wrong source factor (pma)");
    STAssertEquals(dFactorPMA, dFactorOut, @"wrong dest factor (pma)");
}

@end
