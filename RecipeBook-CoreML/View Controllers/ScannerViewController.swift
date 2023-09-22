//
//  ScannerViewController.swift
//  RecipeBook-CoreML
//
//  Created by Łukasz Bielawski on 11/09/2023.
//

import AVFoundation
import Combine
import UIKit
import Vision

final class ScannerViewController: UIViewController {
    let imagePredictor = ImagePredictor()

    var recipesTableViewIsLoadingSubscribtion: AnyCancellable?

    var session: AVCaptureSession?
    let output = AVCapturePhotoOutput()
    let previewLayer = AVCaptureVideoPreviewLayer()

    var dataSource: UICollectionViewDiffableDataSource<Int, String>!

    var ingredientCollectionViewConstraint: NSLayoutConstraint!

    var snapshot = NSDiffableDataSourceSnapshot<Int, String>()

    lazy var takePhotoButton: CircleButton = {
        let takePhotoButton = CircleButton(systemImage: "camera.circle.fill")
        takePhotoButton.isUserInteractionEnabled = true
        takePhotoButton.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTapTakePhotoButton)))

        return takePhotoButton
    }()

    lazy var applyIngredientButton: CircleButton = {
        let applyIngredientButton = CircleButton(systemImage: "checkmark.circle.fill")
        applyIngredientButton.isUserInteractionEnabled = true
        applyIngredientButton.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTapApplyIngredientButton)))

        return applyIngredientButton
    }()

    lazy var recipesAreLoadingActivityIndicatiorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView()
        activityIndicatorView.style = .large
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.isHidden = true
        return activityIndicatorView
    }()

    lazy var ingredientsCollection: UICollectionView = {
        var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        configuration.backgroundColor = .primaryColor

        configuration.trailingSwipeActionsConfigurationProvider = { indexPath in
            let del =
                UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
                    guard let self = self else { return }
                    self.snapshot.deleteItems([String((self.dataSource.itemIdentifier(for: indexPath))!)])
                    self.dataSource.apply(self.snapshot)
                    self.animateIngredientCollectionView()
                    completion(true)
                }
            return UISwipeActionsConfiguration(actions: [del])
        }

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

        setupDataSource()

        checkCameraStatus()
    }

    func setupConstraints() {
        view.layer.addSublayer(previewLayer)
        view.addSubview(takePhotoButton)
        view.addSubview(ingredientsCollection)
        view.addSubview(applyIngredientButton)
        view.addSubview(recipesAreLoadingActivityIndicatiorView)

        NSLayoutConstraint.activate([
            takePhotoButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            takePhotoButton.trailingAnchor.constraint(equalTo: applyIngredientButton.leadingAnchor, constant: -16),
            ingredientsCollection.bottomAnchor.constraint(equalTo: takePhotoButton.bottomAnchor),
            ingredientsCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            ingredientsCollection.trailingAnchor.constraint(equalTo: takePhotoButton.leadingAnchor, constant: -16),
            applyIngredientButton.bottomAnchor.constraint(equalTo: takePhotoButton.bottomAnchor),
            applyIngredientButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            recipesAreLoadingActivityIndicatiorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recipesAreLoadingActivityIndicatiorView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        ingredientCollectionViewConstraint =
            ingredientsCollection.heightAnchor.constraint(equalToConstant: view.bounds.size.height / 2)

        ingredientCollectionViewConstraint.isActive = true
    }

    func setupCollectionView() {
        let registration = UICollectionView.CellRegistration<UICollectionViewListCell, String> { cell, _, ingredient in

            var content = cell.defaultContentConfiguration()
            content.text = ingredient
            cell.contentConfiguration = content
            cell.contentView.backgroundColor = UIColor.primaryColor
        }

        dataSource =
            UICollectionViewDiffableDataSource<Int, String>(
                collectionView: ingredientsCollection)
        { collectionView, indexPath, ingredient in
            collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: ingredient)
        }
    }

    func setupDataSource() {
        snapshot.appendSections([0])
        snapshot.appendItems([])
        dataSource?.apply(snapshot)
    }

    func appendToSnapshot(_ items: [String]) {
        if ingredientsCollection.collectionViewLayout.collectionViewContentSize.height == 0.0 {
            ingredientCollectionViewConstraint.constant = 1.0
        }
        snapshot.appendItems(items)
        dataSource?.apply(snapshot)
        animateIngredientCollectionView()
    }

    private func animateIngredientCollectionView() {
        ingredientsCollection.layoutIfNeeded()
        UIView.animate(withDuration: 1.0) {
            self.ingredientCollectionViewConstraint.constant =
                self.ingredientsCollection.collectionViewLayout.collectionViewContentSize.height
            self.view.layoutIfNeeded()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.topItem?.title = "Scan ingredients"

        recipesAreLoadingActivityIndicatiorView.stopAnimating()
        recipesAreLoadingActivityIndicatiorView.isHidden = true

        session?.startRunning()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    private func setupSubscribtion(recipesTableViewController: RecipesTableViewController) {
        recipesTableViewIsLoadingSubscribtion =
            recipesTableViewController.viewModel
                .dataLoadingFinishedPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    guard let self = self else { return }

                    self.recipesTableViewIsLoadingSubscribtion?.cancel()
                    self.recipesTableViewIsLoadingSubscribtion = nil
                    self.tabBarController?.selectedViewController = recipesTableViewController
                }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
        ingredientsCollection.layoutIfNeeded()
        ingredientCollectionViewConstraint.constant =
            ingredientsCollection.collectionViewLayout.collectionViewContentSize.height
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
        guard let dataSource else { return }

        let identifiers = dataSource.snapshot().itemIdentifiers

        guard !identifiers.isEmpty else { return }

        for id in identifiers {
            print(id)
        }

        session?.stopRunning()

        let recipesTableViewController =
            tabBarController?.viewControllers?.first as! RecipesTableViewController

        recipesAreLoadingActivityIndicatiorView.startAnimating()
        recipesAreLoadingActivityIndicatiorView.isHidden = false

        setupSubscribtion(recipesTableViewController: recipesTableViewController)
        recipesTableViewController.performScannerSearch(ingredients: identifiers)
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
            print("no predictions")
            return
        }
        let topPrediction = Array(predictions.sorted(by: { $0.confidence > $1.confidence })).first

        appendToSnapshot([topPrediction!.identifier.replacingOccurrences(of: "_", with: " ")])
    }
}
