//
//  SettingViewController.swift
//  FinalProject
//
//  Created by Isak Sabelko on 12/4/24.
//
//will be a uinavcontroller

import Foundation
import UIKit

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        // Add a button for the test setting just to show myself that it is a uinavcontroller
        let testSettingButton = UIButton(type: .system)
        testSettingButton.setTitle("Test Setting", for: .normal)
        testSettingButton.addTarget(self, action: #selector(openTestSetting), for: .touchUpInside)

        view.addSubview(testSettingButton)
        testSettingButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            testSettingButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            testSettingButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc private func openTestSetting() {
        let testSettingVC = UIViewController()
        testSettingVC.view.backgroundColor = .systemGray6
        testSettingVC.title = "Test Setting Screen"

        let label = UILabel()
        label.text = "This is a test setting screen."
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        testSettingVC.view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: testSettingVC.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: testSettingVC.view.centerYAnchor)
        ])

        // Push the test setting screen onto top of stack! :) yay
        navigationController?.pushViewController(testSettingVC, animated: true)
    }
}
