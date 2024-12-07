//
//  ViewClimbsViewController.swift
//  FinalProject
//
//  Created by Isak Sabelko on 12/4/24.
//
import UIKit

// MARK: - ViewClimbsViewController
class ViewClimbsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var tableView: UITableView!
    var newFolderButton: UIButton!
    var folderNames: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "View Climbs"

        // Initialize the UI
        setupUI()

        // Load existing folders
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

    // MARK: - UITableViewDataSource
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

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let folderName = folderNames[indexPath.row]
        let folderContentsVC = FolderContentsViewController()
        folderContentsVC.folderName = folderName
        navigationController?.pushViewController(folderContentsVC, animated: true)
    }
}

// MARK: - FolderContentsViewController
class FolderContentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var folderName: String = ""
    var imagePaths: [URL] = []
    private var tableView: UITableView!

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
                tableView.reloadData()
            } catch {
                print("Failed to load images: \(error)")
            }
        }
    }

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imagePaths.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath)
        cell.textLabel?.text = imagePaths[indexPath.row].lastPathComponent
        return cell
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

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let imagePath = imagePaths[indexPath.row]
        let imageViewer = ImageViewController()
        imageViewer.imagePath = imagePath
        navigationController?.pushViewController(imageViewer, animated: true)
    }
}

// MARK: - ImageViewController
class ImageViewController: UIViewController {
    var imagePath: URL!
    private var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = imagePath.lastPathComponent

        setupImageView()
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

    private func loadImage() {
        if let imageData = try? Data(contentsOf: imagePath), let image = UIImage(data: imageData) {
            imageView.image = image
        } else {
            print("Failed to load image at path: \(imagePath.path)")
        }
    }
}
