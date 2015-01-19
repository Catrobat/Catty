/**
 *  Copyright (C) 2010-2014 The Catrobat Team
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

#import "CBXMLSerializer.h"
#import "Program+CBXMLHandler.h"
#import "GDataXMLElement+CustomExtensions.h"
#import "CBXMLContext.h"
#import "CatrobatLanguageDefines.h"
#import "CBXMLPositionStack.h"

@interface CBXMLSerializer()

@property (nonatomic, strong) NSString *xmlPath;

@end

@implementation CBXMLSerializer

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

#define SIMULATOR_DEBUGGING_ENABLED 0
#define SIMULATOR_DEBUGGING_BASE_PATH @"/Users/ralph/Desktop/"

#pragma mark - Program serialization
+ (GDataXMLDocument*)xmlDocumentForProgram:(Program*)program
{
    CBXMLContext *context = [CBXMLContext new];
    GDataXMLElement *programElement = [program xmlElementWithContext:context];
    
    // sanity check => stack must contain only one element!!
    // only <program> root-element must remain on the stack!!
    if (context.currentPositionStack.numberOfXmlElements != 1) {
        NSError(@"FATAL! Unable to serialize program. Current position stack contains no or more than \
                1 element but should contain only one element named 'program'");
        abort();
    }
    NSString *remainingXmlElementName = [context.currentPositionStack popXmlElementName];
    if (! [remainingXmlElementName isEqualToString:@"program"]) {
        NSError(@"FATAL! Unable to serialize program. Current position stack contains an element named \
                '%@' but should contain an element with name 'program'", remainingXmlElementName);
        abort();
    }
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:programElement];
    return document;
}

- (void)serializeProgram:(Program*)program
{
    @try {
        NSInfo(@"Saving Program...");
        GDataXMLDocument *document = [[self class] xmlDocumentForProgram:program];
        NSString *xmlString = [NSString stringWithFormat:@"%@\n%@", kCatrobatHeaderXMLDeclaration,
                               [document.rootElement XMLStringPrettyPrinted:YES]];

#if !SIMULATOR_DEBUGGING_ENABLED
        // FIXME: [GDataXMLElement XMLStringPrettyPrinted] always adds "&amp;" to already escaped strings
        //        Unfortunately XMLStringPrettyPrinted only escapes "&" to "&amp;" and ignores all other
        //        invalid characters that have to be escaped. Therefore we can't rely on
        //        the XMLStringPrettyPrinted method. {
        xmlString = [xmlString stringByReplacingOccurrencesOfString:@"&amp;lt;" withString:@"&lt;"];
        xmlString = [xmlString stringByReplacingOccurrencesOfString:@"&amp;gt;" withString:@"&gt;"];
        xmlString = [xmlString stringByReplacingOccurrencesOfString:@"&amp;amp;" withString:@"&amp;"];
        xmlString = [xmlString stringByReplacingOccurrencesOfString:@"&amp;quot;" withString:@"&quot;"];
        xmlString = [xmlString stringByReplacingOccurrencesOfString:@"&amp;apos;" withString:@"&apos;"];
        // }
#else
        xmlString = [xmlString stringByReplacingOccurrencesOfString:@"&amp;lt;" withString:@"<"];
        xmlString = [xmlString stringByReplacingOccurrencesOfString:@"&amp;gt;" withString:@">"];
        xmlString = [xmlString stringByReplacingOccurrencesOfString:@"&amp;amp;" withString:@"&"];
        xmlString = [xmlString stringByReplacingOccurrencesOfString:@"&amp;quot;" withString:@"\""];
        xmlString = [xmlString stringByReplacingOccurrencesOfString:@"&amp;apos;" withString:@"'"];
#endif

        NSLog(@"%@", xmlString);
        NSError *error = nil;

#if SIMULATOR_DEBUGGING_ENABLED
        NSString *referenceXmlString = [NSString stringWithFormat:@"%@\n%@",
                                        kCatrobatHeaderXMLDeclaration,
                                        [program.XMLdocument.rootElement XMLStringPrettyPrinted:YES]];
        NSString *referenceXmlPath = [NSString stringWithFormat:@"%@/original.xml", SIMULATOR_DEBUGGING_BASE_PATH];
        NSString *generatedXmlPath = [NSString stringWithFormat:@"%@/generated.xml", SIMULATOR_DEBUGGING_BASE_PATH];
        [referenceXmlString writeToFile:referenceXmlPath
                             atomically:YES
                               encoding:NSUTF8StringEncoding
                                  error:&error];
        [xmlString writeToFile:generatedXmlPath
                    atomically:YES
                      encoding:NSUTF8StringEncoding
                         error:&error];

        error = nil;
        //#import <Foundation/NSTask.h> // debugging for OSX
        //        NSTask *task = [[NSTask alloc] init];
        //        [task setLaunchPath:@"/usr/bin/diff"];
        //        [task setArguments:[NSArray arrayWithObjects:referenceXmlPath, generatedXmlPath, nil]];
        //        [task setStandardOutput:[NSPipe pipe]];
        //        [task setStandardInput:[NSPipe pipe]]; // piping to NSLog-tty (terminal emulator)
        //        [task launch];
        //        [task release];
#endif

        if(![xmlString writeToFile:self.xmlPath atomically:YES encoding:NSUTF8StringEncoding error:&error])
            NSError(@"Program could not saved to disk! %@", error);

        // update last access time
        [Program updateLastModificationTimeForProgramWithName:program.header.programName
                                                    programID:program.header.programID];
        NSInfo(@"Saving finished...");
    } @catch(NSException *exception) {
        NSError(@"Program could not be loaded! %@", [exception description]);
    }
}

@end
