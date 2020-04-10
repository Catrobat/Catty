/**
 *  Copyright (C) 2010-2020 The Catrobat Team
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
import WebKit
import XCTest

@testable import Pocket_Code

class DemoNavigationAction: WKNavigationAction {
    let testRequest: URLRequest
    override var request: URLRequest {
         testRequest
    }

    init(testRequest: URLRequest) {
        self.testRequest = testRequest
        super.init()
    }
}

final class HelpWebViewControllerTests: XCTestCase {

    func testDecidePolicyForNavigationAllow() {
        let webView = WKWebView()
        let viewController = HelpWebViewController()

        let expectation = XCTestExpectation(description: "NavigationActionPolicy allowed when URL is valid and is not a download URL")

        if let url = URL(string: NetworkDefines.helpUrl) {
            let testRequest1 = URLRequest(url: url)
            let navigationAction = DemoNavigationAction(testRequest: testRequest1)
            viewController.webView(webView, decidePolicyFor: navigationAction) { navigationActionPolicy in
                XCTAssertEqual(navigationActionPolicy, WKNavigationActionPolicy.allow)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 1)
    }

    func testDecidePolicyForNavigationCancelWhenInvalidUrl() {
        let webView = WKWebView()
        let viewController = HelpWebViewController()

        let expectation = XCTestExpectation(description: "NavigationActionPolicy canceled when URL is invalid")

        if let url = URL(string: "some_invalid_url") {
            let testRequest2 = URLRequest(url: url)
            let navigationAction = DemoNavigationAction(testRequest: testRequest2)
            viewController.webView(webView, decidePolicyFor: navigationAction) { navigationActionPolicy in
                XCTAssertEqual(navigationActionPolicy, WKNavigationActionPolicy.cancel)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 1)
    }

    func testDecidePolicyForNavigationCancelWhenMissingProjectID() {
        let webView = WKWebView()
        let viewController = HelpWebViewController()

        let expectation = XCTestExpectation(description: "NavigationActionPolicy canceled when project ID is misisng from download URL")

        if let url = URL(string: NetworkDefines.downloadUrl + "/.catrobat?fname=some_name") {
            let testRequest4 = URLRequest(url: url)
            let navigationAction = DemoNavigationAction(testRequest: testRequest4)
            viewController.webView(webView, decidePolicyFor: navigationAction) { navigationActionPolicy in
                XCTAssertEqual(navigationActionPolicy, WKNavigationActionPolicy.cancel)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 1)
    }

    func testDecidePolicyForNavigationCancelWhenMissingProjectName() {
        let webView = WKWebView()
        let viewController = HelpWebViewController()

        let expectation = XCTestExpectation(description: "NavigationActionPolicy canceled when project name is misisng from download URL")

        if let url = URL(string: NetworkDefines.downloadUrl + "/1234.catrobat") {
            let testRequest3 = URLRequest(url: url)
            let navigationAction = DemoNavigationAction(testRequest: testRequest3)
            viewController.webView(webView, decidePolicyFor: navigationAction) { navigationActionPolicy in
                XCTAssertEqual(navigationActionPolicy, WKNavigationActionPolicy.cancel)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 1)
    }

    func testDecidePolicyForNavigationCancelWhenInvalidDownloadURL() {
        let webView = WKWebView()
        let viewController = HelpWebViewController()

        let expectation = XCTestExpectation(description: "NavigationActionPolicy canceled when an invalid download URL detected")

        if let url = URL(string: NetworkDefines.downloadUrl + "/123catrobat?fname=some+project+name") {
            let testRequest4 = URLRequest(url: url)
            let navigationAction = DemoNavigationAction(testRequest: testRequest4)
            viewController.webView(webView, decidePolicyFor: navigationAction) { navigationActionPolicy in
                XCTAssertEqual(navigationActionPolicy, WKNavigationActionPolicy.cancel)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 1)
    }

    func testDecidePolicyForNavigationCancelWhenProjectExists() {
        let webView = WKWebView()
        let viewController = HelpWebViewController()

        let expectation = XCTestExpectation(description: "NavigationActionPolicy canceled when project to download already exists")

        if let url = URL(string: NetworkDefines.downloadUrl + "/123.catrobat?fname=My+first+project") {
            let testRequest4 = URLRequest(url: url)
            let navigationAction = DemoNavigationAction(testRequest: testRequest4)
            viewController.webView(webView, decidePolicyFor: navigationAction) { navigationActionPolicy in
                XCTAssertEqual(navigationActionPolicy, WKNavigationActionPolicy.cancel)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 1)
    }

     func testDecidePolicyForNavigationCancelWhenValidDownloadURL() {
           let webView = WKWebView()
           let viewController = HelpWebViewController()

           let expectation = XCTestExpectation(description: "NavigationActionPolicy canceled when a valid download URL is detected")

           if let url = URL(string: NetworkDefines.downloadUrl + "/123.catrobat?fname=some_name") {
               let testRequest4 = URLRequest(url: url)
               let navigationAction = DemoNavigationAction(testRequest: testRequest4)
               viewController.webView(webView, decidePolicyFor: navigationAction) { navigationActionPolicy in
                   XCTAssertEqual(navigationActionPolicy, WKNavigationActionPolicy.cancel)
                   expectation.fulfill()
               }
           }

           wait(for: [expectation], timeout: 1)
       }

}
