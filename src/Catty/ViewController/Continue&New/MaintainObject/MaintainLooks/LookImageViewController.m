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

#import "LookImageViewController.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "TableUtil.h"
#import "RuntimeImageCache.h"
#import "ProgramDefines.h"
#import "LanguageTranslationDefines.h"

@interface LookImageViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic,strong)UIImage* paintImage;
@property (nonatomic,strong)NSString* paintImagePath;
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


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor backgroundColor];
    self.imageView.backgroundColor = [UIColor backgroundColor];
    self.navigationController.toolbar.hidden = YES;
    self.navigationController.title = self.title = self.imageName;
    UIBarButtonItem *editButtonItem = [TableUtil editButtonItemWithTarget:self action:@selector(editAction)];
    self.navigationItem.rightBarButtonItem = editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ((! self.imageView.image) && self.imagePath) {
        [self loadImage];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.toolbar.hidden = NO;
}

#pragma mark - scroll view delegates
- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}


- (void)editAction
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
    PaintViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"paint"];
    vc.delegate = self;
    self.imageView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor clearColor];
    UIGraphicsBeginImageContextWithOptions(self.imageView.frame.size, NO, 0.0);
    [self.imageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.view.backgroundColor = [UIColor backgroundColor];
    self.imageView.backgroundColor = [UIColor backgroundColor];
    vc.editingImage = img;
//    NSDebug(@"%@",img);
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark paintDelegate

- (void)showSavePaintImageAlert:(UIImage *)image andPath:(NSString *)path
{
    self.paintImage = image;
    self.paintImagePath = path;
    [Util confirmAlertWithTitle:kLocalizedSaveToPocketCode message:kLocalizedPaintSaveChanges delegate:self tag:0];
}
#pragma mark - alert delegate
- (void)alertView:(CatrobatAlertController*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != 0) {
            //        NSDebug(@"yes");
        if (self.paintImagePath && self.paintImage) {
            [self addPaintedImage:self.paintImage andPath:self.paintImagePath];
        }
    }
}

#pragma mark paintDelegate
- (void)addPaintedImage:(UIImage *)image andPath:(NSString *)path
{
    self.imageView.image = image;

    NSData *imageData = UIImagePNGRepresentation(image);
    NSDebug(@"Writing file to disk");
        // leaving the main queue here!
    NSBlockOperation* saveOp = [NSBlockOperation blockOperationWithBlock:^{
            // save image to programs directory
        [imageData writeToFile:self.imagePath atomically:YES];
    }];
        // completion block is NOT executed on the main queue
    [saveOp setCompletionBlock:^{
            // execute this on the main queue
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{

        }];
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:saveOp];
    
    NSString *imageDirPath = [[self.spriteObject projectPath] stringByAppendingString:kProgramImagesDirName];
    NSString * fileName = [self.imagePath stringByReplacingOccurrencesOfString:imageDirPath withString:@""];
    NSRange result = [fileName rangeOfString:kResourceFileNameSeparator];

    if ((result.location == NSNotFound) || (result.location == 0) || (result.location >= ([fileName length]-1)))
        abort();
        return;
    
    NSString *previewImageName =  [NSString stringWithFormat:@"%@_%@%@",
            [fileName substringToIndex:result.location],
            kPreviewImageNamePrefix,
            [fileName substringFromIndex:(result.location + 1)]
            ];

    RuntimeImageCache *cache = [RuntimeImageCache sharedImageCache];
    NSString *filePath = [NSString stringWithFormat:@"%@%@", imageDirPath, previewImageName];
    [cache overwriteThumbnailImageFromDiskWithThumbnailPath:filePath image:image thumbnailFrameSize:CGSizeMake(kPreviewImageWidth, kPreviewImageHeight)];
    
    
    [cache replaceImage:image withName:filePath];
    

}

@end
