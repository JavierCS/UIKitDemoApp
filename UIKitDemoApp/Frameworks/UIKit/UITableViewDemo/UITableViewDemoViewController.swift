//
//  UITableViewDemoViewController.swift
//  UIKitDemoApp
//
//  Created by Javier Cruz Santiago on 18/09/24.
//

import UIKit

class Area {
    var name: String
    var employees: [String]
    
    init(name: String, employees: [String]) {
        self.name = name
        self.employees = employees
    }
}

final class UITableViewDemoViewController: UIViewController {
    // MARK: - UIElements
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Logic Vars
    private var dataSource: [Area] = [
        Area(name: "Arquitectura", employees: ["Javier", "Grecia"]),
        Area(name: "Desarrollo", employees: ["Alan", "Alejandro", "Andoni", "Andres", "Benjamin", "Cesar", "Daniel", "Diegop", "Carlos", "Emanuel", "Esmeralda", "Giovanni", "Hugo", "Isai", "Ivan", "Jair", "Jose", "Joel", "Juan", "Mario", "Mayra", "Mayte", "Mitzi", "Nestor", "Octavio", "Raul", "Ricardo", "Rocio", "Sarahí", "Sergio"]),
        Area(name: "Design System", employees: ["Manuel", "Oswaldo"]),
        Area(name: "Integración", employees: ["Daniel", "Martell"]),
        Area(name: "Jefatura", employees: ["Gibrán"])
    ]

    // MARK: - Initialization Code
    
    // MARK: - LifeCycle Management
    override func viewDidLoad() {
        super.viewDidLoad()
        initialConfiguration()
    }
    
    // MARK: - Configuration Management
    private func initialConfiguration() {
        title = "UITableView"
        tableView.register(UINib(nibName: String(describing: UITableViewDemoTableViewCell.self), bundle: .main), forCellReuseIdentifier: String(describing: UITableViewDemoTableViewCell.self))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.dragDelegate = self
        tableView.dropDelegate = self
        tableView.dragInteractionEnabled = true
    }
    
    // MARK: - Utils
    
    // MARK: - UIElements Actions
}

// MARK: - UITableViewDataSource Management
extension UITableViewDemoViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSource[section].name
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return dataSource.map {
            $0.name.prefix(1).uppercased()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].employees.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = dataSource[indexPath.section].employees[indexPath.row]
        content.image = UIImage(systemName: "person.fill")
        cell.contentConfiguration = content
        cell.selectionStyle = .none
        return cell
    }
}

// MARK: - UITableViewDelegate Management
extension UITableViewDemoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete", handler: { contextualAction, view, completion in
            contextualAction.image = UIImage(systemName: "trash")
            print("Delete row at: \(indexPath)")
            completion(true)
        })
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        print(editingStyle)
//    }
//    
//    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
//        return .delete
//    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = dataSource[sourceIndexPath.section].employees.remove(at: sourceIndexPath.row)
        dataSource[destinationIndexPath.section].employees.insert(item, at: destinationIndexPath.row)
        print("Fila movida de \(sourceIndexPath) a \(destinationIndexPath)")
    }
}

// MARK: - UITableViewDragDelegate Management
extension UITableViewDemoViewController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: any UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let item = dataSource[indexPath.section].employees[indexPath.row]
        let itemProvider = NSItemProvider(object: item as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }
}

// MARK: - UITableViewDropDelegate Management
extension UITableViewDemoViewController: UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, performDropWith coordinator: any UITableViewDropCoordinator) {
        let destinationIndexPath: IndexPath
        
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            destinationIndexPath = IndexPath(row: tableView.numberOfRows(inSection: 0), section: 0)
        }
        
        coordinator.items.forEach { dropItem in
            if let sourceIndexPath = dropItem.sourceIndexPath {
                tableView.performBatchUpdates({
                    tableView.deleteRows(at: [sourceIndexPath], with: .automatic)
                    tableView.insertRows(at: [destinationIndexPath], with: .automatic)
                })
                coordinator.drop(dropItem.dragItem, toRowAt: destinationIndexPath)
            }
        }
    }
}
