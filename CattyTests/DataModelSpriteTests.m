//
//  DataModelSpriteTests.m
//  Catty
//
//  Created by Christof Stromberger on 07.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "DataModelSpriteTests.h"
#import "Sprite.h"
#import "BaseSprite.h"

#define SAMPLE_NAME @"KittyCat"
#define SAMPLE_PATH @"normalcat.png"
#define SAMPLE_POS_X 100
#define SAMPLE_POS_Y 100
#define SAMPLE_POS_Z 0
#define SAMPLE_INDEX 0
#define SAMPLE_COSTUME_NAME @"SampleCostume"

@implementation DataModelSpriteTests

@synthesize costume = _costume;
@synthesize effect = _effect;
@synthesize costumeArray = _costumeArray;

//#pragma mark - tear up & down
//- (void)setUp
//{
//    [super setUp];
//
//    //this is tested in DataModelCostumeTests.m
//    self.costume = [[Costume alloc] initWithName:SAMPLE_NAME andPath:SAMPLE_PATH];
//    self.effect = [[GLKBaseEffect alloc] init];
//    self.costumeArray = [[NSArray alloc] initWithObjects:self.costume, nil];
//
//}
//
//
//- (void)tearDown
//{    
//    [super tearDown];
//    
//    self.costume = nil;
//    self.effect = nil;
//    self.costumeArray = nil;
//}
//
//-(BOOL)compareGLKVector3:(GLKVector3)firstVector with:(GLKVector3)secondVector
//{
//    if (firstVector.x != secondVector.x)
//        return NO;
//    if (firstVector.y != secondVector.y)
//        return NO;
//    if (firstVector.z != secondVector.z)
//        return NO;
//    return YES;
//}
//
//#pragma mark - unit tests
////- (void)test001_createBasicSprite
////{
////    Sprite *sprite = [[Sprite alloc] initWithEffect:self.effect];
////    sprite.name = SAMPLE_NAME;
////    sprite.projectPath = SAMPLE_PATH;
////    
////    //creating tmp costume
////    Costume *costume = [[Costume alloc] initWithName:SAMPLE_COSTUME_NAME andPath:SAMPLE_PATH];
////    [sprite addCostume:costume];
////    STAssertEquals(sprite.name, SAMPLE_NAME, @"check name");
////    Costume *retCostume = [sprite.costumesArray objectAtIndex:0];
////    STAssertEqualObjects(costume, retCostume, @"checking costume of sprite");
////}
//
//-(void)test001_createBaseSprite
//{
//    BaseSprite *sprite = [[BaseSprite alloc]initWithEffect:self.effect];
//    STAssertEqualObjects(sprite.effect, self.effect, @"GLKBaseEffect wrong");
//    
//    NSString *spriteName = @"Test name of sprite";
//    sprite.name = spriteName;
//    STAssertTrue([sprite.name isEqualToString:spriteName], @"Sprite-name wrong");
//    
//    STAssertTrue(sprite.showSprite, @"sprite is hidden - should be visible");
//    sprite.showSprite = NO;
//    STAssertFalse(sprite.showSprite, @"sprite is visible - should be hidden");
//    sprite.showSprite = YES;
//    STAssertTrue(sprite.showSprite, @"sprite is hidden - should be visible");
//    
//    STAssertTrue([self compareGLKVector3:sprite.realPosition with:GLKVector3Make(0.0f, 0.0f, 0.0f)], @"Wrong init-position");
//    GLKVector3 newPosition = GLKVector3Make(123.4f, 65.3f, 0.93f);
//    sprite.realPosition = newPosition;
//    STAssertTrue([self compareGLKVector3:sprite.realPosition with:newPosition], @"Wrong position");
//
//    STAssertTrue(sprite.rotationInDegrees == 0.0f, @"Wrong init-rotation-value");
//    float newRotation = 13.4f;
//    sprite.rotationInDegrees = newRotation;
//    STAssertTrue(sprite.rotationInDegrees == newRotation, @"Wrong rotation-value");
//    
//    STAssertTrue(sprite.alphaValue == 1.0f, @"Wrong init-alpha-value");
//    float newAlpha = 0.5f;
//    sprite.alphaValue = newAlpha;
//    STAssertTrue(sprite.alphaValue == newAlpha, @"Wrong alpha-value");
//}


@end
