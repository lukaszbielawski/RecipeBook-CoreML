//
//  UIImageExtensions.swift
//  RecipeBook-CoreML
//
//  Created by Łukasz Bielawski on 12/09/2023.
//

import Foundation
import UIKit

extension UIImage {
    var cropImage: UIImage {
        let cgImage = self.cgImage!

        let width = cgImage.width
        let height = cgImage.height
        let tolerance = 0.98

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        let bitmapInfo: UInt32 = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue

        guard let context = CGContext(data: nil,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: bitsPerComponent,
                                      bytesPerRow: bytesPerRow,
                                      space: colorSpace, bitmapInfo:
                                      bitmapInfo),
            let ptr = context.data?.assumingMemoryBound(to: UInt8.self)
        else {
            return self
        }

        context.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: width, height: height))

        var minX = 0
        var minY = 0

        for pixelX in 1 ..< width {
            var whitePixelCounter = 0
            var firstY: Int?
            var firstX: Int?

            for pixelY in 1 ..< height {
                let index = bytesPerRow * Int(pixelY) + bytesPerPixel * Int(pixelX)
                let red = CGFloat(ptr[index]) / 255.0
                let green = CGFloat(ptr[index + 1]) / 255.0
                let blue = CGFloat(ptr[index + 2]) / 255.0
                if red >= tolerance && green >= tolerance && blue >= tolerance {
                    if firstX == nil {
                        firstX = pixelX
                    }
                    whitePixelCounter += 1
                } else {
                    if firstY == nil {
                        firstY = pixelY
                    }
                }
                minX = pixelX
                minY = pixelY
            }
            if whitePixelCounter < height / 4 {
                minX = firstX ?? 0
                minY = firstY ?? 0
                break
            }
        }

        var maxX = 0
        var maxY = 0

        for pixelX in (1 ..< width).reversed() {
            var whitePixelCounter = 0
            var firstY: Int?
            var firstX: Int?

            for pixelY in (1 ..< height).reversed() {
                let index = bytesPerRow * Int(pixelY) + bytesPerPixel * Int(pixelX)
                let red = CGFloat(ptr[index]) / 255.0
                let green = CGFloat(ptr[index + 1]) / 255.0
                let blue = CGFloat(ptr[index + 2]) / 255.0
                if red >= tolerance && green >= tolerance && blue >= tolerance {
                    if firstX == nil {
                        firstX = pixelX
                    }
                    whitePixelCounter += 1
                } else {
                    if firstY == nil {
                        firstY = pixelY
                    }
                }
                maxX = pixelX
                maxY = pixelY
            }
            if whitePixelCounter < height / 4 {
                maxX = firstX ?? 0
                maxY = firstY ?? 0
                break
            }
        }

        let rectX = min(minX, width - maxX)
        let rectY = min(minY, width - maxY)

        let rect = CGRect(x: CGFloat(rectX) * 1.1,
                          y: CGFloat(rectY) * 1.1,
                          width: CGFloat(width) - 2.2 * CGFloat(rectX),
                          height: CGFloat(height) - 2.2 * CGFloat(rectY))

        let croppedImage = self.cgImage!.cropping(to: rect)
        return UIImage(cgImage: croppedImage!, scale: scale, orientation: imageOrientation)
    }
}
