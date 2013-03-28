/**
 *  Copyright (C) 2010-2013 The Catrobat Team
 *  (<http://developer.catrobat.org/credits>)
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *
 *  An additional term exception under section 7 of the GNU Affero
 *  General Public License, version 3, is available at
 *  http://developer.catrobat.org/license_additional_term
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU Affero General Public License for more details.
 *
 *  You should have received a copy of the GNU Affero General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "ParserTests.h"
#import "ProjectParser.h"
#import "Parser.h"
#import "Program.h"
#import "SpriteObject.h"
#import "Look.h"
#import "Script.h"
#import "Startscript.h"
#import "Whenscript.h"

// Bricks
#import "Setlookbrick.h"
#import "Setsizetobrick.h"
#import "Waitbrick.h"

@interface ParserTests()

@property (nonatomic, strong) ProjectParser *parser;

@end

@implementation ParserTests


// -----------------------------------------------------------------------------
- (void)setUp
{
    [super setUp];
    
    // instantiate parser
    self.parser = [[ProjectParser alloc] init];
}


// -----------------------------------------------------------------------------
- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}



// -----------------------------------------------------------------------------
- (void)test001_basicParserTest {
    STAssertNil([self.parser loadProject:nil], @"Check if parser handles invalid input");
}


// -----------------------------------------------------------------------------
- (void)test002_parseSimpleBricks {
    // parse SetSizeToBrick
    NSString *xml = @"<org.catrobat.catroid.content.bricks.SetSizeToBrick><size>120.0</size><sprite reference=\"../../../../..\"/></org.catrobat.catroid.content.bricks.SetSizeToBrick>";
    
    id object = [self.parser loadProject:[xml dataUsingEncoding:NSUTF8StringEncoding]];
    STAssertNotNil(object, @"Check object");
    STAssertTrue([object isKindOfClass:[Setsizetobrick class]], @"Check if introspection succeeded");
    
    Setsizetobrick *brick = (Setsizetobrick*)object;
    STAssertEqualObjects(brick.size, [NSNumber numberWithFloat:120.0f], @"Check size of SetSizeToBrick");
    STAssertFalse(brick.size.floatValue != 120.0f, @"Check size value");
}


// -----------------------------------------------------------------------------
- (void)test003_testEntireParserWithDefaultProject {
    // parse default project
    Parser *parser = [[Parser alloc] init];
    
    NSBundle *bundle = [NSBundle mainBundle];
    STAssertNotNil(bundle, @"Check bundle");
    
    NSString *xmlPath = [bundle pathForResource:@"defaultProjectTest" ofType:@"xml"];
    STAssertNotNil(xmlPath, @"Check XML path");
    
    Program *project = [parser generateObjectForLevel:xmlPath];
    STAssertNotNil(project, @"Check project");
    
    
    // check basic project properties
    // ---------------------------------------------------------------------
    STAssertTrue([project.applicationBuildName isEqualToString:@""],         @"Check application build name");
    STAssertTrue([project.applicationBuildNumber isEqualToString:@"0"],      @"Check application build number");
    STAssertTrue([project.applicationName isEqualToString:@"Catroid"],       @"Check application name");
    STAssertTrue([project.applicationVersion isEqualToString:@"0.7.0beta"],  @"Check application version");
    STAssertTrue([project.catrobatLanguageVersion isEqualToString:@"0.3"],   @"Check catrobat language version");
    STAssertNil(project.dateTimeUpload,                                      @"Check date time upload");
    STAssertTrue([project.description isEqualToString:@"testdescription2"],  @"Check description");
    STAssertTrue([project.deviceName isEqualToString:@"Nexus S"],            @"Check device name");
    STAssertTrue([project.mediaLicense isEqualToString:@""],                 @"Check media license");
    STAssertTrue([project.platform isEqualToString:@"Android"],              @"Check platform");
    STAssertTrue([project.platformVersion isEqualToString:@"10"],            @"Check platform version");
    STAssertTrue([project.programLicense isEqualToString:@""],               @"Check program license");
    STAssertTrue([project.programName isEqualToString:@"testingproject1"],   @"Check program name");
    STAssertTrue([project.remixOf isEqualToString:@""],                      @"Check remix of");
    STAssertEqualObjects(project.screenHeight, [NSNumber numberWithInt:800], @"Check screen height");
    STAssertEqualObjects(project.screenWidth, [NSNumber numberWithInt:480],  @"Check screen width");
    STAssertNotNil(project.objectList,                                       @"Check sprite list (just for not nil)");
    STAssertTrue([project.uRL isEqualToString:@""],                          @"Check url");
    STAssertTrue([project.userHandle isEqualToString:@""],                   @"Check user handle");
    
    
    // not let's check the sprites
    // ---------------------------------------------------------------------
    NSArray *sprites = project.objectList;
    STAssertTrue(sprites.count == 2,                           @"Check sprites list count");
    
    // check the first sprite
    SpriteObject *sprite1 = [sprites objectAtIndex:0];
    STAssertNotNil(sprite1,                                    @"Check sprite1 for not nil");
    STAssertTrue([sprite1 isKindOfClass:[Sprite class]],       @"Check class of sprite1");
    STAssertTrue([sprite1.name isEqualToString:@"Background"], @"Check name of the sprite");
    NSArray *lookList1 = sprite1.lookList;
    STAssertNotNil(lookList1,                                  @"Check looklist1 for not nil");
    STAssertTrue(lookList1.count == 1,                         @"Check look list count");
    
    // check look
    Look *look1 = [lookList1 objectAtIndex:0];
    STAssertNotNil(look1,                                      @"Check if look1 is not nil");
    STAssertTrue([look1 isKindOfClass:[LookData class]],       @"Check class of look1");
    STAssertTrue([look1.name isEqualToString:@"background"],   @"Check name of look1");
    NSString *fn1 = @"B978398F6E8D16B857AA81618F3EF879_background";
    STAssertTrue([look1.fileName isEqualToString:fn1],         @"Check look1 file name");
    
    // check scripts
    NSArray *scripts1 = sprite1.scriptList;
    STAssertNotNil(scripts1,                                   @"Check if scripts1 is not nil");
    STAssertTrue(scripts1.count == 1,                          @"Check count of scripts1 list");
    id script1 = [scripts1 objectAtIndex:0];
    STAssertNotNil(script1,                                    @"Check for script1 not nil");
    STAssertTrue([script1 isKindOfClass:[Startscript class]],  @"Check first start script");
    Startscript *start1 = (Startscript*)script1;
    
    // check bricks of first script
    NSArray *bricks1 = start1.brickList;
    STAssertNotNil(bricks1,                                    @"Check for the first brick list");
    STAssertTrue(bricks1.count == 1,                           @"Check the count of the first brick list");
    
    id brick1 = [bricks1 objectAtIndex:0];
    STAssertNotNil(brick1,                                     @"Check for brick1 not nil");
    STAssertTrue([brick1 isKindOfClass:[SetLookBrick class]],  @"Check for class of brick");
    Setlookbrick *lookBrick = (Setlookbrick*)brick1;
    STAssertNotNil(lookBrick,                                  @"Check for look brick not nil");
    // TODO: check for lookBrick.look AND lookBrick.sprite
    // But this is currently not implemented by the parser because of X-Stream XML...
    
    
    // check the second sprite
    SpriteObject *sprite2 = [sprites objectAtIndex:1];
    STAssertNotNil(sprite2,                                    @"Check sprite2 for not nil");
    STAssertTrue([sprite2 isKindOfClass:[Sprite class]],       @"Check for class of sprite2");
    STAssertTrue([sprite2.name isEqualToString:@"Catroid"],    @"Check for name of sprite2");
    NSArray *lookList2 = sprite2.lookList;
    STAssertNotNil(lookList2,                                  @"Check for look list2 not nil");
    STAssertTrue(lookList2.count == 3,                         @"Check for count of the second look list");
    
    NSString *fn2 = @"7064E57016F4326F59F0B098D83EB259_normalCat";
    NSString *fn3 = @"FE5DF421A5746EC7FC916AC1B94ECC17_banzaiCat";
    NSString *fn4 = @"3673EC84679EE425A215B86B085EC292_cheshireCat";
    Look *look2 = [lookList2 objectAtIndex:0];
    Look *look3 = [lookList2 objectAtIndex:1];
    Look *look4 = [lookList2 objectAtIndex:2];
    
    // check looks
    STAssertNotNil(look2,                                      @"Check for look2 not nil");
    STAssertNotNil(look3,                                      @"Check for look3 not nil");
    STAssertNotNil(look4,                                      @"Check for look4 not nil");
    STAssertTrue([look2.fileName isEqualToString:fn2],         @"Check for filename of look2");
    STAssertTrue([look3.fileName isEqualToString:fn3],         @"Check for filename of look3");
    STAssertTrue([look4.fileName isEqualToString:fn4],         @"Check for filename of look4");
    STAssertTrue([look2.name isEqualToString:@"normalCat"],    @"Check for name of look2");
    STAssertTrue([look3.name isEqualToString:@"banzaiCat"],    @"Check for name of look3");
    STAssertTrue([look4.name isEqualToString:@"cheshireCat"],  @"Check for name of look4");
    
    // check scripts
    NSArray *scripts2 = sprite2.scriptList;
    STAssertNotNil(scripts2,                                   @"Check if scripts2 is not nil");
    STAssertTrue(scripts2.count == 2,                          @"Check count of scripts2 list");
    id script2 = [scripts2 objectAtIndex:0];
    STAssertNotNil(script2,                                    @"Check for script2 not nil");
    STAssertTrue([script2 isKindOfClass:[Startscript class]],  @"Check second start script");
    Startscript *start2 = (Startscript*)script2;
    // check bricks of second script
    NSArray *bricks2 = start2.brickList;
    STAssertNotNil(bricks2,                                    @"Check for the second brick list");
    STAssertTrue(bricks2.count == 1,                           @"Check the count of the second brick list");
    // Brick is already checked above (SetLookBrick)
    
    id script3 = [scripts2 objectAtIndex:1];
    STAssertNotNil(script3,                                    @"Check for script3 not nil");
    STAssertTrue([script3 isKindOfClass:[Whenscript class]],  @"Check third start script");
    Whenscript *when1 = (Whenscript*)script3;
    // check bricks of third script
    NSArray *bricks3 = when1.brickList;
    STAssertNotNil(bricks3,                                    @"Check for the third brick list");
    STAssertTrue(bricks3.count == 5,                           @"Check the count of the third brick list");
    
    // first brick - SetLookBrick
    id temp = [bricks3 objectAtIndex:0];
    STAssertNotNil(temp,                                       @"Check for temp not nil");
    STAssertTrue([temp isKindOfClass:[SetLookBrick class]],    @"Check first brick in when script");
    // ... This brick is a SetLookBrick -> already checked above
    
    // second brick - WaitBrick
    temp = [bricks3 objectAtIndex:1];
    STAssertNotNil(temp,                                       @"Check for temp not nil");
    STAssertTrue([temp isKindOfClass:[WaitBrick class]],       @"Check class of brick");
    Waitbrick *wait1 = (Waitbrick*)temp;
    NSNumber *n = [NSNumber numberWithInt:500];
    STAssertEqualObjects(wait1.timeToWaitInMilliSeconds, n,    @"Check wait time of wait brick");
    // TODO: Check sprite reference of this brick... but -> X-Stream...
    
    // third brick - SetLookBrick
    temp = [bricks3 objectAtIndex:2];
    STAssertNotNil(temp,                                       @"Check for temp not nil");
    STAssertTrue([temp isKindOfClass:[SetLookBrick class]],    @"Check third brick in when script");
    // ... This brick is a SetLookBrick -> already checked above
    
    // fourth brick - WaitBrick
    temp = [bricks3 objectAtIndex:3];
    STAssertNotNil(temp,                                       @"Check for temp not nil");
    STAssertTrue([temp isKindOfClass:[WaitBrick class]],       @"Check fourth brick in when script");
    // ... This brick is a WaitBrick -> already checked above
    
    // fifth brick - SetLookBrick
    temp = [bricks3 objectAtIndex:4];
    STAssertNotNil(temp,                                       @"Check for temp not nil");
    STAssertTrue([temp isKindOfClass:[SetLookBrick class]],    @"Check fifth brick in when script");
    // ... This brick is a SetLookBrick -> already checked above

    
    // check when script action
    STAssertTrue([when1.action isEqualToString:@"Tapped"],     @"Check action of when script");
    
    // that's it!
    // test finished! :-)
}



@end
