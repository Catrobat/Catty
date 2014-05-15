//
//  PlaceHolderView.m
//  Catty
//
//  Created by luca on 07/05/14.
//
//

#import "PlaceHolderView.h"
#import "UIDefines.h"
#import "UIColor+CatrobatUIColorExtensions.h"

@interface PlaceHolderView ()
@property (nonatomic, strong) UILabel *placeholderDescriptionLabel;

@end


@implementation PlaceHolderView

- (id)initWithTitle:(NSString *)tile
{
    if (self = [super init]) {
        _title = tile;
        [self initPlaceHolderView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initPlaceHolderView];
    }
    return self;
}

- (void)initPlaceHolderView
{
    self.userInteractionEnabled = NO;
    _placeholderDescriptionLabel = [UILabel new];
    _placeholderDescriptionLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
                                                        UIViewAutoresizingFlexibleRightMargin |
                                                        UIViewAutoresizingFlexibleTopMargin |
                                                        UIViewAutoresizingFlexibleBottomMargin;
    _placeholderDescriptionLabel.textAlignment = NSTextAlignmentCenter;
    [_placeholderDescriptionLabel setFont:[UIFont systemFontOfSize:25]];
    _placeholderDescriptionLabel.text = [NSString stringWithFormat:kUIViewControllerPlaceholderDescriptionStandard,
                                             _title];
    _placeholderDescriptionLabel.backgroundColor = UIColor.clearColor;
    _placeholderDescriptionLabel.textColor = UIColor.skyBlueColor;
    self.contentView = _placeholderDescriptionLabel;
    self.shimmering = YES;
}

- (void)setTitle:(NSString *)title
{
    if (title.length) {
        self.placeholderDescriptionLabel.text = [NSString stringWithFormat:kUIViewControllerPlaceholderDescriptionStandard,
                                                 title];
    }
}

@end
