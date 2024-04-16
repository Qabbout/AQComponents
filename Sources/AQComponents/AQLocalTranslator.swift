//
//  AQLocalTranslator.swift
//
//
//  Created by Abdulrahman Qabbout on 27/06/2023.
//

//import UIKit
//import MLKit
//import MLKitLanguageID
//
//    /// To use this class, add the following in the podfile
//    ///   pod 'GoogleMLKit/Translate', '~> 4.0.0'
//    ///   pod 'GoogleMLKit/LanguageID', '~> 4.0.0'
//public final class AQLocalTranslator: NSObject {
//
//    public struct Output {
//        public let languageCode: String?
//        public let translatedText: String?
//        public let error: String?
//    }
//
//    public static let shared = LocalTranslator()
//    var sourceRemoteModel: TranslateRemoteModel!
//    var targetRemoteModel: TranslateRemoteModel!
//    var translator: Translator!
//    var options: TranslatorOptions!
//    var downloadInProgressLanguages: Set<TranslateRemoteModel> = Set()
//    lazy var allLanguages = TranslateLanguage.allLanguages().sorted {
//        return Locale.current.localizedString(forLanguageCode: $0.rawValue)!
//        < Locale.current.localizedString(forLanguageCode: $1.rawValue)!
//    }
//    lazy var languageId = LanguageIdentification.languageIdentification()
//    private lazy var didFinishDownloading: (String) -> Void = {_ in}
//    private override init() {
//        super.init()
//    }
//
//        /// Translate text to a specific target language or to local language
//        /// - Parameters:
//        ///   - currentText: The text to translate
//        ///   - targetLanguage: Optional - The target language
//        ///   - downloading: The downloading closure
//        ///   - completion: The completion closure, returns the ``Output``
//    public func localTranslate(currentText: String,
//                               targetLanguage: TranslateLanguage? = nil,
//                               downloading: @escaping () -> Void,
//                               completion: @escaping (Output) -> Void) {
//            identifyLangauge(text: currentText) {[weak self] output in
//                guard let self = self else { return }
//                if let error = output.error {
//                    completion(output)
//                } else if let languageCode = output.languageCode, languageCode != "und" {
//                    self.options = TranslatorOptions(sourceLanguage: .allLanguages().first(where: {$0.rawValue == languageCode}) ?? .english, targetLanguage: targetLanguage ?? .allLanguages().first(where: {$0.rawValue == Locale.current.languageCode}) ?? .arabic)
//                    self.sourceRemoteModel = TranslateRemoteModel.translateRemoteModel(language: self.options.sourceLanguage)
//                    self.targetRemoteModel = TranslateRemoteModel.translateRemoteModel(language: self.options.targetLanguage)
//                    self.translator = Translator.translator(options: self.options)
//
//                    if ModelManager.modelManager().downloadedTranslateModels.contains(self.sourceRemoteModel) && ModelManager.modelManager().downloadedTranslateModels.contains(self.targetRemoteModel) {
//                        self.translator.translate(currentText, completion: { translatedText, error in
//                            completion(.init(languageCode: languageCode, translatedText: translatedText, error: error?.localizedDescription))
//                        })
//                    } else {
//                        downloading()
//                        if !ModelManager.modelManager().isModelDownloaded(self.sourceRemoteModel) {
//                            guard !self.downloadInProgressLanguages.contains(self.sourceRemoteModel) else { return }
//                            ModelManager.modelManager().download(
//                                self.sourceRemoteModel,
//                                conditions: ModelDownloadConditions(
//                                    allowsCellularAccess: true,
//                                    allowsBackgroundDownloading: true
//                                )
//                            )
//                            self.downloadInProgressLanguages.insert(self.sourceRemoteModel)
//                        }
//                        if !ModelManager.modelManager().isModelDownloaded(self.targetRemoteModel) {
//                            guard !self.downloadInProgressLanguages.contains(self.targetRemoteModel) else { return }
//                            ModelManager.modelManager().download(
//                                self.targetRemoteModel,
//                                conditions: ModelDownloadConditions(
//                                    allowsCellularAccess: true,
//                                    allowsBackgroundDownloading: true
//                                )
//                            )
//                            self.downloadInProgressLanguages.insert(self.targetRemoteModel)
//                        }
//                        self.didFinishDownloading = {[weak self] downloadError in
//                            guard let self = self else { return }
//                            guard downloadError == nil else {
//                                return completion(.init(languageCode: languageCode, translatedText: nil, error: downloadError))
//                            }
//                            self.translator?.translate(currentText, completion: { translatedText, error in
//                                completion(.init(languageCode: languageCode, translatedText: translatedText, error: error?.localizedDescription))
//                            })
//                        }
//                    }
//                    debugPrint("Detected language code: \(languageCode)")
//                } else {
//                    completion(output)
//                }
//            }
//    }
//    func identifyLangauge(text: String, completion: @escaping (Output) -> Void) {
//        languageId.identifyLanguage(for: text) { languageCode, error in
//            if let error = error {
//                completion(.init(languageCode: languageCode, translatedText: nil, error: "Error identifying language: \(error.localizedDescription)"))
//            } else if languageCode == "und" {
//                completion(.init(languageCode: languageCode, translatedText: nil, error: "Could not identify language."))
//            } else {
//                completion(.init(languageCode: languageCode, translatedText: nil, error: nil))
//            }
//        }
//    }
//
//            /// Add this function after successful Login
//        public func setupObservers() {
//
//            NotificationCenter.default.addObserver(
//                forName: .mlkitModelDownloadDidSucceed,
//                object: nil,
//                queue: nil
//            ) {[weak self] notification in
//                guard let self = self,
//                      let userInfo = notification.userInfo,
//                      let model = userInfo[ModelDownloadUserInfoKey.remoteModel.rawValue] as? TranslateRemoteModel else { return }
//
//                self.downloadInProgressLanguages.remove(model)
//
//                    // The model was downloaded and is available on the device
//                if self.downloadInProgressLanguages.isEmpty {
//                    self.didFinishDownloading(nil)
//                }
//            }
//
//            NotificationCenter.default.addObserver(
//                forName: .mlkitModelDownloadDidFail,
//                object: nil,
//                queue: nil
//            ) {[weak self] notification in
//                guard let self = self,
//                      let userInfo = notification.userInfo,
//                      let model = userInfo[ModelDownloadUserInfoKey.remoteModel.rawValue] as? TranslateRemoteModel else { return }
//                let error = userInfo[ModelDownloadUserInfoKey.error.rawValue] as? String
//
//                    // The model failed to download
//                if model.language.rawValue != Locale.current.languageCode {
//                    self.didFinishDownloading(error)
//                }
//            }
//            downloadDefaultLanguageModel()
//        }
//
//    private func downloadDefaultLanguageModel() {
//        guard let language = TranslateLanguage.allLanguages().first(where: {$0.rawValue == Locale.current.languageCode}) else {return}
//        if !ModelManager.modelManager().isModelDownloaded(TranslateRemoteModel.translateRemoteModel(language: language)) {
//            ModelManager.modelManager().download(TranslateRemoteModel.translateRemoteModel(language: language), conditions: .init(allowsCellularAccess: true, allowsBackgroundDownloading: true))
//        }
//    }
//}
//
