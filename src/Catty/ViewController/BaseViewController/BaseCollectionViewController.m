/**
 *  Copyright (C) 2010-2015 The Catrobat Team
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

#import "BaseCollectionViewController.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "TableUtil.h"
#import "UIDefines.h"
#import "Util.h"
#import "ActionSheetAlertViewTags.h"
#import "LanguageTranslationDefines.h"
#import <tgmath.h>
#import "CatrobatAlertView.h"
#import "LoadingView.h"
#import "BDKNotifyHUD.h"
#import "PlaceHolderView.h"
#import "KeychainUserDefaultsDefines.h"


#import <CoreBluetooth/CoreBluetooth.h>
#import "SensorHandler.h"
#import <AudioToolbox/AudioToolbox.h>

@class BluetoothPopupVC;

@interface BaseCollectionViewController ()

@end

@implementation BaseCollectionViewController

- (PlaceHolderView*)placeHolderView
{
    if (!_placeHolderView) {
        _placeHolderView = [[PlaceHolderView alloc] initWithFrame:self.collectionView.bounds];
        [self.view insertSubview:_placeHolderView aboveSubview:self.collectionView];
        _placeHolderView.hidden = YES;
    }
    return _placeHolderView;
}

- (void)showPlaceHolder:(BOOL)show
{
    self.collectionView.alwaysBounceVertical = self.placeHolderView.hidden = (! show);
}

- (void)playSceneAction:(id)sender
{
    [self playSceneAction:sender animated:YES];
}

- (void)playSceneAction:(id)sender animated:(BOOL)animated;
{
    if ([self respondsToSelector:@selector(stopAllSounds)]) {
        [self performSelector:@selector(stopAllSounds)];
    }
    
    self.scenePresenterViewController = [ScenePresenterViewController new];
    self.scenePresenterViewController.program = [Program programWithLoadingInfo:[Util lastUsedProgramLoadingInfo]];
    NSInteger resources = [self.scenePresenterViewController.program getRequiredResources];
    if ([self checkResources:resources]) {
        [self startSceneWithVC:self.scenePresenterViewController];
    }
}

-(void)startSceneWithVC:(ScenePresenterViewController*)vc
{
    [self.navigationController setToolbarHidden:YES animated:YES];
    [self.navigationController pushViewController:vc animated:YES];
}

-(BOOL)checkResources:(NSInteger)requiredResources
{
    NSString *notAvailable = @"";
    NSMutableArray *bluetoothArray = [NSMutableArray new];
    if ((requiredResources & kTextToSpeech) > 0) {
        //intern iOS AVSpeechSynthesizer always available
    }
    
    if ((requiredResources & kFaceDetection) > 0) {
        [[SensorHandler sharedSensorHandler] faceDetectionInit];
    }
    
    if ((requiredResources & kVibration) > 0) {
        NSInteger available = kSystemSoundID_Vibrate;
        if (!available) {
            if([notAvailable isEqualToString:@""]){
                notAvailable = [NSString stringWithFormat:@"%@",kLocalizedVibration];
            } else {
                notAvailable = [NSString stringWithFormat:@"%@,%@",notAvailable,kLocalizedVibration];
            }
        }
    }
    if ((requiredResources & kLocation) > 0) {
        if (![[SensorHandler sharedSensorHandler] locationAvailable]) {
            if([notAvailable isEqualToString:@""]){
                notAvailable = [NSString stringWithFormat:@"%@",kLocalizedSensorCompass];
            } else {
                notAvailable = [NSString stringWithFormat:@"%@,%@",notAvailable,kLocalizedSensorCompass];
            }
        }
    }
    if ((requiredResources & kAccelerometer) > 0) {
        if (![[SensorHandler sharedSensorHandler] accelerometerAvailable]) {
            if([notAvailable isEqualToString:@""]){
                notAvailable = [NSString stringWithFormat:@"%@",kLocalizedSensorAcceleration];
            } else {
                notAvailable = [NSString stringWithFormat:@"%@,%@",notAvailable,kLocalizedSensorAcceleration];
            }
        }
    }
    if ((requiredResources & kGyro) > 0) {
        if (![[SensorHandler sharedSensorHandler] gyroAvailable]) {
            if([notAvailable isEqualToString:@""]){
                notAvailable = [NSString stringWithFormat:@"%@",kLocalizedSensorRotation];
            } else {
                notAvailable = [NSString stringWithFormat:@"%@,%@",notAvailable,kLocalizedSensorRotation];
            }
        }
    }
    if ((requiredResources & kMagnetometer) > 0) {
        if (![[SensorHandler sharedSensorHandler] magnetometerAvailable]) {
            if([notAvailable isEqualToString:@""]){
                notAvailable = [NSString stringWithFormat:@"%@",kLocalizedSensorMagnetic];
            } else {
                notAvailable = [NSString stringWithFormat:@"%@,%@",notAvailable,kLocalizedSensorMagnetic];
            }
        }
    }
    if ((requiredResources & kLoudness) > 0) {
        if (![[SensorHandler sharedSensorHandler] loudnessAvailable]) {
            if([notAvailable isEqualToString:@""]){
                notAvailable = [NSString stringWithFormat:@"%@",kLocalizedSensorLoudness];
            } else {
                notAvailable = [NSString stringWithFormat:@"%@,%@",notAvailable,kLocalizedSensorLoudness];
            }
        }
    }
    if ((requiredResources & kLED) > 0) {
        if (![[FlashHelper sharedFlashHandler] isAvailable]) {
            if([notAvailable isEqualToString:@""]){
                notAvailable = [NSString stringWithFormat:@"%@",kLocalizedSensorLED];
            } else {
                notAvailable = [NSString stringWithFormat:@"%@,%@",notAvailable,kLocalizedSensorLED];
            }
        }
    }
    if (![notAvailable isEqualToString:@""]) {
        notAvailable = [NSString stringWithFormat:@"%@ %@",notAvailable,kLocalizedNotAvailable];
        [Util confirmAlertWithTitle:kLocalizedPocketCode message:notAvailable delegate:self tag:kResourcesAlertView];
        return NO;
    }
    //CheckBluetooth
    
    if ((requiredResources & kBluetoothPhiro) > 0 && kPhiroActivated) {
        //ConnectPhiro
        [bluetoothArray addObject:[NSNumber numberWithInteger:BluetoothDeviceIDphiro]];
    }
    
    if ((requiredResources & kBluetoothArduino) > 0 && kArduinoActivated) {
        //ConnectArduino
        [bluetoothArray addObject:[NSNumber numberWithInteger:BluetoothDeviceIDarduino]];
    }
    if ( bluetoothArray.count > 0) {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iPhone" bundle: nil];
        BluetoothPopupVC * bvc = (BluetoothPopupVC*)[storyboard instantiateViewControllerWithIdentifier:@"bluetoothPopupVC"];
        [bvc setDeviceArray:bluetoothArray];
        [bvc setDelegate:self];
        [bvc setVc:self.scenePresenterViewController];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:(UIViewController*)bvc];
        [self presentViewController:navController animated:YES completion:nil];
        return NO;
    } else {
        return YES;
    }
    return YES;
}

#pragma mark - Setup Toolbar
- (void)setupToolBar
{
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                              target:nil
                                                                              action:nil];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transparent1x1"]];
    UIBarButtonItem *invisibleButton = [[UIBarButtonItem alloc] initWithCustomView:imageView];
    UIBarButtonItem *delete = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                                                            target:self
                                                                            action:@selector(deleteAlertView)];
    delete.tintColor = [UIColor redColor];
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                         target:self
                                                                         action:@selector(showBrickPickerAction:)];
    add.enabled = (! self.editing);
    UIBarButtonItem *play = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay
                                                                          target:self
                                                                          action:@selector(playSceneAction:)];
    play.enabled = (! self.editing);
    if (self.editing) {
        self.toolbarItems = @[flexItem,invisibleButton, delete, invisibleButton, flexItem];
    } else {
        self.toolbarItems = @[flexItem,invisibleButton, add, invisibleButton, flexItem,
                              flexItem, flexItem, invisibleButton, play, invisibleButton, flexItem];
    }
}


@end
