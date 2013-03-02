//
//  TableUtil.h
//  Catty
//
//  Created by Dominik Ziegler on 3/1/13.
//  Copyright (c) 2013 Graz University of Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CatrobatBaseCell;

@interface TableUtil : NSObject


+(CGFloat)getHeightForContinueCell;
+(CGFloat)getHeightForImageCell;
+(void)initNavigationItem:(UINavigationItem*)navigationItem withTitle:(NSString*)title enableBackButton:(BOOL)backButtonEnabled target:(id)target;
+(void)addSeperatorForCell:(CatrobatBaseCell*)cell atYPosition:(CGFloat)y;

@end
