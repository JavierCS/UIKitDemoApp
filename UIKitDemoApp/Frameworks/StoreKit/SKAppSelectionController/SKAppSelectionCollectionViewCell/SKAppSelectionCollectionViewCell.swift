import UIKit

class SKAppSelectionCollectionViewCell: UICollectionViewCell {
    // MARK: - UIElements
    @IBOutlet weak var appIconImageView: UIImageView!
    
    // MARK: - Logic Vars
    var app: SKOverlayDrawableAppProtocol!
    
    // MARK: - Configuration Management
    func showApp(_ app: SKOverlayDrawableAppProtocol) {
        self.app = app
        appIconImageView.image = UIImage(named: app.imageName)
    }
}
