//
//  NewsViewController.swift
//  FinalProject
//
//  Created by Isak Sabelko on 12/4/24.
//

import Foundation
import UIKit
import SwiftSoup

class FeaturedNewsCell: UITableViewCell {
    static let identifier = "FeaturedNewsCell"
    
    private let customImageView = UIImageView()
    private let titleLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        customImageView.contentMode = .scaleAspectFill
        customImageView.clipsToBounds = true
        customImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(customImageView)
        
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            customImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            customImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            customImageView.widthAnchor.constraint(equalToConstant: 300),
            customImageView.heightAnchor.constraint(equalToConstant: 200),
            
            titleLabel.topAnchor.constraint(equalTo: customImageView.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Reset the image and text when the cell is reused
        customImageView.image = nil
        titleLabel.text = nil
    }
    
    func configure(with title: String, imageURL: String) {
        titleLabel.text = title
        
        if let url = URL(string: imageURL) {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.customImageView.image = image
                    }
                }
            }.resume()
        }
    }
}

class NewsCell: UITableViewCell {
    static let identifier = "NewsCell"
    
    private let titleLabel = UILabel()
    private let customImageView = UIImageView()
    
    var isFeatured: Bool = false {
        didSet {
            customImageView.isHidden = !isFeatured
            updateConstraintsForFeatured(isFeatured)
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        titleLabel.font = .systemFont(ofSize: 16)
        titleLabel.numberOfLines = 0 // Allow for multiple lines
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        customImageView.contentMode = .scaleAspectFill
        customImageView.clipsToBounds = true
        customImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(customImageView)
        
        // Set up initial constraints for when the image is present
        updateConstraintsForFeatured(true)
    }
    
    private func updateConstraintsForFeatured(_ isFeatured: Bool) {
        // Remove previous constraints if they exist
        contentView.removeConstraints(contentView.constraints)
        
        if isFeatured {
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
                titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
                titleLabel.trailingAnchor.constraint(equalTo: customImageView.leadingAnchor, constant: -10),
                
                customImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
                customImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
                customImageView.widthAnchor.constraint(equalToConstant: 100),
                customImageView.heightAnchor.constraint(equalToConstant: 100),
                
                titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10),
                contentView.bottomAnchor.constraint(greaterThanOrEqualTo: titleLabel.bottomAnchor, constant: 10)
            ])
        } else {
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
                titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
                titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
                titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
            ])
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Reset the image and text when the cell is reused
        customImageView.image = nil
        titleLabel.text = nil
    }
    
    func configure(with title: String, imageURL: String) {
        titleLabel.text = title
        
        if let url = URL(string: imageURL) {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.customImageView.image = image
                    }
                }
            }.resume()
        }
    }
}


//controller
class NewsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private var news: [(title: String, url: String, images: [String])] = []
    private let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Climbing News"

        setupTableView()
        fetchNews()
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

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
                for article in articles {
                    let title = try article.text()
                    let link = try article.attr("href")
                    let completeURL = link.starts(with: "http") ? link : "https://www.outsideonline.com\(link)"
                    
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
                            
                            self.news.append((title: title, url: completeURL, images: fullImageUrls))
                            
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
        return news.isEmpty ? 0 : news.count + 1 // +1 for the featured story
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Print statement for debugging
        print("Table view row: \(indexPath.row), news count: \(news.count)")

        if indexPath.row == 0, let firstStory = news.first {
            // Configure the featured news cell
            let cell = tableView.dequeueReusableCell(withIdentifier: FeaturedNewsCell.identifier, for: indexPath) as! FeaturedNewsCell
            cell.configure(with: firstStory.title, imageURL: firstStory.images.first ?? "")
            return cell
        } else {
            // Adjust the index for the rest of the cells
            let adjustedIndex = indexPath.row - 1 // Adjust for the featured story offset

            // Check if the adjusted index is within bounds
            guard adjustedIndex < news.count else {
                print("Index out of range when creating cell for row: \(indexPath.row)")
                return UITableViewCell() // Return an empty cell to avoid crash
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: NewsCell.identifier, for: indexPath) as! NewsCell
            let article = news[adjustedIndex]

            // Configure the cell with title only if it's not featured
            cell.isFeatured = false // Ensure this is set for non-featured cells
            cell.configure(with: article.title, imageURL: article.images.first ?? "")
            return cell
        }
    }

    // UITableViewDelegate Method
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Check that the index is valid before accessing
        guard indexPath.row < news.count else {
            print("Index out of range")
            return
        }
        
        let article = news[indexPath.row]
        if let url = URL(string: article.url) {
            UIApplication.shared.open(url)
        }
    }
}

