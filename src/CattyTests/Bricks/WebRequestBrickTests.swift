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

import Nimble
@testable import Pocket_Code
import XCTest

final class WebRequestBrickTests: XCTestCase {

    var scheduler: CBScheduler!
    var context: CBScriptContextProtocol!
    var brick: WebRequestBrick!
    var downloaderMock: WebRequestDownloaderMock!
    var downloaderFactoryMock: WebRequestDownloaderFactoryMock!

    override func setUp() {
        let scene = Scene()
        let object = SpriteObjectMock(scene: scene)
        let script = StartScript()
        script.object = object

        let url = "http://catrob.at/joke"
        let formula = Formula(string: url)
        let userVariable = UserVariable(name: "var")

        brick = WebRequestBrick(request: formula!, userVariable: userVariable, script: script)

        let logger = CBLogger(name: "Logger")
        let broadcastHandler = CBBroadcastHandler(logger: logger)
        let formulaInterpreter = FormulaManager(stageSize: Util.screenSize(true), landscapeMode: false)

        scheduler = CBScheduler(logger: logger, broadcastHandler: broadcastHandler, formulaInterpreter: formulaInterpreter, audioEngine: AudioEngineMock())
        scheduler.running = true

        context = CBScriptContextMock(object: object, script: script, formulaManager: formulaInterpreter)

        downloaderMock = WebRequestDownloaderMock()
        downloaderFactoryMock = WebRequestDownloaderFactoryMock(downloaderMock)
        brick.downloaderFactory = downloaderFactoryMock

        UserDefaults.standard.setValue(true, forKey: kUseWebRequestBrick)
    }

    private func callInstructionAndWaitExecClosure() {
        DispatchQueue.global().async {
            switch self.brick.instruction() {
            case let .waitExecClosure(closure):
                closure(self.context, self.scheduler)
            default:
                XCTFail("Fatal Error")
            }
        }
    }

    func testCallbackSubmitSuccess() {
        let expectedValue = "RequestResponse"
        XCTAssertNotEqual(expectedValue, brick.userVariable?.value as? String)

        brick.callbackSubmit(with: expectedValue, error: nil, expectation: CBExpectation())

        XCTAssertEqual(expectedValue, brick.userVariable?.value as? String)
    }

    func testCallbackSubmitSuccessNoUserVariable() {
        brick.userVariable = nil

        brick.callbackSubmit(with: "request", error: nil, expectation: CBExpectation())

        XCTAssertEqual(brick.userVariable, nil)
    }

    func testPrepareRequestString() {
        var input = "catrob.at/joke"
        var output = brick.prepareRequestString(input: input)
        XCTAssertEqual(output, "https://" + input)

        input = "http://catrob.at/joke"
        output = brick.prepareRequestString(input: input)
        XCTAssertEqual(output, input)

        input = "https://catrob.at/joke"
        output = brick.prepareRequestString(input: input)
        XCTAssertEqual(output, input)

        input = "'http://catrob.at/joke'"
        output = brick.prepareRequestString(input: input)
        XCTAssertEqual(output, "http://catrob.at/joke")
    }

    func testWebRequestDownloaderUrl() {
        let expectedUrl = "https://catrob.at/test"
        brick.request = Formula(string: expectedUrl)

        XCTAssertNil(downloaderFactoryMock.latestUrl)

        callInstructionAndWaitExecClosure()

        expect(self.downloaderFactoryMock.latestUrl).toEventually(equal(expectedUrl))
    }

    func testSchedulerPaused() {
        downloaderMock.expectedError = .notTrusted

        XCTAssertTrue(scheduler.running)

        callInstructionAndWaitExecClosure()

        expect(self.scheduler.running).toEventually(beFalse(), timeout: .seconds(3))
    }

    func testUrlIsNotInTrustedDomains() {
        downloaderMock.expectedError = .notTrusted

        callInstructionAndWaitExecClosure()

        expect(Util.topmostViewController().isKind(of: UIAlertController.self)).toEventually(beTruthy(), timeout: .seconds(3))

        let alertController = Util.topmostViewController() as! UIAlertController
        let actions = alertController.actions

        XCTAssertEqual(3, actions.count)
        XCTAssertEqual(kLocalizedOnce, actions.first?.title)
        XCTAssertEqual(kLocalizedDeny, actions.last?.title)
    }

    func testUrlInTrustedDomains() {
        downloaderMock.expectedError = .none
        XCTAssertTrue(scheduler.running)

        callInstructionAndWaitExecClosure()

        expect(self.downloaderMock.downloadMethodCalls).toEventually(equal(1))
        expect(self.scheduler.running).toEventually(beTrue())
    }

    func testWebRequestDownloaderError() {
        downloaderMock.expectedError = .unexpectedError

        XCTAssertTrue(scheduler.running)
        XCTAssertNil(brick.userVariable?.value)

        callInstructionAndWaitExecClosure()

        expect(self.downloaderMock.downloadMethodCalls).toEventually(equal(1))
        expect(self.scheduler.running).toEventually(beTrue())
        expect(self.brick.userVariable?.value as? String).toEventually(equal(WebRequestDownloaderError.unexpectedError.message()))
    }

    func testWebRequestDownloaderErrorInvalidURL() {
        downloaderMock.expectedError = .invalidURL

        callInstructionAndWaitExecClosure()

        expect(self.brick.userVariable?.value as? String).toEventually(equal(WebRequestDownloaderError.invalidURL.message()))
    }

    func testSuccessfulDownload() {
        let expectedResponse = "Response"
        downloaderMock.expectedResponse = expectedResponse

        callInstructionAndWaitExecClosure()

        expect(self.downloaderMock.downloadMethodCalls).toEventually(equal(1))
        expect(self.scheduler.running).toEventually(beTrue())
        expect(self.brick.userVariable?.value as? String).toEventually(equal(expectedResponse))
    }
}
