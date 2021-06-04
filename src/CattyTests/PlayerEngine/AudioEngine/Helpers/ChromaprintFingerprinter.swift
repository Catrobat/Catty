/**
 *  Copyright (C) 2010-2021 The Catrobat Team
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

import AVFoundation
import Chromaprint

class ChromaprintFingerprinter {

    public func generateFingerprint(fromSongAtUrl songUrl: URL) -> (String, Double)? {

        /// Set the maximum number of seconds we're going to use for fingerprinting
        let maxLength = 120

        /** Create an instance of an unsafe mutable pointer of unknown length so we can
         pass it to chromaprint_get_raw_fingerprint without errors.
         The defer ensures it is not leaked if we drop out early.
         */
        var rawFingerprint: UnsafeMutablePointer<UInt32>? = UnsafeMutablePointer<UInt32>.allocate(capacity: 1)
        var fingerprintSize = Int32(bigEndian: 0)
        var simHash = UInt32(bigEndian: 0)

        defer {
            rawFingerprint?.deallocate()
        }

        // Start by creating a chromaprint context.
        let algo = Int32(CHROMAPRINT_ALGORITHM_TEST2.rawValue)
        guard let chromaprintContext = chromaprint_new(algo) else { return nil }

        /// Decode the song and get back its duration.
        /// The chromaprintContext will contain the fingerprint.
        let audioDecoder = ChromaprintAudioDecoder()
        let duration = audioDecoder.decodeAudio(songUrl, withMaxLength: maxLength, forContext: chromaprintContext)

        // Make a raw fingerprint from the song data.
        if chromaprint_get_raw_fingerprint(chromaprintContext, &rawFingerprint, &fingerprintSize) == 0 {
            print("Error: could not get fingerprint")
            return nil
        }

        // Calculate the SimHash from the raw fingerprint
        if chromaprint_hash_fingerprint(rawFingerprint, fingerprintSize, &simHash) == 0 {
            print("Error: could not get similarity hash")
            return nil
        }

        var simHashString = String(simHash, radix: 2)
        simHashString = pad(string: simHashString, toSize: 32)

        chromaprint_free(chromaprintContext)
        return (String(describing: simHashString), duration)
    }

    private func pad(string: String, toSize: Int) -> String {
        var padded = string
        for _ in 0..<(toSize - string.count) {
            padded = "0" + padded
        }
        return padded
    }
}
