//
//  TableUtil.m
//  Catty
//
//  Created by Dominik Ziegler on 3/1/13.
//  Copyright (c) 2013 Graz University of Technology. All rights reserved.
//

#import "TableUtil.h"
#import "Util.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "CatrobatBaseCell.h"

#define kIphone5ScreenHeight 568.0f
#define kContinueCellHeight  124.0f
#define kImageCellHeight     79.0f



@implementation TableUtil

+(CGFloat)getHeightForContinueCell {
    CGFloat screenHeight = [Util getScreenHeight];
    return (kContinueCellHeight*screenHeight)/kIphone5ScreenHeight;
}

+(CGFloat)getHeightForImageCell {
    CGFloat screenHeight = [Util getScreenHeight];
    return (kImageCellHeight*screenHeight)/kIphone5ScreenHeight;
}

+(void)initNavigationItem:(UINavigationItem*)navigationItem withTitle:(NSString*)title enableBackButton:(BOOL)backButtonEnabled target:(id)target{
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"catrobat"]];
    UILabel* titleLabel = [[UILabel alloc] init];
    titleLabel.textColor = [UIColor darkBlueColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    titleLabel.text = title;
    titleLabel.backgroundColor = [UIColor clearColor];
    [titleLabel sizeToFit];
    

    NSMutableArray* barButtonItems = [[NSMutableArray alloc] init];
    
    if(backButtonEnabled) {
        UIBarButtonItem* backButton =  [self createBackButtonWithTarget:target];
        [barButtonItems addObject:backButton];
    } //else { // This looks weird.. 
//        UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
//        fixed.width = 30.0f;
//        [barButtonItems addObject:fixed];
//    }
   
    [barButtonItems addObject:[[UIBarButtonItem alloc] initWithCustomView:imageView]];
    [barButtonItems addObject:[[UIBarButtonItem alloc] initWithCustomView:titleLabel]];
    

    [navigationItem setLeftBarButtonItems:barButtonItems animated:YES];
    

}

+(void)addSeperatorForCell:(CatrobatBaseCell*)cell{
    if(cell.seperatorView == nil) {
        UIImageView *seperator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellseperator"]];
        seperator.frame = CGRectMake(0.0f, 0.0f, cell.bounds.size.width, 4.0f);
        [cell.contentView addSubview:seperator];
        cell.seperatorView = seperator;
    }
}



#pragma mark Helper
+(UIBarButtonItem*)createBackButtonWithTarget:(id)target{
    UIButton *backbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *img = [UIImage imageNamed:@"backbutton"];
    
    backbutton.frame = CGRectMake(20, 100, img.size.width+10, img.size.height);
    
    
    [backbutton setImage:img forState:UIControlStateNormal];
    [backbutton setImage:img forState:UIControlStateHighlighted];
    [backbutton setImage:img forState:UIControlStateSelected];
    [backbutton addTarget:target action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    return [[UIBarButtonItem alloc] initWithCustomView:backbutton];
    

}



@end
