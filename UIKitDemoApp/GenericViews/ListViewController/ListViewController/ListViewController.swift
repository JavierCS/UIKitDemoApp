import UIKit

class ListViewController: UIViewController {
    // MARK: - UIElements
    @IBOutlet weak var elementsList: UITableView!
    
    // MARK: - Logic Vars
    var list: List!
    
    // MARK: - LifeCycle Management
    override func viewDidLoad() {
        super.viewDidLoad()
        initialConfiguration()
    }
    
    // MARK: - Configuration Management
    private func initialConfiguration() {
        title = list.title
        elementsList.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        elementsList.dataSource = self
        elementsList.delegate = self
    }
    
    // MARK: - UIElements Actions
    private func getControllerToShow<T:UIViewController>(for anyClass: AnyClass) -> T? {
        if anyClass == UIViewController.self { return UIViewController() as? T }
        guard let controllerType = anyClass as? T.Type else { return nil }
        return controllerType.init(nibName: String(describing: anyClass), bundle: .main)
    }
}

// MARK: - UITableViewDataSource Management
extension ListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = list.elements[indexPath.row].name
        return cell
    }
}

// MARK: - UITableViewDelegate Management
extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let element = list.elements[indexPath.row]
        guard let controllerToShow = getControllerToShow(for: element.controllerToShow) else { return }
        if let listController = controllerToShow as? ListViewController,
           let listData = element.nextListData {
            listController.list = listData
        }
        if let contextDataController = controllerToShow as? ContextDataSupportProtocol,
           let contextData = element.contextData {
            contextDataController.setContextData(contextData)
        }
        show(controllerToShow, sender: nil)
    }
}
