import UIKit

class FrameworksController: UIViewController {
    // MARK: - UIElements
    @IBOutlet weak var frameworksList: UITableView!
    
    // MARK: - Logic Vars
    private var frameworks: [ListElement] = [
        ListElement(
            name: "AV Kit",
            controllerToShow: ListViewController.self,
            nextListData: List(
                title: "AV Kit",
                elements: [
                
                ]
            )
        ),
        ListElement(
            name: "Persistance",
            controllerToShow: ListViewController.self,
            nextListData: List(
                title: "Persistance",
                elements: [
                    ListElement(
                        name: "Core Data",
                        controllerToShow: ListViewController.self,
                        nextListData: List(
                            title: "Core Data",
                            elements: [
                                ListElement(name: "Hit List", controllerToShow: HitListViewController.self),
                                ListElement(name: "Bow Ties", controllerToShow: BowTiesListViewController.self)
                            ]
                        )
                    )
                ]
            )
        ),
        ListElement(
            name: "Store Kit",
            controllerToShow: ListViewController.self,
            nextListData: List(
                title: "Store Kit",
                elements: [
                    ListElement(
                        name: SKComponent.SKOverlay.rawValue,
                        controllerToShow: SKAppSelectionViewController.self,
                        contextData: SKOverlayViewController.self
                    ),
                    ListElement(
                        name: SKComponent.SKStoreProductViewController.rawValue,
                        controllerToShow: SKAppSelectionViewController.self,
                        contextData: StoreProductViewController.self
                    )
                ]
            )
        )
    ]
    
    // MARK: - LifeCycle Management
    override func viewDidLoad() {
        super.viewDidLoad()
        initialConfiguration()
    }
    
    // MARK: - Configuration Management
    private func initialConfiguration() {
        title = "Demo App"
        frameworksList.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        frameworksList.dataSource = self
        frameworksList.delegate = self
    }
    
    // MARK: - UIElements Actions
    private func getControllerToShow<T:UIViewController>(for controllerClass: AnyClass) -> T? {
        guard let controllerType = controllerClass as? T.Type else { return nil }
        return controllerType.init(nibName: String(describing: controllerClass), bundle: .main)
    }
}

// MARK: - UITableViewDataSource Management
extension FrameworksController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return frameworks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = frameworks[indexPath.row].name
        return cell
    }
}

// MARK: - UITableViewDelegate Management
extension FrameworksController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let framework = frameworks[indexPath.row]
        guard let controllerToShow = getControllerToShow(for: framework.controllerToShow) else { return }
        if let listController = controllerToShow as? ListViewController, let listData = framework.nextListData {
            listController.list = listData
        }
        show(controllerToShow, sender: nil)
    }
}
