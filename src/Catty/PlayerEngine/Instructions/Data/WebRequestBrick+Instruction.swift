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

    static let alertSemaphore = DispatchSemaphore(value: 1)

    @nonobjc func instruction() -> CBInstruction {
        if WebRequestBrick.isWebRequestBrickEnabled() {
            guard let request = self.request else { fatalError("Unexpected found nil.") }
            guard let trustedDomains = TrustedDomainManager() else { return CBInstruction.invalidInstruction }

            return CBInstruction.waitExecClosure { context, scheduler in
                let displayString = context.formulaInterpreter.interpretString(request, for: self.script.object)
                let requestString = self.prepareRequestString(input: displayString)
                let downloader = self.downloaderFactory.create(url: requestString, trustedDomainManager: trustedDomains)

                let downloadIsFinishedExpectation = CBExpectation()

                self.sendRequest(downloader: downloader) { response, error in
                    if let error = error, case WebRequestDownloaderError.notTrusted = error {
                        self.pause(scheduler)

                        DispatchQueue.main.async {
                            type(of: self.alertControllerBuilder).alert(title: kLocalizedAllowWebAccess + "?", message: requestString)
                                .addDefaultAction(title: kLocalizedOnce) {
                                    self.resume(scheduler)
                                    self.allowedOnceAction(downloader: downloader, url: requestString, trustedDomains: trustedDomains, expectation: downloadIsFinishedExpectation)
                                }
                                .addDefaultAction(title: kLocalizedAlways) {
                                    type(of: self.alertControllerBuilder)
                                        .alert(title: kLocalizedAlwaysAllowWebAccess + "?", message: requestString + "\n\n" + kLocalizedAlwaysAllowWebRequestDescription)
                                        .addDefaultAction(title: kLocalizedAlways) {
                                            self.resume(scheduler)
                                            self.allowedAlwaysAction(downloader: downloader, url: requestString, trustedDomains: trustedDomains, expectation: downloadIsFinishedExpectation)
                                        }
                                        .addDefaultAction(title: kLocalizedMoreInformation) {
                                            self.resume(scheduler)
                                            if let url = URL(string: NetworkDefines.kWebRequestWikiURL), UIApplication.shared.canOpenURL(url) {
                                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                            }
                                        }
                                        .addDestructiveAction(title: kLocalizedCancel) {
                                            self.resume(scheduler)
                                            self.callbackSubmit(with: nil, error: .notTrusted, expectation: downloadIsFinishedExpectation)
                                            return
                                        }
                                        .build()
                                        .showWithController(Util.topmostViewController())
                                }
                                .addDestructiveAction(title: kLocalizedDeny) {
                                    self.resume(scheduler)
                                    self.callbackSubmit(with: nil, error: .notTrusted, expectation: downloadIsFinishedExpectation)
                                    return
                                }
                                .build()
                                .showWithController(Util.topmostViewController())
                        }
                    } else {
                        self.callbackSubmit(with: response, error: error, expectation: downloadIsFinishedExpectation)
                    }
                }

                downloadIsFinishedExpectation.wait()
            }
        } else {
            return CBInstruction.invalidInstruction
        }
    }

    func pause(_ scheduler: CBSchedulerProtocol) {
        scheduler.pause()
        type(of: self).alertSemaphore.wait()
    }

    func resume(_ scheduler: CBSchedulerProtocol) {
        scheduler.resume()

        DispatchQueue.main.async {
            type(of: self).alertSemaphore.signal()
        }
    }

    func allowedOnceAction(downloader: WebRequestDownloader, url: String, trustedDomains: TrustedDomainManager, expectation: CBExpectation) {
        self.sendRequest(downloader: downloader, force: true) { response, error in
            self.callbackSubmit(with: response, error: error, expectation: expectation)
        }
    }

    func allowedAlwaysAction(downloader: WebRequestDownloader, url: String, trustedDomains: TrustedDomainManager, expectation: CBExpectation) {
        let addError = trustedDomains.add(url: url)
        if addError != nil {
            self.callbackSubmit(with: nil, error: .unexpectedError, expectation: expectation)
        } else {
            self.sendRequest(downloader: downloader) { response, error in
                self.callbackSubmit(with: response, error: error, expectation: expectation)
            }
        }
    }

    func callbackSubmit(with input: String?, error: WebRequestDownloaderError?, expectation: CBExpectation) {
        if let userVariable = self.userVariable {
            userVariable.value = extractMessage(input: input, error: error)
        }

        DispatchQueue.main.async {
            expectation.fulfill()
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

    private func sendRequest(downloader: WebRequestDownloader, force: Bool = false, completion: @escaping (String?, WebRequestDownloaderError?) -> Void) {
        downloader.download(force: force) { response, error in
            if let error = error {
                completion(nil, error)
            } else {
                completion(response, nil)
            }
        }
    }

    private static func isWebRequestBrickEnabled() -> Bool {
         UserDefaults.standard.bool(forKey: kUseWebRequestBrick)
    }
}
