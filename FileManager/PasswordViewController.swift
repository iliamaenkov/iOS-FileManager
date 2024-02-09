//
//  PasswordViewController.swift
//  FileManager
//
//  Created by Ilya Maenkov on 09.02.2024.
//

import UIKit
import KeychainSwift

final class PasswordViewController: UIViewController, ErrorAlert {

    // MARK: - Properties
    
    private let keychain: KeychainSwift
    
    private let currentPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.isSecureTextEntry = true
        textField.placeholder = "Current Password"
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.layer.cornerRadius = 8
        textField.clipsToBounds = true
        
        return textField
    }()

    private let newPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.isSecureTextEntry = true
        textField.placeholder = "New Password"
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.layer.cornerRadius = 8
        textField.clipsToBounds = true
        
        return textField
    }()

    private let repeatPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.isSecureTextEntry = true
        textField.placeholder = "Repeat New Password"
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.layer.cornerRadius = 8
        textField.clipsToBounds = true
        
        return textField
    }()

    private let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Save", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        
        return button
    }()

    // MARK: - Lifecycle
    
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
        title = "Change Password"

        setupLayout()
        setupActions()
    }

    // MARK: - Methods
    
    private func setupLayout() {
        view.addSubview(currentPasswordTextField)
        view.addSubview(newPasswordTextField)
        view.addSubview(repeatPasswordTextField)
        view.addSubview(saveButton)

        NSLayoutConstraint.activate([
            currentPasswordTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            currentPasswordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            currentPasswordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            currentPasswordTextField.heightAnchor.constraint(equalToConstant: 40),

            newPasswordTextField.topAnchor.constraint(equalTo: currentPasswordTextField.bottomAnchor, constant: 20),
            newPasswordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            newPasswordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            newPasswordTextField.heightAnchor.constraint(equalToConstant: 40),

            repeatPasswordTextField.topAnchor.constraint(equalTo: newPasswordTextField.bottomAnchor, constant: 20),
            repeatPasswordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            repeatPasswordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            repeatPasswordTextField.heightAnchor.constraint(equalToConstant: 40),

            saveButton.topAnchor.constraint(equalTo: repeatPasswordTextField.bottomAnchor, constant: 30),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 40),
        ])
    }

    private func setupActions() {
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }

    @objc private func saveButtonTapped() {
        guard let newPassword = newPasswordTextField.text, !newPassword.isEmpty else {
            showErrorAlert(message: "New password not provided")
            return
        }

        guard newPassword.count >= 4 else {
            showErrorAlert(message: "New password must be at least 4 characters long")
            return
        }
        
        guard let repeatedPassword = repeatPasswordTextField.text, !repeatedPassword.isEmpty else {
            showErrorAlert(message: "Repeated password not provided")
            return
        }

        guard newPassword == repeatedPassword else {
            showErrorAlert(message: "Passwords do not match")
            return
        }
        guard currentPasswordTextField.text == keychain.get("password") else {
            showErrorAlert(message: "Confirm current password")
            return
        }
        keychain.set(newPassword, forKey: "password")

        dismiss(animated: true, completion: nil)
    }
}
