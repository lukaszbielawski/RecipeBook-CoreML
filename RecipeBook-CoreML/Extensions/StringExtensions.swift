//
//  StringExtensions.swift
//  RecipeBook-CoreML
//
//  Created by Łukasz Bielawski on 11/09/2023.
//

import Foundation

extension String {
    var removeHtmlTags: String {
        self.replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression, range: nil)
    }

    var removeNewlineCharsAndWhitespaces: String {
        self
            .replacingOccurrences(of: "^\\s*", with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespaces)
    }
}
