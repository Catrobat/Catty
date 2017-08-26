/**
 *  Copyright (C) 2010-2017 The Catrobat Team
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

#import "ImagePicker.h"
#import "UIImage+CatrobatUIImageExtensions.h"
#import <Photos/Photos.h>
#import "UIImage+Rotate.h"
#import "Pocket_Code-Swift.h"

@implementation ImagePicker

- (id) initWithDrawViewCanvas:(PaintViewController *)canvas
{
  self = [super init];
  if(self)
  {
    self.canvas = canvas;
  }
  return self;
}

- (void)settingsActionTapped {
    if ([self.canvas.delegate respondsToSelector:@selector(addPaintedImage:andPath:)]) {
        if (self.canvas.editingPath) {
            [self.canvas.delegate addPaintedImage:self.canvas.saveView.image andPath:self.canvas.editingPath];
        } else {
            [self.canvas.delegate addPaintedImage:self.canvas.saveView.image andPath:@"settings"];
        }
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

- (void)cameraImagePickerAction
{
    //IMAGEPICKER CAMERA
    if ([self checkUserAuthorisation:UIImagePickerControllerSourceTypeCamera]) {
        if([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusAuthorized){
            [self openPicker:UIImagePickerControllerSourceTypeCamera];
        }
        else {
            [[[[[AlertControllerBuilder alertWithTitle:nil message:kLocalizedNoAccesToCameraCheckSettingsDescription]
             addCancelActionWithTitle:kLocalizedCancel handler:nil]
             addDefaultActionWithTitle:kLocalizedSettings handler:^{
                 [self settingsActionTapped];
             }] build]
             showWithController:self.canvas];
        }
    }
}

- (void)imagePickerAction
{
    //IMAGEPICKER CameraRoll
    if ([self checkUserAuthorisation:UIImagePickerControllerSourceTypePhotoLibrary]) {
        if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
            [self openPicker:UIImagePickerControllerSourceTypePhotoLibrary];
        }
        else {
            [[[[[AlertControllerBuilder alertWithTitle:nil message:kLocalizedNoAccesToImagesCheckSettingsDescription]
             addCancelActionWithTitle:kLocalizedCancel handler:nil]
             addDefaultActionWithTitle:kLocalizedSettings handler:^{
                 [self settingsActionTapped];
             }] build]
             showWithController:self.canvas];
        }
    }
}

#pragma mark imagePicker delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
  
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if (! image) {
        image = info[UIImagePickerControllerOriginalImage];
    }
    image = [image fixOrientation];
    if (! image) {
        return;
    }
    image = [UIImage imageWithImage:image
                   scaledToMaxWidth:self.canvas.saveView.frame.size.width
                          maxHeight:self.canvas.saveView.frame.size.height];
  [self.canvas setImagePickerImage:image];
  
  [picker dismissViewControllerAnimated:YES completion:NULL];
  
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
  
  [picker dismissViewControllerAnimated:YES completion:NULL];
  
}

- (BOOL)checkUserAuthorisation:(UIImagePickerControllerSourceType)pickerType
{
    
    
    BOOL state = NO;
    
    if(pickerType == UIImagePickerControllerSourceTypePhotoLibrary)
    {
        if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined) {
            
            PHFetchOptions *allPhotosOptions = [PHFetchOptions new];
            allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
            
            PHFetchResult *allPhotosResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:allPhotosOptions];
            [allPhotosResult enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
                NSDebug(@"asset %@", asset);
                if (*stop) {
                    [self openPicker:pickerType];
                    return;
                }
                *stop = TRUE;
            }];
        }else{
            state = YES;
        }
    }else if (pickerType == UIImagePickerControllerSourceTypeCamera)
    {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if(authStatus == AVAuthorizationStatusNotDetermined){
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if(granted){
                    [self openPicker:pickerType];
                    return;
                }
            }];
        }else{
            state = YES;
        }
    }
    return state;
}

- (void)openPicker:(UIImagePickerControllerSourceType)pickerType
{
    if ([UIImagePickerController isSourceTypeAvailable:pickerType]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = pickerType;
        picker.navigationBar.tintColor = [UIColor navTintColor];
        
        [self.canvas presentViewController:picker animated:YES completion:NULL];
    } else {
        [Util alertWithText:pickerType == UIImagePickerControllerSourceTypeCamera ? kLocalizedNoCamera : kLocalizedImagePickerSourceNotAvailable];
    }
}


@end
