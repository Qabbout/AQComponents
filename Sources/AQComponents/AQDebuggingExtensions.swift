#if DEBUG

import UIKit

extension UIWindow {
    
    public class var key: UIWindow {
        let selector: Selector = NSSelectorFromString("keyWindow")
        let result = UIWindow.perform(selector)
        return result?.takeUnretainedValue() as! UIWindow
    }
}

extension UIView {
    
    public var recursiveDescription: NSString {
        let selector: Selector = NSSelectorFromString("recursiveDescription")
        let result = perform(selector)
        return result?.takeUnretainedValue() as! NSString
    }
}


extension UIViewController {
    
    public var printHierarchy: NSString {
        let selector: Selector = NSSelectorFromString("_printHierarchy")
        let result = perform(selector)
        return result?.takeUnretainedValue() as! NSString
    }
}

#endif
