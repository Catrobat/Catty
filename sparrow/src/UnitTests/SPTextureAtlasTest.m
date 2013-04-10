//
//  SPTextureAtlasTest.m
//  Sparrow
//
//  Created by Daniel Sperl on 04.04.13.
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "SPTextureAtlas.h"
#import "SPTexture.h"
#import "SPRectangle.h"
#import "SPSubTexture.h"

@interface SPTextureAtlasTest : SenTestCase
@end

@implementation SPTextureAtlasTest

- (void)testBasicFunctionality
{
    SPTexture *texture = [[SPTexture alloc] initWithWidth:100 height:100];
    SPTextureAtlas *atlas = [[SPTextureAtlas alloc] initWithTexture:texture];

    STAssertEquals(0, atlas.numTextures, @"wrong texture count");
    
    SPRectangle *region0 = [SPRectangle rectangleWithX:50 y:25 width:50 height:75];
    [atlas addRegion:region0 withName:@"region_0"];
    
    STAssertEquals(1, atlas.numTextures, @"wrong texture count");
    
    SPSubTexture *subTexture = (SPSubTexture *)[atlas textureByName:@"region_0"];
    
    STAssertEquals(subTexture.baseTexture, texture, @"wrong base texture");
    
    SPRectangle *expectedClipping = [SPRectangle rectangleWithX:0.5f y:0.25f width:0.5f height:0.75f];
    SPRectangle *clipping = subTexture.clipping;
    
    STAssertTrue([expectedClipping isEquivalent:clipping], @"wrong region");
    
    NSArray *expectedNames = @[@"region_0"];
    NSArray *names = atlas.names;
    
    STAssertTrue([expectedNames isEqualToArray:names], @"wrong names array");

    SPRectangle *region1 = [SPRectangle rectangleWithX:0 y:10 width:20 height:30];
    [atlas addRegion:region1 withName:@"region_1"];
    
    expectedNames = @[@"region_0", @"region_1"];
    names = atlas.names;
    
    STAssertTrue([expectedNames isEqualToArray:names], @"wrong names array");
    
    SPRectangle *region2 = [SPRectangle rectangleWithX:0 y:0 width:10 height:10];
    [atlas addRegion:region2 withName:@"other_name"];
    
    names = [atlas namesStartingWith:@"region"];
    STAssertTrue([expectedNames isEqualToArray:names], @"wrong names array");
}

@end
