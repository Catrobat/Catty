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

import Foundation

class TrustedDomainManager {
    private let defaultTrustedDomainPath: URL?
    private let deviceTrustedDomainPath: URL
    private var trustedDomains = [String]()
    private var fileManager: CBFileManager

    init?(fileManager: CBFileManager = CBFileManager()) {
        self.fileManager = fileManager

        defaultTrustedDomainPath = Bundle.main.url(forResource: "TrustedDomains", withExtension: "plist")

        guard let documentDirectoryUrls = self.fileManager.urls(.documentDirectory, in: .userDomainMask) as? [String] else { return nil }
        guard let documentDirectoryUrl = URL(string: documentDirectoryUrls[0]) else { return nil }
        deviceTrustedDomainPath = documentDirectoryUrl.appendingPathComponent(kTrustedDomainFilename + ".plist")

        let creationError = createTrustedDomainsOnDeviceIfNotExist()
        let fetchingError = fetchTrustedDomains()

        if creationError != nil || fetchingError != nil {
            return nil
        }
    }

    // Just needed for CATTY-571
    func clear() -> TrustedDomainManagerError? {
        trustedDomains.removeAll()
        return storeTrustedDomains()
    }

    private func createTrustedDomainsOnDeviceIfNotExist() -> TrustedDomainManagerError? {
        guard let defaultPath = defaultTrustedDomainPath?.path else { return .plist }
        let devicePath = deviceTrustedDomainPath.absoluteString

        if !fileManager.fileExists(devicePath) {
            fileManager.copyExistingFile(atPath: defaultPath, toPath: devicePath, overwrite: true)
        }

        return nil
    }

    private func fetchTrustedDomains() -> TrustedDomainManagerError? {
        guard let data = fileManager.read(deviceTrustedDomainPath.path) else { return .unexpectedError }
        guard let domains = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String] else { return .unexpectedError }
        trustedDomains = domains
        return nil
    }

    private func storeTrustedDomains() -> TrustedDomainManagerError? {
        let encoder = PropertyListEncoder()

        if let data = try? encoder.encode(trustedDomains) {
            let success = fileManager.write(data, toPath: deviceTrustedDomainPath.path)
            if !success {
                return .unexpectedError
            }
        }

        return nil
    }

    private func standardizeUrl(url: String) -> String {
        var requestedURL = url
        if requestedURL.hasPrefix("'") {
            requestedURL = String(requestedURL.dropFirst())
        }
        if requestedURL.hasSuffix("'") {
            requestedURL = String(requestedURL.dropLast())
        }
        if requestedURL.hasSuffix("/") {
            requestedURL = String(requestedURL.dropLast())
        }
        return requestedURL
    }

    func isUrlInTrustedDomains(url: String) -> Bool {
        trustedDomains.contains(standardizeUrl(url: url))
    }

    func add(url: String) -> TrustedDomainManagerError? {
        trustedDomains.append(standardizeUrl(url: url))
        return storeTrustedDomains()
    }
}

enum TrustedDomainManagerError: Error {
    /// Indicates an invalid plist file
    case plist
    /// Indicates an unexpected error
    case unexpectedError
}
