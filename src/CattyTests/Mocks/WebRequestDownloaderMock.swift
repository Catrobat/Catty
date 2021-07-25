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

@testable import Pocket_Code

class WebRequestDownloaderMock: WebRequestDownloader {

    var downloadMethodCalls = 0
    var expectedResponse: String?
    var expectedError: WebRequestDownloaderError?

    required init(url: String, session: URLSession?, trustedDomainManager: TrustedDomainManager?) {
        super.init(url: url, session: session, trustedDomainManager: nil)
    }

    required init(expectedResponse: String? = nil, expectedError: WebRequestDownloaderError? = nil) {
        self.expectedResponse = expectedResponse
        self.expectedError = expectedError
        super.init(url: "", session: nil, trustedDomainManager: nil)
    }

    override func download(force: Bool, completion: @escaping (String?, WebRequestDownloaderError?) -> Void) {
        downloadMethodCalls += 1
        completion(expectedResponse, expectedError)
    }
}

class WebRequestDownloaderFactoryMock: WebRequestDownloaderFactory {

    let downloaderMock: WebRequestDownloader
    var latestUrl: String?

    required init(_ downloaderMock: WebRequestDownloader) {
        self.downloaderMock = downloaderMock
    }

    override func create(url: String, session: URLSession? = nil, trustedDomainManager: TrustedDomainManager? = nil) -> WebRequestDownloader {
        self.latestUrl = url
        return downloaderMock
    }
}
