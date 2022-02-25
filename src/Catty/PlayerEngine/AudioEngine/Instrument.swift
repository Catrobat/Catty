/**
 *  Copyright (C) 2010-2022 The Catrobat Team
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

@objc enum Instrument: Int, CaseIterable {
    case piano
    case electricPiano
    case cello
    case flute
    case vibraphone
    case organ
    case guitar
    case electricGuitar
    case bass
    case pizzicato
    case synthPad
    case choir
    case synthLead
    case woodenFlute
    case trombone
    case saxophone
    case bassoon
    case clarinet
    case musicBox
    case steelDrum
    case marimba

    var localizedName: String { self.data.localizedName }
    var tag: String { self.data.tag }
    var fileName: String { self.data.folder + ".sfz" }

    var url: URL? {
        if let resourcePath = Bundle.main.resourcePath {
            return URL(fileURLWithPath: resourcePath + "/Audio Engine/Sample Instruments Compressed/" + self.data.folder + "/" + self.fileName)
        }
        return nil
    }

    private var data: (tag: String, localizedName: String, folder: String) {
        switch self {
        case .piano:
            return ("PIANO", kLocalizedPiano, "piano")
        case .electricPiano:
            return ("ELECTRIC_PIANO", kLocalizedElectricPiano, "electric-piano")
        case .cello:
            return ("CELLO", kLocalizedCello, "cello")
        case .flute:
            return ("FLUTE", kLocalizedFlute, "flute")
        case .vibraphone:
            return ("VIBRAPHONE", kLocalizedVibraphone, "vibraphone")
        case .organ:
            return ("ORGAN", kLocalizedOrgan, "organ")
        case .guitar:
            return ("GUITAR", kLocalizedGuitar, "guitar")
        case .electricGuitar:
            return ("ELECTRIC_GUITAR", kLocalizedElectricGuitar, "electric-guitar")
        case .bass:
            return ("BASS", kLocalizedBass, "bass")
        case .pizzicato:
            return ("PIZZICATO", kLocalizedPizzicato, "pizzicato")
        case .synthPad:
            return ("SYNTH_PAD", kLocalizedSynthPad, "synth-pad")
        case .choir:
            return ("CHOIR", kLocalizedChoir, "choir")
        case .synthLead:
            return ("SYNTH_LEAD", kLocalizedSynthLead, "synth-lead")
        case .woodenFlute:
            return ("WOODEN_FLUTE", kLocalizedWoodenFlute, "wooden-flute")
        case .trombone:
            return ("TROMBONE", kLocalizedTrombone, "trombo")
        case .saxophone:
            return ("SAXOPHONE", kLocalizedSaxophone, "saxophone")
        case .bassoon:
            return ("BASSOON", kLocalizedBassoon, "basso")
        case .clarinet:
            return ("CLARINET", kLocalizedClarinet, "clarinet")
        case .musicBox:
            return ("MUSIC_BOX", kLocalizedMusicBox, "music-box")
        case .steelDrum:
            return ("STEEL_DRUM", kLocalizedSteelDrum, "steel-drum")
        case .marimba:
            return ("MARIMBA", kLocalizedMarimba, "marim")
        }
    }

    static func from(tag: String) -> Instrument? {
        for instrument in Instrument.allCases where instrument.tag == tag {
            return instrument
        }
        return nil
    }

    static func from(localizedName: String) -> Instrument? {
        for instrument in Instrument.allCases where instrument.localizedName == localizedName {
            return instrument
        }
        return nil
    }
}
