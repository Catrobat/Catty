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

import Nimble
import XCTest

@testable import Pocket_Code

final class PaintViewControllerTests: XCTestCase {

    var navigationController: NavigationControllerMock!

    override func setUp() {
        self.navigationController = NavigationControllerMock()
        self.navigationController.navigationBarFrame = CGRect(origin: .zero, size: CGSize(width: 100, height: 40))
        self.navigationController.toolbarFrame = CGRect(origin: CGPoint(x: 0, y: 900), size: .zero)

        super.setUp()
    }

    func testNotification() {
        let controller = PaintViewController()
        let expectedNotification = Notification(name: .paintViewControllerDidAppear, object: controller)

        expect(controller.viewDidAppear(true)).to(postNotifications(contain(expectedNotification)))
    }

    func testSetupZoom() {
        let width = CGFloat(100)
        let height = CGFloat(150)

        let image = createImage(CGSize(width: width, height: height))
        let controller = PaintViewControllerMock(editingImage: image, navigationController: navigationController)

        XCTAssertEqual(width, image.size.width)

        XCTAssertEqual(CGRect.zero, controller!.drawView.frame)

        controller?.setupZoom(for: image)

        XCTAssertEqual(width, controller!.drawView.frame.width)
        XCTAssertEqual(height, controller!.drawView.frame.height)
    }

    func testSetupZoomLongPortrait() {
        let width = CGFloat(1200)
        let height = CGFloat(3648)
        let ratio = width / height

        let image = createImage(CGSize(width: width, height: height))
        let controller = PaintViewControllerMock(editingImage: image, navigationController: navigationController)

        XCTAssertEqual(width, image.size.width)

        XCTAssertEqual(CGRect.zero, controller!.drawView.frame)

        controller?.setupZoom(for: image)
        let ratioAfterZoom = controller!.drawView.frame.width / controller!.drawView.frame.height
        XCTAssertTrue(Double(ratio - ratioAfterZoom) <= Double.epsilon)

        let viewHeight = controller!.navigationController!.toolbar.frame.origin.y - Util.statusBarHeight() - controller!.navigationController!.navigationBar.frame.size.height
        XCTAssertEqual(viewHeight * 0.9, controller!.drawView.frame.height)
    }

    func testSetupZoomWideLandscape() {
        let width = CGFloat(2500)
        let height = CGFloat(479)
        let ratio = width / height

        let image = createImage(CGSize(width: width, height: height))
        let controller = PaintViewControllerMock(editingImage: image, navigationController: navigationController)

        XCTAssertEqual(width, image.size.width)

        XCTAssertEqual(CGRect.zero, controller!.drawView.frame)

        controller?.setupZoom(for: image)
        let ratioAfterZoom = controller!.drawView.frame.width / controller!.drawView.frame.height
        XCTAssertTrue(Double(ratio - ratioAfterZoom) <= Double.epsilon)

        let viewWidth = controller!.view.bounds.size.width
        XCTAssertEqual(viewWidth * 0.9, controller!.drawView.frame.width)
    }

    func testSetupZoomCenterPosition() {
        let width = CGFloat(100)
        let height = CGFloat(150)

        let image = createImage(CGSize(width: width, height: height))
        let controller = PaintViewControllerMock(editingImage: image, navigationController: navigationController)

        controller?.setupZoom(for: image)

        let horizontalDistanceLeftEdge = controller!.helper.frame.origin.x
        let horizontalDistanceRightEdge = controller!.scrollView.bounds.size.width - (horizontalDistanceLeftEdge + controller!.helper.frame.size.width)

        XCTAssertTrue(Double(horizontalDistanceLeftEdge - horizontalDistanceRightEdge) <= Double.epsilon)

        let verticalDistanceUpperEdge = controller!.helper.frame.origin.y
        let verticalDistanceLowerEdge = controller!.scrollView.bounds.size.height - (verticalDistanceUpperEdge + controller!.helper.frame.size.height)

        XCTAssertTrue(Double(verticalDistanceUpperEdge - verticalDistanceLowerEdge) <= Double.epsilon)
    }

    private func createImage(_ size: CGSize) -> UIImage {
        let rect = CGRect(origin: .zero, size: size)

        UIGraphicsBeginImageContextWithOptions(rect.size, false, 1.0)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return UIImage(cgImage: image!.cgImage!)
    }
}
