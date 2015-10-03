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
        for (idx, objectToCompare) in self.enumerate() {
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

    mutating func prepend(newElement: Element) {
        self.insert(newElement, atIndex: 0)
    }
}

func +=<T>(inout left: [T], right: T) {
    left.append(right)
}

func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.timeIntervalSince1970 == rhs.timeIntervalSince1970
}

func <(lhs: NSDate, rhs: NSDate) -> Bool {
    if lhs.compare(rhs) == .OrderedAscending {
        return true
    }
    return false
}

// MARK: Typedefs
typealias CBScheduleLongActionElement = (context: CBScriptContextProtocol, durationFormula: Formula, actionClosure: CBLongActionCreateClosure)
typealias CBScheduleActionElement = (context: CBScriptContextProtocol, action: SKAction)
typealias CBHighPriorityScheduleElement = (context: CBScriptContextProtocol, closure: CBHighPriorityExecClosure)
typealias CBScheduleElement = (context: CBScriptContextProtocol, closure: CBExecClosure)

typealias CBExecClosure = (context: CBScriptContextProtocol, scheduler: CBSchedulerProtocol) -> Void
typealias CBHighPriorityExecClosure = (context: CBScriptContextProtocol,
    scheduler: CBSchedulerProtocol, broadcastHandler: CBBroadcastHandlerProtocol) -> Void
typealias CBLongActionClosure = (SKNode, CGFloat) -> Void
typealias CBLongActionCreateClosure = (duration: NSTimeInterval) -> CBLongActionClosure

// MARK: Enums
enum CBInstruction {
    case HighPriorityExecClosure(closure: CBHighPriorityExecClosure)
    case ExecClosure(closure: CBExecClosure)
//    case LongDurationExecClosure(closure: CBExecClosure) // unused atm.
    case WaitExecClosure(closure: CBExecClosure)
    case LongDurationAction(durationFormula: Formula, actionCreateClosure: CBLongActionCreateClosure)
    case Action(action: SKAction)
    case InvalidInstruction()
}


//##################################################################################################
//                _____ __        __          ____  _
//               / ___// /_____ _/ /____     / __ \(_)___ _____ __________ _____ ___
//               \__ \/ __/ __ `/ __/ _ \   / / / / / __ `/ __ `/ ___/ __ `/ __ `__ \
//              ___/ / /_/ /_/ / /_/  __/  / /_/ / / /_/ / /_/ / /  / /_/ / / / / / /
//             /____/\__/\__,_/\__/\___/  /_____/_/\__,_/\__, /_/   \__,_/_/ /_/ /_/
//                                                      /____/
//##################################################################################################
//
//                 +----------+        +-----------+          +--------+
//     o---------->| Runnable |------->|  Running  |--------->|  Dead  |-------->o
//  (Initial state)+----------+        +-----------+          +--------+   (Final
//                                          | ^                             state)
//                                          | |
//                                          v |
//                                     +-----------+
//                                     |  Waiting  |
//                                     +-----------+
//
//##################################################################################################

enum CBScriptContextState {

    // initial state for a CBScriptExecContext that has
    // not yet been added to the scheduler
    case Runnable

    // indicates that CBScriptExecContext has already
    // been added to the scheduler
    case Running

    // indicates that a script is waiting for BroadcastWait scripts
    // (listening to the corresponding broadcastMessage) to be finished!!
    case Waiting

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
