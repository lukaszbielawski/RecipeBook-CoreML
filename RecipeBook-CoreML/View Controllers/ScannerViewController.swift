//
//  ScannerViewController.swift
//  RecipeBook-CoreML
//
//  Created by Łukasz Bielawski on 11/09/2023.
//

import AVFoundation
import UIKit
import Vision

final class ScannerViewController: UIViewController, Taggable {
    var tag: TabType = .scanner

    let imagePredictor = ImagePredictor()

    var counter: Int = 3
    private var firstTime = true

    var session: AVCaptureSession?
    let output = AVCapturePhotoOutput()
    let previewLayer = AVCaptureVideoPreviewLayer()

    var dataSource: UICollectionViewDiffableDataSource<Int, String>?

    var ingredientCollectionViewConstraint: NSLayoutConstraint?

    lazy var takePhotoButton: CircleButton = {
        let takePhotoButton = CircleButton(systemImage: "camera.circle.fill")
        takePhotoButton.isUserInteractionEnabled = true
        takePhotoButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapTakePhotoButton)))

        return takePhotoButton
    }()

    lazy var applyIngredientButton: CircleButton = {
        let applyIngredientButton = CircleButton(systemImage: "checkmark.circle.fill")
        applyIngredientButton.isUserInteractionEnabled = true
        applyIngredientButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapApplyIngredientButton)))

        return applyIngredientButton
    }()

    lazy var ingredientsCollection: UICollectionView = {
        var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        configuration.backgroundColor = .primaryColor
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)

        let ingredientsCollection = UICollectionView(frame: .zero, collectionViewLayout: layout)

        ingredientsCollection.layer.borderColor = UIColor.accentColor.cgColor
        ingredientsCollection.layer.borderWidth = 1
        ingredientsCollection.layer.cornerRadius = 16.0

        ingredientsCollection.translatesAutoresizingMaskIntoConstraints = false
        return ingredientsCollection
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .primaryColor
        title = "Scanner"

        setupConstraints()

        setupCollectionView()

        setDataSource(["apples", "bananas", "milk"])

        checkCameraStatus()
    }

    func setupConstraints() {
        view.layer.addSublayer(previewLayer)
        view.addSubview(takePhotoButton)
        view.addSubview(ingredientsCollection)
        view.addSubview(applyIngredientButton)

        NSLayoutConstraint.activate([
            takePhotoButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            takePhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            ingredientsCollection.topAnchor.constraint(lessThanOrEqualTo: view.centerYAnchor),
            ingredientsCollection.bottomAnchor.constraint(equalTo: takePhotoButton.bottomAnchor),
            ingredientsCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            ingredientsCollection.trailingAnchor.constraint(equalTo: takePhotoButton.leadingAnchor, constant: -16),
            applyIngredientButton.bottomAnchor.constraint(equalTo: takePhotoButton.bottomAnchor),
            applyIngredientButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        ingredientCollectionViewConstraint = ingredientsCollection.heightAnchor.constraint(equalToConstant: view.bounds.size.height / 2)
        ingredientCollectionViewConstraint?.isActive = true
    }

    func setupCollectionView() {
        let registration = UICollectionView.CellRegistration<UICollectionViewListCell, String> { cell, _, ingredient in

            var content = cell.defaultContentConfiguration()
            content.text = ingredient
            cell.contentConfiguration = content
            cell.contentView.backgroundColor = UIColor.primaryColor
        }

        dataSource = UICollectionViewDiffableDataSource<Int, String>(collectionView: ingredientsCollection) { collectionView, indexPath, ingredient in
            collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: ingredient)
        }
    }

    func setDataSource(_ items: [String]) {
        counter += 1
        var snapshot = NSDiffableDataSourceSnapshot<Int, String>()
        snapshot.appendSections([0])
        snapshot.appendItems(items)
        print("xdsad")
        dataSource?.apply(snapshot)

        guard !firstTime else {
            firstTime = false
            return
        }

        ingredientsCollection.layoutIfNeeded()
        UIView.animate(withDuration: 1.0) {
            self.ingredientCollectionViewConstraint?.constant = self.ingredientsCollection.collectionViewLayout.collectionViewContentSize.height
            self.view.layoutIfNeeded()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.topItem?.title = tag.title
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
        ingredientsCollection.layoutIfNeeded()
        ingredientCollectionViewConstraint?.constant = ingredientsCollection.collectionViewLayout.collectionViewContentSize.height
        print("xdadas")
    }
}

extension ScannerViewController {
    private func checkCameraStatus() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { status in
                guard status else {
                    return
                }
                DispatchQueue.main.async {
                    self.setupCamera()
                }
            }
        case .restricted:
            break
        case .denied:
            break
        case .authorized:
            setupCamera()
        @unknown default:
            break
        }
    }

    private func setupCamera() {
        let session = AVCaptureSession()
        if let device = AVCaptureDevice.default(for: .video) {
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(input) {
                    session.addInput(input)
                }

                if session.canAddOutput(output) {
                    session.addOutput(output)
                }

                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.session = session

                session.startRunning()
                self.session = session

            } catch {
                print(error)
            }
        }
    }

    @objc private func didTapTakePhotoButton() {
        output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }

    @objc private func didTapApplyIngredientButton() {
        var array: [String] = []
        for number in 1 ... counter {
            array.append(String("different".shuffled()))
        }
        setDataSource(array.shuffled())
    }
}

extension ScannerViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation() else {
            return
        }
        let image = UIImage(data: data)

        classifyImage(image!)
    }
}

extension ScannerViewController {
    private func classifyImage(_ image: UIImage) {
        do {
            try imagePredictor.makePredictions(for: image,
                                               completionHandler: imagePredictionHandler)
        } catch {
            print("Vision was unable to make a prediction...\n\n\(error.localizedDescription)")
        }
    }

    private func imagePredictionHandler(_ predictions: [VNClassificationObservation]?) {
        guard let predictions = predictions else {
//            updatePredictionLabel("No predictions. (Check console log.)")
            print("no predictions")
            return
        }

        let topThreePredictions = Array(predictions.sorted(by: { $0.confidence > $1.confidence })[0 ... 2])

        for prediction in topThreePredictions {
            print(prediction.identifier, prediction.confidence)
        }
    }
}
