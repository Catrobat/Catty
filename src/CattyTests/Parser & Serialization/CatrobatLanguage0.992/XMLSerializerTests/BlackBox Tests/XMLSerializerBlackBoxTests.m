/**
 *  Copyright (C) 2010-2017 The Catrobat Team
 *  (http://developer.catrobat.org/credits)
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *
 *  An additional term exception under section 7 of the GNU Affero
 *  General Public License, version 3, is available at
 *  (http://developer.catrobat.org/license_additional_term)
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU Affero General Public License for more details.
 *
 *  You should have received a copy of the GNU Affero General Public License
 *  along with this program.  If not, see http://www.gnu.org/licenses/.
 */

#import <XCTest/XCTest.h>
#import "XMLAbstractTest.h"
#import "Program.h"
#import "CBXMLSerializer.h"
#import "Scene.h"

@interface XMLSerializerBlackBoxTests : XMLAbstractTest

@end

@implementation XMLSerializerBlackBoxTests

- (void)testParseXMLAndSerializeProgramAndCompareXML:(NSString *)xmlFile {
//    NSString *xmlFileFolder = nil;
//    if ([xmlFile containsString:@"_098"]) {
//        xmlFileFolder = [xmlFile stringByReplacingOccurrencesOfString:@"_098" withString:@""];
//    } else if ([xmlFile containsString:@"098"]) {
//        xmlFileFolder = [xmlFile stringByReplacingOccurrencesOfString:@"098" withString:@""];
//    } else {
//        return;
//    }
//    
//    Program *program = [self getProgramForXML:xmlFile];
//    GDataXMLDocument *document = [CBXMLSerializer xmlDocumentForProgram:program];
//    
//    NSString *pathToXmlFiles = @"/Users/bigdreamer/Desktop/GSoC/Catty/src/CattyTests/Resources/ParserTests/";
//    
//    NSString *newXmlFile = [[[[pathToXmlFiles stringByAppendingPathComponent:xmlFileFolder]
//                              stringByAppendingPathComponent:xmlFile]
//                             stringByReplacingOccurrencesOfString:@"098" withString:@"0992"]
//                            stringByAppendingPathExtension:@"xml"];
//    
//    NSString *xmlString = [NSString stringWithFormat:@"%@\n%@", kCatrobatHeaderXMLDeclaration,
//                           [document.rootElement XMLStringPrettyPrinted:YES]];
//    
//    NSDebug(@"Generated XML output:\n%@", xmlString);
//    NSError *error = nil;
//    
//    if (! [xmlString writeToFile:newXmlFile atomically:YES encoding:NSUTF8StringEncoding error:&error]) {
//        NSError(@"Program could not saved to disk! %@", error);
//    }
    
    [super testParseXMLAndSerializeProgramAndCompareXML:xmlFile];
}

- (void)testAirFight
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"Air_fight_0.5_0992"];
}

- (void)testInvalidAirFight
{
    Program *program098 = [self getProgramForXML:@"Air_fight_0.5_098"];
    
    XCTAssertEqual(1, [program098.scenes count], @"Invalid scenes");
    Scene *scene = program098.scenes.firstObject;
    
    SpriteObject *background = [scene.objectList objectAtIndex:0];
    background.name = @"Invalid";
    BOOL equal = [self isProgram:program098 equalToXML:@"Air_fight_0.5_0992"];
    XCTAssertFalse(equal, @"Serialized program and XML are not equal");
}

- (void)testAirplaneWithShadow06
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"Airplane_with_shadow_0992"];
}

- (void)testCompass01
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"Compass_0.1_0992"];
}

- (void)testDemonstration
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"Demonstration_0992"];
}

- (void)testDrinkMoreWater
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"Drink_more_water_0992"];
}

- (void)testEncapsulated
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"Encapsulated_0992"];
}

- (void)testFlapPacMan
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"Flap_Pac_Man_0992"];
}

- (void)testFlappy30
{
   [self testParseXMLAndSerializeProgramAndCompareXML:@"Flappy_v3.0_0992"];
}

- (void)testGossipGirl
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"Gossip_Girl_0992"];
}

- (void)testMemory
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"Memory_0992"];
}

- (void)testMinecraftWorkInProgress
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"Minecraft_Work_In_Progress_0992"];
}

- (void)testMinions_
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"Minions__0992"];
}

- (void)testPongStarter
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"Pong_Starter_0992"];
}

- (void)testRockPaperScissors
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"Rock_paper_scissors_0992"];
}

- (void)testTicTacToeMaster
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"Tic_Tac_Toe_Master_0992"];
}

- (void)testWordBalloonDemo
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"Word_balloon_demo_0992"];
}

- (void)testXRayPhone
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"X_Ray_phone_0992"];
}

- (void)testGalaxyWar
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"Galaxy_War_0992"];
}

- (void)testSkydivingSteve
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"Skydiving_Steve_0992"];
}

- (void)testPythagoreanTheorem
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"Pythagorean_Theorem_0992"];
}

- (void)testValidProgramAllBricks
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"ValidProgramAllBricks0992"];
}

- (void)testLedFlashBrick
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"LedFlashBrick0992"];
}

- (void)testNyancat
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"Nyancat_1.0_0992"];
}

- (void)testPiano
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"Piano_0992"];
}

- (void)testSolarSystem
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"Solar_System_v1.0_0992"];
}

- (void)testValidHeader
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"ValidHeader0992"];
}

- (void)testValidProgram
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"ValidProgram0992"];
}

@end
