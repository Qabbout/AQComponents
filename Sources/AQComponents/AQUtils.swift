//
//  AQUtils.swift
//
//
//  Created by Abdulrahman Qabbout on 27/06/2023.
//

import UIKit
import MessageUI

final public class AQUtils {
    
    public static func setScrollViewWillEndDraggingToVerticalPaging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>, layout: UICollectionViewFlowLayout) {
        
        let cellHeightIncludingSpacing = layout.itemSize.height + layout.minimumLineSpacing
        let proposedContentOffsetY = targetContentOffset.pointee.y
        let rawIndex = (proposedContentOffsetY + scrollView.contentInset.top) / cellHeightIncludingSpacing
        
        let velocityThreshold: CGFloat = 0.1 // Adjust this value as needed
        let isSwipeDown = velocity.y > 0
        let isSwipeUp = velocity.y < 0
        
        let index: CGFloat = if (isSwipeDown && velocity.y > velocityThreshold) || (isSwipeUp && velocity.y < -velocityThreshold) {
            // Use ceil or floor depending on swipe direction to determine the index
            isSwipeDown ? ceil(rawIndex) : floor(rawIndex)
        } else {
            // Use rounding for small or no velocity
            round(rawIndex)
        }
        
        // Adjust the targetContentOffset to snap to the nearest cell
        targetContentOffset.pointee.y = index * cellHeightIncludingSpacing - scrollView.contentInset.top
        
    }
    
    public static func convertTimeStampToSeconds(timeStamp: String) -> Double {
        let components = timeStamp.split(separator: ":")
        guard
            components.count == 2,
            let minutes = Int(components[0]),
            let seconds = Int(components[1])
        else {
            return 0.0
        }
        
        return Double((minutes * 60) + seconds)
    }
    
    public static func runMethodAfter(sleepValue: Double = 0.1, closure: @escaping () -> Void) {
        let deadlineTime = DispatchTime.now() + sleepValue
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            closure()
        }
    }
    
    public static func getKeyWindowSceneView() -> UIWindow? {
        UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .filter(\.isKeyWindow).first
    }
    
    public static func randomString(of length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var s = ""
        for _ in 0 ..< length {
            s.append(letters.randomElement()!)
        }
        return s
    }
    
    public static func setNewRootViewControllerWithAnimation(newViewController: UIViewController, animation: CATransition? = nil, useDefaultAnimations: Bool = false) {
        if let window = UIApplication.shared.delegate?.window {
            if let animation {
                window?.layer.add(animation, forKey: kCATransition)
            } else if useDefaultAnimations {
                let transition = CATransition()
                transition.type = .fade
                transition.duration = 0.3
                window?.layer.add(transition, forKey: kCATransition)
            }
            window?.rootViewController = newViewController
            window?.makeKeyAndVisible()
        }
    }
    public static func showAlerts(vc: UIViewController, view: UIView?, title: String, message: String, cancelButtonTitle: String, alertStyle: UIAlertController.Style, actions: [(title: String, style: UIAlertAction.Style, handler: () -> Void)], completion: @escaping (_ actionClicked: Bool) -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: alertStyle)
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = view
            popoverController.sourceRect = CGRect(x: view?.bounds.midX ?? 0, y: view?.bounds.midY ?? 0, width: 0, height: 0)
        }
        let action = UIAlertAction(title: cancelButtonTitle, style: .cancel) { _ in
            completion(false)
        }
        alertController.addAction(action)
        for action in actions {
            let newAction = UIAlertAction(title: action.title, style: action.style) { _ in
                action.handler()
                completion(action.style != .cancel)
            }
            alertController.addAction(newAction)
        }
        vc.present(alertController, animated: true)
    }
    
    public static func showAlerControllerWithTextField(vc: UIViewController? = nil, title:String, message:String, dismissTitle:String, actionTitle:String, actionButtonStyle:UIAlertAction.Style = .default, textfieldPlaceholder: String = "",textfieldText: String? = nil, isTextFieldSecured:Bool = false, shouldDisableActionButton: Bool = false, completion:@escaping (_ actionClicked:Bool, _ textFieldText: String, _ alertController: UIAlertController) -> Void ) {
        
        
        
        let alertController = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.isSecureTextEntry = isTextFieldSecured
            textField.placeholder = textfieldPlaceholder
            if let textfieldText = textfieldText {
                textField.text = textfieldText
            }
            if let vc = vc {
                textField.delegate = vc as? any UITextFieldDelegate
            }
        }
        completion(false, "", alertController)
        let action = UIAlertAction.init(title: dismissTitle, style: .cancel) { (clicked) in
            completion(false, "", alertController)
        }
        let action2 = UIAlertAction.init(title: actionTitle, style: actionButtonStyle) { (clicked) in
            let textField = alertController.textFields![0]
            completion(true, textField.text ?? "", alertController)
        }
        
        action2.isEnabled = !shouldDisableActionButton
        
        alertController.addAction(action)
        alertController.addAction(action2)
        if let vc = vc {
            
            vc.presenter.present(alertController, animated: true, completion: {})
        } else {
            let topView = UIApplication.shared.topViewController()
            topView?.presenter.present(alertController, animated: true, completion: {})
        }
    }
    
    
    public static func addFullScreenBlock(blockColor: UIColor = UIColor.clear) {
        removeFullScreenBlock()
        let loadingView = UIView()
        let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        loadingView.frame = CGRect(x: 0, y: 0, width: window?.frame.size.width ?? UIScreen.main.bounds.width, height: window?.frame.size.height ?? UIScreen.main.bounds.height)
        loadingView.backgroundColor = UIColor.clear
        loadingView.tag = 32323
        
        window?.addSubview(loadingView)
    }
    
    public static func removeFullScreenBlock() {
        let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        window?.viewWithTag(32323)?.removeFromSuperview()
    }
    
    public static func localeCountryCode(for regionCode: String, language: String = "en") -> String? {
        Locale(identifier: language + "_" + regionCode)
            .localizedString(forRegionCode: regionCode)
    }
    
    public static func isAppAttachedToXcodeDebugger() -> Bool {
        // Buffer for "sysctl(...)" call's result.
        var info = kinfo_proc()
        // Counts buffer's size in bytes (like C/C++'s `sizeof`).
        var size = MemoryLayout.stride(ofValue: info)
        // Tells we want info about own process.
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        // Call the API (and assert success).
        let junk = sysctl(&mib, UInt32(mib.count), &info, &size, nil, 0)
        assert(junk == 0, "sysctl failed")
        // Finally, checks if debugger's flag is present yet.
        return (info.kp_proc.p_flag & P_TRACED) != 0
    }
    
    public static func closeCurrentJourney(_ completion: (() -> Void)?) {
        UIApplication.shared.topViewController()?.navigationController?.popToRootViewController(animated: true, completion: { vc in
            completion?()
        })
    }
    
    public static func copyTpClipboard(string: String) {
        UIPasteboard.general.string = string
    }
    
    public static func sendEmail(to: String, viewController: UIViewController) {
        if MFMailComposeViewController.canSendMail() {
            let vc: MFMailComposeViewController = MFMailComposeViewController()
            vc.mailComposeDelegate = viewController as? any MFMailComposeViewControllerDelegate
            vc.setToRecipients([to])
            viewController.present(vc, animated: true)
        }
    }
    
    public static func makeACall(phoneNumber: String) {
        if let phoneCallURL = URL(string: "tel:\(phoneNumber.replace(target: " ", withString: ""))".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") {
            UIApplication.shared.open(phoneCallURL, options: [:], completionHandler: nil)
        }
    }
    
    // MARK: - get the domain name from the email
    public static func getEmailDomain(email: String) -> String {
        let domain = email.components(separatedBy: "@")
        return (domain.last) ?? ""
    }
    
    
    // MARK: - convert image to base 64
    public static func convertImageTobase64(image: UIImage, compressRatio : CGFloat = 0.4) -> String? {
        var imageData: Data?
        imageData = image.jpegData(compressionQuality: compressRatio)
        let strBase64 = imageData?.base64EncodedString(options: .lineLength64Characters) ?? ""
        return strBase64
    }
    
    // MARK: - convert data to base 64
    public static func convertDataTobase64(data:Data) -> String? {
        let strBase64 = data.base64EncodedString(options: .lineLength64Characters)
        return strBase64
    }
    
    public static func base64toImage(value: String) -> UIImage {
        // Find the start of the Base64 part
        if let base64Start = value.range(of: ";base64,") {
            
            // Extract the Base64 part
            let base64 = String(value[base64Start.upperBound...])
            
            // Convert base64 string to Data
            if let decodedData = Data(base64Encoded: base64, options: .ignoreUnknownCharacters) {
                // Create UIImage from Data
                return UIImage(data: decodedData) ?? UIImage()
            }
        } else {
            
            if let decodedData = Data(base64Encoded: value, options: .ignoreUnknownCharacters) {
                return UIImage(data: decodedData) ?? UIImage()
            }
        }
        return UIImage()
    }
    
    public static func base64WithURIToImage(value: String) -> UIImage {
        if let url = URL(string: value) {
            let data = try! Data(contentsOf: url)
            return UIImage(data: data) ?? UIImage()
        }
        return UIImage()
    }
    
    
    // MARK: - Get Country Calling Code
    public static func getCountryCallingCode(countryRegionCode:String) -> String {
        
        let prefixCodes = ["AF": "93", "AE": "971", "AL": "355", "AN": "599", "AS":"1", "AD": "376", "AO": "244", "AI": "1", "AG":"1", "AR": "54","AM": "374", "AW": "297", "AU":"61", "AT": "43","AZ": "994", "BS": "1", "BH":"973", "BF": "226","BI": "257", "BD": "880", "BB": "1", "BY": "375", "BE":"32","BZ": "501", "BJ": "229", "BM": "1", "BT":"975", "BA": "387", "BW": "267", "BR": "55", "BG": "359", "BO": "591", "BL": "590", "BN": "673", "CC": "61", "CD":"243","CI": "225", "KH":"855", "CM": "237", "CA": "1", "CV": "238", "KY":"345", "CF":"236", "CH": "41", "CL": "56", "CN":"86","CX": "61", "CO": "57", "KM": "269", "CG":"242", "CK": "682", "CR": "506", "CU":"53", "CY":"537","CZ": "420", "DE": "49", "DK": "45", "DJ":"253", "DM": "1", "DO": "1", "DZ": "213", "EC": "593", "EG":"20", "ER": "291", "EE":"372","ES": "34", "ET": "251", "FM": "691", "FK": "500", "FO": "298", "FJ": "679", "FI":"358", "FR": "33", "GB":"44", "GF": "594", "GA":"241", "GS": "500", "GM":"220", "GE":"995","GH":"233", "GI": "350", "GQ": "240", "GR": "30", "GG": "44", "GL": "299", "GD":"1", "GP": "590", "GU": "1", "GT": "502", "GN":"224","GW": "245", "GY": "595", "HT": "509", "HR": "385", "HN":"504", "HU": "36", "HK": "852", "IR": "98", "IM": "44", "IL": "972", "IO":"246", "IS": "354", "IN": "91", "ID":"62", "IQ":"964", "IE": "353","IT":"39", "JM":"1", "JP": "81", "JO": "962", "JE":"44", "KP": "850", "KR": "82","KZ":"77", "KE": "254", "KI": "686", "KW": "965", "KG":"996","KN":"1", "LC": "1", "LV": "371", "LB": "961", "LK":"94", "LS": "266", "LR":"231", "LI": "423", "LT": "370", "LU": "352", "LA": "856", "LY":"218", "MO": "853", "MK": "389", "MG":"261", "MW": "265", "MY": "60","MV": "960", "ML":"223", "MT": "356", "MH": "692", "MQ": "596", "MR":"222", "MU": "230", "MX": "52","MC": "377", "MN": "976", "ME": "382", "MP": "1", "MS": "1", "MA":"212", "MM": "95", "MF": "590", "MD":"373", "MZ": "258", "NA":"264", "NR":"674", "NP":"977", "NL": "31","NC": "687", "NZ":"64", "NI": "505", "NE": "227", "NG": "234", "NU":"683", "NF": "672", "NO": "47","OM": "968", "PK": "92", "PM": "508", "PW": "680", "PF": "689", "PA": "507", "PG":"675", "PY": "595", "PE": "51", "PH": "63", "PL":"48", "PN": "872","PT": "351", "PR": "1","PS": "970", "QA": "974", "RO":"40", "RE":"262", "RS": "381", "RU": "7", "RW": "250", "SM": "378", "SA":"966", "SN": "221", "SC": "248", "SL":"232","SG": "65", "SK": "421", "SI": "386", "SB":"677", "SH": "290", "SD": "249", "SR": "597","SZ": "268", "SE":"46", "SV": "503", "ST": "239","SO": "252", "SJ": "47", "SY":"963", "TW": "886", "TZ": "255", "TL": "670", "TD": "235", "TJ": "992", "TH": "66", "TG":"228", "TK": "690", "TO": "676", "TT": "1", "TN":"216","TR": "90", "TM": "993", "TC": "1", "TV":"688", "UG": "256", "UA": "380", "US": "1", "UY": "598","UZ": "998", "VA":"379", "VE":"58", "VN": "84", "VG": "1", "VI": "1","VC":"1", "VU":"678", "WS": "685", "WF": "681", "YE": "967", "YT": "262","ZA": "27" , "ZM": "260", "ZW":"263"]
        let countryDialingCode = prefixCodes[countryRegionCode]
        return countryDialingCode ?? ""
    }
    
    
    // MARK: - Get Country Name
    public static func countryName(countryCode: String) -> String {
        let current = Locale(identifier: "en_US")
        return current.localizedString(forRegionCode: countryCode) ?? ""
    }
    
    // MARK: - Open Google Maps
    public static func openGoogleMapsWithLatAndLong(lat:String, long:String) {
        
        // if GoogleMap installed
        if let url = URL(string: "comgooglemaps://"), let latitude = Float(lat), let longitude = Float(long), UIApplication.shared.canOpenURL(url) {
            guard let url = URL(string: "comgooglemaps://?saddr=&daddr=\(latitude),\(longitude)&directionsmode=driving") else { return }
            UIApplication.shared.open(url, options: [:]) { (done) in}
        } else {
            // if GoogleMap App is not installed
            if let latitude = Float(lat), let longitude = Float(long) {
                guard let url = URL(string:"https://maps.google.com/?q=@\(latitude),\(longitude)&nav=1") else {return}
                UIApplication.shared.open(url, options: [:]) { (done) in}
            }
        }
    }
    
    public static func openGoogleMapsWithAddressName(address:String) {
        
        let addressStr = address.replace(target: " ", withString: "+")
        
        // if GoogleMap installed
        if let url = URL(string: "comgooglemaps://"), UIApplication.shared.canOpenURL(url) {
            guard let url = URL(string: "comgooglemaps://?saddr=\(addressStr)&directionsmode=driving") else { return }
            UIApplication.shared.open(url, options: [:]) { (done) in}
        } else {
            // if GoogleMap App is not installed
            guard let url = URL(string: "https://maps.google.com/maps?f=d&daddr=\(addressStr)&nav=1") else {return}
            UIApplication.shared.open(url, options: [:]) { (done) in}
        }
    }
    
    // MARK: - deletect URL
    public static func detectUrlText(text: String) -> (Bool, String) {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
        for match in matches {
            guard let range = Range(match.range, in: text) else { continue }
            let url = text[range]
            let urlString = String(url)
            if self.verifyUrl(urlString: urlString) {
                return (true, urlString)
            } else {
                let newURLString = self.replaceSomeValueForLink(url: urlString)
                if self.verifyUrl(urlString: newURLString) {
                    return (true, newURLString)
                }
            }
        }
        return (false, "")
    }
    
    public static func replaceSomeValueForLink(url: String) -> String {
        var urlString = url.lowercased()
        if !urlString.contains("http://www.") && !urlString.contains("https://www.") {
            urlString = urlString.replace(target: "www.", withString: "")
            if urlString.contains("http://") {
                urlString = urlString.replace(target: "http://", withString: "")
                urlString = "http://www.\(urlString)"
            } else if urlString.contains("https://") {
                urlString = urlString.replace(target: "https://", withString: "")
                urlString = "https://www.\(urlString)"
            } else {
                urlString = urlString.replace(target: "http://", withString: "")
                urlString = "http://www.\(urlString)"
            }
        }
        return urlString
    }
    
    // MARK: - Verify Url
    public static func verifyUrl (urlString: String?) -> Bool {
        // Check for nil
        if let urlString = urlString {
            // create NSURL instance
            if let url = NSURL(string: urlString) {
                // check if your application can open the NSURL instance
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
    
    // MARK: - Image Resizing
    public static func resizeImage(image: UIImage, targetHeight: CGFloat) -> UIImage {
        // Get current image size
        let size = image.size
        
        // Compute scaled, new size
        let heightRatio = targetHeight / size.height
        let newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Create new image
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Return new image
        return newImage!
    }
    
    
}
