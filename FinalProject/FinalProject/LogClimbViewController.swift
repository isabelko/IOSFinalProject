//
//  LogClimbViewController.swift
//  FinalProject
//
//  Created by Isak Sabelko on 12/4/24.
//

import UIKit

class LogClimbViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIColorPickerViewControllerDelegate {

    private var uploadedImageView: UIImageView!
    private var stickFigureView: StickFigureView!
    private var buttonStackView: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupUI()
    }

    private func setupUI() {
        // Image View for the uploaded image
        uploadedImageView = UIImageView()
        uploadedImageView.contentMode = .scaleAspectFit
        uploadedImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(uploadedImageView)

        NSLayoutConstraint.activate([
            uploadedImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            uploadedImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            uploadedImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            uploadedImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5)
        ])

        // Stick Figure View overlay
        stickFigureView = StickFigureView()
        stickFigureView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stickFigureView)

        NSLayoutConstraint.activate([
            stickFigureView.topAnchor.constraint(equalTo: uploadedImageView.topAnchor),
            stickFigureView.leadingAnchor.constraint(equalTo: uploadedImageView.leadingAnchor),
            stickFigureView.trailingAnchor.constraint(equalTo: uploadedImageView.trailingAnchor),
            stickFigureView.bottomAnchor.constraint(equalTo: uploadedImageView.bottomAnchor)
        ])

        // Buttons for image upload and color pickers
        let uploadButton = UIButton(type: .system)
        uploadButton.setTitle("Upload Image", for: .normal) // Corrected
        uploadButton.addTarget(self, action: #selector(uploadImageTapped), for: .touchUpInside)

        let jointColorButton = UIButton(type: .system)
        jointColorButton.setTitle("Change Joint Color", for: .normal) // Corrected
        jointColorButton.addTarget(self, action: #selector(changeJointColorTapped), for: .touchUpInside)

        let limbColorButton = UIButton(type: .system)
        limbColorButton.setTitle("Change Limb Color", for: .normal) // Corrected
        limbColorButton.addTarget(self, action: #selector(changeLimbColorTapped), for: .touchUpInside)


        // Stack view to organize buttons
        buttonStackView = UIStackView(arrangedSubviews: [uploadButton, jointColorButton, limbColorButton])
        buttonStackView.axis = .vertical
        buttonStackView.spacing = 16
        buttonStackView.alignment = .center
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonStackView)

        NSLayoutConstraint.activate([
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    @objc private func uploadImageTapped() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }

    @objc private func changeJointColorTapped() {
        showColorPicker(for: .joints)
    }

    @objc private func changeLimbColorTapped() {
        showColorPicker(for: .limbs)
    }

    private func showColorPicker(for type: StickFigureComponent) {
        let colorPicker = UIColorPickerViewController()
        colorPicker.delegate = self
        colorPicker.title = type == .joints ? "Select Joint Color" : "Select Limb Color"
        colorPicker.view.tag = type.rawValue // Use view tag to identify which component to update
        present(colorPicker, animated: true)
    }

    // Handle the selected image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        if let image = info[.originalImage] as? UIImage {
            uploadedImageView.image = image
            stickFigureView.isHidden = false // Show stick figure when an image is uploaded
        }
    }

    // Handle color selection from the color picker
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        let selectedColor = viewController.selectedColor
        if viewController.view.tag == StickFigureComponent.joints.rawValue {
            stickFigureView.jointColor = selectedColor
        } else if viewController.view.tag == StickFigureComponent.limbs.rawValue {
            stickFigureView.limbColor = selectedColor
        }
    }
}

// Enum to distinguish between joints and limbs
enum StickFigureComponent: Int {
    case joints = 0
    case limbs = 1
}
