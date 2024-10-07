import Foundation
import UIKit

public extension UIWindow {
    class func getTopViewController() -> UIViewController? {
        guard let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }),
              var rootViewController = keyWindow.rootViewController else { return nil }
        while let presentedViewController = rootViewController.presentedViewController {
            rootViewController = presentedViewController
        }
        return rootViewController
    }
    
    @discardableResult
    func makeSecure() -> UITextField {
        let field = UITextField()
        field.isSecureTextEntry = true
        addSubview(field)
        layer.superlayer?.addSublayer(field.layer)
        field.layer.sublayers?.last?.addSublayer(self.layer)
        return field
    }
}
