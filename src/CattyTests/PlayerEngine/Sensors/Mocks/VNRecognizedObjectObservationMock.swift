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

@testable import Pocket_Code
import Vision

class VNRecognizedObjectObservationMock: VNRecognizedObjectObservation {
    var labelsMock: [VNClassificationObservation] = []
    var boundingBoxMock = CGRect.zero
    override var labels: [VNClassificationObservation] {
        self.labelsMock
    }
    override var boundingBox: CGRect {
        self.boundingBoxMock
    }

    init(labelMock: String, boundingBoxMock: CGRect) {
        self.labelsMock.append(VNClassificationObservationMock(labelMock))
        self.boundingBoxMock = boundingBoxMock
        super.init()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

class VNClassificationObservationMock: VNClassificationObservation {
    var identifierMock: String = ""
    override var identifier: String {
        self.identifierMock
    }

    init(_ labelMock: String) {
        self.identifierMock = labelMock
        super.init()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
