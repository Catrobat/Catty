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

import AudioKit
import Foundation

class AudioRecorder {
    init() {
    }

    static func getNewAudioRecorder(node: AKNode) -> AKAudioFile? {
        // Create file URL
        let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let filePath = documents + "/recorded1"
        let fileURL = URL(fileURLWithPath: filePath)

        FileManager.default.createFile(atPath: fileURL.path, contents: nil, attributes: nil)
        // Create AKAudioFile
        let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 48000, channels: 2, interleaved: true)
        let file: AKAudioFile

        do {
            try file = AKAudioFile(forWriting: fileURL, settings: format!.settings)
            //            let recorder1 = try AKNodeRecorder(node: node)
            //            return recorder1
        } catch {
            return nil
        }

        return file
    }
}
