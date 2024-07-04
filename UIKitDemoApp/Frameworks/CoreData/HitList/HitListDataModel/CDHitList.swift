import Foundation
import CoreData

class CDHitList {
    static var shared = CDHitList()
    
    lazy var persistantContainer = {
        let container = NSPersistentContainer(name: "HitList")
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Container creation error: \(error.localizedDescription)")
            }
        }
        return container
    }()
}
