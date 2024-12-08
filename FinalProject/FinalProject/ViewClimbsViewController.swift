//
//  ViewClimbsViewController.swift
//  FinalProject
//
//  Created by Isak Sabelko on 12/4/24.

import UIKit

//class for viewing climbs, within nav tab, nav controller with table
class ViewClimbsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var tableView: UITableView!
    var newFolderButton: UIButton!
    var folderNames: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "View Climbs"

        setupUI()
        loadFolders()
    }

    private func setupUI() {
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FolderCell")
        view.addSubview(tableView)

        newFolderButton = UIButton(type: .system)
        newFolderButton.setTitle("New Folder", for: .normal)
        newFolderButton.backgroundColor = .systemBlue
        newFolderButton.setTitleColor(.white, for: .normal)
        newFolderButton.layer.cornerRadius = 8
        newFolderButton.translatesAutoresizingMaskIntoConstraints = false
        newFolderButton.addTarget(self, action: #selector(newFolderButtonTapped), for: .touchUpInside)
        view.addSubview(newFolderButton)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: newFolderButton.topAnchor, constant: -10),

            newFolderButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            newFolderButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            newFolderButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            newFolderButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc private func newFolderButtonTapped() {
        showNewFolderAlert()
    }
    
    //create folder for new climbs
    func createFolder(named folderName: String) {
        let fileManager = FileManager.default
        if let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let folderPath = documentsPath.appendingPathComponent(folderName)
            do {
                try fileManager.createDirectory(at: folderPath, withIntermediateDirectories: true, attributes: nil)
                folderNames.append(folderName)
                tableView.reloadData()
            } catch {
                print("Failed to create folder: \(error)")
            }
        }
    }
    
    //update to show
    func showNewFolderAlert() {
        let alert = UIAlertController(title: "New Folder", message: "Enter folder name", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Folder Name"
        }
        let createAction = UIAlertAction(title: "Create", style: .default) { _ in
            if let folderName = alert.textFields?.first?.text, !folderName.isEmpty {
                self.createFolder(named: folderName)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(createAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    //load new folders or old
    func loadFolders() {
        let fileManager = FileManager.default
        if let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            do {
                let folderURLs = try fileManager.contentsOfDirectory(at: documentsPath, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
                folderNames = folderURLs.filter { $0.hasDirectoryPath }.map { $0.lastPathComponent }
                tableView.reloadData()
            } catch {
                print("Failed to load folders: \(error)")
            }
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

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let folderName = folderNames[indexPath.row]
            deleteFolder(named: folderName) { success in
                if success {
                    self.folderNames.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                }
            }
        }
    }
    
    //allow folder deletion
    private func deleteFolder(named folderName: String, completion: (Bool) -> Void) {
        let fileManager = FileManager.default
        if let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let folderPath = documentsPath.appendingPathComponent(folderName)
            do {
                try fileManager.removeItem(at: folderPath)
                completion(true)
            } catch {
                print("Failed to delete folder: \(error)")
                completion(false)
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let folderName = folderNames[indexPath.row]
        let folderContentsVC = FolderContentsViewController()
        folderContentsVC.folderName = folderName
        navigationController?.pushViewController(folderContentsVC, animated: true)
    }
}

//ik this should be in a seperate file but it has to do with viewclimbs so I like it here sorry
//view for when in a folder, table view
class FolderContentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var folderName: String = ""
    var imagePaths: [URL] = []
    private var tableView: UITableView!
    private let orderFileName = ".order"

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = folderName

        setupTableView()
        loadImages()
    }

    private func setupTableView() {
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ImageCell")
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func loadImages() {
        let fileManager = FileManager.default
        if let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let folderPath = documentsPath.appendingPathComponent(folderName)

            do {
                let fileURLs = try fileManager.contentsOfDirectory(at: folderPath, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
                imagePaths = fileURLs.filter { $0.pathExtension.lowercased() == "png" || $0.pathExtension.lowercased() == "jpg" }
                applySavedOrder()
                tableView.reloadData()
            } catch {
                print("Failed to load images: \(error)")
            }
        }
    }

    //allow for organizing image order
    private func applySavedOrder() {
        let fileManager = FileManager.default
        if let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let orderFilePath = documentsPath.appendingPathComponent(folderName).appendingPathComponent(orderFileName)
            if let orderData = try? Data(contentsOf: orderFilePath),
               let order = try? JSONDecoder().decode([String].self, from: orderData) {
                imagePaths.sort {
                    order.firstIndex(of: $0.lastPathComponent) ?? Int.max < order.firstIndex(of: $1.lastPathComponent) ?? Int.max
                }
            }
        }
    }

    private func saveOrder() {
        let fileManager = FileManager.default
        if let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let orderFilePath = documentsPath.appendingPathComponent(folderName).appendingPathComponent(orderFileName)
            let order = imagePaths.map { $0.lastPathComponent }
            do {
                let orderData = try JSONEncoder().encode(order)
                try orderData.write(to: orderFilePath)
                print("Order saved: \(order)")
            } catch {
                print("Failed to save order: \(error)")
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imagePaths.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath)

        cell.contentView.subviews.forEach { $0.removeFromSuperview() }

        //display the image filename
        let label = UILabel()
        label.text = imagePaths[indexPath.row].lastPathComponent
        label.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(label)

        let moveUpButton = UIButton(type: .system)
        moveUpButton.setTitle("↑", for: .normal)
        moveUpButton.tag = indexPath.row
        moveUpButton.addTarget(self, action: #selector(moveImageUp(_:)), for: .touchUpInside)
        moveUpButton.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(moveUpButton)

        let moveDownButton = UIButton(type: .system)
        moveDownButton.setTitle("↓", for: .normal)
        moveDownButton.tag = indexPath.row
        moveDownButton.addTarget(self, action: #selector(moveImageDown(_:)), for: .touchUpInside)
        moveDownButton.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(moveDownButton)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 10),
            label.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),

            moveDownButton.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -10),
            moveDownButton.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),

            moveUpButton.trailingAnchor.constraint(equalTo: moveDownButton.leadingAnchor, constant: -10),
            moveUpButton.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
        ])

        return cell
    }

    //button and moving image around in folder
    @objc private func moveImageUp(_ sender: UIButton) {
        let index = sender.tag
        guard index > 0 else { return }

        imagePaths.swapAt(index, index - 1)
        tableView.reloadData()
        saveOrder()
    }

    @objc private func moveImageDown(_ sender: UIButton) {
        let index = sender.tag
        guard index < imagePaths.count - 1 else { return }

        imagePaths.swapAt(index, index + 1)
        tableView.reloadData()
        saveOrder()
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let imagePath = imagePaths[indexPath.row]
            deleteImage(at: imagePath) { success in
                if success {
                    self.imagePaths.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                }
            }
        }
    }

    private func deleteImage(at imagePath: URL, completion: (Bool) -> Void) {
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: imagePath)
            completion(true)
        } catch {
            print("Failed to delete image: \(error)")
            completion(false)
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let imagePath = imagePaths[indexPath.row]
        let imageViewer = ImageViewController()
        imageViewer.imagePath = imagePath
        imageViewer.imagePaths = imagePaths
        imageViewer.currentIndex = indexPath.row
        navigationController?.pushViewController(imageViewer, animated: true)
    }
}

