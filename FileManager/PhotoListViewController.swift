//
//  PhotoListViewController.swift
//  FileManager
//
//  Created by Ilya Maenkov on 06.02.2024.
//

import UIKit

enum SortingOption {
    case alphabetical
    case reverse
}

final class PhotoListViewController: UIViewController {

    
    private let fileService: FileService

    var sortingOption: SortingOption = .alphabetical {
         didSet {
             updateSorting()
         }
     }
    
    //MARK: - UI Elements
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        
        return tableView
    }()

    private lazy var imagePicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        
        return picker
    }()
    
    //MARK: - LifeCycle
    
    init(fileService: FileService = FileService()) {
         self.fileService = fileService
         super.init(nibName: nil, bundle: nil)
     }

     required init?(coder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
     }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupLayout()
        setupNavigation()
        NotificationCenter.default.addObserver(self, selector: #selector(sortingOptionChanged(_:)), name: Notification.Name("SortingOptionChanged"), object: nil)
        
        sortingOption = UserDefaults.standard.value(forKey: "isSortingAlphabetical") as? Bool == true ? .alphabetical : .reverse
    }

    //MARK: - Methods
    
    private func setupNavigation() {
        navigationItem.title = "Foto"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonAction))
        navigationItem.rightBarButtonItem?.tintColor = .systemBlue
    }

    private func setupLayout() {
        view.addSubview(tableView)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    @objc private func addButtonAction() {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc private func sortingOptionChanged(_ notification: Notification) {
        if let sortingOption = notification.object as? SortingOption {
            self.sortingOption = sortingOption
        }
        // Ensure to call updateSorting here or perform any actions you need
        updateSorting()
    }
    
    private func updateSorting() {
        switch sortingOption {
        case .alphabetical:
            fileService.files = fileService.sortedItems
        case .reverse:
            fileService.files = fileService.sortedItems.reversed()
        }
        tableView.reloadData()
    }
}

//MARK: - Extensions

extension PhotoListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(fileService.files.count, 1)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if fileService.files.isEmpty && indexPath.row == 0 {
            cell.textLabel?.text = "Tap to add foto..."
            cell.imageView?.image = nil
        } else {
            let originalString = fileService.files[indexPath.row]
            cell.textLabel?.text = originalString
         
            cell.imageView?.image = nil
            
            if let filePath = fileService.getPath(at: indexPath.row),
               let image = UIImage(contentsOfFile: filePath) {
                let scaledImage = image.resized(to: CGSize(width: 32, height: 32))
                cell.imageView?.image = scaledImage
            }
        }
        return cell
    }
}

extension PhotoListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if !fileService.files.isEmpty {
            if editingStyle == .delete {
                fileService.deleteItem(at: indexPath.row) { success in
                    if success {
                        tableView.reloadData()
                    }
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if fileService.files.isEmpty && indexPath.row == 0 {
            addButtonAction()
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            let fileName = fileService.files[indexPath.row]
            let alert = UIAlertController(title: "Полное имя изображения", message: fileName, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
    }
}

extension PhotoListViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)

        if let image = info[.originalImage] as? UIImage,
           let imageURL = info[.imageURL] as? URL,
           let fileName = imageURL.path.components(separatedBy: "/").last,
           let imageData = image.jpegData(compressionQuality: 1.0) ?? image.pngData() {

            _ = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)

            fileService.addFile(name: fileName, data: imageData, originalImageURL: imageURL) { success in
                if success {
                    self.tableView.reloadData()
                } else {
                    print("Не удалось добавить изображение")
                }
            }
        }
    }
}

extension UIImage {
    func resized(to targetSize: CGSize) -> UIImage {
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        let scaleFactor = min(widthRatio, heightRatio)

        let scaledSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)

        UIGraphicsBeginImageContextWithOptions(scaledSize, false, 0.0)
        defer { UIGraphicsEndImageContext() }

        draw(in: CGRect(origin: .zero, size: scaledSize))

        guard let resizedImage = UIGraphicsGetImageFromCurrentImageContext() else { return self }
        return resizedImage
    }
}
