/**
 *  Copyright (C) 2010-2023 The Catrobat Team
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
    private let trustedDomainPath: URL?
    private let userTrustedDomainPath: URL
    private var trustedDomains = [String]()
    var userTrustedDomains = [String]()
    private var fileManager: CBFileManager
    private var trustedDomainRegex = String()

    init?(fileManager: CBFileManager = CBFileManager()) {
        self.fileManager = fileManager

        trustedDomainPath = Bundle.main.url(forResource: "TrustedDomains", withExtension: "plist")

        guard let documentDirectoryUrls = self.fileManager.urls(.documentDirectory, in: .userDomainMask) as? [String] else { return nil }
        guard let documentDirectoryUrl = URL(string: documentDirectoryUrls[0]) else { return nil }
        userTrustedDomainPath = documentDirectoryUrl.appendingPathComponent(kTrustedDomainFilename + ".plist")

        let tdFetchingError = fetchTrustedDomains()
        let userTDFetchingError = fetchUserTrustedDomains()
        if tdFetchingError != nil || userTDFetchingError != nil {
            return nil
        }

        trustedDomainRegex = generateTrustedDomainRegex()
    }

    private func fetchTrustedDomains() -> TrustedDomainManagerError? {
        guard let data = fileManager.read(trustedDomainPath?.path) else { return .unexpectedError }
        guard let domains = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String] else { return .unexpectedError }
        trustedDomains = domains
        return nil
    }

    private func fetchUserTrustedDomains() -> TrustedDomainManagerError? {
        guard let data = fileManager.read(userTrustedDomainPath.path) else { return nil } // empty
        guard let domains = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String] else { return .unexpectedError }
        userTrustedDomains = domains
        return nil
    }

    func storeUserTrustedDomains() -> TrustedDomainManagerError? {
        let encoder = PropertyListEncoder()

        if let data = try? encoder.encode(userTrustedDomains) {
            let success = fileManager.write(data, toPath: userTrustedDomainPath.path)
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

    private func generateTrustedDomainRegex() -> String {
        let firstLevel = #"^https?://((www\.)?|[a-zA-Z]+.:(@|[a-zA-Z]+.)(www\.)?)?([a-zA-Z]+\.)?("#
        let domains = trustedDomains.joined(separator: "|").replacingOccurrences(of: ".", with: "\\.")
        let topLevel = ")(:[0-9]{1,5})?(/[a-zA-Z0-9-()@:%_\\\\+~#.?&/=]*)?$"
        return firstLevel + domains + topLevel
    }

    func isUrlInTrustedDomains(url: String) -> Bool {
        let result = url.range(
            of: trustedDomainRegex,
            options: .regularExpression
        )

        if result != nil {
            return true
        }

        return userTrustedDomains.contains(standardizeUrl(url: url))
    }

    func add(url: String) -> TrustedDomainManagerError? {
        userTrustedDomains.append(standardizeUrl(url: url))
        return storeUserTrustedDomains()
    }

    func remove(url: String) -> TrustedDomainManagerError? {
        userTrustedDomains.removeObject(standardizeUrl(url: url))
        return storeUserTrustedDomains()
    }

    func clear() -> TrustedDomainManagerError? {
        userTrustedDomains.removeAll()
        return storeUserTrustedDomains()
    }
}

enum TrustedDomainManagerError: Error {
    /// Indicates an invalid plist file
    case plist
    /// Indicates an unexpected error
    case unexpectedError
}
