//
//  SceneDelegate.swift
//  FinalProject
//
//  Created by Isak Sabelko on 11/19/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [
            createViewController(for: MainViewController(), title: "News", imageName: "newspaper"),
            createViewController(for: ViewClimbsViewController(), title: "View Climbs", imageName: "list.bullet"),
            createViewController(for: LogClimbViewController(), title: "Log Climb", imageName: "plus"),
            createNavController(for: SettingsViewController(), title: "Settings", imageName: "gear")
        ]

        // Add a pan gesture recognizer
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        tabBarController.view.addGestureRecognizer(panGesture)

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
        self.window = window
    }

    private func createNavController(for rootViewController: UIViewController, title: String, imageName: String) -> UINavigationController {
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = UIImage(systemName: imageName)
        rootViewController.navigationItem.title = title
        return navController
    }

    private func createViewController(for viewController: UIViewController, title: String, imageName: String) -> UIViewController {
        viewController.tabBarItem.title = title
        viewController.tabBarItem.image = UIImage(systemName: imageName)
        return viewController
    }

    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: gesture.view)

        // Check for a horizontal swipe to the left with a sufficient distance
        if gesture.state == .ended && translation.x < -200 { // Adjust -200 for larger swipes
            guard let tabBarController = window?.rootViewController as? UITabBarController else { return }

            // Find the index of the "Log Climb" tab
            guard let logClimbIndex = tabBarController.viewControllers?.firstIndex(where: {
                ($0.tabBarItem.title == "Log Climb")
            }) else {
                print("Log Climb tab not found")
                return
            }

            tabBarController.selectedIndex = logClimbIndex
        }
    }
}





