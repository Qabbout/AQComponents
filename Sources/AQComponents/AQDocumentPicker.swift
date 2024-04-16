//
//  AQDocumentPicker.swift
//
//
//  Created by Abdulrahman Qabbout on 16/04/2024.
//

import UIKit

public protocol AQDocumentPickerDelegate: AnyObject {
    func documentPicker(_ picker: AQDocumentPicker, didPickDocumentsAt urls: [URL])
    func documentPickerWasCancelled(_ picker: AQDocumentPicker)
}

public final class AQDocumentPicker: NSObject, UIDocumentPickerDelegate {
    
    private weak var viewController: UIViewController?
    private weak var delegate: AQDocumentPickerDelegate?
    
    public init(viewController: UIViewController, delegate: AQDocumentPickerDelegate) {
        self.viewController = viewController
        self.delegate = delegate
        super.init()
    }
    
    public func presentForImport(types: [String], allowsMultipleSelection: Bool) {
        let picker = UIDocumentPickerViewController(documentTypes: types, in: .import)
        configurePicker(picker, allowsMultipleSelection: allowsMultipleSelection)
    }
    
    public func presentForExport(url: URL, allowsMultipleSelection: Bool) {
        // Ensure the URL is accessible from your app’s sandbox
        let picker = UIDocumentPickerViewController(url: url, in: .exportToService)
        configurePicker(picker, allowsMultipleSelection: allowsMultipleSelection)
    }
    
    private func configurePicker(_ picker: UIDocumentPickerViewController, allowsMultipleSelection: Bool) {
        picker.delegate = self
        picker.allowsMultipleSelection = allowsMultipleSelection
        viewController?.present(picker, animated: true, completion: nil)
    }
    
    // UIDocumentPickerDelegate methods
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        // Handle file copying or moving if necessary
        for url in urls {
            processFile(at: url)
        }
        delegate?.documentPicker(self, didPickDocumentsAt: urls)
    }
    
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        delegate?.documentPickerWasCancelled(self)
    }
    
    private func processFile(at url: URL) {
        // Example: Copy the file to a specific directory
        let localPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationURL = localPath.appendingPathComponent(url.lastPathComponent)
        do {
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            try FileManager.default.copyItem(at: url, to: destinationURL)
        } catch {
            dump("Failed to copy file: \(error.localizedDescription)")
        }
    }
}


///EXAMPLE:
//class MyViewController: UIViewController, AQDocumentPickerDelegate {
//
//var documentPicker: AQDocumentPicker?
//
//override func viewDidLoad() {
//    super.viewDidLoad()
//    documentPicker = AQDocumentPicker(viewController: self, delegate: self)
//}
//
//func importDocuments() {
//    documentPicker?.presentForImport(types: [String(kUTTypePDF)], allowsMultipleSelection: true)
//}
//
//func exportDocument(url: URL) {
//    documentPicker?.presentForExport(url: url)
//}
//
//// Implement the AQDocumentPickerDelegate methods
//}


