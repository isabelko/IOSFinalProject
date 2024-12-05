//
//  ViewController.swift
//  FinalProject
//
//  Created by Isak Sabelko on 11/19/24.
//
//this has kinda become my main view controller because it is the news view controller for the nav controlelr

import UIKit
import SwiftSoup

class NewsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private var featuredStory: (title: String, url: String, images: [String])?
    private var news: [(title: String, url: String, images: [String])] = []
    private let tableView = UITableView()
    
    
    // Add the title label
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Climbing News"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Climbing News"

        // Set the tab bar's appearance to solid
        tabBarController?.tabBar.isTranslucent = false
        tabBarController?.tabBar.barTintColor = .white  // Set a solid color for the tab bar
        
        setupTitleLabel()  // Add the title label setup
        setupTableView()
        fetchNews()
    }

    // Function to setup the title label
    private func setupTitleLabel() {
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 40)  // Adjust height as needed
        ])
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10), // Add space below title
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)  // Ensure it doesn't go behind tab bar
        ])

        // Adjust content inset to avoid going under the tab bar
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: tabBarController?.tabBar.frame.height ?? 0, right: 0)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(FeaturedNewsCell.self, forCellReuseIdentifier: FeaturedNewsCell.identifier)
        tableView.register(NewsCell.self, forCellReuseIdentifier: NewsCell.identifier)
    }

    private func fetchNews() {
        guard let url = URL(string: "https://www.outsideonline.com/climbing/") else { return }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self, let data = data, error == nil else {
                print("Failed to fetch news: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                let html = String(data: data, encoding: .utf8) ?? ""
                let document = try SwiftSoup.parse(html)

                let articles = try document.select("a.o-heading__link").array()
                for (index, article) in articles.enumerated() {
                    let title = try article.text()
                    let link = try article.attr("href")
                    let completeURL = link.starts(with: "http") ? link : "https://www.outsideonline.com" + (link.starts(with: "/") ? "" : "/") + link

                    let articlePageURL = URL(string: completeURL)!
                    let articleTask = URLSession.shared.dataTask(with: articlePageURL) { [weak self] data, response, error in
                        guard let self = self, let data = data, error == nil else {
                            print("Failed to fetch article page: \(error?.localizedDescription ?? "Unknown error")")
                            return
                        }

                        do {
                            let articleHTML = String(data: data, encoding: .utf8) ?? ""
                            let articleDocument = try SwiftSoup.parse(articleHTML)
                            let images = try articleDocument.select("img.o-image.lazy").array()
                            let imageUrls = images.compactMap { try? $0.attr("data-src") }
                            let fullImageUrls = imageUrls.map { url in
                                url.starts(with: "http") ? url : "https://www.outsideonline.com\(url)"
                            }

                            // Use the first article as the featured story
                            if index == 0 {
                                self.featuredStory = (title: title, url: completeURL, images: fullImageUrls)
                            } else {
                                self.news.append((title: title, url: completeURL, images: fullImageUrls))
                            }

                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        } catch {
                            print("Error parsing article for images: \(error)")
                        }
                    }

                    articleTask.resume()
                }
            } catch {
                print("Error parsing HTML: \(error)")
            }
        }

        task.resume()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news.isEmpty ? 0 : news.count + (featuredStory != nil ? 1 : 0)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let featuredStory = featuredStory, indexPath.row == 0 {
            // Configure the featured news cell
            let cell = tableView.dequeueReusableCell(withIdentifier: FeaturedNewsCell.identifier, for: indexPath) as! FeaturedNewsCell
            cell.configure(with: featuredStory.title, imageURL: featuredStory.images.first ?? "")
            return cell
        } else {
            // Adjust the index for the regular news cells (skip the first featured cell)
            let adjustedIndex = indexPath.row - (featuredStory != nil ? 1 : 0)

            // Ensure the adjusted index is within bounds
            guard adjustedIndex < news.count else {
                print("Index out of range when creating cell for row: \(indexPath.row)")
                return UITableViewCell() // Return an empty cell to avoid a crash
            }

            // Configure the cell for the regular news article
            let cell = tableView.dequeueReusableCell(withIdentifier: NewsCell.identifier, for: indexPath) as! NewsCell
            let article = news[adjustedIndex]
            cell.isFeatured = false // Hide the image for non-featured cells
            cell.configure(with: article.title, imageURL: "") // No image for non-featured articles
            return cell
        }
    }

    // UITableViewDelegate Method
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Check if the selected row corresponds to the featured story
        if indexPath.row == 0, let firstStory = featuredStory {
            // If the first cell (the featured story) is selected, use its URL
            if let url = URL(string: firstStory.url) {
                UIApplication.shared.open(url)
            }
        } else {
            // Adjust for the offset when selecting a non-featured news cell
            let adjustedIndex = indexPath.row - (featuredStory != nil ? 1 : 0)
            
            // Ensure the adjusted index is valid before accessing
            guard adjustedIndex < news.count else {
                print("Index out of range")
                return
            }
            
            let article = news[adjustedIndex]
            if let url = URL(string: article.url) {
                UIApplication.shared.open(url)
            }
        }
    }
}
//class MainViewController: UIViewController {
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .systemBackground
//        title = "Climbing App"
//
//        setupUI()
//    }
//
//    private func setupUI() {
//        let stackView = UIStackView()
//        stackView.axis = .vertical
//        stackView.alignment = .center
//        stackView.spacing = 20
//
//        let settingsButton = createButton(title: "Settings", action: #selector(openSettings))
//        let viewClimbsButton = createButton(title: "View Climbs", action: #selector(openViewClimbs))
//        let logClimbButton = createButton(title: "Log Climb", action: #selector(openLogClimb))
//
//        stackView.addArrangedSubview(settingsButton)
//        stackView.addArrangedSubview(viewClimbsButton)
//        stackView.addArrangedSubview(logClimbButton)
//
//        view.addSubview(stackView)
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
//        ])
//    }
//
//    private func createButton(title: String, action: Selector) -> UIButton {
//        let button = UIButton(type: .system)
//        button.setTitle(title, for: .normal)
//        button.addTarget(self, action: action, for: .touchUpInside)
//        return button
//    }
//
//    @objc private func openSettings() {
//        navigationController?.pushViewController(SettingsViewController(), animated: true)
//    }
//
//    @objc private func openViewClimbs() {
//        navigationController?.pushViewController(ViewClimbsViewController(), animated: true)
//    }
//
//    @objc private func openLogClimb() {
//        navigationController?.pushViewController(LogClimbViewController(), animated: true)
//    }
//}


//import UIKit
//
//class ViewController: UIViewController {
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view.
//        //test commit comment
//    }
//
//
//}

