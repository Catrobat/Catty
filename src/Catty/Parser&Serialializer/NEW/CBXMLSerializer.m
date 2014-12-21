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

//#define SIMULATOR_DEBUGGING_ENABLED 1
//#define SIMULATOR_DEBUGGING_BASE_PATH @"/Users/ralph/Desktop/diff"

#pragma mark - Program serialization
- (void)serializeProgram:(Program*)program
{
    @try {
        NSInfo(@"Saving Program...");
        CBXMLContext *context = [CBXMLContext new];
        GDataXMLElement *programElement = [program xmlElementWithContext:context];
        GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:programElement];
        NSString *xmlString = [NSString stringWithFormat:@"%@\n%@", kCatrobatHeaderXMLDeclaration,
                               [document.rootElement XMLStringPrettyPrinted:YES]];
        NSError *error = nil;
        [xmlString writeToFile:self.xmlPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
        // update last access time
        [Program updateLastModificationTimeForProgramWithName:program.header.programName
                                                    programID:program.header.programID];
        NSLogError(error);
        NSInfo(@"Saving finished...");
    } @catch(NSException *exception) {
        NSError(@"Program could not be loaded! %@", [exception description]);
    }

     //#ifdef SIMULATOR_DEBUGGING_ENABLED
     //        NSString *referenceXmlString = [NSString stringWithFormat:@"%@\n%@",
     //                                        kCatrobatXMLDeclaration,
     //                                        [self.XMLdocument.rootElement XMLStringPrettyPrinted:YES]];
     ////        NSLog(@"Reference XML-Document:\n\n%@\n\n", referenceXmlString);
     ////        NSLog(@"XML-Document:\n\n%@\n\n", xmlString);
     //        NSString *referenceXmlPath = [NSString stringWithFormat:@"%@/reference.xml", SIMULATOR_DEBUGGING_BASE_PATH];
     //        NSString *generatedXmlPath = [NSString stringWithFormat:@"%@/generated.xml", SIMULATOR_DEBUGGING_BASE_PATH];
     //        [referenceXmlString writeToFile:referenceXmlPath
     //                             atomically:YES
     //                               encoding:NSUTF8StringEncoding
     //                                  error:&error];
     //        [xmlString writeToFile:generatedXmlPath
     //                    atomically:YES
     //                      encoding:NSUTF8StringEncoding
     //                         error:&error];
     //
     ////#import <Foundation/NSTask.h> // debugging for OSX
     ////        NSTask *task = [[NSTask alloc] init];
     ////        [task setLaunchPath:@"/usr/bin/diff"];
     ////        [task setArguments:[NSArray arrayWithObjects:referenceXmlPath, generatedXmlPath, nil]];
     ////        [task setStandardOutput:[NSPipe pipe]];
     ////        [task setStandardInput:[NSPipe pipe]]; // piping to NSLog-tty (terminal emulator)
     ////        [task launch];
     ////        [task release];
     //#endif
}

@end
