/**
 *  Copyright (C) 2010-2019 The Catrobat Team
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
typealias CBCondition = (_ context: CBScriptContextProtocol) -> Bool

typealias CBScheduleLongActionElement = (context: CBScriptContextProtocol, duration: CBDuration, actionClosure: CBLongActionClosure)
typealias CBScheduleActionElement = (context: CBScriptContextProtocol, closure: CBActionClosure)
typealias CBHighPriorityScheduleElement = (context: CBScriptContextProtocol, closure: CBHighPriorityExecClosure)
typealias CBScheduleElement = (context: CBScriptContextProtocol, closure: CBExecClosure)
typealias CBFormulaBufferElement = (context: CBScriptContextProtocol, brick: BrickFormulaProtocol)
typealias CBConditionalFormulaBufferElement = (context: CBScriptContextProtocol, condition: CBConditionalSequence)

typealias CBExecClosure = (_ context: CBScriptContextProtocol, _ scheduler: CBSchedulerProtocol) -> Void
typealias CBHighPriorityExecClosure = (_ context: CBScriptContextProtocol,
    _ scheduler: CBSchedulerProtocol, _ broadcastHandler: CBBroadcastHandlerProtocol) -> Void
typealias CBLongActionClosure = (_ duration: TimeInterval, _ context: CBScriptContextProtocol) -> SKAction
typealias CBActionClosure = (_ context: CBScriptContextProtocol) -> SKAction

// MARK: - Enums
indirect enum CBInstruction {
    case highPriorityExecClosure(closure: CBHighPriorityExecClosure)
    case execClosure(closure: CBExecClosure)
    case waitExecClosure(closure: CBExecClosure)
    case longDurationAction(duration: CBDuration, closure: CBLongActionClosure)
    case action(closure: CBActionClosure)
    case formulaBuffer(brick: BrickFormulaProtocol)
    case conditionalFormulaBuffer(conditionalBrick: CBConditionalSequence)
    case invalidInstruction
}

enum CBDuration {
    case varTime(formula: Formula)
    case fixedTime(duration: Double)
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
    case runnable

    // indicates that CBScriptExecContext has already
    // been added to the scheduler
    case running

    // indicates that a script is waiting for BroadcastWait scripts
    // (listening to the corresponding broadcastMessage) to be finished!!
    case waiting

    // indicates that CBScriptExecContext is going to be removed
    // from the scheduler soon
    case dead

}

enum CBBroadcastType: String {
    case Broadcast
    case BroadcastWait
}

// MARK: - Protocol extensions
// TODO: simplify and remove duplicate...
extension Collection where Iterator.Element == CBScriptContextProtocol {

    func contains(_ e: Iterator.Element) -> Bool {
        for element in self where (element == e) {
            return true
        }
        return false
    }

    func indexOfElement(_ e: Iterator.Element) -> Int? {
        var index = 0
        for element in self {
            if element == e {
                return index
            }
            index += 1
        }
        return nil
    }

}

extension Collection where Iterator.Element == CBBroadcastScriptContextProtocol {

    func contains(_ e: Iterator.Element) -> Bool {
        for element in self where (element == e) {
            return true
        }
        return false
    }

    func indexOfElement(_ e: Iterator.Element) -> Int? {
        var index = 0
        for element in self {
            if element == e {
                return index
            }
            index += 1
        }
        return nil
    }

}

// MARK: - Extensions
extension Array {
    mutating func removeObject<U: Equatable>(_ object: U) {
        var index: Int?
        for (idx, objectToCompare) in self.enumerated() {
            if let to = objectToCompare as? U {
                if object == to {
                    index = idx
                }
            }
        }
        if let index = index {
            self.remove(at: index)
        }
    }

    mutating func prepend(_ newElement: Element) {
        self.insert(newElement, at: 0)
    }
}

// MARK: - Custom operators
func == (lhs: CBScriptContextProtocol, rhs: CBScriptContextProtocol) -> Bool {
    return lhs.id == rhs.id
}

func += (left: inout CBScriptContext, right: CBInstruction) {
    left.appendInstructions([right])
}

func += (left: inout CBScriptContext, right: [CBInstruction]) {
    left.appendInstructions(right)
}

func += <T>(left: inout [T], right: T) {
    left.append(right)
}

func == (lhs: Date, rhs: Date) -> Bool {
    return lhs.timeIntervalSince1970 == rhs.timeIntervalSince1970
}

func < (lhs: Date, rhs: Date) -> Bool {
    if lhs.compare(rhs) == .orderedAscending {
        return true
    }
    return false
}
