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

struct PlayerConfig {
    static let LoopMinDurationTime = 0.02 // 20ms
    static let MinIntervalBetweenTwoAcceptedTouches = 0.2 // 200ms
    static let MaxRecursionLimitOfSelfBroadcasts = 40
    static let NumberOfWaitQueuesInitialValue = 3
    static let RotationDegreeOffset = 90.0 // needed for PointInDirectionBrick + PointToBrick
}

// Logger names for release and debug mode configured in Swell.plist
//--------------------------------------------------------------------------------------------------
#if DEBUG
//==================================================================================================
//                                      DEVELOPER MODE
//==================================================================================================

struct LoggerConfig {
    static let PlayerSceneID = "CBSceneLogger.Debug"
    static let PlayerSchedulerID = "CBSchedulerLogger.Debug"
    static let PlayerFrontendID = "CBFrontendLogger.Debug"
    static let PlayerBackendID = "CBBackendLogger.Debug"
    static let PlayerBroadcastHandlerID = "CBBroadcastHandlerLogger.Debug"
}

#else // DEBUG == 1
//==================================================================================================
//                                       RELEASE MODE
//==================================================================================================

struct LoggerConfig {
    static let PlayerSceneID = "CBSceneLogger.Release"
    static let PlayerSchedulerID = "CBSchedulerLogger.Release"
    static let PlayerFrontendID = "CBFrontendLogger.Release"
    static let PlayerBackendID = "CBBackendLogger.Release"
    static let PlayerBroadcastHandlerID = "CBBroadcastHandlerLogger.Release"
}

////------------------------------------------------------------------------------------------------
#endif // DEBUG

//==================================================================================================
//                                        TEST MODE
//==================================================================================================

// Test logger names configured in Swell.plist
struct LoggerTestConfig {
    static let PlayerSceneID = "CBSceneLogger.Test"
    static let PlayerSchedulerID = "CBSchedulerLogger.Test"
    static let PlayerFrontendID = "CBFrontendLogger.Test"
    static let PlayerBackendID = "CBBackendLogger.Test"
    static let PlayerBroadcastHandlerID = "CBBroadcastHandlerLogger.Test"
}
