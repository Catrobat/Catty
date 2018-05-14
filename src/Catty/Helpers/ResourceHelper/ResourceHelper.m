/**
 *  Copyright (C) 2010-2018 The Catrobat Team
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
#import "Pocket_Code-Swift.h"
#import "BaseCollectionViewController.h"

@class BluetoothPopupVC;

@implementation ResourceHelper

+(BOOL)checkResources:(NSInteger)requiredResources delegate:(id<BluetoothSelection,ResourceNotAvailableDelegate>)delegate
{
    NSMutableArray *bluetoothArray = [NSMutableArray new];
    if ((requiredResources & kTextToSpeech) > 0) {
        //intern iOS AVSpeechSynthesizer always available
    }
    
    if ((requiredResources & kFaceDetection) > 0) {
        [[SensorHandler sharedSensorHandler] faceDetectionInit];
    }
    
    // Sensors
    NSInteger unavailableResource = [[CBSensorManager shared] getUnavailableResources:requiredResources];
    NSMutableArray<NSString*>* unavailableResourceMessages = [NSMutableArray new];
    
    if ((unavailableResource & kVibration) > 0) {
        [unavailableResourceMessages addObject:[NSString stringWithFormat:@"%@",kLocalizedVibration]];
    }
    
    if ((unavailableResource & kLocation) > 0) {
        [unavailableResourceMessages addObject:[NSString stringWithFormat:@"%@",kLocalizedSensorLocation]];
    }
    
    if ((unavailableResource & kCompass) > 0) {
        [unavailableResourceMessages addObject:[NSString stringWithFormat:@"%@",kLocalizedSensorCompass]];
    }
    
    if ((unavailableResource & kAccelerometer) > 0) {
        [unavailableResourceMessages addObject:[NSString stringWithFormat:@"%@",kLocalizedSensorAcceleration]];
    }
    
    if ((unavailableResource & kGyro) > 0) {
        [unavailableResourceMessages addObject:[NSString stringWithFormat:@"%@",kLocalizedSensorRotation]];
    }
    
    if ((unavailableResource & kMagnetometer) > 0) {
        [unavailableResourceMessages addObject:[NSString stringWithFormat:@"%@",kLocalizedSensorMagnetic]];
    }
    
    if ((requiredResources & kLoudness) > 0) {
        if (![[SensorHandler sharedSensorHandler] loudnessAvailable]) {
            [unavailableResourceMessages addObject:[NSString stringWithFormat:@"%@",kLocalizedSensorLoudness]];
        }
    }
    if ((requiredResources & kLED) > 0) {
        if (![[FlashHelper sharedFlashHandler] isAvailable]) {
            [unavailableResourceMessages addObject:[NSString stringWithFormat:@"%@",kLocalizedSensorLED]];
        }
    }
    if ([unavailableResourceMessages count] > 0) {
        NSString *alertMessage = [NSString stringWithFormat:@"%@ %@",[unavailableResourceMessages componentsJoinedByString:@", "], kLocalizedNotAvailable];
        
        [[[[[AlertControllerBuilder alertWithTitle:kLocalizedPocketCode message:alertMessage]
         addCancelActionWithTitle:kLocalizedCancel handler:nil]
         addDefaultActionWithTitle:kLocalizedYes handler:^{
             [delegate userAgreedToContinueAnyway];
         }] build]
         showWithController:[Util topmostViewController]];
        
        return NO;
    }
    
    //CheckBluetooth
    if ((requiredResources & kBluetoothPhiro) > 0 && [Util isPhiroActivated]) {
        //ConnectPhiro
        if (!([BluetoothService sharedInstance].phiro.state == CBPeripheralStateConnected)) {
            [bluetoothArray addObject:[NSNumber numberWithInteger:BluetoothDeviceIDPhiro]];
        } else {
            Phiro *phiro = [BluetoothService sharedInstance].phiro;
            [phiro reportSensorData:YES];
        }
    }
    
    if ((requiredResources & kBluetoothArduino) > 0 && [Util isArduinoActivated]) {
        //ConnectArduino
        if (!([BluetoothService sharedInstance].arduino.state == CBPeripheralStateConnected)) {
            [bluetoothArray addObject:[NSNumber numberWithInteger:BluetoothDeviceIDArduino]];
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
