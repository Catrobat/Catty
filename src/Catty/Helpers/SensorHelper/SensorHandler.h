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

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>
#import "SensorManager.h"
#import <AVFoundation/AVFoundation.h>

@interface SensorHandler : NSObject <AVAudioRecorderDelegate,AVAudioPlayerDelegate>


+ (instancetype)sharedSensorHandler;

- (CMRotationRate) rotationRate;
- (CMAcceleration) acceleration;
- (CMMagneticField) magneticField;

- (double) valueForSensor:(Sensor)sensor;

- (void) stopSensors;
- (void)faceDetectionInit;

- (BOOL)locationAvailable;
- (BOOL)accelerometerAvailable;
- (BOOL)gyroAvailable;
- (BOOL)magnetometerAvailable;
- (BOOL)loudnessAvailable;
@end
