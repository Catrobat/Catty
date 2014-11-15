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

#import "UserVariable.h"
#import "GDataXMLNode.h"
#import "Program.h"

@implementation UserVariable

-(NSString*)description
{
    return [NSString stringWithFormat:@"UserVariable: Name: %@, Value: %@", self.name, self.value ];
}

- (GDataXMLElement*)toXMLforObject:(SpriteObject*)spriteObject
{
    GDataXMLElement *userVariableXMLElement = [GDataXMLNode elementWithName:@"userVariable"];
    GDataXMLElement *nameXMLElement = [GDataXMLNode elementWithName:@"name" stringValue:self.name];
    [userVariableXMLElement addChild:nameXMLElement];
    return userVariableXMLElement;
}

- (GDataXMLElement*)toXMLforProgram:(Program*)program
{
    GDataXMLElement *userVariableXMLElement = [GDataXMLNode elementWithName:@"userVariable"];
    [userVariableXMLElement addAttribute:[GDataXMLNode elementWithName:@"reference"
                                                           stringValue:@"../../../../../objectList/object[10]/scriptList/startScript/brickList/setVariableBrick[2]/userVariable"]];
    return userVariableXMLElement;
}

- (BOOL)isEqualToUserVariable:(UserVariable*)userVariable
{
    if([self.name isEqualToString:userVariable.name] && [self.value isEqualToNumber:userVariable.value])
        return YES;
    return NO;
}

@end
