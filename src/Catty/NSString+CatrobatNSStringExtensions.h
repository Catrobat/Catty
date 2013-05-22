//
//  CustomExtensions.h
//  Catty
//
//  Created by Dominik Ziegler on 10/10/12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

@interface NSString (CatrobatNSStringExtensions) <NSXMLParserDelegate>

- (NSString*) sha1;

- (NSString*) stringByEscapingHTMLEntities;

- (BOOL)containsString:(NSString*)string;

@end




