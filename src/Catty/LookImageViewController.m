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

#import "LookImageViewController.h"
#import "UIColor+CatrobatUIColorExtensions.h"

@interface LookImageViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation LookImageViewController

#pragma mark - getters and setters
- (void)loadImage
{
    if (self.imageView) {
        if (self.imagePath) {
            dispatch_queue_t imageLoadQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
            dispatch_async(imageLoadQueue, ^{
                UIImage *image = [[UIImage alloc] initWithContentsOfFile:self.imagePath];
                // perform UI stuff on main queue (UIKit is not thread safe!!)
                dispatch_sync(dispatch_get_main_queue(), ^{
                    // only update the image if we're still on screen
                    if (self.imageView.window) {
                        self.imageView.image = image;
                        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
                        self.imageView.clipsToBounds = YES;
                        self.imageView.frame = self.scrollView.bounds;
                        self.scrollView.contentSize = CGSizeMake(self.imageView.frame.size.width, self.imageView.frame.size.height);
                        self.scrollView.maximumZoomScale = 2.0;
                        self.scrollView.minimumZoomScale = 1.0;
                        self.scrollView.delegate = self;
                    }
                });
            });
        } else {
            self.imageView.image = nil;
        }
    }
}

- (void)setImagePath:(NSString*)imagePath
{
    if (! [_imagePath isEqual:imagePath]) {
        _imagePath = imagePath;
        // we're on screen, so update the image
        if (self.imageView.window) {
            [self loadImage];
        } else {
            // we're not on screen, so no need to loadImage (it will happen next viewWillAppear:)
            // but image has changed (so we can't leave imageView.image the same, so set to nil)
            self.imageView.image = nil;
        }
    }
}

#pragma mark - view events
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIColor *backgroundColor = [UIColor darkBlueColor];
    self.view.backgroundColor = backgroundColor;
    self.imageView.backgroundColor = backgroundColor;
    self.navigationController.toolbar.hidden = YES;
    if ((! self.imageView.image) && self.imagePath) {
        [self loadImage];
    }
    self.navigationController.title = self.title = self.imageName;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.toolbar.hidden = NO;
}

- (void)viewDidUnload
{
    self.imageView = nil;
    [super viewDidUnload];
}

#pragma mark - scroll view delegates
- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

@end
