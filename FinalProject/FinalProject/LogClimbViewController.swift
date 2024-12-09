//
//  LogClimbViewController.swift
//  FinalProject
//
//  Created by Isak Sabelko on 11/19/24.
//

import UIKit

class FolderSelectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var fetchFolderNames: (() -> [String])?
    var onFolderSelected: ((String) -> Void)?
    
    private var tableView: UITableView!
    private var folderNames: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Select Folder"
        
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshFolderNames()
    }
    
    private func setupTableView() {
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FolderCell")
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func refreshFolderNames() {
        if let fetchFolderNames = fetchFolderNames {
            folderNames = fetchFolderNames()
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folderNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FolderCell", for: indexPath)
        cell.textLabel?.text = folderNames[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedFolder = folderNames[indexPath.row]
        onFolderSelected?(selectedFolder)
        dismiss(animated: true)
    }
}



class LogClimbViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIColorPickerViewControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    private var uploadedImageView: UIImageView!
    private var stickFigureView: StickFigureView!
    private var settingsButton: UIButton!
    private var saveClimbButton: UIButton!

    private var folderNames: [String] = []
    private let pickerView = UIPickerView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        loadFolders()
        setupUI()
    }

    private func setupUI() {
        //image below stick figure
        uploadedImageView = UIImageView()
        uploadedImageView.contentMode = .scaleAspectFit
        uploadedImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(uploadedImageView)

        NSLayoutConstraint.activate([
            uploadedImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            uploadedImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            uploadedImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            uploadedImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.85)
        ])

        //stick figure view on top of image
        stickFigureView = StickFigureView()
        stickFigureView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stickFigureView)

        NSLayoutConstraint.activate([
            stickFigureView.topAnchor.constraint(equalTo: uploadedImageView.topAnchor),
            stickFigureView.leadingAnchor.constraint(equalTo: uploadedImageView.leadingAnchor),
            stickFigureView.trailingAnchor.constraint(equalTo: uploadedImageView.trailingAnchor),
            stickFigureView.bottomAnchor.constraint(equalTo: uploadedImageView.bottomAnchor)
        ])

        //setting button at bottom
        settingsButton = UIButton(type: .system)
        settingsButton.setTitle("Settings", for: .normal)
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        settingsButton.menu = createSettingsMenu()
        settingsButton.showsMenuAsPrimaryAction = true
        view.addSubview(settingsButton)

        NSLayoutConstraint.activate([
            settingsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            settingsButton.topAnchor.constraint(equalTo: uploadedImageView.bottomAnchor, constant: 20),
            settingsButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    private func createSettingsMenu() -> UIMenu {
        //settings menu optioons
        let uploadImageAction = UIAction(title: "Upload Image", image: UIImage(systemName: "photo")) { _ in
            self.uploadImageTapped()
        }

        let changeJointColorAction = UIAction(title: "Change Joint Color", image: UIImage(systemName: "paintbrush")) { _ in
            self.changeJointColorTapped()
        }

        let changeLimbColorAction = UIAction(title: "Change Limb Color", image: UIImage(systemName: "paintbrush.fill")) { _ in
            self.changeLimbColorTapped()
        }

        let saveClimbAction = UIAction(title: "Save Climb", image: UIImage(systemName: "square.and.arrow.down")) { _ in
            self.saveClimbTapped()
        }

        return UIMenu(title: "Settings", children: [uploadImageAction, changeJointColorAction, changeLimbColorAction, saveClimbAction])
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

    @objc private func saveClimbTapped() {
        guard let screenshot = captureScreenshot() else { return }
        promptForImageName { [weak self] imageName in
            self?.showFolderPicker(for: screenshot, imageName: imageName)
        }
    }

    private func promptForImageName(completion: @escaping (String) -> Void) {
        let alert = UIAlertController(title: "Save Image", message: "Enter a name for your image", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Image Name"
        }
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            if let imageName = alert.textFields?.first?.text, !imageName.isEmpty {
                completion(imageName)
            } else {
                completion("Climb_\(UUID().uuidString)") // Fallback to default name if none provided
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }

    //select folder to save image in
    private func showFolderPicker(for screenshot: UIImage, imageName: String) {
        let folderSelectionVC = FolderSelectionViewController()
        folderSelectionVC.fetchFolderNames = { [weak self] in
            self?.loadFoldersFromFileSystem() ?? [] // Fetch updated folder list
        }
        folderSelectionVC.onFolderSelected = { [weak self] selectedFolder in
            self?.saveScreenshot(screenshot, to: selectedFolder, withName: imageName)
        }
        
        let navigationController = UINavigationController(rootViewController: folderSelectionVC)
        present(navigationController, animated: true)
    }

    //i wanted to save the state of stick figure and image to then be able to modify it later but
    //went with a quick way of just screenshotting the screen and storing it.
    func saveScreenshot(_ image: UIImage, to folderName: String, withName imageName: String) {
        if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let folderPath = documentsPath.appendingPathComponent(folderName)
            let sanitizedImageName = imageName.replacingOccurrences(of: "[^a-zA-Z0-9_-]", with: "_", options: .regularExpression)
            let filePath = folderPath.appendingPathComponent("\(sanitizedImageName).png")

            do {
                if !FileManager.default.fileExists(atPath: folderPath.path) {
                    try FileManager.default.createDirectory(at: folderPath, withIntermediateDirectories: true, attributes: nil)
                }
                if let imageData = image.pngData() {
                    try imageData.write(to: filePath)
                    print("Screenshot saved at: \(filePath)")
                }
            } catch {
                print("Failed to save screenshot: \(error)")
            }
        }
    }

    private func captureScreenshot() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        return renderer.image { context in
            view.layer.render(in: context.cgContext)
        }
    }

    private func loadFoldersFromFileSystem() -> [String] {
        let fileManager = FileManager.default
        if let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            do {
                let folderURLs = try fileManager.contentsOfDirectory(at: documentsPath, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
                return folderURLs.filter { $0.hasDirectoryPath }.map { $0.lastPathComponent }
            } catch {
                print("Failed to load folders: \(error)")
            }
        }
        return []
    }

    private func loadFolders() {
        folderNames = loadFoldersFromFileSystem()
    }

    //color picker option
    private func showColorPicker(for type: StickFigureComponent) {
        let colorPicker = UIColorPickerViewController()
        colorPicker.delegate = self
        colorPicker.title = type == .joints ? "Select Joint Color" : "Select Limb Color"
        colorPicker.view.tag = type.rawValue
        present(colorPicker, animated: true)
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return folderNames.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return folderNames[row]
    }

    //select image for background to put climber on
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)

        if let image = info[.originalImage] as? UIImage {
            uploadedImageView.image = image
            stickFigureView.isHidden = false
        }
    }

    //chang ecolor of joiont or limb
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        let selectedColor = viewController.selectedColor
        if viewController.view.tag == StickFigureComponent.joints.rawValue {
            stickFigureView.jointColor = selectedColor
        } else if viewController.view.tag == StickFigureComponent.limbs.rawValue {
            stickFigureView.limbColor = selectedColor
        }
    }
}

//decide if joint or limb
enum StickFigureComponent: Int {
    case joints = 0
    case limbs = 1
}
