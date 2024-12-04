//
//  ViewController.swift
//  FinalProject
//
//  Created by Isak Sabelko on 11/19/24.
//

import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Climbing App"

        setupUI()
    }

    private func setupUI() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 20

        let settingsButton = createButton(title: "Settings", action: #selector(openSettings))
        let viewClimbsButton = createButton(title: "View Climbs", action: #selector(openViewClimbs))
        let logClimbButton = createButton(title: "Log Climb", action: #selector(openLogClimb))

        stackView.addArrangedSubview(settingsButton)
        stackView.addArrangedSubview(viewClimbsButton)
        stackView.addArrangedSubview(logClimbButton)

        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func createButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    @objc private func openSettings() {
        navigationController?.pushViewController(SettingsViewController(), animated: true)
    }

    @objc private func openViewClimbs() {
        navigationController?.pushViewController(ViewClimbsViewController(), animated: true)
    }

    @objc private func openLogClimb() {
        navigationController?.pushViewController(LogClimbViewController(), animated: true)
    }
}


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

