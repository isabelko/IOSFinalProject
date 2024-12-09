//
//  ViewController.swift
//  FinalProject
//
//  Created by Isak Sabelko on 11/19/24.
//

import UIKit
import SwiftSoup //used to scrape outsiders website for news stories

//opens first to news
class MainNewsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private var featuredStory: (title: String, url: String, images: [String])?
    private var news: [(title: String, url: String, images: [String])] = []
    private let tableView = UITableView()
    
    
    //title on top
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

        //set up tabbar looks
        tabBarController?.tabBar.isTranslucent = false
        tabBarController?.tabBar.barTintColor = .white
        
        setupTitleLabel()
        setupTableView()
        fetchNews()
    }

    //setup title
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
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: tabBarController?.tabBar.frame.height ?? 0, right: 0)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(FeaturedNewsCell.self, forCellReuseIdentifier: FeaturedNewsCell.identifier)
        tableView.register(NewsCell.self, forCellReuseIdentifier: NewsCell.identifier)
    }

    //function for fetching news to then display
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

                            //first article on website and set it as featured news
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
            //first set up featured story at top
            let cell = tableView.dequeueReusableCell(withIdentifier: FeaturedNewsCell.identifier, for: indexPath) as! FeaturedNewsCell
            cell.configure(with: featuredStory.title, imageURL: featuredStory.images.first ?? "")
            return cell
        } else {
            //then do the other stories
            let adjustedIndex = indexPath.row - (featuredStory != nil ? 1 : 0)

            //check for errors
            guard adjustedIndex < news.count else {
                print("Index out of range when creating cell for row: \(indexPath.row)")
                return UITableViewCell() // Return an empty cell to avoid a crash
            }

            //now display other storeis that arent featured
            let cell = tableView.dequeueReusableCell(withIdentifier: NewsCell.identifier, for: indexPath) as! NewsCell
            let article = news[adjustedIndex]
            cell.isFeatured = false //decide if featured
            cell.configure(with: article.title, imageURL: "") //no image for non featured
            return cell
        }
    }

    //UITableViewDelegate Method
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        //check for featured story
        if indexPath.row == 0, let firstStory = featuredStory {
            //put in first cell on top
            if let url = URL(string: firstStory.url) {
                UIApplication.shared.open(url)
            }
        } else {
            //rest is non featured
            let adjustedIndex = indexPath.row - (featuredStory != nil ? 1 : 0)
            
            //make sure valid index
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

