//
//  LogClimbViewController.swift
//  FinalProject
//
//  Created by Isak Sabelko on 11/19/24.
//

import UIKit


class LogClimbViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIColorPickerViewControllerDelegate {

    private var uploadedImageView: UIImageView!
    private var stickFigureView: StickFigureView!
    private var settingsButton: UIButton!

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
            uploadedImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.85) // Larger height was .7
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

        // Settings Button with Drop-down Menu
        settingsButton = UIButton(type: .system)
        settingsButton.setTitle("Settings", for: .normal)
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        settingsButton.menu = createSettingsMenu()
        settingsButton.showsMenuAsPrimaryAction = true // Automatically show menu on tap
        view.addSubview(settingsButton)

        NSLayoutConstraint.activate([
            settingsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            settingsButton.topAnchor.constraint(equalTo: uploadedImageView.bottomAnchor, constant: 20),
            settingsButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    private func createSettingsMenu() -> UIMenu {
        // Create menu actions
        let uploadImageAction = UIAction(title: "Upload Image", image: UIImage(systemName: "photo")) { _ in
            self.uploadImageTapped()
        }

        let changeJointColorAction = UIAction(title: "Change Joint Color", image: UIImage(systemName: "paintbrush")) { _ in
            self.changeJointColorTapped()
        }

        let changeLimbColorAction = UIAction(title: "Change Limb Color", image: UIImage(systemName: "paintbrush.fill")) { _ in
            self.changeLimbColorTapped()
        }

        // Return menu
        return UIMenu(title: "Settings", children: [uploadImageAction, changeJointColorAction, changeLimbColorAction])
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
        colorPicker.view.tag = type.rawValue
        present(colorPicker, animated: true)
    }

    // Handle the selected image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)

        if let image = info[.originalImage] as? UIImage {
            uploadedImageView.image = image
            stickFigureView.isHidden = false
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


