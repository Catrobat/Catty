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

#import <XCTest/XCTest.h>
#import "XMLAbstractTest.h"
#import "CBXMLParser.h"
#import "GDataXMLElement+CustomExtensions.h"
#import "UIDefines.h"
#import "Program.h"
#import "Look.h"
#import "Sound.h"
#import "Script.h"
#import "Brick.h"
#import "CatrobatLanguageDefines.h"
#import "Program+CustomExtensions.h"
#import "CBXMLContext.h"
#import "CBXMLOpenedNestingBricksStack.h"
#import "CBXMLValidator.h"
#import "CBXMLLogger.h"
#import "Header+CBXMLHandler.h"
#import "SpriteObject+CBXMLHandler.h"
#import "VariablesContainer+CBXMLHandler.h"
#import "Script+CBXMLHandler.h"
#import "UserVariable+CBXMLHandler.h"
#import "Formula+CBXMLHandler.h"
#import "FormulaElement+CBXMLHandler.h"
#import "SetLookBrick+CBXMLHandler.h"
#import "SetSizeToBrick+CBXMLHandler.h"
#import "SetVariableBrick+CBXMLHandler.h"
#import "ForeverBrick+CBXMLHandler.h"
#import "LoopEndBrick+CBXMLHandler.h"
#import "PlaceAtBrick+CBXMLHandler.h"
#import "WaitBrick+CBXMLHandler.h"
#import "ShowBrick+CBXMLHandler.h"
#import "SetLookBrick+CBXMLHandler.h"
#import "GlideToBrick+CBXMLHandler.h"
#import "HideBrick+CBXMLHandler.h"
#import "PlaySoundBrick+CBXMLHandler.h"
#import "SetXBrick+CBXMLHandler.h"
#import "SetYBrick+CBXMLHandler.h"
#import "ChangeXByNBrick+CBXMLHandler.h"
#import "ChangeYByNBrick+CBXMLHandler.h"
#import "MoveNStepsBrick+CBXMLHandler.h"
#import "TurnLeftBrick+CBXMLHandler.h"
#import "TurnRightBrick+CBXMLHandler.h"
#import "PointInDirectionBrick+CBXMLHandler.h"
#import "PointToBrick+CBXMLHandler.h"
#import "StopAllSoundsBrick+CBXMLHandler.h"

@class GDataXMLDocument;

@interface XMLParserAbstractTest : XMLAbstractTest

- (NSString*)getPathForXML: (NSString*)xmlFile;
- (GDataXMLDocument*)getXMLDocumentForPath: (NSString*)xmlPath;
- (void)compareProgram:(NSString*)programName092 withProgram:(NSString*)programName093;

@end
