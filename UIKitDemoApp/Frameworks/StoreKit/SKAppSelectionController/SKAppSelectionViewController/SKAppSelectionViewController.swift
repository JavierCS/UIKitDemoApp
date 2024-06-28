import UIKit
import StoreKit

class SKAppSelectionViewController: UIViewController {
    // MARK: - UIElements
    @IBOutlet weak var appGrid: UICollectionView!
    
    // MARK: - Logic Vars
    private var controllerToCallClass: AnyClass?
    private var request: SKProductsRequest!
    
    private var apps: [SKOverlayDrawableAppProtocol] = [
        SKApp(
            imageName: "appleMusic",
            name: "Apple Music",
            identifier: "id1108187390",
            url: URL(string: "https://apps.apple.com/us/app/apple-music/id1108187390")
        ),
        SKApp(
            imageName: "tetris",
            name: "Tetris",
            identifier: "id1491074310",
            url: URL(string: "https://apps.apple.com/us/app/tetris/id1491074310")
        ),
        SKApp(
            imageName: "twitch",
            name: "Twitch",
            identifier: "id460177396",
            url: URL(string: "https://apps.apple.com/mx/app/twitch/id460177396")
        )
    ]
    
    // MARK: - LifeCycle Management
    override func viewDidLoad() {
        super.viewDidLoad()
        initialConfiguration()
    }
    
    // MARK: - Configuration Management
    private func initialConfiguration() {
        title = "Select An App"
        appGrid.register(UINib(nibName: String(describing: SKAppSelectionCollectionViewCell.self), bundle: .main), forCellWithReuseIdentifier: "Cell")
        appGrid.dataSource = self
        appGrid.delegate = self
    }
    
    
}

// MARK: - ContextDataSupportProtocol Management
extension SKAppSelectionViewController: ContextDataSupportProtocol {
    func setContextData(_ contextData: Any) {
        guard let controllerClass = contextData as? AnyClass else { return }
        controllerToCallClass = controllerClass
    }
}

// MARK: - UICollectionViewDataSource Management
extension SKAppSelectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return apps.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? SKAppSelectionCollectionViewCell else { return UICollectionViewCell() }
        cell.showApp(apps[indexPath.row])
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout Management
extension SKAppSelectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let app = apps[indexPath.row]
        guard let controllerToShowClass = controllerToCallClass,
              let controllerToShow = UIViewController.getControllerXibInstance(forClass: controllerToShowClass) else { return }
        if let contextDataController = controllerToShow as? ContextDataSupportProtocol {
            contextDataController.setContextData(app)
        }
        show(controllerToShow, sender: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = collectionView.frame.width / 2
        let itemSize = CGSize(width: itemWidth, height: itemWidth + 80.0)
        return itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}

// MARK: - SKOverlayDelegate Management
extension SKAppSelectionViewController: SKOverlayDelegate {
    
}
