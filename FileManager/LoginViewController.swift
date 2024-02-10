//
//  LoginViewController.swift
//  FileManager
//
//  Created by Ilya Maenkov on 06.02.2024.
//

import UIKit
import KeychainSwift

enum PasswordState {
    case initial
    case creatingPassword
    case repeatingPassword
}

final class LoginViewController: UIViewController, ErrorAlert {

    //MARK: - Properties
    
    private let keychain: KeychainSwift
    var coordinator: AppCoordinator?
    
    private var passwordState: PasswordState = .initial
    private var initialPassword: String?

    //MARK: - UIElements
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.isSecureTextEntry = true
        textField.backgroundColor = .systemGray6
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Enter your password"
        textField.layer.cornerRadius = 8
        textField.clipsToBounds = true
        
        ///Check
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        textField.leftView = leftPaddingView
        textField.leftViewMode = .always

        return textField
    }()

    private let logInButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        
        return button
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
        
        view.addSubview(passwordTextField)
        view.addSubview(logInButton)
        
        setupConstraints()
        checkExistingPassword()
        updateUI()
    }

    //MARK: - Methods
    
    private func setupConstraints() {
        logInButton.addTarget(self, action: #selector(tapLogIn), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),

            logInButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 12),
            logInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            logInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            logInButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func checkExistingPassword() {
        if keychain.get("password") != nil {
            passwordState = .repeatingPassword
        } else {
            passwordState = .initial
        }
    }
    
    private func updateUI() {
        switch passwordState {
        case .initial:
            logInButton.setTitle("Create Password", for: .normal)
        case .creatingPassword:
            logInButton.setTitle("Repeat Password", for: .normal)
        case .repeatingPassword:
            logInButton.setTitle("Enter Password", for: .normal)
        }
    }

    private func createPassword() {
        guard let password = passwordTextField.text, password.count >= 4 else {
            showErrorAlert(message: "Password must be at least 4 characters long")
            return
        }
        initialPassword = password
        passwordState = .creatingPassword
        updateUI()
        
        passwordTextField.text = ""
    }

    private func repeatPassword() {
        guard let password = passwordTextField.text, password.count >= 4 else {
            showErrorAlert(message: "Password must be at least 4 characters long")
            return
        }
        guard let firstPassword = initialPassword else {
            showErrorAlert(message: "Unexpected error. Please try again.")
            return
        }
        
        if password == firstPassword {
            keychain.set(password, forKey: "password")
            coordinator?.showMainTabBar()
        } else {
            showErrorAlert(message: "Passwords do not match")
            passwordState = .creatingPassword
            updateUI()
            
            passwordTextField.text = ""
        }
    }
    
    private func enterPassword() {
        guard let enteredPassword = passwordTextField.text else { return }
        if keychain.get("password") == enteredPassword {
            coordinator?.showMainTabBar()
        } else {
            showErrorAlert(message: "Incorrect Password")
        }
    }
    
    @objc private func tapLogIn() {
        switch passwordState {
        case .initial:
            createPassword()
        case .creatingPassword:
            repeatPassword()
        case .repeatingPassword:
            enterPassword()
        }
    }
}
