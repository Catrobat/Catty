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

#import <XCTest/XCTest.h>
#import "NSString+CatrobatNSStringExtensions.h"

@interface CustomExtensionsTests : XCTestCase

@end

@implementation CustomExtensionsTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}


- (void) testEscapingHTMLEntities
{
    NSMutableString* testString = [[NSMutableString alloc]initWithFormat:@"entities: &amp; , &quot; , &#x27; , &#x39; , &#x92; , &#x96; , &gt; and &lt; "];
    
    NSRange range = NSMakeRange(0, testString.length);
    
    NSString* compareString =[[NSString alloc]initWithFormat:@"entities: & , \" , ' , ' , ' , ' , > and < "];

    
    NSArray *stringsToReplace = [[NSArray alloc] initWithObjects:   @"&amp;"   ,@"&quot;"  ,@"&#x27;" ,@"&#x39;"
                                 ,@"&#x92;"  ,@"&#x96;"  ,@"&gt;"   ,@"&lt;"    ,nil];
    
    NSArray *stringsReplaceBy = [[NSArray alloc] initWithObjects:   @"&"       ,@"\""      ,@"'"      ,@"'"
                                 ,@"'"       ,@"'"       ,@">"      ,@"<"       ,nil];
    
    
    for (int i =0; i< [stringsReplaceBy count]; i++)
    {
        [testString replaceOccurrencesOfString:[stringsToReplace objectAtIndex:i]
                                withString:[stringsReplaceBy objectAtIndex:i]
                                   options:NSLiteralSearch
                                     range:range];
        range = NSMakeRange(0, testString.length);
    }
    
//    [testString stringByEscapingHTMLEntities];


    
    BOOL check = NO;
    if ([testString isEqualToString:compareString]) {
        
    }
    else{
        check = YES;
    }
//    NSDebug(@"STring1 : %@",testString);
//    NSDebug(@"STring2 : %@",compareString);
    
    XCTAssertFalse(check,@"stringByEscapingHTMLEntities is not correctly replaced");
    
    
}
@end
