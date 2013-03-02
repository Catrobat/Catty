//
//  CatrobatBaseCell.m
//  Catty
//
//  Created by Dominik Ziegler on 2/28/13.
//  Copyright (c) 2013 Graz University of Technology. All rights reserved.
//

#import "CatrobatBaseCell.h"


@implementation CatrobatBaseCell

@synthesize seperatorView = _topSeperatorView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}


-(id)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super initWithCoder:aDecoder]) {
        [self initialize];
    }
    
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)initialize {
    self.selectedBackgroundView = [self getSelectedBackground];
    self.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessory"]];
    
    UIImageView *seperator = [self getSeperator];
    [self.contentView addSubview:seperator];
    self.seperatorView = seperator;
}

-(UIView*)getSelectedBackground{
    UIView *bgColorView = [[UIView alloc] init];
    [bgColorView setBackgroundColor:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.15f]];
    return bgColorView;
}

-(UIImageView*)getSeperator {
    UIImageView *seperator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellseperator"]];
    seperator.frame = CGRectMake(0.0f, 0.0f, self.bounds.size.width, 4.0f);
    return seperator;
    
}



@end
