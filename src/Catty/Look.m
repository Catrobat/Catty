/**
 *  Copyright (C) 2010-2013 The Catrobat Team
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


#import "Look.h"
#import "ProgramDefines.h"
#import "GDataXMLNode.h"

@interface Look ()
@end

@implementation Look

@synthesize fileName = _costumeFileName;
@synthesize name = _costumeName;

#pragma mark - init methods
- (id)initWithPath:(NSString*)filePath
{
    self = [super init];
    if (self) {
        self.name = nil;
        if (filePath == nil || [filePath length] == 0) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:@"You cannot instantiate a costume without a file path"
                                         userInfo:nil];
            return nil;
        } else {
            self.fileName = filePath;
        }
    }
    return self;
}

- (id)initWithName:(NSString*)name andPath:(NSString*)filePath
{
    self = [super init];
    if (self) {
        self.name = name;
        if (filePath == nil || [filePath length] == 0) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:@"You cannot instantiate a costume without a file path"
                                         userInfo:nil];
            return nil;
        } else {
            self.fileName = filePath;
        }
    }
    return self;
}

- (NSString*)previewImageFileName
{
    // e.g. 34A109A82231694B6FE09C216B390570_normalCat
    NSRange result = [self.fileName rangeOfString:kResourceFileNameSeparator];
    if ((result.location == NSNotFound) || (result.location == 0) || (result.location >= ([self.fileName length]-1)))
        return nil; // Invalid file name convention -> this should not happen. XXX/FIXME: maybe we want to abort here??

    return [NSString stringWithFormat:@"%@_%@%@",
        [self.fileName substringToIndex:result.location],
        kPreviewImageNamePrefix,
        [self.fileName substringFromIndex:(result.location + 1)]
    ];
}

- (instancetype)deepCopy
{
    Look *copiedLook = [[Look alloc] init];
    copiedLook.fileName = [NSString stringWithString:self.fileName];
    copiedLook.name = [NSString stringWithString:self.name];
    return copiedLook;
}

- (GDataXMLElement*)toXML
{
    GDataXMLElement *lookXMLElement = [GDataXMLNode elementWithName:@"look"];
    [lookXMLElement addChild:[GDataXMLElement elementWithName:@"fileName" stringValue:self.fileName]];
    [lookXMLElement addChild:[GDataXMLElement elementWithName:@"name" stringValue:self.name]];
    return lookXMLElement;
}

#pragma mark - description
- (NSString*)description
{
    return [NSString stringWithFormat:@"Name: %@\rPath: %@\r", self.name, self.fileName];
}

@end
