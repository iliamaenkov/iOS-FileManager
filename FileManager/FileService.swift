//
//  FileService.swift
//  FileManager
//
//  Created by Ilya Maenkov on 06.02.2024.
//

import Foundation
import UIKit

final class FileService {
    
    private let pathForFolder: String
    
    var items: [String] {
        let files = (try? FileManager.default.contentsOfDirectory(atPath: pathForFolder)) ?? []

        let imageExtensions = Set(["jpg", "jpeg", "png", "gif", "bmp", "webp"])

        let images = files
            .filter { fileName in
                let filePath = pathForFolder + "/" + fileName
                var isDirectory: ObjCBool = false
                FileManager.default.fileExists(atPath: filePath, isDirectory: &isDirectory)

                guard !isDirectory.boolValue else {
                    return false
                }

                let fileExtension = (filePath as NSString).pathExtension.lowercased()
                return imageExtensions.contains(fileExtension)
            }
            .sorted()

        return images
    }

    
    init() {
        pathForFolder = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        print("pathForFolder", pathForFolder)
    }
    
    init(pathFolder: String) {
        self.pathForFolder = pathFolder
    }
    
    func addFile(name: String, data: Data, originalImageURL: URL, completion: @escaping (Bool) -> Void) {
        //        let fileExtension = originalImageURL.pathExtension.lowercased()
        //        let imageName = "\(data.hashValue).\(fileExtension)"
        let url = URL(fileURLWithPath: pathForFolder).appendingPathComponent(name)

        if FileManager.default.fileExists(atPath: url.path) {
            DispatchQueue.main.async {
                self.showFileExistsAlert(url: url) { shouldOverwrite in
                    if shouldOverwrite {
                        do {
                            try data.write(to: url)
                            completion(true)
                        } catch {
                            completion(false)
                        }
                    } else {
                        completion(false)
                    }
                }
            }
        } else {
            do {
                try data.write(to: url)
                completion(true)
            } catch {
                completion(false)
            }
        }
    }

    
    private func showFileExistsAlert(url: URL, completion: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: "Файл уже существует", message: "Хотите перезаписать файл?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Перезаписать", style: .destructive) { _ in
            completion(true)
        })
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel) { _ in
            completion(false)
        })
        
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = scene.windows.first?.rootViewController {
            rootViewController.present(alert, animated: true, completion: nil)
        } else {
            completion(false)
        }
    }
    
    func deleteItem(at index: Int, completion: @escaping (Bool) -> Void) {
        let path = pathForFolder + "/" + items[index]
        let url = URL(fileURLWithPath: path)
        
        do {
            try FileManager.default.removeItem(at: url)
            completion(true)
        } catch {
            completion(false)
        }
    }
    
    func getPath(at index: Int) -> String? {
        guard index >= 0, index < items.count else {
            return nil
        }
        
        let path = pathForFolder + "/" + items[index]
        return path
    }
}
