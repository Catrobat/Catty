/**
 *  Copyright (C) 2010-2017 The Catrobat Team
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

        return CBInstruction.waitExecClosure { (_, _) in
            let durationInSeconds = self.timeToWaitInSeconds.interpretDouble(forSprite: object)

            // check if an invalid duration is given! => prevents UInt32 underflow
            if durationInSeconds <= 0.0 { return }

            // UInt32 overflow protection check
            if durationInSeconds > 60.0 {
                //logger.warn("WOW!!! long time to sleep (> 1min!!!)...")
                let wakeUpTime = Date().addingTimeInterval(durationInSeconds)
                //logger.debug("Sleeping now until \(wakeUpTime)...")
                Thread.sleep(until: wakeUpTime)
            } else {
                let durationInMicroSeconds = durationInSeconds * 1_000_000
                let uduration = UInt32(durationInMicroSeconds) // in microseconds (10^-6)
                if uduration > 100 { // check if it makes sense at all to pause the thread...
                    usleep(uduration)
                }
            }
        }
    }

}
