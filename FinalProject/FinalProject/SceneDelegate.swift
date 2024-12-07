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
            createNavController(for: ViewClimbsViewController(), title: "View Climbs", imageName: "list.bullet"),
            createViewController(for: LogClimbViewController(), title: "Log Climb", imageName: "plus"),
            createNavController(for: SettingsViewController(), title: "Settings", imageName: "gear")
        ]

        // Add a pan gesture recognizer for custom swipe navigation
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        tabBarController.view.addGestureRecognizer(panGesture)

        // Set up the window with the tab bar controller
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
        self.window = window
    }

    // Create a navigation controller for tabs that need navigation functionality
    private func createNavController(for rootViewController: UIViewController, title: String, imageName: String) -> UINavigationController {
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = UIImage(systemName: imageName)
        rootViewController.navigationItem.title = title
        return navController
    }

    // Create a standalone view controller for tabs without navigation
    private func createViewController(for viewController: UIViewController, title: String, imageName: String) -> UIViewController {
        viewController.tabBarItem.title = title
        viewController.tabBarItem.image = UIImage(systemName: imageName)
        return viewController
    }

    // Handle the pan gesture for right swipe navigation
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let tabBarController = window?.rootViewController as? UITabBarController else { return }

        // Detect the direction and magnitude of the pan gesture
        let translation = gesture.translation(in: gesture.view)
        let velocity = gesture.velocity(in: gesture.view)

        // Check for a horizontal **right swipe**
        if gesture.state == .ended && translation.x > 250 && abs(translation.y) < 50 && velocity.x > 0 {
            print("Detected a right swipe!") // Debugging log

            // Find the index of the "Log Climb" tab
            guard let logClimbIndex = tabBarController.viewControllers?.firstIndex(where: {
                ($0.tabBarItem.title == "Log Climb")
            }) else {
                print("Log Climb tab not found")
                return
            }

            // Switch to the "Log Climb" tab
            tabBarController.selectedIndex = logClimbIndex
        }
    }
}
