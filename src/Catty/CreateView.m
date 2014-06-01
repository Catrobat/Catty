/**
 *  Copyright (C) 2010-2013 The Catrobat Team
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

#import <QuartzCore/QuartzCore.h>
#import "CreateView.h"
#import "CatrobatProject.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "ImageCache.h"
#import "CAGradientLayer+CatrobatCAGradientExtensions.h"
#import "NSString+CatrobatNSStringExtensions.h"
#import "UIImage+CatrobatUIImageExtensions.h"
#import "ButtonTags.h"
#import "TTTAttributedLabel.h"
#import "EVCircularProgressView.h"
#import "LanguageTranslationDefines.h"
#import "RoundBorderedButton.h"
#import "DownloadImageCache.h"

#define kHTMLATagPattern @"(?i)<a([^>]+)>(.+?)</a>"
#define kHTMLAHrefTagPattern @"href=\"(.*?)\""

@implementation CreateView

+ (UIView*)createProgramDetailView:(CatrobatProject*)project target:(id)target {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0)];
    view.backgroundColor = [UIColor clearColor];
    [view setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    
    [self addNameLabelWithProjectName:project.projectName toView:view];
    [self addAuthorLabelWithAuthor:project.author toView:view];
    [self addProgramDescriptionLabelWithDescription:project.description toView:view target:target];
    [self addThumbnailImageWithImageUrlString:project.screenshotSmall toView:view];
    [self addBigImageWithImageUrlString:project.screenshotBig toView:view];
    [self addDownloadButtonToView:view withTarget:target];
    [self addLoadingButtonToView:view withTarget:target];
    [self addPlayButtonToView:view withTarget:target];
    
    
    NSDate *projectDate = [NSDate dateWithTimeIntervalSince1970:[project.uploaded doubleValue]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    NSString *uploaded = [dateFormatter stringFromDate:projectDate];
    [self addInformationLabelToView:view withAuthor:project.author downloads:project.downloads uploaded:uploaded version:project.version views:project.views];
    
    return view;
    
}

+ (void)addNameLabelWithProjectName:(NSString*)projectName toView:(UIView*)view
{
    UILabel* nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 10, 155, 25)];
    nameLabel.text = projectName;
    [self configureTitleLabel:nameLabel];
    [self setMaxHeightIfGreaterForView:view withHeight:10+25];
        
    [view addSubview:nameLabel];
}

+ (void)addAuthorLabelWithAuthor:(NSString*)author toView:(UIView*)view
{
    
    UILabel* authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 30, 155, 25)];
    authorLabel.text = author;
    [self configureTextLabel:authorLabel];
    [view addSubview:authorLabel];
    [self setMaxHeightIfGreaterForView:view withHeight:30+25];
    
}

+ (CGFloat)addProgramDescriptionLabelWithDescription:(NSString*)description toView:(UIView*)view target:(id)target
{
    UILabel* descriptionTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 95, 155, 25)];
    [self configureTitleLabel:descriptionTitleLabel];
    descriptionTitleLabel.text = kUILabelTextDescription;
    [view addSubview:descriptionTitleLabel];

    description = [description stringByReplacingOccurrencesOfString:@"<br>" withString:@""];
    description = [description stringByReplacingOccurrencesOfString:@"<br />" withString:@""];


    if ((! description) || [description isEqualToString:@""]) {
        description = kUILabelTextNoDescriptionAvailable;
        
    }

    CGSize maximumLabelSize = CGSizeMake(296, FLT_MAX);
//    CGSize expectedSize = [description sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17.0f]}];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:14] forKey:NSFontAttributeName];
    CGRect labelBounds = [description boundingRectWithSize:maximumLabelSize
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:attributes
                                                   context:nil];
    CGSize expectedSize = CGSizeMake(ceilf(labelBounds.size.width), ceilf(labelBounds.size.height));
//    CGSize expectedSize = [description sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:maximumLabelSize lineBreakMode:NSLineBreakByWordWrapping];

    TTTAttributedLabel* descriptionLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(20, 120, 280, expectedSize.height)];
    [self configureDescriptionLabel:descriptionLabel];
    descriptionLabel.delegate = target;
    descriptionLabel.text = description;

    expectedSize = [descriptionLabel.text sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:maximumLabelSize lineBreakMode:NSLineBreakByWordWrapping];
    descriptionLabel.frame = CGRectMake(descriptionLabel.frame.origin.x, descriptionLabel.frame.origin.y, descriptionLabel.frame.size.width, expectedSize.height);
    [view addSubview:descriptionLabel];
    [self setMaxHeightIfGreaterForView:view withHeight:120+expectedSize.height];
    return descriptionLabel.frame.size.height;
}

+ (void)addThumbnailImageWithImageUrlString:(NSString*)imageUrlString toView:(UIView*)view
{
    UIImage* image = [[DownloadImageCache sharedImageCache] getImageWithName:imageUrlString];

    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.frame = CGRectMake(20, 15, 65, 65);

    imageView.layer.cornerRadius = 5.0;
    imageView.layer.masksToBounds = YES;
    imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    imageView.layer.borderWidth = 1.0;

    [view addSubview:imageView];
}

+ (void) addBigImageWithImageUrlString:(NSString*)imageUrlString toView:(UIView*)view
{
    
    UIImageView *imageView = [[UIImageView alloc] init];
    CGFloat offset = view.frame.size.height + 10;
    imageView.frame = CGRectMake(82.5, offset, 155, 235);
    
    imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    imageView.layer.borderWidth = 1.0;
    imageView.layer.masksToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [view addSubview:imageView];
    
    [self setMaxHeightIfGreaterForView:view withHeight:offset + 235];
    
    UIImage* errorImage = [UIImage imageNamed:@"thumbnail_large"];
    imageView.image = [UIImage imageWithContentsOfURL:[NSURL URLWithString:imageUrlString]
                                          placeholderImage:nil
                                          errorImage:errorImage
                                         onCompletion:^(UIImage *image) {
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  [[imageView viewWithTag:kActivityIndicator] removeFromSuperview];
                                                  imageView.image = image;
                                              });
                                         }];
    
    if(!imageView.image) {
        UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        activity.tag = kActivityIndicator;
        activity.frame = CGRectMake(imageView.frame.size.width/2.0f - 25.0f/2.0f, imageView.frame.size.height/2.0f - 25.0f/2.0f, 25.0f, 25.0f);
        [imageView addSubview:activity];
        [activity startAnimating];
    }
    

}

+ (void) addDownloadButtonToView:(UIView*)view withTarget:(id)target
{
    UIButton *downloadButton = [[RoundBorderedButton alloc] initWithFrame:CGRectMake(195, 55, 105, 25)];
    downloadButton.tag = kDownloadButtonTag;
    downloadButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [downloadButton setTitle:kUIButtonTitleDownload forState:UIControlStateNormal];
    [downloadButton setTintColor:[UIColor lightOrangeColor]];

    [downloadButton addTarget:target action:@selector(downloadButtonPressed) forControlEvents:UIControlEventTouchUpInside];

    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activity.tag = kActivityIndicator;
    activity.frame = CGRectMake(5, 0, 25, 25);
    [downloadButton addSubview:activity];
    
    
    [view addSubview:downloadButton];
}

+ (void)addPlayButtonToView:(UIView*)view withTarget:(id)target
{
    UIButton *playButton = [[RoundBorderedButton alloc] initWithFrame:CGRectMake(195, 55, 105, 25)];
    playButton.tag = kPlayButtonTag;
    playButton.hidden = YES;
    playButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [playButton setTitle:kUIButtonTitlePlay forState:UIControlStateNormal];
    [playButton addTarget:target action:@selector(playButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [playButton setTintColor:[UIColor lightOrangeColor]];
   

    [view addSubview:playButton];
}

+(void) addLoadingButtonToView:(UIView*)view withTarget:(id)target
{
    EVCircularProgressView* button = [[EVCircularProgressView alloc] init];
    button.tag =kStopLoadingTag;
    button.tintColor = [UIColor lightOrangeColor];
    button.frame = CGRectMake(235, 55, 28, 28);
    button.hidden = YES;

    [button addTarget:target action:@selector(stopLoading) forControlEvents:UIControlEventTouchUpInside];


    [view addSubview:button];
}

+ (void)addInformationLabelToView:(UIView*)view withAuthor:(NSString*)author downloads:(NSNumber*)downloads uploaded:(NSString*)uploaded version:(NSString*)version views:(NSNumber*)views
{
    CGFloat offset = view.frame.size.height + 10;
    UILabel* informationLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, offset, 155, 25)];
    informationLabel.text = kUILabelTextInformation;
    [self configureTitleLabel:informationLabel];
    [view addSubview:informationLabel];
    offset += 25.0f;

    NSArray* informationArray = [[NSArray alloc] initWithObjects:author, downloads, uploaded, version, views, nil];
    NSArray* informationTitleArray = [[NSArray alloc] initWithObjects:
                                      kUILabelTextAuthor,
                                      kUILabelTextDownloads,
                                      kUILabelTextUploaded,
                                      kUILabelTextVersion,
                                      kUILabelTextViews, nil];
    NSUInteger counter = 0;
    for (id info in informationArray) {
        UILabel* titleLabel = [self getInformationTitleLabelWithTitle:[informationTitleArray objectAtIndex:counter] atYPosition:offset];
        [view addSubview:titleLabel];

        UILabel* infoLabel = [self getInformationDetailLabelWithTitle:info atYPosition:offset];
        [view addSubview:infoLabel];

        offset += 25.0f;
        ++counter;
    }
    [self setMaxHeightIfGreaterForView:view withHeight:offset];
}

+ (void) addShadowToTitleLabelForButton:(UIButton*)button
{
    button.titleLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    button.titleLabel.layer.shadowOpacity = 0.3f;
    button.titleLabel.layer.shadowRadius = 1;
    button.titleLabel.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
}


+ (void) configureTitleLabel:(UILabel*)label
{
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:16];
    label.textColor = [UIColor blueGrayColor];
    label.layer.shadowColor = [[UIColor whiteColor] CGColor];
    label.layer.shadowOffset = CGSizeMake(0.0, 0.0);
}


+ (void) configureTextLabel:(UILabel*)label
{
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor blueGrayColor];
    label.layer.shadowColor = [[UIColor whiteColor] CGColor];
    label.layer.shadowOffset = CGSizeMake(0.0, 0.0);
}


+ (UILabel*)getInformationTitleLabelWithTitle:(NSString*)title atYPosition:(CGFloat)yPosition
{
    UILabel* titleInformationLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, yPosition, 80, 25)];
    titleInformationLabel.text = title;
    titleInformationLabel.textAlignment = NSTextAlignmentRight;
    titleInformationLabel.backgroundColor = [UIColor clearColor];
    titleInformationLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    titleInformationLabel.textColor = [UIColor grayColor];
    return titleInformationLabel;
}

+ (UILabel*)getInformationDetailLabelWithTitle:(NSString*)title atYPosition:(CGFloat)yPosition
{
    UILabel* detailInformationLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, yPosition, 155, 25)];
    detailInformationLabel.text =  [title stringByEscapingHTMLEntities];;
    detailInformationLabel.textColor = [UIColor blueGrayColor];
    detailInformationLabel.font = [UIFont systemFontOfSize:14.0f];
    detailInformationLabel.backgroundColor = [UIColor clearColor];
    return detailInformationLabel;
}

+ (void)setMaxHeightIfGreaterForView:(UIView*)view withHeight:(CGFloat)height
{
    CGRect frame = view.frame;
    if(frame.size.height < height) {
        frame.size.height = height;
        view.frame = frame;
    }
}

+ (void)configureDescriptionLabel:(TTTAttributedLabel*)label
{
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 0;
    [self configureTextLabel:label];
    label.enabledTextCheckingTypes = NSTextCheckingAllTypes;
    label.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
    
    NSMutableDictionary *mutableLinkAttributes = [NSMutableDictionary dictionary];
    [mutableLinkAttributes setObject:[UIColor brightGrayColor] forKey:(NSString*)kCTForegroundColorAttributeName];
    [mutableLinkAttributes setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCTUnderlineStyleAttributeName];
    
    NSMutableDictionary *mutableActiveLinkAttributes = [NSMutableDictionary dictionary];
    [mutableActiveLinkAttributes setObject:[UIColor whiteColor] forKey:(NSString*)kCTForegroundColorAttributeName];
    [mutableActiveLinkAttributes setObject:[NSNumber numberWithBool:NO] forKey:(NSString *)kCTUnderlineStyleAttributeName];
        
    label.linkAttributes = mutableLinkAttributes;
    label.activeLinkAttributes = mutableActiveLinkAttributes;
}

+ (void)parseHyperlinksForLabel:(TTTAttributedLabel*)label withText:(NSString*)text
{
    NSError* error = nil;
    NSRegularExpression *aTagRegex = [NSRegularExpression regularExpressionWithPattern:kHTMLATagPattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *aTags = [aTagRegex matchesInString:text options:0 range:NSMakeRange(0, [text length])];
    NSRegularExpression *aHrefRegex = [NSRegularExpression regularExpressionWithPattern:kHTMLAHrefTagPattern options:NSRegularExpressionCaseInsensitive error:&error];

    NSMapTable* urlRangeMapTable = [NSMapTable strongToStrongObjectsMapTable];

    for (NSInteger index = ([aTags count] - 1); index >= 0; --index) {
        NSTextCheckingResult* result = [aTags objectAtIndex:index];
        NSString* href = [text substringWithRange:[result rangeAtIndex:1]];
        NSString* name = [text substringWithRange:[result rangeAtIndex:2]];

        NSTextCheckingResult* urlResult = [aHrefRegex firstMatchInString:href options:0 range:NSMakeRange(0, [href length])];
        NSString* url = [href substringWithRange:[urlResult rangeAtIndex:1]];

        NSRange resultRange = [result range];
        NSUInteger offset = text.length;
        text = [text stringByReplacingCharactersInRange:resultRange withString:name];
        offset -= text.length;

        NSEnumerator *enumerator = [urlRangeMapTable keyEnumerator];
        NSArray* keys = [enumerator allObjects];

        for (NSString* key in keys) {
            NSRange nameRange = [[urlRangeMapTable objectForKey:key ] rangeValue];
            nameRange.location = nameRange.location-offset;
            [urlRangeMapTable setObject:[NSValue valueWithRange:nameRange] forKey:key];
        }

        NSRange nameRange = NSMakeRange(resultRange.location, name.length);
        [urlRangeMapTable setObject:[NSValue valueWithRange:nameRange] forKey:url];
    }

    label.text = text;
    for (NSString* url in urlRangeMapTable) {
        NSRange nameRange = [[urlRangeMapTable objectForKey:url ] rangeValue];
        [label addLinkToURL:[NSURL URLWithString:url] withRange:nameRange];
    }
}


@end
