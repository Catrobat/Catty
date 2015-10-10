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

import Foundation

extension PhiroPlayToneBrick :CBInstructionProtocol {
    
    func instruction() -> CBInstruction {
        
        return CBInstruction.ExecClosure { (context, _) in
            let durationInterpretation:NSInteger = NSInteger(self.durationFormula.interpretIntegerForSprite(self.script?.object))
            
            
            guard let phiro:Phiro = BluetoothService.sharedInstance.phiro else {
                        //ERROR
                        return;
                    }
            
            
            switch (self.tone) {
            case .DO:
                    phiro.playTone(262, duration: durationInterpretation);
                break;
            case .RE:
                    phiro.playTone(294, duration: durationInterpretation);
                break;
            case .MI:
                    phiro.playTone(330, duration: durationInterpretation);
                break;
            case .FA:
                    phiro.playTone(349, duration: durationInterpretation);
                break;
            case .SO:
                    phiro.playTone(392, duration: durationInterpretation);
                break;
            case .LA:
                    phiro.playTone(440, duration: durationInterpretation);
                break;
            case .TI:
                    phiro.playTone(494, duration: durationInterpretation);
                break;
            }        }
        
    }
    
}


