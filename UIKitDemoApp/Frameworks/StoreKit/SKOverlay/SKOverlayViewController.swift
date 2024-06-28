import UIKit
import StoreKit

class SKOverlayViewController: UIViewController {
    // MARK: - UIElements
    @IBOutlet weak var positionSelector: UISegmentedControl!
    
    // MARK: - Logic Vars
    var app: SKApp!
    
    // MARK: - LifeCycle Management
    override func viewDidLoad() {
        super.viewDidLoad()
        initialConfiguration()
    }
    
    // MARK: - Configuration Management
    private func initialConfiguration() {
        title = app.name
    }
    
    // MARK: - UIElements Actions
    @IBAction func openAppUrl(_ sender: UIButton) {
        guard let appUrl = app.url,
              UIApplication.shared.canOpenURL(appUrl) else { return }
        UIApplication.shared.open(appUrl)
    }
    
    @IBAction func showOverLay(_ sender: UIButton) {
        guard let scene = view.window?.windowScene,
              let overlayPosition = SKOverlay.Position.init(rawValue: positionSelector.selectedSegmentIndex) else { return }
        let configuration = SKOverlay.AppConfiguration(appIdentifier: app.identifier, position: overlayPosition)
        let overlay = SKOverlay(configuration: configuration)
//        overlay.delegate = self
        overlay.present(in: scene)
    }
}

// MARK: - ContextDataSupportProtocol Management
extension SKOverlayViewController: ContextDataSupportProtocol {
    func setContextData(_ contextData: Any) {
        guard let app = contextData as? SKApp else { return }
        self.app = app
    }
}
