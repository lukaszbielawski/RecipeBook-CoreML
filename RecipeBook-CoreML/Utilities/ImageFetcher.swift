//
//  ImageFetcher.swift
//  RecipeBook-CoreML
//
//  Created by Łukasz Bielawski on 12/09/2023.
//

import Foundation
import QuartzCore
import UIKit

enum DownloadError: Error {
    case invalidUrl
    case invalidResponse
    case decodingError
}

final class ImageDownloader {
    private(set) static var shared = ImageDownloader()

    private init() {}

    func downloadImage(from url: String, crop: Bool = true) async throws -> UIImage {
        guard let url = URL(string: url) else {
            throw DownloadError.invalidUrl
        }

        let (data, response) = try await URLSession.shared.data(for: URLRequest(url: url))

        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw DownloadError.invalidResponse
        }

        let image = UIImage(data: data)
        guard let image = image else {
            throw DownloadError.decodingError
        }

        if crop {
            return image.cropImage
        } else {
            return image
        }
    }
}
