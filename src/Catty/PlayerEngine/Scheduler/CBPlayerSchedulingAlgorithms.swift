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

@objc protocol CBPlayerSchedulingAlgorithmProtocol {
    func scriptExecContextForNextInstruction(lastScript: Script?,
        scriptExecContextDict: [Script:CBScriptExecContext]) -> CBScriptExecContext
}

// implements a RoundRobin-like scheduling algorithm
final class CBPlayerSchedulingRR : NSObject, CBPlayerSchedulingAlgorithmProtocol {

    func scriptExecContextForNextInstruction(lastScript: Script?,
        scriptExecContextDict: [Script:CBScriptExecContext]) -> CBScriptExecContext
    {
        assert(scriptExecContextDict.isEmpty == false) // make sure dict is not empty (as specified!)
        if lastScript == nil {
            return scriptExecContextDict.values.first! // take first context
        }
        var takeNextScript = false
        var rounds = 2
        while rounds-- > 0 {
            for (script, context) in scriptExecContextDict {
                if takeNextScript {
                    return context
                }
                if script == lastScript {
                    takeNextScript = true
                    continue
                }
            }
        }
        fatalError("This should NEVER happen!")
    }
}

// implements a random order scheduling algorithm
final class CBPlayerSchedulingAlgorithmRandomOrder : NSObject, CBPlayerSchedulingAlgorithmProtocol {

    func scriptExecContextForNextInstruction(lastScript: Script?,
        scriptExecContextDict: [Script:CBScriptExecContext]) -> CBScriptExecContext
    {
        assert(scriptExecContextDict.isEmpty == false) // make sure dict is not empty (as specified!)
        let randomIndex = arc4random_uniform(UInt32(scriptExecContextDict.count))
        return Array(scriptExecContextDict.values)[Int(randomIndex)]
    }
}
