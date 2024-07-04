import Foundation
import CoreData

class CDBowTies {
    static var shared = CDBowTies()
    
    lazy var persistantContainer = {
        let container = NSPersistentContainer(name: "BowTies")
        container.loadPersistentStores { storeDescription, error in
            if let error = error as? NSError {
                fatalError("Container creation error: \(error.localizedDescription)")
            }
        }
        return container
    }()
}
