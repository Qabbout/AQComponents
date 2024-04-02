import UIKit

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

    static func showAlerWithTextField(title: String, message: String, tfPlaceholder: String, isSecureTextEntry: Bool, actionString: String?, dismissTitle: String?, completion: @escaping (_ written: String?) -> Void) {
        let topView = UIApplication.topViewController() ?? UIViewController()
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = tfPlaceholder
            textField.isSecureTextEntry = isSecureTextEntry
        }
        alert.addAction(UIAlertAction(title: actionString, style: .default, handler: { _ in
            if let textField = alert.textFields?[0] {
                completion(textField.text ?? "")
            }
        }))
        alert.addAction(UIAlertAction(title: dismissTitle, style: .cancel, handler: { _ in
            completion(nil)
        }))
        if let popoverPresentationController = alert.popoverPresentationController {
            popoverPresentationController.sourceView = topView.view
            popoverPresentationController.sourceRect = CGRect(x: topView.view.bounds.midX, y: topView.view.bounds.midY, width: 0, height: 0)
        }
        topView.present(alert, animated: true, completion: nil)
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

}
