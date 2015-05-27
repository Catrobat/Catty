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

// Logger names for release and debug mode configured in Swell.plist
//------------------------------------------------------------------------------------------------------------
#if DEBUG == 0
//============================================================================================================
//
//                                             RELEASE MODE
//
//============================================================================================================
#define kCBLoggerPlayerSceneID @"CBPlayerSceneLogger.Release"
#define kCBLoggerPlayerSchedulerID @"CBPlayerSchedulerLogger.Release"
#define kCBLoggerPlayerFrontendID @"CBPlayerFrontendLogger.Release"
#define kCBLoggerPlayerBackendID @"CBPlayerBackendLogger.Release"
#define kCBLoggerPlayerBroadcastHandlerID @"CBPlayerBroadcastHandlerLogger.Release"
//------------------------------------------------------------------------------------------------------------

#else // DEBUG == 1
//============================================================================================================
//
//                                            DEVELOPER MODE
//
//============================================================================================================

#define kCBLoggerPlayerSceneID @"CBPlayerSceneLogger.Debug"
#define kCBLoggerPlayerSchedulerID @"CBPlayerSchedulerLogger.Debug"
#define kCBLoggerPlayerFrontendID @"CBPlayerFrontendLogger.Debug"
#define kCBLoggerPlayerBackendID @"CBPlayerBackendLogger.Debug"
#define kCBLoggerPlayerBroadcastHandlerID @"CBPlayerBroadcastHandlerLogger.Debug"

#endif // DEBUG



//============================================================================================================
//
//                                            TEST MODE
//
//============================================================================================================

// Test logger names configured in Swell.plist
#define kCBTestLoggerPlayerSceneID @"CBPlayerSceneLogger.test"
#define kCBTestLoggerPlayerSchedulerID @"CBPlayerSchedulerLogger.Test"
#define kCBTestLoggerPlayerFrontendID @"CBPlayerFrontendLogger.Test"
#define kCBTestLoggerPlayerBackendID @"CBPlayerBackendLogger.Test"
#define kCBTestLoggerPlayerBroadcastHandlerID @"CBPlayerBroadcastHandlerLogger.Test"