//again should be seperate file but used withing folder within image selection, shows the image clicked on and allows navigation to next
//image in order set by user
class ImageViewController: UIViewController {
    var imagePath: URL!
    var imagePaths: [URL] = [] //list of images for navigation within folder
    var currentIndex: Int = 0 //index of the current image within folder
    private var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupImageView()
        setupNavigationButtons()
        loadImage()
    }

    private func setupImageView() {
        imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func setupNavigationButtons() {
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(showNextImage)),
            UIBarButtonItem(title: "Previous", style: .plain, target: self, action: #selector(showPreviousImage))
        ]
    }

    //loading image
    private func loadImage() {
        if let imageData = try? Data(contentsOf: imagePath), let image = UIImage(data: imageData) {
            imageView.image = image
            navigationItem.title = imagePath.lastPathComponent
        } else {
            print("Failed to load image at path: \(imagePath.path)")
        }
    }

    //move between images
    @objc private func showNextImage() {
        guard currentIndex + 1 < imagePaths.count else { return }
        currentIndex += 1
        imagePath = imagePaths[currentIndex]
        loadImage()
    }
    
    //move between images
    @objc private func showPreviousImage() {
        guard currentIndex - 1 >= 0 else { return }
        currentIndex -= 1
        imagePath = imagePaths[currentIndex]
        loadImage()
    }
}
