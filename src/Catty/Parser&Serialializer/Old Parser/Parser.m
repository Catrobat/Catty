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

#import "Parser.h"
#import "ProjectParser.h"
#import "SpriteObject.h"
#import "Script.h"
#import "Program+CustomExtensions.h"

@implementation Parser

- (Program*)generateObjectForProgramWithPath:(NSString*)path
{
    // sanity check
    if (! path || [path isEqualToString:@""]) {
        NSDebug(@"Path (%@) is NOT valid!", path);
        return nil;
    }
    
    NSError *error;
    //open xml file
    NSString *xmlFile = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    
    // sanity check
    if (error) { return nil; }
    
    NSData* xmlData = [xmlFile dataUsingEncoding:NSUTF8StringEncoding];
    
    //using dom parser (gdata)
    ProjectParser *parser = [[ProjectParser alloc] init];
    
    // return Project object
    Program *program = [parser loadProject:xmlData];
    [program updateReferences];
    return program;
}

@end
