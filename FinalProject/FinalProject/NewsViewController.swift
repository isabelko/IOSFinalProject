//  NewsViewController.swift
//  FinalProject
//
//  Created by Isak Sabelko on 11/19/24.
//

import Foundation
import UIKit

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

//table cells
class NewsCell: UITableViewCell {
    static let identifier = "NewsCell"
    
    private let titleLabel = UILabel()
    private let customImageView = UIImageView()
    
    var isFeatured: Bool = false {
        didSet {
            customImageView.isHidden = !isFeatured  //determine if featured
            updateConstraintsForFeatured(isFeatured)
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        titleLabel.font = .systemFont(ofSize: 16)
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        customImageView.contentMode = .scaleAspectFill
        customImageView.clipsToBounds = true
        customImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(customImageView)
    }
    
    private func updateConstraintsForFeatured(_ isFeatured: Bool) {
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
    
    func configure(with title: String, imageURL: String) {
        titleLabel.text = title
        
        if isFeatured, let url = URL(string: imageURL) {
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


