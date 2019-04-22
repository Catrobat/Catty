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

import Foundation

class AudioEngineConfig {

    public static let localizedInstrumentNames: [String] = [kLocalizedPiano,
                                                            kLocalizedElectricPiano,
                                                            kLocalizedOrgan,
                                                            kLocalizedGuitar,
                                                            kLocalizedElectricGuitar,
                                                            kLocalizedBass,
                                                            kLocalizedPizzicato,
                                                            kLocalizedCello,
                                                            kLocalizedTrombone,
                                                            kLocalizedClarinet,
                                                            kLocalizedSaxophone,
                                                            kLocalizedFlute,
                                                            kLocalizedWoodenFlute,
                                                            kLocalizedBassoon,
                                                            kLocalizedChoir,
                                                            kLocalizedVibraphone,
                                                            kLocalizedMusicBox,
                                                            kLocalizedSteelDrum,
                                                            kLocalizedMarimba,
                                                            kLocalizedSynthLead,
                                                            kLocalizedSynthPad]

    public static let localizedDrumNames: [String] = [kLocalizedSnareDrum,
                                                      kLocalizedBassDrum,
                                                      kLocalizedSideStick,
                                                      kLocalizedCrashCymbal,
                                                      kLocalizedOpenHiHat,
                                                      kLocalizedClosedHiHat,
                                                      kLocalizedTambourine,
                                                      kLocalizedHandClap,
                                                      kLocalizedClaves,
                                                      kLocalizedWoodBlock,
                                                      kLocalizedCowbell,
                                                      kLocalizedTriangle,
                                                      kLocalizedWoodenBongo,
                                                      kLocalizedConga,
                                                      kLocalizedCabasa,
                                                      kLocalizedGuiro,
                                                      kLocalizedVibraslap,
                                                      kLocalizedCuica]

    public static let localizedEffectNames: [String] = [kLocalizedPitch,
                                                      kLocalizedPanLeftRight]

    public static let instrumentPath: [String] = ["1-piano",
                                                  "2-electric-piano",
                                                  "3-organ",
                                                  "4-guitar",
                                                  "5-electric-guitar",
                                                  "6-bass",
                                                  "7-pizzicato",
                                                  "8-cello",
                                                  "9-trombo",
                                                  "10-clarinet",
                                                  "11-saxophone",
                                                  "12-flute",
                                                  "13-wooden-flute",
                                                  "14-basso",
                                                  "15-choir",
                                                  "16-vibraphone",
                                                  "17-music-box",
                                                  "18-steel-drum",
                                                  "19-marim",
                                                  "20-synth-lead",
                                                  "21-synth-pad",
                                                  "22-drums"]

    class func beatsToSeconds(beats: Double, bpm: Double) -> Double {
        return beats * 60 / bpm
    }

    class func beatsToSeconds(beatsFormula: Formula, bpm: Double, spriteObject: SpriteObject, context: CBScriptContextProtocol) -> Double {
        let beats = context.formulaInterpreter.interpretDouble(beatsFormula, for: spriteObject)
        return beatsToSeconds(beats: beats, bpm: bpm)
    }

    class func stringFormulaToUtterance(text: Formula, spriteObject: SpriteObject, context: CBScriptContextProtocol) -> AVSpeechUtterance {
        var speakText = context.formulaInterpreter.interpretString(text, for: spriteObject)
        if Double(speakText) != nil {
            let num = (speakText as NSString).doubleValue
            speakText = (num as NSNumber).stringValue
        }

        let utterance = AVSpeechUtterance(string: speakText)
        utterance.rate = (floor(NSFoundationVersionNumber) < 1200 ? 0.15 : 0.5)

        return utterance
    }
}

enum SoundEffectType: Int {
    case pitch = 0, pan
}

enum SamplerType: String {
    case instrument = "instrument", drum = "drum"
}
