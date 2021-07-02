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

extension WebRequestBrick: CBInstructionProtocol {

    @nonobjc func instruction() -> CBInstruction {
        if WebRequestBrick.isWebRequestBrickEnabled() {
            guard let request = self.request else { fatalError("Unexpected found nil.") }
            guard let trustedDomains = TrustedDomainManager() else { return CBInstruction.invalidInstruction }
            _ = trustedDomains.clear() // TODO: Remove in CATTY-600

            return CBInstruction.waitExecClosure { context, scheduler in
                let displayString = context.formulaInterpreter.interpretString(request, for: self.script.object)
                let requestString = self.prepareRequestString(input: displayString)
                let downloader = self.downloaderFactory.create(url: requestString, trustedDomainManager: trustedDomains)

                self.sendRequest(downloader: downloader) { response, error in
                    if let error = error, case WebRequestDownloaderError.notTrusted = error {
                        DispatchQueue.main.async {
                            AlertControllerBuilder.alert(title: kLocalizedAllowWebAccess + "?", message: requestString)
                                .addCancelAction(title: kLocalizedNo) {
                                    self.callbackSubmit(with: nil, error: .notTrusted, scheduler: scheduler)
                                    return
                                }
                                .addDefaultAction(title: kLocalizedYes) {
                                    let addError = trustedDomains.add(url: requestString)
                                    if addError != nil {
                                        self.callbackSubmit(with: nil, error: .unexpectedError, scheduler: scheduler)
                                    } else {
                                        self.sendRequest(downloader: downloader) { response, error in
                                            self.callbackSubmit(with: response, error: error, scheduler: scheduler)
                                        }
                                    }
                                }
                                .build()
                                .showWithController(Util.topmostViewController())
                        }
                    } else {
                        self.callbackSubmit(with: response, error: error, scheduler: scheduler)
                    }
                }

                scheduler.pause()
            }
        } else {
            return CBInstruction.invalidInstruction
        }
    }

    func callbackSubmit(with input: String?, error: WebRequestDownloaderError?, scheduler: CBSchedulerProtocol) {
        if let userVariable = self.userVariable {
            userVariable.value = extractMessage(input: input, error: error)
        }

        DispatchQueue.main.async {
          scheduler.resume()
        }
    }

    func prepareRequestString(input: String) -> String {
        var requestString = input
        if requestString.hasPrefix("'") {
            requestString = String(requestString.dropFirst())
        }
        if requestString.hasSuffix("'") {
            requestString = String(requestString.dropLast())
        }
        if !requestString.hasPrefix("https://") && !requestString.hasPrefix("http://") {
            requestString = "https://" + requestString
        }
        return requestString
    }

    private func extractMessage(input: String?, error: WebRequestDownloaderError?) -> String {
        guard let input = input else {
            guard let error = error else {
                return kLocalizedUnexpectedErrorTitle
            }
            return error.message()
        }
        return input
    }

    private func sendRequest(downloader: WebRequestDownloader, completion: @escaping (String?, WebRequestDownloaderError?) -> Void) {
        downloader.download { response, error in
            if let error = error {
                completion(nil, WebRequestDownloaderError(downloaderError: error))
            } else {
                completion(response, nil)
            }
        }
    }

    private static func isWebRequestBrickEnabled() -> Bool {
         UserDefaults.standard.bool(forKey: kUseWebRequestBrick)
    }
}
