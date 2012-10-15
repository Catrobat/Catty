//
//  CustomExtensions.h
//  Catty
//
//  Created by Dominik Ziegler on 10/10/12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

@interface NSString (CustomExtensions)
- (NSString *) md5;
@end

@interface NSData (CustomExtensions)
- (NSString*)md5;
@end
