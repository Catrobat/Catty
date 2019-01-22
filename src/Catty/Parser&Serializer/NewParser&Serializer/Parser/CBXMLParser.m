/**
 *  Copyright (C) 2010-2019 The Catrobat Team
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

#import "CBXMLParser.h"
#import "GDataXMLNode.h"
#import "Project+CBXMLHandler.h"
#import "Project+CustomExtensions.h"
#import "CBXMLParserContext.h"
#import "Util.h"

// NEVER MOVE THESE DEFINE CONSTANTS TO ANOTHER (HEADER) FILE
#define kCatrobatXMLParserMinSupportedLanguageVersion 0.93f
#define kCatrobatXMLParserMaxSupportedLanguageVersion [[Util catrobatLanguageVersion] floatValue]

@interface CBXMLParser()

@property (nonatomic, strong) NSString *xmlPath;
@property (nonatomic, strong) NSString *xmlContent;

@end

@implementation CBXMLParser

#pragma mark - Initialization
- (id)initWithPath:(NSString*)path
{
    if (self = [super init]) {
        // sanity check
        if (! path || [path isEqualToString:@""]) {
            NSLog(@"Path (%@) is NOT valid!", path);
            return nil;
        }
        self.xmlPath = path;
    }
    return self;
}

- (id)initWithXMLContent:(NSString*)xmlContent
{
    if (self = [super init]) {
        self.xmlContent = xmlContent;
    }
    return self;
}

#pragma mark - Supported versions
- (BOOL)isSupportedLanguageVersion:(CGFloat)languageVersion
{
    return ((languageVersion >= kCatrobatXMLParserMinSupportedLanguageVersion)
            && (languageVersion <= kCatrobatXMLParserMaxSupportedLanguageVersion));
}

#pragma mark - Project parsing
- (Project*)parseAndCreateProject
{
    NSError *error;
    NSString *xmlFile;

    if (self.xmlContent) {
        xmlFile = self.xmlContent;
    } else {
        xmlFile = [NSString stringWithContentsOfFile:self.xmlPath
                                                  encoding:NSUTF8StringEncoding
                                                     error:&error];
    }

    // sanity check
    if (error) {
        NSError(@"XML file could not be loaded!");
        return nil;
    }

    NSDebug(@"%@", xmlFile);
    NSData *xmlData = [xmlFile dataUsingEncoding:NSUTF8StringEncoding];

    // sanity check
    if (! xmlData) {
        NSError(@"XML file could not be loaded!");
        return nil;
    }

    error = nil;
    GDataXMLDocument *xmlDocument = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];

    // sanity check
    if (error || (! xmlDocument)) { return nil; }

    Project *project = nil;
    @try {
        CGFloat languageVersion = [Util detectCBLanguageVersionFromXMLWithPath:self.xmlPath];
        NSInfo(@"Parsing Project with CatrobatLanguageVersion %g...", languageVersion);
        CBXMLParserContext *parserContext = [[CBXMLParserContext alloc]
                                             initWithLanguageVersion:languageVersion];
        project = [parserContext parseFromElement:xmlDocument.rootElement withClass:[Project class]];
        project.unsupportedElements = parserContext.unsupportedElements;
        NSInfo(@"Parsing finished...");
    } @catch(NSException *exception) {
        NSError(@"Project could not be loaded! %@", [exception description]);
        return nil;
    }
    [project updateReferences];
    return project;
}

@end
