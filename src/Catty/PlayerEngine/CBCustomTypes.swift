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

// MARK: - Typedefs
typealias CBScheduleLongActionElement = (context: CBScriptContextProtocol, duration: CBDuration, actionClosure: CBLongActionCreateClosure)
typealias CBScheduleActionElement = (context: CBScriptContextProtocol, action: SKAction)
typealias CBHighPriorityScheduleElement = (context: CBScriptContextProtocol, closure: CBHighPriorityExecClosure)
typealias CBScheduleElement = (context: CBScriptContextProtocol, closure: CBExecClosure)

typealias CBExecClosure = (context: CBScriptContextProtocol, scheduler: CBSchedulerProtocol) -> Void
typealias CBHighPriorityExecClosure = (context: CBScriptContextProtocol,
    scheduler: CBSchedulerProtocol, broadcastHandler: CBBroadcastHandlerProtocol) -> Void
typealias CBLongActionClosure = (SKNode, CGFloat) -> Void
typealias CBLongActionCreateClosure = (duration: NSTimeInterval) -> CBLongActionClosure

// MARK: - Enums
enum CBInstruction {
    case HighPriorityExecClosure(closure: CBHighPriorityExecClosure)
    case ExecClosure(closure: CBExecClosure)
//    case LongDurationExecClosure(closure: CBExecClosure) // unused atm.
    case WaitExecClosure(closure: CBExecClosure)
    case LongDurationAction(duration: CBDuration, actionCreateClosure: CBLongActionCreateClosure)
    case Action(action: SKAction)
    case InvalidInstruction()
}

enum CBDuration {
    case VarTime(formula: Formula)
    case FixedTime(duration: Double)
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

enum CBBroadcastType: String {
    case Broadcast = "Broadcast"
    case BroadcastWait = "BroadcastWait"
}


// MARK: - Protocol extensions
// TODO: simplify and remove duplicate...
extension CollectionType where Generator.Element == CBScriptContextProtocol {
    
    func contains(e: Generator.Element) -> Bool {
        for element in self {
            if element == e {
                return true
            }
        }
        return false
    }
    
    func indexOfElement(e: Generator.Element) -> Int? {
        var index = 0
        for element in self {
            if element == e {
                return index
            }
            ++index
        }
        return nil
    }
    
}

extension CollectionType where Generator.Element == CBBroadcastScriptContextProtocol {
    
    func contains(e: Generator.Element) -> Bool {
        for element in self {
            if element == e {
                return true
            }
        }
        return false
    }
    
    func indexOfElement(e: Generator.Element) -> Int? {
        var index = 0
        for element in self {
            if element == e {
                return index
            }
            ++index
        }
        return nil
    }
    
}

// MARK: - Extensions
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

// MARK: - Custom operators
func ==(lhs: CBScriptContextProtocol, rhs: CBScriptContextProtocol) -> Bool {
    return lhs.id == rhs.id
}

func +=(inout left: CBScriptContext, right: CBInstruction) {
    left.appendInstructions([right])
}

func +=(inout left: CBScriptContext, right: [CBInstruction]) {
    left.appendInstructions(right)
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
