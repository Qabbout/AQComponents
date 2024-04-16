//
//  AQImageVideoPicker.swift
//
//
//  Created by Abdulrahman Qabbout on 16/04/2024.
//

import UIKit
import PhotosUI

@available(iOS 14.0, *)
protocol AQImageVideoPickerDelegate: AnyObject {
    func imageVideoPicker(_ picker: AQImageVideoPicker, didSelectImagesAt urls: [URL])
    func imageVideoPicker(_ picker: AQImageVideoPicker, didSelectVideosAt urls: [URL])
    func imageVideoPickerDidCancel(_ picker: AQImageVideoPicker)
}

@available(iOS 14.0, *)
public class AQImageVideoPicker: NSObject {
    
    weak var delegate: AQImageVideoPickerDelegate?
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController, delegate: AQImageVideoPickerDelegate) {
        super.init()
        self.viewController = viewController
        self.delegate = delegate
    }
    
    public func present(allowsMultipleSelection: Bool, configuration: PHPickerConfiguration,  completion: (() -> Void)? = nil) {
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        viewController?.present(picker, animated: true, completion: completion)
    }
}

@available(iOS 14.0, *)
extension AQImageVideoPicker: PHPickerViewControllerDelegate {
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard !results.isEmpty else {
            delegate?.imageVideoPickerDidCancel(self)
            return
        }
        
        let imageResults = results.filter { $0.itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier) }
        let videoResults = results.filter { $0.itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) }
        
        processPickedItems(imageResults, mediaType: .image)
        processPickedItems(videoResults, mediaType: .movie)
    }

    private func processPickedItems(_ results: [PHPickerResult], mediaType: UTType) {
        let group = DispatchGroup()
        var urls: [URL] = []

        for result in results {
            group.enter()
            result.itemProvider.loadFileRepresentation(forTypeIdentifier: mediaType.identifier) { (url, error) in
                if let url = url, let newURL = self.copyToTempLocation(originalURL: url) {
                    urls.append(newURL)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            if mediaType == .image {
                self.delegate?.imageVideoPicker(self, didSelectImagesAt: urls)
            } else if mediaType == .movie {
                self.delegate?.imageVideoPicker(self, didSelectVideosAt: urls)
            }
        }
    }

    private func copyToTempLocation(originalURL: URL) -> URL? {
        let fileManager = FileManager.default
        let tempDirectoryURL = fileManager.temporaryDirectory
        let targetURL = tempDirectoryURL.appendingPathComponent(originalURL.lastPathComponent)

        do {
            if fileManager.fileExists(atPath: targetURL.path) {
                try fileManager.removeItem(at: targetURL)
            }
            try fileManager.copyItem(at: originalURL, to: targetURL)
            return targetURL
        } catch {
            print("Failed to copy file: \(error)")
            return nil
        }
    }
}
