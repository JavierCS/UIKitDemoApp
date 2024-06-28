import UIKit

extension UIViewController {
    static func getControllerXibInstance<T:UIViewController>(forClass controllerClass: AnyClass) -> T? {
        guard let controllerType = controllerClass as? T.Type else { return nil }
        return controllerType.init(nibName: String(describing: controllerClass), bundle: .main)
    }
}
