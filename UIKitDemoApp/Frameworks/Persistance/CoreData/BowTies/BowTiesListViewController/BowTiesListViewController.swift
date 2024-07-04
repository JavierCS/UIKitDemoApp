import UIKit
import CoreData

class BowTiesListViewController: UIViewController {
    // MARK: - UIElements
    @IBOutlet weak var bowTieImage: UIImageView!
    @IBOutlet weak var bowTieNameLabel: UILabel!
    @IBOutlet weak var bowTieRatingLabel: UILabel!
    @IBOutlet weak var bowTieTimesWornLabel: UILabel!
    @IBOutlet weak var bowTieLastWornLabel: UILabel!
    @IBOutlet weak var bowTiesList: UITableView!
    
    var bowTies = [BowTie]()
    var selectedIndexPath: IndexPath?
    
    // MARK: - Life Cycle Management
    override func viewDidLoad() {
        super.viewDidLoad()
        initialConfiguration()
    }
    
    // MARK: - Configuration Management
    private func initialConfiguration() {
        configureTable()
        insertSampleData()
        fetchData()
        showInitialTableState()
    }
    
    private func configureTable() {
        bowTiesList.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        bowTiesList.dataSource = self
        bowTiesList.delegate = self
    }
    
    private func showInitialTableState() {
        let firstIndexPath = IndexPath(row: 0, section: 0)
        bowTiesList.selectRow(at: firstIndexPath, animated: true, scrollPosition: .none)
        showBowTieData(for: firstIndexPath)
    }
    
    // MARK: - Persistance Management
    private func insertSampleData() {
        let fetch = BowTie.fetchRequest()
        fetch.predicate = NSPredicate(format: "searchKey != nil")
        let count = try! CDBowTies.shared.persistantContainer.viewContext.count(for: fetch)
        if count != 0 { return }
        guard count == 0,
              let dictionaries = Bundle.getDictionaryArrayFromPlistFile("BowTiesSampleData") else { return }
        for dictionary in dictionaries {
            let entity = NSEntityDescription.entity(forEntityName: "BowTie", in: CDBowTies.shared.persistantContainer.viewContext)!
            let bowTie = BowTie(entity: entity, insertInto: CDBowTies.shared.persistantContainer.viewContext)
            bowTie.id = UUID(uuidString: dictionary.string(for: "id")!)
            bowTie.name = dictionary.string(for: "name")
            bowTie.searchKey = dictionary.string(for: "searchKey")
            bowTie.rating = dictionary.double(for: "rating")!
            let colorDictionary = dictionary.dictionary(for: "tintColor")
            bowTie.tintColor = UIColor.color(dict: colorDictionary)
            let imageName = dictionary.string(for: "imageName")
            let image = UIImage(named: imageName!)
            bowTie.photoData = image?.pngData()
            bowTie.lastWorn = dictionary.date(for: "lastWorn")
            bowTie.timesWorn = dictionary.nsNumber(for: "timesWorn")!.int32Value
            bowTie.isFavorite = dictionary.bool(for: "isFavorite")
            bowTie.url = URL(string: dictionary.string(for: "url")!)
        }
        try! CDBowTies.shared.persistantContainer.viewContext.save()
    }
    
    private func fetchData() {
        let request = BowTie.fetchRequest()
        guard let bowTies = try? CDBowTies.shared.persistantContainer.viewContext.fetch(request) else { return }
        self.bowTies = bowTies
        bowTiesList.reloadData()
    }
    
    private func wearBowTie(at indexPath: IndexPath) {
        let bowTie = bowTies[indexPath.row]
        bowTie.timesWorn += 1
        bowTie.lastWorn = Date()
        do {
            try bowTie.managedObjectContext?.save()
        } catch {
            fatalError("Wearing error: \(error.localizedDescription)")
        }
    }
    
    private func rateBowtie(forItemAt indexPath: IndexPath, newRate: Double) {
        let bowTie = bowTies[indexPath.row]
        bowTie.rating = newRate
        do {
            try bowTie.managedObjectContext?.save()
        } catch {
            fatalError("New rating error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - UIElements Actions
    private func showBowTieData(for indexPath: IndexPath) {
        let bowTie = bowTies[indexPath.row]
        if let imageData = bowTie.photoData,
           let image = UIImage(data: imageData) {
            bowTieImage.image = image
        }
        bowTieNameLabel.text = bowTie.name
        bowTieRatingLabel.text = "Rating: \(bowTie.rating)"
        bowTieTimesWornLabel.text = "# times worn: \(bowTie.timesWorn)"
        bowTieLastWornLabel.text = "Last worn: \(bowTie.lastWorn?.description ?? "")"
    }
    
    @IBAction func didTouchWearButton(_ sender: UIButton) {
        guard let indexPath = selectedIndexPath else { return }
        wearBowTie(at: indexPath)
        showBowTieData(for: indexPath)
    }
    
    @IBAction func didTouchRateButton(_ sender: UIButton) {
        let alert = UIAlertController(title: "Rate", message: "Rate this Bow Tie", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Rate"
            textField.keyboardType = .decimalPad
        }
        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] alertAction in
            guard let rateTextField = alert.textFields?.first,
                  let rateText = rateTextField.text,
                  let rating = Double(rateText),
                  let indexPath = selectedIndexPath else { return }
            rateBowtie(forItemAt: indexPath, newRate: rating)
            showBowTieData(for: indexPath)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource Management
extension BowTiesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bowTies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = bowTies[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Select a Bow Tie"
    }
}

// MARK: - UITableViewDelegate Management
extension BowTiesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        showBowTieData(for: indexPath)
    }
}
