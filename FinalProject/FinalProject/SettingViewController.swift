//
//  SettingViewController.swift
//  FinalProject
//
//  Created by Isak Sabelko on 11/19/24.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Settings"

        //switch for enabling/disabling news
        let disableNewsSwitch = UISwitch()
        disableNewsSwitch.isOn = !UserDefaults.standard.bool(forKey: "disableNews") // Default is news enabled
        disableNewsSwitch.addTarget(self, action: #selector(toggleNews(_:)), for: .valueChanged)


        let disableNewsLabel = UILabel()
        disableNewsLabel.text = "Enable News"
        disableNewsLabel.font = .systemFont(ofSize: 16)
        disableNewsLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(disableNewsLabel)
        view.addSubview(disableNewsSwitch)
        disableNewsSwitch.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            disableNewsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            disableNewsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            disableNewsSwitch.centerYAnchor.constraint(equalTo: disableNewsLabel.centerYAnchor),
            disableNewsSwitch.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    @objc private func toggleNews(_ sender: UISwitch) {
        let isDisabled = !sender.isOn
        UserDefaults.standard.set(isDisabled, forKey: "disableNews")

        //notify MainNewsViewController about the change
        NotificationCenter.default.post(name: Notification.Name("NewsVisibilityChanged"), object: nil)
    }
}
