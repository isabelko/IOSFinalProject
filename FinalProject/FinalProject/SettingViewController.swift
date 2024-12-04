//
//  SettingViewController.swift
//  FinalProject
//
//  Created by Isak Sabelko on 12/4/24.
//

import Foundation

import UIKit

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let button = UIButton(type: .system)
        button.setTitle("Go to Sub-Settings", for: .normal)
        button.addTarget(self, action: #selector(openSubSettings), for: .touchUpInside)

        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc private func openSubSettings() {
        let subSettingsVC = UIViewController()
        subSettingsVC.view.backgroundColor = .systemGray6
        subSettingsVC.title = "Sub-Settings"
        navigationController?.pushViewController(subSettingsVC, animated: true)
    }
}
