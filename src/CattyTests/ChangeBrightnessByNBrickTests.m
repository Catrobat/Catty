//
//  ChangeBrightnessByNBrickTests.m
//  Catty
//
//  Created by Marc Slavec on 5/22/14.
//
//

#import <XCTest/XCTest.h>
#import "BrickTests.h"

@interface ChangeBrightnessByNBrickTests  : BrickTests

@end

@implementation ChangeBrightnessByNBrickTests

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

-(void)testChangeBrightnessByNBrick
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
    
    ChangeBrightnessByNBrick* brick = [[ChangeBrightnessByNBrick alloc] init];
    brick.object = object;
    [object.lookList addObject:look];
    [object.lookList addObject:look];
    object.currentLook = look;
    object.currentUIImageLook = [UIImage imageWithContentsOfFile:filePath];
    object.currentLookBrightness = 1.0f;
    
    Formula* brightness = [[Formula alloc] init];
    FormulaElement* formulaTree = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"100";
    brightness.formulaTree = formulaTree;
    brick.changeBrightness = brightness;
    
    dispatch_block_t action = [brick actionBlock];
    
    action();
    XCTAssertEqualWithAccuracy([object brightness], 200.0f,0.1f, @"ChangeBrightnessBrick - Brightness not correct");
    [Program removeProgramFromDiskWithProgramName:program.header.programName];
}

-(void)testChangeBrightnessByNBrickWrongInput
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
    
    ChangeBrightnessByNBrick* brick = [[ChangeBrightnessByNBrick alloc] init];
    brick.object = object;
    [object.lookList addObject:look];
    [object.lookList addObject:look];
    object.currentLook = look;
    object.currentUIImageLook = [UIImage imageWithContentsOfFile:filePath];
    object.currentLookBrightness = 1.0f;
    
    Formula* brightness = [[Formula alloc] init];
    FormulaElement* formulaTree = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"a";
    brightness.formulaTree = formulaTree;
    brick.changeBrightness = brightness;
    
    dispatch_block_t action = [brick actionBlock];
    
    action();
    XCTAssertEqualWithAccuracy([object brightness], 100.0f,0.1f, @"ChangeBrightnessBrick - Brightness not correct");
    [Program removeProgramFromDiskWithProgramName:program.header.programName];
}

-(void)testChangeBrightnessByNBrickPositive
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
    
    ChangeBrightnessByNBrick* brick = [[ChangeBrightnessByNBrick alloc] init];
    brick.object = object;
    [object.lookList addObject:look];
    [object.lookList addObject:look];
    object.currentLook = look;
    object.currentUIImageLook = [UIImage imageWithContentsOfFile:filePath];
    object.currentLookBrightness = 0.0f;
    
    Formula* brightness = [[Formula alloc] init];
    FormulaElement* formulaTree = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"50";
    brightness.formulaTree = formulaTree;
    brick.changeBrightness = brightness;
    
    dispatch_block_t action = [brick actionBlock];
    
    action();
    XCTAssertEqualWithAccuracy([object brightness], 50.0f,0.1f, @"ChangeBrightnessBrick - Brightness not correct");
    [Program removeProgramFromDiskWithProgramName:program.header.programName];
}

-(void)testChangeBrightnessByNBrickNegative
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
    
    ChangeBrightnessByNBrick* brick = [[ChangeBrightnessByNBrick alloc] init];
    brick.object = object;
    [object.lookList addObject:look];
    [object.lookList addObject:look];
    object.currentLook = look;
    object.currentUIImageLook = [UIImage imageWithContentsOfFile:filePath];
    object.currentLookBrightness = 1.0f;
    
    Formula* brightness = [[Formula alloc] init];
    FormulaElement* formulaTree = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"-50";
    brightness.formulaTree = formulaTree;
    brick.changeBrightness = brightness;
    
    dispatch_block_t action = [brick actionBlock];
    
    action();
    XCTAssertEqualWithAccuracy([object brightness], 50.0f,0.1f, @"ChangeBrightnessBrick - Brightness not correct");
    [Program removeProgramFromDiskWithProgramName:program.header.programName];
}


@end
