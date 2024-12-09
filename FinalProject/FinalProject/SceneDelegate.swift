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

        //setup tabbarcontroller for the main screen
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [
            createViewController(for: MainNewsViewController(), title: "News", imageName: "newspaper"),
            createNavController(for: ViewClimbsViewController(), title: "View Climbs", imageName: "list.bullet"),
            createViewController(for: LogClimbViewController(), title: "Log Climb", imageName: "plus"),
            createViewController(for: SettingsViewController(), title: "Settings", imageName: "gear")
        ]

        //set up pan gesture so right swipe is larger, ui gesture was too small
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        tabBarController.view.addGestureRecognizer(panGesture)

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
        self.window = window
    }

    //nav controller
    private func createNavController(for rootViewController: UIViewController, title: String, imageName: String) -> UINavigationController {
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = UIImage(systemName: imageName)
        rootViewController.navigationItem.title = title
        return navController
    }

    //views without nav controller
    private func createViewController(for viewController: UIViewController, title: String, imageName: String) -> UIViewController {
        viewController.tabBarItem.title = title
        viewController.tabBarItem.image = UIImage(systemName: imageName)
        return viewController
    }

    //set up functionalitt of right swipe
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let tabBarController = window?.rootViewController as? UITabBarController else { return }

        //speed and direction
        let translation = gesture.translation(in: gesture.view)
        let velocity = gesture.velocity(in: gesture.view)

        //check for right swipe for going to log new climb
        if gesture.state == .ended && translation.x > 250 && abs(translation.y) < 50 && velocity.x > 0 {
            print("Detected a right swipe!") //quick debug

            //find log climb
            guard let logClimbIndex = tabBarController.viewControllers?.firstIndex(where: {
                ($0.tabBarItem.title == "Log Climb")
            }) else {
                print("Log Climb tab not found")
                return
            }

            //go to log climb
            tabBarController.selectedIndex = logClimbIndex
        }
    }
}
