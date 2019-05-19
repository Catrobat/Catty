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

@objc extension WaitBrick: CBInstructionProtocol {

    @nonobjc func instruction() -> CBInstruction {

        guard let object = self.script?.object
            else { fatalError("This should never happen!") } // (pre)fetch only once (micro-optimization)
        return CBInstruction.waitExecClosure { context, scheduler in
            let timeIsUpExpectation = Expectation()
            let durationInSeconds = context.formulaInterpreter.interpretDouble(self.timeToWaitInSeconds, for: object)
            if durationInSeconds <= 0.0 { return }
            let durationTimer = ExtendedTimer.init(timeInterval: durationInSeconds,
                                                   repeats: false,
                                                   execOnMainRunLoop: true,
                                                   startTimerImmediately: false) {_ in
                                                    timeIsUpExpectation.fulfill()
            }

            scheduler.registerTimer(durationTimer)
            timeIsUpExpectation.wait()
            scheduler.removeTimer(durationTimer)
        }
    }
}
