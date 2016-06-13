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

#import "ResourceHelper.h"
#import "SensorHandler.h"
#import "ProgramDefines.h"
#import "LanguageTranslationDefines.h"
#import "FlashHelper.h"
#import "FaceDetection.h"
#import "KeychainUserDefaultsDefines.h"
#import "Pocket_Code-Swift.h"
#import "ActionSheetAlertViewTags.h"
#import "BaseCollectionViewController.h"

#import <CoreBluetooth/CoreBluetooth.h>
#import <AudioToolbox/AudioToolbox.h>

@class CentralManager;
@class BluetoothPopupVC;

@implementation ResourceHelper

+(BOOL)checkResources:(NSInteger)requiredResources delegate:(id<BluetoothSelection,CatrobatAlertViewDelegate>)delegate
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
                notAvailable = [NSString stringWithFormat:@"%@, %@",notAvailable,kLocalizedVibration];
            }
        }
    }
    if ((requiredResources & kLocation) > 0) {
        if (![[SensorHandler sharedSensorHandler] locationAvailable]) {
            if([notAvailable isEqualToString:@""]){
                notAvailable = [NSString stringWithFormat:@"%@",kLocalizedSensorCompass];
            } else {
                notAvailable = [NSString stringWithFormat:@"%@, %@",notAvailable,kLocalizedSensorCompass];
            }
        }
    }
    if ((requiredResources & kAccelerometer) > 0) {
        if (![[SensorHandler sharedSensorHandler] accelerometerAvailable]) {
            if([notAvailable isEqualToString:@""]){
                notAvailable = [NSString stringWithFormat:@"%@",kLocalizedSensorAcceleration];
            } else {
                notAvailable = [NSString stringWithFormat:@"%@, %@",notAvailable,kLocalizedSensorAcceleration];
            }
        }
    }
    if ((requiredResources & kGyro) > 0) {
        if (![[SensorHandler sharedSensorHandler] gyroAvailable]) {
            if([notAvailable isEqualToString:@""]){
                notAvailable = [NSString stringWithFormat:@"%@",kLocalizedSensorRotation];
            } else {
                notAvailable = [NSString stringWithFormat:@"%@, %@",notAvailable,kLocalizedSensorRotation];
            }
        }
    }
    if ((requiredResources & kMagnetometer) > 0) {
        if (![[SensorHandler sharedSensorHandler] magnetometerAvailable]) {
            if([notAvailable isEqualToString:@""]){
                notAvailable = [NSString stringWithFormat:@"%@",kLocalizedSensorMagnetic];
            } else {
                notAvailable = [NSString stringWithFormat:@"%@, %@",notAvailable,kLocalizedSensorMagnetic];
            }
        }
    }
    if ((requiredResources & kLoudness) > 0) {
        if (![[SensorHandler sharedSensorHandler] loudnessAvailable]) {
            if([notAvailable isEqualToString:@""]){
                notAvailable = [NSString stringWithFormat:@"%@",kLocalizedSensorLoudness];
            } else {
                notAvailable = [NSString stringWithFormat:@"%@, %@",notAvailable,kLocalizedSensorLoudness];
            }
        }
    }
    if ((requiredResources & kLED) > 0) {
        if (![[FlashHelper sharedFlashHandler] isAvailable]) {
            if([notAvailable isEqualToString:@""]){
                notAvailable = [NSString stringWithFormat:@"%@",kLocalizedSensorLED];
            } else {
                notAvailable = [NSString stringWithFormat:@"%@, %@",notAvailable,kLocalizedSensorLED];
            }
        }
    }
    if (![notAvailable isEqualToString:@""]) {
        notAvailable = [NSString stringWithFormat:@"%@ %@",notAvailable,kLocalizedNotAvailable];
        [Util confirmAlertWithTitle:kLocalizedPocketCode message:notAvailable delegate:delegate tag:kResourcesAlertView];
        return NO;
    }
    //CheckBluetooth
    
    if ((requiredResources & kBluetoothPhiro) > 0 && [Util isPhiroActivated]) {
        //ConnectPhiro
        if (!([BluetoothService sharedInstance].phiro.state == CBPeripheralStateConnected)) {
            [bluetoothArray addObject:[NSNumber numberWithInteger:BluetoothDeviceIDphiro]];
        } else {
            Phiro *phiro = [BluetoothService sharedInstance].phiro;
            [phiro reportSensorData:YES];
        }
    }
    
    if ((requiredResources & kBluetoothArduino) > 0 && [Util isArduinoActivated]) {
        //ConnectArduino
        if (!([BluetoothService sharedInstance].arduino.state == CBPeripheralStateConnected)) {
            [bluetoothArray addObject:[NSNumber numberWithInteger:BluetoothDeviceIDarduino]];
        } else {
            ArduinoDevice *arduino = [BluetoothService sharedInstance].arduino;
            [arduino reportSensorData:YES];
        }
    }
    if ( bluetoothArray.count > 0) {
        if( [CentralManager sharedInstance].state == CBCentralManagerStatePoweredOn || [CentralManager sharedInstance].state == CBCentralManagerStateUnknown){
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iPhone" bundle: nil];
            BluetoothPopupVC * bvc = (BluetoothPopupVC*)[storyboard instantiateViewControllerWithIdentifier:@"bluetoothPopupVC"];
            [bvc setDeviceArray:bluetoothArray];
            [bvc setDelegate:delegate];
            if ([delegate isKindOfClass:[BaseTableViewController class]]) {
                BaseTableViewController *btvc = (BaseTableViewController*)delegate;
                [bvc setVc:btvc.scenePresenterViewController];
                UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:(UIViewController*)bvc];
                [btvc presentViewController:navController animated:YES completion:nil];
            } else if ([delegate isKindOfClass:[BaseCollectionViewController class]]) {
                BaseCollectionViewController *bcvc = (BaseCollectionViewController*)delegate;
                [bvc setVc:bcvc.scenePresenterViewController];
                UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:(UIViewController*)bvc];
                [bcvc presentViewController:navController animated:YES completion:nil];
            } else {
                //ViewController To ScenePresenter must have a reference to the ScenePresenterViewController!!
                return NO;
            }

        } else if([CentralManager sharedInstance].state == CBCentralManagerStatePoweredOff){
            [Util alertWithText:kLocalizedBluetoothPoweredOff];
        } else {
            [Util alertWithText:kLocalizedBluetoothNotAvailable];
        }
        return NO;
    } else {
        return YES;
    }
    return YES;
}


@end
