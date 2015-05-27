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
typealias CBBroadcastQueueElement = (message: String, senderScript: Script)
typealias CBExecClosure = dispatch_block_t

// MARK: Enums
enum CBScriptState {
    case Runnable
    case Running
    case RunningMature // for StartScripts => broadcast + broadcast wait start queue
    case Waiting       // for broadcast wait!!
    case Sleeping
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
