/**
 *  Copyright (C) 2010-2015 The Catrobat Team
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

#import "XMLAbstractTest.h"
#import "GDataXMLElement+CustomExtensions.h"
#import "CBXMLParser.h"

@implementation XMLAbstractTest

- (NSString*)getPathForXML:(NSString*)xmlFile
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:xmlFile ofType:@"xml"];
    return path;
}

- (GDataXMLDocument*)getXMLDocumentForPath:(NSString*)xmlPath
{
    NSError *error;
    NSString *xmlFile = [NSString stringWithContentsOfFile:xmlPath
                                                  encoding:NSUTF8StringEncoding
                                                     error:&error];
    NSData *xmlData = [xmlFile dataUsingEncoding:NSUTF8StringEncoding];
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];
    return document;
}

- (Program*)getProgramForXML:(NSString*)xmlFile
{
    CBXMLParser *parser = [[CBXMLParser alloc] initWithPath:[self getPathForXML:xmlFile]];
    Program *program = [parser parseAndCreateProgram];
    return program;
}

@end
