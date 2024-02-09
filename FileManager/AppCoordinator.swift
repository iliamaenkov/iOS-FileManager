//
//  AppCoordinator.swift
//  FileManager
//
//  Created by Ilya Maenkov on 09.02.2024.
//

import UIKit
import KeychainSwift

final class AppCoordinator {
    
    private let keychain = KeychainSwift()
    private let window: UIWindow

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        let loginViewController = LoginViewController(keychain: keychain)
        loginViewController.coordinator = self
        let navigationController = UINavigationController(rootViewController: loginViewController)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }

    func showMainTabBar() {
        let mainTabBarController = MainTabBarController()
        window.rootViewController = mainTabBarController
    }
}
