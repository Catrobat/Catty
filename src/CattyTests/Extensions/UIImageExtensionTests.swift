/**
 *  Copyright (C) 2010-2016 The Catrobat Team
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

import XCTest

@testable import Pocket_Code

final class UIImageExtensionTests: XCTestCase {
    
    struct PixelDataARGB {
        var a:UInt8 = 255
        var r:UInt8
        var g:UInt8
        var b:UInt8
    }
    
    struct PixelDataRGBA {
        var r:UInt8
        var g:UInt8
        var b:UInt8
        var a:UInt8 = 255
    }
    
    func testTransparencyRGBA() {
        let bundlePath = NSBundle(forClass: self.dynamicType).pathForResource("transparency-rgba", ofType: "png")
        let image = UIImage(contentsOfFile: bundlePath!)
        
        let nonTransparentPoints = [
            CGPoint(x: 1, y: 1),
            CGPoint(x: 8, y: 0),
            CGPoint(x: 7, y: 2),
            CGPoint(x: 3, y: 4),
            CGPoint(x: 1, y: 6),
            CGPoint(x: 6, y: 6),
            CGPoint(x: 2, y: 7),
            CGPoint(x: 9, y: 9)
        ]
        
        for pixelX in 0..<10 {
            for pixelY in 0..<10 {
                let point = CGPoint(x: pixelX, y: pixelY)
                
                var expectedTransparency = true
                for nonTransparentPoint in nonTransparentPoints {
                    if nonTransparentPoint == point {
                        expectedTransparency = false
                        break
                    }
                }
                
                let isTransparent = image!.isTransparentPixelAtPoint(point)
                XCTAssertEqual(expectedTransparency, isTransparent, "Wrong alpha value at point")
            }
        }
    }
    
    func testTransparencyGrayAlpha() {
        let bundlePath = NSBundle(forClass: self.dynamicType).pathForResource("transparency-gray-alpha", ofType: "png")
        let image = UIImage(contentsOfFile: bundlePath!)
        
        let nonTransparentPoints = [
            CGPoint(x: 1, y: 1),
            CGPoint(x: 8, y: 0),
            CGPoint(x: 7, y: 2),
            CGPoint(x: 3, y: 4),
            CGPoint(x: 1, y: 6),
            CGPoint(x: 6, y: 6),
            CGPoint(x: 2, y: 7),
            CGPoint(x: 9, y: 9)
        ]
        
        for pixelX in 0..<10 {
            for pixelY in 0..<10 {
                let point = CGPoint(x: pixelX, y: pixelY)
                
                var expectedTransparency = true
                for nonTransparentPoint in nonTransparentPoints {
                    if nonTransparentPoint == point {
                        expectedTransparency = false
                        break
                    }
                }
                
                let isTransparent = image!.isTransparentPixelAtPoint(point)
                XCTAssertEqual(expectedTransparency, isTransparent, "Wrong alpha value at point")
            }
        }
    }
    
    func testTransparencyRGB() {
        let bundlePath = NSBundle(forClass: self.dynamicType).pathForResource("transparency-rgb", ofType: "png")
        let image = UIImage(contentsOfFile: bundlePath!)
        
        for pixelX in 0..<10 {
            for pixelY in 0..<10 {
                let point = CGPoint(x: pixelX, y: pixelY)
                let isTransparent = image!.isTransparentPixelAtPoint(point)
                XCTAssertFalse(isTransparent, "Wrong alpha value at point")
            }
        }
    }
    
    func testTransparencyARGB() {
      let pixels: [PixelDataARGB] = [
            PixelDataARGB(a: 0, r: 0, g: 0, b: 0),
            PixelDataARGB(a: 255, r: 0, g: 0, b: 0),
            PixelDataARGB(a: 10, r: 10, g: 10, b: 10)
        ]
        
        let image = self.imageFromARGB(pixels, width: 1, height: 3)
        XCTAssertNotNil(image, "Image should not be nil")
        
        XCTAssertTrue(image.isTransparentPixelAtPoint(CGPoint(x: 0, y: 0)), "Wrong alpha value at point (0, 0)")
        XCTAssertFalse(image.isTransparentPixelAtPoint(CGPoint(x: 0, y: 1)), "Wrong alpha value at point (0, 1)")
        XCTAssertFalse(image.isTransparentPixelAtPoint(CGPoint(x: 0, y: 2)), "Wrong alpha value at point (0, 2)")
    }
    
    func imageFromARGB(pixels:[PixelDataARGB], width:Int, height:Int)->UIImage {
        assert(pixels.count == Int(width * height))
        
        var data = pixels
        let providerRef = CGDataProviderCreateWithCFData(
            NSData(bytes: &data, length: data.count * 4)
        )
        
        let cgim = CGImageCreate(
            width,
            height,
            8,
            32,
            width * 4,
            CGColorSpaceCreateDeviceRGB(),
            CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedFirst.rawValue),
            providerRef,
            nil,
            true,
            CGColorRenderingIntent.RenderingIntentDefault
        )
        
        return UIImage(CGImage: cgim!)
    }
}
