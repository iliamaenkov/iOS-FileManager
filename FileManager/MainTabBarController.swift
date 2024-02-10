//
//  MainTabBarController.swift
//  FileManager
//
//  Created by Ilya Maenkov on 09.02.2024.
//

import UIKit
import KeychainSwift

final class MainTabBarController: UITabBarController {
    
    private let keychain = KeychainSwift()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
    }

    private func setupViewControllers() {
        let photoListViewController = PhotoListViewController()
        let settingsViewController = SettingsViewController(keychain: keychain)

        let photoListNavigationController = UINavigationController(rootViewController: photoListViewController)
        let settingsNavigationController = UINavigationController(rootViewController: settingsViewController)

        photoListViewController.sortingOption = settingsViewController.currentSortingOption

        photoListNavigationController.navigationBar.isHidden = false
        settingsNavigationController.navigationBar.isHidden = false

        photoListViewController.tabBarItem = UITabBarItem(title: "Files", image: UIImage(systemName: "folder"), tag: 0)
        settingsViewController.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gear"), tag: 1)

        viewControllers = [photoListNavigationController, settingsNavigationController]
    }
}

