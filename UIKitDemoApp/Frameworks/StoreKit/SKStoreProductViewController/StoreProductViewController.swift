import UIKit
import StoreKit

class StoreProductViewController: UIViewController {
    // MARK: - Logic Vars
    private var app: SKApp!
    
    // MARK: - LifeCycle Management
    override func viewDidLoad() {
        super.viewDidLoad()
        initialConfiguration()
    }
    
    // MARK: - Configuration Management
    private func initialConfiguration() {
        let storeViewController = SKStoreProductViewController()
        let parameters = [
            SKStoreProductParameterITunesItemIdentifier: app.identifier
        ]
        storeViewController.loadProduct(withParameters: parameters) { [weak self] loaded, error in
            self?.present(storeViewController, animated: true)
        }
    }
}

// MARK: - ContextDataSupportProtocol Management
extension StoreProductViewController: ContextDataSupportProtocol {
    func setContextData(_ contextData: Any) {
        guard let app = contextData as? SKApp else { return }
        self.app = app
    }
}
