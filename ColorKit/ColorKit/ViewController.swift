//
//  ViewController.swift
//  ColorKit
//
//  Created by Stephano Portella on 26/04/25.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    private let imageContainerView = UIView()
    private let roundedContainerView = UIView()
    private let imageView = UIImageView()
    private let addImageButton = UIButton(type: .system)
    private let resetButton = UIButton(type: .system)

    private let colorPaletteView = ColorPaletteView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupLayout()
        setupActions()
    }

    private func setupLayout() {
        view.addSubview(imageContainerView)
        imageContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            imageContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageContainerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 2.0/3.0)
        ])

        imageContainerView.addSubview(roundedContainerView)
        roundedContainerView.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        roundedContainerView.layer.cornerRadius = 20
        roundedContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            roundedContainerView.centerXAnchor.constraint(equalTo: imageContainerView.centerXAnchor),
            roundedContainerView.centerYAnchor.constraint(equalTo: imageContainerView.centerYAnchor),
            roundedContainerView.widthAnchor.constraint(equalTo: imageContainerView.widthAnchor, multiplier: 0.85),
            roundedContainerView.heightAnchor.constraint(equalTo: roundedContainerView.widthAnchor)
        ])

        roundedContainerView.addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: roundedContainerView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: roundedContainerView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: roundedContainerView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: roundedContainerView.trailingAnchor)
        ])

        roundedContainerView.addSubview(addImageButton)
        addImageButton.setTitle("＋", for: .normal)
        addImageButton.setTitleColor(.white, for: .normal)
        addImageButton.titleLabel?.font = .systemFont(ofSize: 50, weight: .light)
        addImageButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addImageButton.centerXAnchor.constraint(equalTo: roundedContainerView.centerXAnchor),
            addImageButton.centerYAnchor.constraint(equalTo: roundedContainerView.centerYAnchor)
        ])

        view.addSubview(resetButton)
        resetButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        resetButton.tintColor = .white
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            resetButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            resetButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])

        view.addSubview(colorPaletteView)
        colorPaletteView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            colorPaletteView.topAnchor.constraint(equalTo: imageContainerView.bottomAnchor),
            colorPaletteView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            colorPaletteView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            colorPaletteView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupActions() {
        addImageButton.addTarget(self, action: #selector(selectImageSource), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetImageAndPalette), for: .touchUpInside)
    }

    @objc private func selectImageSource() {
        let alert = UIAlertController(title: "Seleccionar imagen", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Galería", style: .default) { _ in
            self.presentImagePicker(sourceType: .photoLibrary)
        })
        alert.addAction(UIAlertAction(title: "Cámara", style: .default) { _ in
            self.presentImagePicker(sourceType: .camera)
        })
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        present(alert, animated: true)
    }

    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else { return }
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        present(picker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        if let image = info[.originalImage] as? UIImage {
            imageView.image = image
            addImageButton.isHidden = true
            let colors = ColorExtractor.extractDistinctColors(from: image, maxColors: 14)
            colorPaletteView.setColors(colors)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    @objc private func resetImageAndPalette() {
        imageView.image = nil
        addImageButton.isHidden = false
        colorPaletteView.setColors([])
    }
}
