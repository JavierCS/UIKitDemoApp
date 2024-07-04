import UIKit

extension UIColor {
    static func color(dict: [String: Any]?) -> UIColor? {
        guard let dictionary = dict,
              let red = dictionary.float(for: "red"),
              let green = dictionary.float(for: "green"),
              let blue = dictionary.float(for: "blue") else { return nil }
        return UIColor(red: CGFloat(red) / 255.0,
                       green: CGFloat(green) / 255.0,
                       blue: CGFloat(blue) / 255.0,
                       alpha: 1.0)
    }
}
