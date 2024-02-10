//
//  ErrorProtocol.swift
//  FileManager
//
//  Created by Ilya Maenkov on 10.02.2024.
//

import UIKit

protocol ErrorAlert where Self: UIViewController {
    func showErrorAlert(message: String)
}

extension ErrorAlert {
    func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
