/**
 *  Copyright (C) 2010-2016 The Catrobat Team
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

//import AudioToolbox

extension VibrationBrick: CBInstructionProtocol {

    func instruction() -> CBInstruction {
        
        guard let spriteObject = self.script?.object else { fatalError("This should never happen!") }

        let durationFormula = self.durationInSeconds
        return CBInstruction.ExecClosure { (context, scheduler) in
//            self.logger.debug("Performing: VibrationBrick")
            
            let durationInSeconds = durationFormula.interpretDoubleForSprite(spriteObject)
            var numberOfVibrations = durationInSeconds*2;
            if ((numberOfVibrations < 1) && (numberOfVibrations > 0)){
                numberOfVibrations = ceil(numberOfVibrations)
            }else{
                numberOfVibrations = floor(numberOfVibrations)
            }
            var previousOperation : NSBlockOperation? = nil;
            let delayTime = UInt32(0.5 * Double(USEC_PER_SEC))
            
            let max = Int(numberOfVibrations)
            for _ in 0 ..< max {
                let operation : NSBlockOperation = NSBlockOperation (block: {
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                usleep(delayTime)})
                
                if let previous = previousOperation {
                    operation.addDependency(previous)
                }
            CBScheduler.vibrateSerialQueue.addOperation(operation)
            previousOperation = operation
            }
            
            context.state = .Runnable
        }

    }
}
