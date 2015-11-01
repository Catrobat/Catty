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

#import "SettingsTableViewController.h"
#import "TermsOfUseOptionTableViewController.h"
#import "AboutPoketCodeOptionTableViewController.h"
#import "LanguageTranslationDefines.h"
#import "NetworkDefines.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "KeychainUserDefaultsDefines.h"
#import "Pocket_Code-Swift.h"



@implementation SettingsTableViewController

- (void)setup {
	
	self.title = @"Settings";
    self.view.backgroundColor = [UIColor backgroundColor];
    self.view.tintColor = [UIColor globalTintColor];
	[self addSection:[BOTableViewSection sectionWithHeaderTitle:@"" handler:^(BOTableViewSection *section) {

        [section addCell:[BOSwitchTableViewCell cellWithTitle:kLocalizedFaceDetection key:kUseFaceDetectionSensors handler:^(BOSwitchTableViewCell *cell) {
            cell.backgroundColor = [UIColor backgroundColor];
            cell.mainColor = [UIColor globalTintColor];
                    }]];
        
        [section addCell:[BOSwitchTableViewCell cellWithTitle:kLocalizedFaceDetectionFrontCamera key:kUseFrontCamera handler:^(BOSwitchTableViewCell *cell) {
            cell.visibilityKey = kUseFaceDetectionSensors;
            cell.backgroundColor = [UIColor backgroundColor];
            cell.mainColor = [UIColor globalTintColor];
            cell.visibilityBlock = ^BOOL(id settingValue) {
                return [settingValue boolValue];
            };
            cell.onFooterTitle = kLocalizedFaceDetectionDefaultCamera;
            cell.offFooterTitle = kLocalizedFaceDetectionDefaultCamera;
            
        }]];

    }]];
	
    [self addSection:[BOTableViewSection sectionWithHeaderTitle:@"" handler:^(BOTableViewSection *section) {
        
        if (kPhiroActivated) {
            [section addCell:[BOSwitchTableViewCell cellWithTitle:kLocalizedPhiroBricks key:kUsePhiroBricks handler:^(BOSwitchTableViewCell *cell) {
                cell.backgroundColor = [UIColor backgroundColor];
                cell.mainColor = [UIColor globalTintColor];
            }]];
        }
        
        if (kArduinoActivated) {
            [section addCell:[BOSwitchTableViewCell cellWithTitle:kLocalizedArduinoBricks key:kUseArduinoBricks handler:^(BOSwitchTableViewCell *cell) {
                cell.backgroundColor = [UIColor backgroundColor];
                cell.mainColor = [UIColor globalTintColor];
            }]];
        }

        
    }]];
    __unsafe_unretained typeof(self) weakSelf = self;
    if (kPhiroActivated || kArduinoActivated) {
        [self addSection:[BOTableViewSection sectionWithHeaderTitle:@"" handler:^(BOTableViewSection *section) {
            
            [section addCell:[BOButtonTableViewCell cellWithTitle:kLocalizedDisconnectAllDevices key:nil handler:^(BOButtonTableViewCell *cell) {
                cell.backgroundColor = [UIColor backgroundColor];
                cell.mainColor = [UIColor globalTintColor];
                cell.actionBlock = ^{
                    [weakSelf disconnect];
                };
            }]];

        }]];
    }
    

	
	[self addSection:[BOTableViewSection sectionWithHeaderTitle:@"" handler:^(BOTableViewSection *section) {
		[section addCell:[BOChoiceTableViewCell cellWithTitle:kLocalizedAboutPocketCode key:@"choice_2" handler:^(BOChoiceTableViewCell *cell) {
			cell.destinationViewController = [AboutPoketCodeOptionTableViewController new];
            cell.backgroundColor = [UIColor backgroundColor];
            cell.mainColor = [UIColor globalTintColor];
		}]];
        [section addCell:[BOChoiceTableViewCell cellWithTitle:kLocalizedTermsOfUse key:@"choice_2" handler:^(BOChoiceTableViewCell *cell) {
            cell.destinationViewController = [TermsOfUseOptionTableViewController new];
            cell.backgroundColor = [UIColor backgroundColor];
            cell.mainColor = [UIColor globalTintColor];
        }]];
	}]];
	
	[self addSection:[BOTableViewSection sectionWithHeaderTitle:@"" handler:^(BOTableViewSection *section) {
		
        [section addCell:[BOButtonTableViewCell cellWithTitle:kLocalizedPrivacySettings key:nil handler:^(BOButtonTableViewCell *cell) {
            cell.backgroundColor = [UIColor backgroundColor];
            cell.mainColor = [UIColor globalTintColor];
            cell.actionBlock = ^{
                [weakSelf openPrivacySettings];
            };
        }]];
		[section addCell:[BOButtonTableViewCell cellWithTitle:kLocalizedRateUs key:nil handler:^(BOButtonTableViewCell *cell) {
            cell.backgroundColor = [UIColor backgroundColor];
            cell.mainColor = [UIColor globalTintColor];
			cell.actionBlock = ^{
				[weakSelf openRateUsURL];
			};
		}]];
        NSString *version = [[NSString alloc] initWithFormat:@"%@%@",
                             kLocalizedVersionLabel,
                             [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
		section.footerTitle = version;
	}]];
    

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)presentAlertControllerWithTitle:(NSString *)title message:(NSString *)message {
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
	[alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
		[alertController dismissViewControllerAnimated:YES completion:nil];
	}]];
	
	[self presentViewController:alertController animated:YES completion:nil];
}

- (void)showTappedButtonAlert {
    // open url
	[self presentAlertControllerWithTitle:@"Button tapped!" message:nil];
}

- (void)openRateUsURL
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kAppStoreURL]];
}

- (void)openPrivacySettings
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

- (void)disconnect
{
    [[BluetoothService sharedInstance] disconnect];
}

@end
