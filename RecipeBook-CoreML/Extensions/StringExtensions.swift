//
//  StringExtensions.swift
//  RecipeBook-CoreML
//
//  Created by Łukasz Bielawski on 11/09/2023.
//

import Foundation
import UIKit

extension String {
    var insertNewlineAfterEndOfSentence: String {
        self
            .replacingOccurrences(of: ". ", with: ".")
            .replacingOccurrences(of: ".", with: ".\n")
            .replacingOccurrences(of: ".\n)", with: ".)\n")
    }

    func attachIconToString(systemName: String, color: UIColor, margin: CGFloat = 10.0) -> NSMutableAttributedString {
        let imageAttachment = NSTextAttachment()
        let completeText = NSMutableAttributedString(string: "")

        imageAttachment.image = UIImage(systemName: systemName)?.withTintColor(color).withRenderingMode(.alwaysTemplate)
        guard let image = imageAttachment.image else { return completeText }
        imageAttachment.bounds = CGRect(x: 0, y: -3.0,
                                        width: image.size.width * 0.9,
                                        height: image.size.height * 0.9)
        let attachmentString = NSAttributedString(attachment: imageAttachment)
        completeText.append(attachmentString)
        let textAfterIcon = NSAttributedString(string: " \(self)")
        completeText.append(textAfterIcon)
        return completeText
    }
}
