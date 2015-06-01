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

// MARK: Extensions
extension Array {
    mutating func removeObject<U: Equatable>(object: U) {
        var index: Int?
        for (idx, objectToCompare) in enumerate(self) {
            if let to = objectToCompare as? U {
                if object == to {
                    index = idx
                }
            }
        }
        if(index != nil) {
            self.removeAtIndex(index!)
        }
    }
}

func +=<T>(inout left: [T], right: T) {
    left.append(right)
}

// MARK: Typedefs
typealias CBBroadcastQueueElement = (message: String, senderScriptContext: CBScriptContextAbstract,
    broadcastType: CBBroadcastType)
typealias CBExecClosure = dispatch_block_t

// MARK: Enums
enum CBExecType {
    case Runnable
    case Running
}

//############################################################################################################
//
//                    _____ __        __          ____  _
//                   / ___// /_____ _/ /____     / __ \(_)___ _____ __________ _____ ___
//                   \__ \/ __/ __ `/ __/ _ \   / / / / / __ `/ __ `/ ___/ __ `/ __ `__ \
//                  ___/ / /_/ /_/ / /_/  __/  / /_/ / / /_/ / /_/ / /  / /_/ / / / / / /
//                 /____/\__/\__,_/\__/\___/  /_____/_/\__,_/\__, /_/   \__,_/_/ /_/ /_/
//                                                          /____/
//
//############################################################################################################
//
//                                                           +---------------+
//                                                           | RunningMature |----------+
//                                                           +---------------+          |
//                                                                   ^                  v
//                     +----------+        +-----------+             |             +--------+
//         o---------->| Runnable |------->|  Running  |-------------+             |  Dead  |-------->o
//  (Initial state)    +----------+        +-----------+             |             +--------+   (Final state)
//                                              | ^                  v                  ^
//                                              | |         +-----------------+         |
//                                              | |         | RunningBlocking |---------+
//                                              | |         +-----------------+
//                                              v |
//                                         +-----------+
//                                         |  Waiting  |
//                                         +-----------+
//
//############################################################################################################

enum CBScriptState {

    // initial state for a CBScriptExecContext that has
    // not yet been added to the scheduler
    case Runnable

    // indicates that CBScriptExecContext has already
    // been added to the scheduler
    case Running

    // indicates that a running CBScriptExecContext of
    // a StartScript has reached a mature state
    // After CBScriptExecContexts of all StartScripts have reached
    // a mature state already enqueued "broadcast"- and
    // "broadcast wait"-calls can be performed
    case RunningMature

    // indicates that a running CBScriptExecContext of a BroadcastScript
    // is blocking the calling CBScriptExecContext's script
    case RunningBlocking

    // indicates that a script is waiting for all BroadcastWait scripts
    // (listening to the broadcastMessage of this script) to be finished!!
    case Waiting

//    // unused at the moment!
//    case Sleeping

    // indicates that CBScriptExecContext is going to be removed
    // from the scheduler soon
    case Dead

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
