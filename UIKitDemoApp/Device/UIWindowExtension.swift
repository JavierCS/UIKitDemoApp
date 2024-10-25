import Foundation
import UIKit

public extension UIWindow {
    /**
     Retorna el `UIViewController` visible en tu aplicación.
     
     - Returns: `UIViewController` visible.
     */
    class func getTopViewController() -> UIViewController? {
        guard let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }),
              var rootViewController = keyWindow.rootViewController else { return nil }
        while let presentedViewController = rootViewController.presentedViewController {
            rootViewController = presentedViewController
        }
        if let rootNavigation = rootViewController as? UINavigationController, let visibleController = rootNavigation.viewControllers.last {
            return visibleController
        }
        if let rootTabBar = rootViewController as? UITabBarController, let visibleController = rootTabBar.selectedViewController {
            if let embeddedNavigation = visibleController as? UINavigationController, let lastController = embeddedNavigation.viewControllers.last {
                return lastController
            }
            return visibleController
        }
        return rootViewController
    }
    
    /**
     Este método crea un `UITextField` con la propiedad `isSecureTextEntry` habilitada y lo agrega al window de la aplicación para que al tomar screen shots o grabar pantalla se vea obscura
     
     - Returns: `UITextField` agregado al `UIWindow` de la applicación.
     */
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
