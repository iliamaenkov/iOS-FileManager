//
//  SettingsViewController.swift
//  FileManager
//
//  Created by Ilya Maenkov on 08.02.2024.
//

import UIKit
import KeychainSwift

final class SettingsViewController: UIViewController {

    private let keychain: KeychainSwift
    
    //MARK: - Properties
    
    var currentSortingOption: SortingOption = .reverse {
        didSet {
            NotificationCenter.default.post(name: Notification.Name("SortingOptionChanged"), object: currentSortingOption)
        }
    }
    
    private let options = ["Alphabetic Sort", "Change Password", "Delete User"]
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private let sortingSwitch: UISwitch = {
        let sortingSwitch = UISwitch()
        sortingSwitch.translatesAutoresizingMaskIntoConstraints = false
        return sortingSwitch
    }()
    
    //MARK: - Lifecycle
    
    init(keychain: KeychainSwift) {
        self.keychain = keychain
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Settings"

        setupLayout()
        setupNavigation()
        loadSortingSwitchState()
    }
    
    //MARK: - Methods

    private func setupNavigation() {
        navigationItem.title = "Settings"
        navigationItem.rightBarButtonItem?.tintColor = .systemBlue
    }

    private func setupLayout() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "settingCell")

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        sortingSwitch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
    }

    @objc private func switchValueChanged() {
        let isSortingAlphabetical = sortingSwitch.isOn
        currentSortingOption = isSortingAlphabetical ? .alphabetical : .reverse
        saveSortingSwitchState(isSortingAlphabetical)
        
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) {
            cell.textLabel?.text = "Alphabetic Sort: \(isSortingAlphabetical ? "On" : "Off")"
        }
        
        print("Sorting switch value changed to \(isSortingAlphabetical ? "On" : "Off")")
    }
    
    private func showPasswordScreen() {
        let passwordViewController = PasswordViewController(keychain: keychain)
        let navigationController = UINavigationController(rootViewController: passwordViewController)
        present(navigationController, animated: true, completion: nil)
    }
    
    private func saveSortingSwitchState(_ isOn: Bool) {
        UserDefaults.standard.set(isOn, forKey: "isSortingAlphabetical")
    }
    
    private func loadSortingSwitchState() {
        if let isSortingAlphabetical = UserDefaults.standard.value(forKey: "isSortingAlphabetical") as? Bool {
            sortingSwitch.isOn = isSortingAlphabetical
            switchValueChanged()
        }
    }
}

//MARK: - Extensions

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell", for: indexPath)
        
        switch indexPath.row {
        case 0:
            let isSortingOn = sortingSwitch.isOn
            cell.textLabel?.text = "Alphabetic Sort: \(isSortingOn ? "On" : "Off")"
            cell.accessoryView = sortingSwitch
        case 1, 2:
            cell.textLabel?.text = options[indexPath.row]
            cell.accessoryType = (indexPath.row == 1) ? .disclosureIndicator : .none
            cell.textLabel?.textColor = (indexPath.row == 2) ? .red : .black
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            
            switch indexPath.row {
            case 0:
                print("Selected sorting option: \(options[indexPath.row])")
            case 1:
                showPasswordScreen()
            case 2:
                showDeleteUserAlert()
            default:
                break
            }
        }
    
    private func showDeleteUserAlert() {
        let alert = UIAlertController(
            title: "Warning",
            message: "Are you sure you want to delete the user?",
            preferredStyle: .alert
        )
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .destructive) { [weak self] _ in
            self?.keychain.clear()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
}
