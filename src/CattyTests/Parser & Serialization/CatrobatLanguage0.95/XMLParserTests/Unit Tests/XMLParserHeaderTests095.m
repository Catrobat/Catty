/**
 *  Copyright (C) 2010-2016 The Catrobat Team
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

#import "XMLParserHeaderTests093.h"

@interface XMLParserHeaderTests095 : XMLParserHeaderTests093
@end

@implementation XMLParserHeaderTests095

- (void)setUp
{
    self.parserContext = [[CBXMLParserContext alloc] initWithLanguageVersion:0.95f];
}

- (void)testValidHeader
{
    GDataXMLDocument* xmlRoot = [self getXMLDocumentForPath:[self getPathForXML:@"ValidHeader095"]];
    
    Header *header = [self.parserContext parseFromElement:[[xmlRoot.rootElement elementsForName:@"header"] objectAtIndex:0]
                                                withClass:[Header class]];
    XCTAssertNotNil(header, @"Header is nil");
    
    XCTAssertTrue([header.applicationBuildName isEqualToString: @"applicationBuildName"], @"applicationBuildName not correctly parsed");
    XCTAssertTrue([header.applicationBuildNumber isEqualToString: @"123"], @"applicationBuildNumber not correctly parsed");
    XCTAssertTrue([header.applicationVersion isEqualToString: @"applicationVersion"], @"applicationVersion not correctly parsed");
    XCTAssertTrue([header.catrobatLanguageVersion isEqualToString: @"0.95"], @"catrobatLanguageVersion not correctly parsed");
    
    XCTAssertTrue([[[Header headerDateFormatter] stringFromDate:header.dateTimeUpload] isEqualToString: @"2014-11-0211:00:00"],
                  @"dateTimeUpload not correctly parsed");
    XCTAssertTrue([header.programDescription isEqualToString: @"description"], @"description not correctly parsed");
    XCTAssertTrue([header.deviceName isEqualToString: @"Android SDK built for x86"], @"deviceName not correctly parsed");
    XCTAssertTrue([header.mediaLicense isEqualToString: @"mediaLicense"], @"mediaLicense not correctly parsed");
    XCTAssertTrue([header.platform isEqualToString: @"Android"], @"platform not correctly parsed");
    XCTAssertTrue([header.programLicense isEqualToString: @"programLicense"], @"programLicense not correctly parsed");
    XCTAssertTrue([header.programName isEqualToString: @"programName"], @"programName not correctly parsed");
    XCTAssertTrue([header.remixOf isEqualToString: @"remixOf"], @"remixOf not correctly parsed");
    XCTAssertEqual([header.screenHeight intValue], 1184, @"screenHeight not correctly parsed");
    XCTAssertEqual([header.screenWidth intValue], 768, @"screenWidth not correctly parsed");
    XCTAssertTrue([header.tags isEqualToString: @"tags"], @"tags not correctly parsed");
    XCTAssertTrue([header.url isEqualToString: @"url"], @"url not correctly parsed");
    XCTAssertTrue([header.userHandle isEqualToString: @"userHandle"], @"userHandle not correctly parsed");
}

@end
