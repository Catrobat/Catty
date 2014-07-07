//
//  NextLookBrickTests.m
//  Catty
//
//  Created by Marc Slavec on 5/22/14.
//
//

#import <XCTest/XCTest.h>
#import "BrickTests.h"

@interface NextLookBrickTests : BrickTests

@end

@implementation NextLookBrickTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testNextLookBrick
{
    SpriteObject* object = [[SpriteObject alloc] init];
    Program *program = [Program defaultProgramWithName:@"a"];
    object.program = program;
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString * filePath = [bundle pathForResource:@"test.png"
                                           ofType:nil];
    NSData *imageData = UIImagePNGRepresentation([UIImage imageWithContentsOfFile:filePath]);
    Look* look = [[Look alloc] initWithName:@"test" andPath:@"test.png"];
    [imageData writeToFile:[NSString stringWithFormat:@"%@images/%@", [object projectPath], @"test.png"]atomically:YES];
    Look* look1 = [[Look alloc] initWithName:@"test2" andPath:@"test2.png"];
    [imageData writeToFile:[NSString stringWithFormat:@"%@images/%@", [object projectPath], @"test2.png"]atomically:YES];
    
    NextLookBrick* brick = [[NextLookBrick alloc] init];
    brick.object = object;
    [object.lookList addObject:look];
    [object.lookList addObject:look1];
    object.currentLook = look;
    object.currentUIImageLook = [UIImage imageWithContentsOfFile:filePath];
    object.currentLookBrightness = 0.0f;

    
    
    dispatch_block_t action = [brick actionBlock];
    
    action();
    XCTAssertEqual(object.currentLook,look1, @"NextLookBrick not correct");
    [Program removeProgramFromDiskWithProgramName:program.header.programName];
}
@end
