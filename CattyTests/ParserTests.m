//
//  ParserTests.m
//  Catty
//
//  Created by Christof Stromberger on 15.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "ParserTests.h"
#import "RetailParser.h"
#import "Level.h"
#import "Sprite.h"
#import "Costume.h"
#import "Brick.h"
#import "Script.h"
#import "StartScript.h"
#import "SetCostumeBrick.h"

@implementation ParserTests

@synthesize parser = _parser;

#pragma mark - tear up & down
- (void)setUp
{
    [super setUp];

    self.parser = [[RetailParser alloc] init];
}


- (void)tearDown
{    
    [super tearDown];

}

- (void)test001_testBasicParser
{
    NSString *fileName = @"defaultProject";
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:fileName ofType:@"xml"];
    
    Level *level = [self.parser generateObjectForLevel:path];
    NSLog(@"Level: %@", level);
    STAssertTrue([level.name isEqualToString:@"defaultProject"], @"checking if the name of the level is correct");
    Sprite *sprite = [level.spritesArray objectAtIndex:0];
    STAssertTrue([sprite.name isEqualToString:@"Background"], @"checking if the name of the first sprite is correct");
    Costume *costume = [sprite.costumesArray objectAtIndex:0];
    STAssertTrue([costume.costumeName isEqualToString:@"background"], @"checking if the name of the first costume in the sprite is correct");
    Script *script = [sprite.startScriptsArray objectAtIndex:0];
    STAssertTrue(script != nil, @"checking if script is valid");
//    Brick *brick = [script.bricksArray objectAtIndex:0];
//    STAssertTrue([brick isKindOfClass:[SetCostumeBrick class]], @"checking if brick is valid");

}

@end
