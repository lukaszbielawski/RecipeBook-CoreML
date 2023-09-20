//
//  ImageClassifier.swift
//  RecipeBook-CoreML
//
//  Created by Łukasz Bielawski on 19/09/2023.
//

import CoreML
import Foundation
import UIKit
import Vision

enum ImagePredictorError: Error {
    case mlModelInit
    case visionCoreModelInit
    case imageClassifierInit
    case noCGImage
    case noPredictionHandler
}

class ImagePredictor {
    static func createVisionImageClassifier() throws -> VNCoreMLModel {
        let mlModelImageClassifier = try? IngredientsModel(configuration: MLModelConfiguration())

        guard let mlModelImageClassifier else {
            throw ImagePredictorError.mlModelInit
        }

        guard let visionImageClassifier = try? VNCoreMLModel(for: mlModelImageClassifier.model) else {
            throw ImagePredictorError.visionCoreModelInit
        }

        return visionImageClassifier
    }

    private static let imageClassifier = try? createVisionImageClassifier()

    private var predictionHandlers = [VNRequest: ([VNClassificationObservation]?) -> Void]()

    private func createImageClassificationRequest() throws -> VNImageBasedRequest {
        guard let imageClassifier = Self.imageClassifier else {
            throw ImagePredictorError.imageClassifierInit
        }

        let imageClassificationRequest = VNCoreMLRequest(model: imageClassifier,
                                                         completionHandler: visionRequestHandler)

        imageClassificationRequest.imageCropAndScaleOption = .centerCrop
        return imageClassificationRequest
    }

    func makePredictions(for photo: UIImage,
                         completionHandler: @escaping ([VNClassificationObservation]?) -> Void) throws
    {
        let orientation = photo.imageOrientation.toCGImagePropertyOrientation

        guard let photoImage = photo.cgImage else {
            throw ImagePredictorError.noCGImage
        }

        let imageClassificationRequest = try createImageClassificationRequest()
        predictionHandlers[imageClassificationRequest] = completionHandler

        let handler = VNImageRequestHandler(cgImage: photoImage, orientation: orientation)
        let requests: [VNRequest] = [imageClassificationRequest]

        try handler.perform(requests)
    }

    private func visionRequestHandler(_ request: VNRequest, error: Error?) {
        guard let predictionHandler = predictionHandlers.removeValue(forKey: request) else {
            print("No prediction handler")
            return
        }

        if let error {
            print("Vision image classification error...\n\n\(error.localizedDescription)")
            return
        }

        if request.results == nil {
            print("Vision request had no results.")
            return
        }

        guard let observations = request.results as? [VNClassificationObservation] else {
            print("VNRequest produced the wrong result type: \(type(of: request.results)).")
            return
        }

        predictionHandler(observations)
    }
}
