//
//  ProgressLabel.swift
//  RecipeBook-CoreML
//
//  Created by Łukasz Bielawski on 12/09/2023.
//

import Foundation
import UIKit

final class ProgressLabel: PaddingLabel {
    var progressBarColor: UIColor = .raspberryColor
    var fontType = UIFont.boldSystemFont(ofSize: 16)

    var progress: Float = 0 {
        didSet {
            progress = Float.minimum(100.0, Float.maximum(progress, 0.0))
            self.setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        let size = bounds.size
        let progressMessage = NSString(string: "Health score: \(Int(progress))%")
        let stringRange = NSRange(0 ... progressMessage.length + 1)
        let attributedString = String(progressMessage).attachIconToString(systemName: "heart.fill", color: .white)
        let progressX = ceil(CGFloat(progress) / 100 * size.width)
        let textPoint = CGPoint(x: 4, y: 4)

        attributedString.addAttribute(NSAttributedString.Key.font,
                                      value: fontType,
                                      range: stringRange)

        progressBarColor.setFill()
        context.fill(bounds)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                      value: textColor!,
                                      range: stringRange)

        attributedString.draw(at: textPoint)

        context.saveGState()

        let remainingProgressRect = CGRect(x: progressX, y: 0.0, width: size.width - progressX, height: size.height)
        context.addRect(remainingProgressRect)
        context.clip()

        textColor.setFill()
        context.fill(bounds)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                      value: progressBarColor,
                                      range: stringRange)

        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(systemName: "heart")?
            .withTintColor(progressBarColor)
            .withRenderingMode(.alwaysTemplate)
        guard let image = imageAttachment.image else { return }
        imageAttachment.bounds = CGRect(x: 0, y: -3.0,
                                        width: image.size.width * 0.9,
                                        height: image.size.height * 0.9)

        attributedString.addAttribute(NSAttributedString.Key.attachment,
                                      value: imageAttachment,
                                      range: stringRange)
        attributedString.draw(at: textPoint)

        context.restoreGState()
    }
}
