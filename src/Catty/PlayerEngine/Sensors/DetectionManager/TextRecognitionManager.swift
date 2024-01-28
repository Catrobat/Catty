/**
 *  Copyright (C) 2010-2024 The Catrobat Team
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
import NaturalLanguage
import Vision

extension VisualDetectionManager {
    @available(iOS 13.0, *)
    func handleTextObservations(_ textObservations: [VNRecognizedTextObservation]) {
        guard !textObservations.isEmpty else {
            resetTextRecogntion()
            return
        }

        let topCanditateTextObservations = textObservations.filter({ $0.topCandidates(1).first != nil && $0.topCandidates(1).first!.string.isNotEmpty })

        textBlocksNumber = topCanditateTextObservations.count
        textBlockPosition = topCanditateTextObservations.map({ CGPoint(x: $0.boundingBox.origin.x + $0.boundingBox.width / 2,
                                                                       y: $0.boundingBox.origin.y + $0.boundingBox.height / 2) })
        textBlockSizeRatio = topCanditateTextObservations.map({ max($0.boundingBox.width, $0.boundingBox.height) })

        textBlockFromCamera = topCanditateTextObservations.map({ $0.topCandidates(1).first!.string })
        textFromCamera = textBlockFromCamera.joined(separator: " ")

        textBlockLanguageCode = textBlockFromCamera.map({ detectedLanguage(for: $0) ?? VisualDetectionManager.undefinedLanguage })
    }

    func detectedLanguage(for string: String) -> String? {
        let recognizer = NLLanguageRecognizer()
        recognizer.languageConstraints = [NLLanguage.english, NLLanguage.french, NLLanguage.italian, NLLanguage.german,
                                          NLLanguage.spanish, NLLanguage.portuguese, NLLanguage.simplifiedChinese, NLLanguage.traditionalChinese]
        recognizer.processString(string)
        guard let languageCode = recognizer.dominantLanguage?.rawValue else { return nil }
        return languageCode
    }
}
