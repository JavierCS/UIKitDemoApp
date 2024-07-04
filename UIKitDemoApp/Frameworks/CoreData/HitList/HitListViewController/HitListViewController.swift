import UIKit
import CoreData

class HitListViewController: UIViewController {
    // MARK: - UIElements
    @IBOutlet weak var peopleList: UITableView!
    
    // MARK: - Logic Vars
    var people = [NSManagedObject]()
    
    // MARK: - LifeCycle Management
    override func viewDidLoad() {
        super.viewDidLoad()
        initialConfiguration()
    }
    
    // MARK: - Configurations Management
    private func initialConfiguration() {
        title = "Hit List"
        let addBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTouchAddButton(_:)))
        navigationItem.setRightBarButtonItems([addBarButtonItem], animated: true)
        peopleList.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        peopleList.dataSource = self
        peopleList.delegate = self
        read()
    }
    
    // MARK: - UIElements Actions
    @objc private func didTouchAddButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New Name", message: "Add a new name", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Name"
        }
        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] alertAction in
            guard let nameTextField = alert.textFields?.first,
                  let name = nameTextField.text else { return }
            create(name: name)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        present(alert, animated: true)
    }
    
    private func showEditAlert(forItemAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "Edit Name", message: "Edit the current name", preferredStyle: .alert)
        let currentName = people[indexPath.row].value(forKeyPath: "name") as? String
        alert.addTextField { textField in
            textField.text = currentName
            textField.placeholder = "Name"
            textField.clearsOnBeginEditing = true
        }
        let updateAction = UIAlertAction(title: "Update", style: .default) { [unowned self] alertAction in
            guard let nameTextField = alert.textFields?.first,
                  let newName = nameTextField.text,
                  newName != currentName else { return }
            update(elementAt: indexPath, with: newName)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        alert.addAction(updateAction)
        present(alert, animated: true)
    }
    
    private func addRow(at indexPath: IndexPath) {
        peopleList.beginUpdates()
        peopleList.insertRows(at: [indexPath], with: .automatic)
        peopleList.endUpdates()
    }
    
    private func reloadRow(at indexPath: IndexPath) {
        peopleList.beginUpdates()
        peopleList.reloadRows(at: [indexPath], with: .automatic)
        peopleList.endUpdates()
    }
    
    private func removeRow(at indexPath: IndexPath) {
        peopleList.beginUpdates()
        peopleList.deleteRows(at: [indexPath], with: .automatic)
        peopleList.endUpdates()
    }
    
    // MARK: - CRUD Logic Management
    private func create(name: String) {
        let context = CDHitList.shared.persistantContainer.viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: "Person", in: context) else { return }
        let person = NSManagedObject(entity: entity, insertInto: context)
        person.setValue(name, forKeyPath: "name")
        do {
            try context.save()
            people.append(person)
            addRow(at: IndexPath(row: people.count - 1, section: 0))
        } catch {
            fatalError("Saving Error: \(error.localizedDescription)")
        }
    }
    
    private func read() {
        let context = CDHitList.shared.persistantContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Person")
        do {
            people = try context.fetch(fetchRequest)
        } catch {
            fatalError("Fetch Error: \(error.localizedDescription)")
        }
    }
    
    private func update(elementAt indexPath: IndexPath, with newValue: String) {
        let personToUpdate = people[indexPath.row]
        personToUpdate.setValue(newValue, forKeyPath: "name")
        do {
            try personToUpdate.managedObjectContext?.save()
            reloadRow(at: indexPath)
        } catch {
            fatalError("Update Error: \(error.localizedDescription)")
        }
    }
    
    private func delete(at indexPath: IndexPath) {
        let context = CDHitList.shared.persistantContainer.viewContext
        let deletedPerson = people.remove(at: indexPath.row)
        context.delete(deletedPerson)
        guard context.hasChanges else { return }
        do {
            try context.save()
            removeRow(at: indexPath)
        } catch {
            fatalError("Delete Error: \(error.localizedDescription)")
        }
    }
}

// MARK: - UITableViewDataSource Management
extension HitListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let person = people[indexPath.row]
        cell.textLabel?.text = person.value(forKeyPath: "name") as? String
        return cell
    }
}

// MARK: - UITableViewDelegate Management
extension HitListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return UISwipeActionsConfiguration(actions: [
            UIContextualAction(style: .destructive, title: "Delete", handler: { [weak self] contextualAction, view, completion in
                self?.delete(at: indexPath)
                completion(true)
            }),
            UIContextualAction(style: .normal, title: "Editar", handler: { [weak self ] contextualAction, view, completion in
                self?.showEditAlert(forItemAt: indexPath)
                completion(true)
            })
        ])
    }
}
