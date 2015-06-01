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

// MARK: Typedefs
typealias CBBroadcastQueueElement = (message: String, senderScript: Script, broadcastType: CBBroadcastType)
typealias CBExecClosure = dispatch_block_t

// MARK: Enums
enum CBScriptState {
    case Runnable
    case Running
    case RunningMature   // for StartScripts => broadcast + broadcast wait start queue
    case RunningBlocking // for broadcast wait!! (BroadcastScript called by BroadcastWaitBrick)
    case Waiting         // for broadcast wait!! (BroadcastWaitBrick!)
//    case Sleeping        // unused at the moment!
    case Dead
}

enum CBScriptType {
    case Unknown
    case Start
    case When
    case Broadcast

    static func scriptTypeOfScript(script: Script) -> CBScriptType {
        if let _ = script as? StartScript {
            return Start
        } else if let _ = script as? WhenScript {
            return When
        } else if let _ = script as? BroadcastScript {
            return Broadcast
        } else {
            return Unknown
        }
    }
}

enum CBBroadcastType {
    case Broadcast
    case BroadcastWait
    func typeName() -> String {
        switch self {
        case .Broadcast:
            return "Broadcast"
        case .BroadcastWait:
            return "BroadcastWait"
        }
    }
}

// Logger names for release and debug mode configured in Swell.plist
//------------------------------------------------------------------------------------------------------------
#if DEBUG
//============================================================================================================
//
//                                            DEVELOPER MODE
//
//============================================================================================================

struct LoggerConfig {
    static let PlayerSceneID = "CBPlayerSceneLogger.Debug"
    static let PlayerSchedulerID = "CBPlayerSchedulerLogger.Debug"
    static let PlayerFrontendID = "CBPlayerFrontendLogger.Debug"
    static let PlayerBackendID = "CBPlayerBackendLogger.Debug"
    static let PlayerBroadcastHandlerID = "CBPlayerBroadcastHandlerLogger.Debug"
}

#else // DEBUG == 1
//============================================================================================================
//
//                                             RELEASE MODE
//
//============================================================================================================

struct LoggerConfig {
    static let PlayerSceneID = "CBPlayerSceneLogger.Release"
    static let PlayerSchedulerID = "CBPlayerSchedulerLogger.Release"
    static let PlayerFrontendID = "CBPlayerFrontendLogger.Release"
    static let PlayerBackendID = "CBPlayerBackendLogger.Release"
    static let PlayerBroadcastHandlerID = "CBPlayerBroadcastHandlerLogger.Release"
}

////------------------------------------------------------------------------------------------------------------
#endif // DEBUG

//============================================================================================================
//
//                                            TEST MODE
//
//============================================================================================================

// Test logger names configured in Swell.plist
struct LoggerTestConfig {
    static let PlayerSceneID = "CBPlayerSceneLogger.Test"
    static let PlayerSchedulerID = "CBPlayerSchedulerLogger.Test"
    static let PlayerFrontendID = "CBPlayerFrontendLogger.Test"
    static let PlayerBackendID = "CBPlayerBackendLogger.Test"
    static let PlayerBroadcastHandlerID = "CBPlayerBroadcastHandlerLogger.Test"
}
